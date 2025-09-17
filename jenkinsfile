pipeline {
  agent any
  stages {
    stage('Checkout') {
      steps {
        git 'https://github.com/amangithub2003/devops-hands-on-lite.git'
      }
    }
    stage('Build Docker Image') {
      steps {
        sh 'docker build -t amandock8252/devops-hands-on-lite:latest .'
      }
    }
    stage('Push Docker Image') {
      steps {
        withCredentials([string(credentialsId: 'dockerhub-pass', variable: 'DOCKER_PASS')]) {
          sh 'echo $DOCKER_PASS | docker login -u amandock8252 --password-stdin'
          sh 'docker push amandock8252/devops-hands-on-lite:latest'
        }
      }
    }
    stage('Deploy with Ansible') {
      steps {
        sh 'ansible-playbook -i ansible/inventory.ini ansible/playbook.yml'
      }
    }
  }
}


