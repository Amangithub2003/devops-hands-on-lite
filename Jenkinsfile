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

        stage('Deploy with Ansible') {
            steps {
                // Use withCredentials to securely access the SSH key
                withCredentials([sshUserPrivateKey(credentialsId: 'ansible-ssh-key', keyFileVariable: 'ANSIBLE_KEY')]) {
                    sh '''
                    # Add the remote host to the known_hosts file to prevent SSH errors
                    mkdir -p ~/.ssh
                    ssh-keyscan -H 54.86.122.223 >> ~/.ssh/known_hosts

                    # Now run Ansible, passing the SSH key from Jenkins credentials
                    ansible-playbook -i ansible/inventory.ini --private-key=${ANSIBLE_KEY} ansible/playbook.yml
                    '''
                }
            }
        }
    }
}
