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
        // Jalankan bash via heredoc (tanpa tergantung shell Jenkins)
        sh '''
bash -euo pipefail <<'BASH'
export COMPOSE_PROJECT_NAME=elixir

# Pastikan include awal ada
mkdir -p nginx/includes
[ -f nginx/includes/upstream_target.inc ] || echo 'server app_blue:4000;' > nginx/includes/upstream_target.inc

# Baca target aktif; pilih lawannya sebagai kandidat baru
ACTIVE_SVC="$(grep -oE "app_(blue|green)" -m1 nginx/includes/upstream_target.inc || echo app_blue)"
if [ "$ACTIVE_SVC" = "app_blue" ]; then
  NEW_SVC=app_green; OLD_SVC=app_blue
else
  NEW_SVC=app_blue;  OLD_SVC=app_green
fi
echo "Active=$ACTIVE_SVC  New=$NEW_SVC"

# Build & start kandidat baru (di network internal saja)
docker compose build "$NEW_SVC"
docker compose up -d "$NEW_SVC"

# Tunggu HEALTHY pakai container ID
CID="$(docker compose ps -q "$NEW_SVC")"
if [ -z "$CID" ]; then
  echo "No container ID for $NEW_SVC"
  docker compose ps
  exit 1
fi

for i in $(seq 1 30); do
  ST="$(docker inspect -f '{{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}}' "$CID" 2>/dev/null || echo starting)"
  echo "health: $ST"
  if [ "$ST" = "healthy" ]; then
    break
  fi
  sleep 2
  if [ "$i" -eq 30 ]; then
    echo "Health timeout"
    docker logs --tail=200 "$CID" || true
    exit 1
  fi
done

# Pastikan LB hidup (publish 4000)
docker compose up -d lb

# Switch Nginx ke service baru via include, lalu reload
echo "server ${NEW_SVC}:4000;" > nginx/includes/upstream_target.inc
docker compose exec -T lb nginx -t
docker compose exec -T lb nginx -s reload

# (Opsional) stop versi lama
docker compose stop "$OLD_SVC" || true

# Rapikan orphan
docker compose up -d --remove-orphans

# Smoke test via LB (host:4000)
curl -fsS http://localhost:4000/health >/dev/null
BASH
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
