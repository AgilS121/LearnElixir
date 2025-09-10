pipeline {
  agent any
  options { timestamps(); disableConcurrentBuilds() }

  stages {
    stage('Checkout') {
      steps {
        git branch: 'master',
            url: 'git@github.com:AgilS121/LearnElixir.git',
            credentialsId: 'github_ssh'
      }
    }

    stage('Build') {
      steps {
        sh 'docker compose --progress=plain build --no-cache --pull'
      }
    }

    stage('Deploy (Blue-Green)') {
      steps {
        script {
          sh '''
            set -eu

            # 1) Tentukan port aktif dari file yang di-mount ke Nginx
            ACTIVE_PORT=$(grep -oE "400[12]" nginx/upstream_target.conf || echo 4001)
            if [ "$ACTIVE_PORT" = "4001" ]; then
              NEW_PORT=4002; NEW_SVC=app_green; OLD_SVC=app_blue; NEW_COLOR=green
            else
              NEW_PORT=4001; NEW_SVC=app_blue;  OLD_SVC=app_green; NEW_COLOR=blue
            fi
            echo "Active=$ACTIVE_PORT  New=$NEW_PORT ($NEW_SVC)"

            # 2) Build & start kandidat baru
            docker compose build "$NEW_SVC"
            docker compose up -d "$NEW_SVC"

            # 3) Tunggu health=healthy (dari healthcheck compose)
            for i in $(seq 1 30); do
              st=$(docker inspect --format '{{.State.Health.Status}}' "elixir_app_${NEW_COLOR}" 2>/dev/null || echo "starting")
              echo "health: $st"
              [ "$st" = "healthy" ] && break
              sleep 2
              [ "$i" -eq 30 ] && echo "Health timeout" && exit 1
            done

            # 4) Switch Nginx ke port baru dan reload
            echo "server 10.10.10.11:${NEW_PORT};" > nginx/upstream_target.conf
            docker exec elixir_lb nginx -s reload

            # 5) Hentikan versi lama (opsional: bisa sleep 3 dulu)
            docker compose stop "$OLD_SVC" || true

            # 6) Bersihkan orphan
            docker compose up -d --remove-orphans
          '''
        }
      }
    }



  }


  post {
    success {
      withCredentials([string(credentialsId: 'discord_webhook', variable: 'HOOK')]) {
        sh '''
          content="✅ SUCCESS — ${JOB_NAME} #${BUILD_NUMBER}\\n${BUILD_URL}"
          json=$(printf '{"content":"%s"}' "$content")
          curl -fsSL -H "Content-Type: application/json" -d "$json" "$HOOK"
        '''
      }
    }
    failure {
      withCredentials([string(credentialsId: 'discord_webhook', variable: 'HOOK')]) {
        sh '''
          content="❌ FAILED — ${JOB_NAME} #${BUILD_NUMBER}\\n${BUILD_URL}"
          json=$(printf '{"content":"%s"}' "$content")
          curl -fsSL -H "Content-Type: application/json" -d "$json" "$HOOK"
        '''
      }
    }
  }
}
