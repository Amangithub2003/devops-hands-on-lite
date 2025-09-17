pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'amandock8252/devops-hands-on-lite:latest'
    }

    stages {
        stage('Build Docker Image') {
            steps {
                // Stop and remove any existing container with the same image name
                sh '''
                docker ps -a -q --filter "ancestor=$DOCKER_IMAGE" | xargs -r docker rm -f
                docker images -q $DOCKER_IMAGE | xargs -r docker rmi -f
                docker build -t $DOCKER_IMAGE .
                '''
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([string(credentialsId: 'dockerhub-pass', variable: 'DOCKER_PASS')]) {
                    sh '''
                    echo $DOCKER_PASS | docker login -u amandock8252 --password-stdin
                    docker push $DOCKER_IMAGE
                    '''
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

