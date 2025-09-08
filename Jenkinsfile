pipeline {
  agent any

  stages {
    stage('Checkout') {
      steps {
        git branch: 'master', url: 'git@github.com:AgilS121/LearnElixir.git', credentialsId: 'github_ssh'
      }
    }
    stage('Build/Test') {
      steps {
        // ganti sesuai kebutuhanmu
        script {
          if (isUnix()) {
            sh 'echo "Run your build here"'
          } else {
            bat 'echo Run your build here'
          }
        }
      }
    }
  }

  post {
    success {
      withCredentials([string(credentialsId: 'discord_webhook', variable: 'HOOK')]) {
        script {
          def msg = "✅ **SUCCESS** — `${env.JOB_NAME}` #${env.BUILD_NUMBER}\n${env.BUILD_URL}"
          if (isUnix()) {
            sh """curl -s -H "Content-Type: application/json" \
              -d '{ "content": "${msg.replaceAll('"','\\\\\\"')}" }' "$HOOK" >/dev/null || true"""
          } else {
            bat """powershell -NoProfile -Command ^
              \$body = @{ content = '${msg.replaceAll("'", "''")}' } | ConvertTo-Json; ^
              Invoke-RestMethod -Uri "$env:HOOK" -Method Post -ContentType 'application/json' -Body \$body"""
          }
        }
      }
    }
    failure {
      withCredentials([string(credentialsId: 'discord_webhook', variable: 'HOOK')]) {
        script {
          def msg = "❌ **FAILED** — `${env.JOB_NAME}` #${env.BUILD_NUMBER}\n${env.BUILD_URL}"
          if (isUnix()) {
            sh """curl -s -H "Content-Type: application/json" \
              -d '{ "content": "${msg.replaceAll('"','\\\\\\"')}" }' "$HOOK" >/dev/null || true"""
          } else {
            bat """powershell -NoProfile -Command ^
              \$body = @{ content = '${msg.replaceAll("'", "''")}' } | ConvertTo-Json; ^
              Invoke-RestMethod -Uri "$env:HOOK" -Method Post -ContentType 'application/json' -Body \$body"""
          }
        }
      }
    }
  }
}
