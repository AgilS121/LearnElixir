pipeline {
  agent any
  stages {
    stage('Checkout') {
      steps {
        git branch: 'master',
            url: 'git@github.com:org/repo.git',
            credentialsId: 'github_ssh'
      }
    }
  }
}
