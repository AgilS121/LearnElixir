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
          // 1) deteksi port aktif dari file upstream_target.conf (di host workspace)
          sh 'grep -oE "400[12]" nginx/upstream_target.conf || true'
          def active = sh(script: "grep -oE '400[12]' nginx/upstream_target.conf || echo 4001", returnStdout: true).trim()
          def newPort = (active == "4001") ? "4002" : "4001"
          def newSvc  = (newPort == "4001") ? "app_blue" : "app_green"
          def oldSvc  = (newPort == "4001") ? "app_green" : "app_blue"

          // 2) build & start target baru
          sh """
            docker compose build ${newSvc}
            docker compose up -d ${newSvc}
          """

          // 3) healthcheck target baru (pakai endpoint yang pasti 200; bisa '/' atau '/_version')
          sh """
            for i in {1..30}; do
              if curl -fsS http://10.10.10.11:${newPort}/ >/dev/null; then
                echo "New target healthy on ${newPort}"
                break
              fi
              sleep 2
              [ \$i -eq 30 ] && echo "New target NOT healthy" && exit 1
            done
          """

          // 4) switch Nginx: tulis file upstream_target.conf -> port baru, lalu reload
          sh """
            echo "server 10.10.10.11:${newPort};" > nginx/upstream_target.conf
            docker exec elixir_lb nginx -s reload
          """

          // 5) stop versi lama (optional: bisa ditunda beberapa detik)
          sh "docker compose stop ${oldSvc} || true"
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
