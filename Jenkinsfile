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
                withCredentials([sshUserPrivateKey(credentialsId: 'ansible-ssh-key', keyFileVariable: 'ANSIBLE_KEY')]) {
                    sh '''
                    mkdir -p ~/.ssh
                    ssh-keyscan -H 54.86.122.223 >> ~/.ssh/known_hosts

                    # Install the 'python3-six' package on the remote host using the raw module
                    ansible all -i ansible/inventory.ini --private-key=${ANSIBLE_KEY} -m raw -a "sudo apt-get install -y python3-six"

                    # Run the main Ansible playbook
                    ANSIBLE_PYTHON_INTERPRETER=/usr/bin/python3 ansible-playbook -i ansible/inventory.ini --private-key=${ANSIBLE_KEY} ansible/playbook.yml
                    '''
                }
            }
        }
    }
}
