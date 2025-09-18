pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'amandock8252/devops-hands-on-lite:latest'
    }

    stages {
        stage('Build Docker Image') {
            steps {
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

        stage('Deploy to EC2') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'ansible-ssh-key', keyFileVariable: 'ANSIBLE_KEY')]) {
                    sh '''
                    mkdir -p ~/.ssh
                    ssh-keyscan -H 54.86.122.223 >> ~/.ssh/known_hosts

                    ssh -i ${ANSIBLE_KEY} ubuntu@54.86.122.223 "sudo bash -c '
                        docker stop $(docker ps -q --filter ancestor=$DOCKER_IMAGE) || true
                        docker rm $(docker ps -aq --filter ancestor=$DOCKER_IMAGE) || true
                        docker rmi $DOCKER_IMAGE || true
                        docker run -d -p 80:80 amandock8252/devops-hands-on-lite:latest
                    '"
                    '''
                }
            }
        }
    }
}
