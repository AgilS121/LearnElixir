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
        sh '''
          set -euo pipefail
          export COMPOSE_PROJECT_NAME=elixir

          # Baca target aktif dari include Nginx (default app_blue)
          ACTIVE_SVC="$(grep -oE "app_(blue|green)" -m1 nginx/includes/upstream_target.inc || echo app_blue)"
          if [ "$ACTIVE_SVC" = "app_blue" ]; then
            NEW_SVC=app_green; OLD_SVC=app_blue; NEW_PORT=4002
          else
            NEW_SVC=app_blue;  OLD_SVC=app_green; NEW_PORT=4001
          fi
          echo "Active=$ACTIVE_SVC  New=$NEW_SVC"

          # Build & start kandidat baru
          docker compose build "$NEW_SVC"
          docker compose up -d "$NEW_SVC"

          # Tunggu HEALTHY berdasar container ID (bukan nama)
          CID="$(docker compose ps -q "$NEW_SVC")"
          [ -n "$CID" ] || { echo "No container ID for $NEW_SVC"; docker compose ps; exit 1; }

          for i in $(seq 1 30); do
            ST="$(docker inspect -f '{{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}}' "$CID" 2>/dev/null || echo starting)"
            echo "health: $ST"
            [ "$ST" = "healthy" ] && break
            sleep 2
            [ "$i" = 30 ] && echo "Health timeout" && docker logs --tail=200 "$CID" && exit 1
          done

          # Switch Nginx ke service baru via include, lalu reload
          echo "server ${NEW_SVC}:4000;" > nginx/includes/upstream_target.inc
          docker compose exec -T lb nginx -t
          docker compose exec -T lb nginx -s reload

          # Opsional: stop yang lama
          docker compose stop "$OLD_SVC" || true

          # Rapikan
          docker compose up -d --remove-orphans

          # Smoke test via LB
          curl -fsS http://localhost:4000/health >/dev/null
        '''
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
