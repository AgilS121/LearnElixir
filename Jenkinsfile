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
    stage('Deploy') {
    steps {
      sh '''
        docker compose build
        docker compose up -d
        sleep 3
        curl -fsS http://10.10.10.11:4000/ >/dev/null || true
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
