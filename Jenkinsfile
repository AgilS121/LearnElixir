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

    stage('Deploy') {
      steps {
        script {
          def activePort = sh(script: "grep server /etc/nginx/conf.d/default.conf | grep -oE '400[12]'", returnStdout: true).trim()
          def newPort = (activePort == "4001") ? "4002" : "4001"

          sh """
            docker compose build app_${newPort == '4001' ? 'blue' : 'green'}
            docker compose up -d app_${newPort == '4001' ? 'blue' : 'green'}

            # healthcheck
            for i in {1..10}; do
              curl -fsS http://10.10.10.11:${newPort} && break
              sleep 3
            done

            # update nginx ke port baru
            sed -i "s/${activePort}/${newPort}/" /etc/nginx/conf.d/default.conf
            docker exec nginx_container nginx -s reload

            # matikan versi lama
            docker stop elixir_app_${activePort == '4001' ? 'blue' : 'green'} || true
          """
        }
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
