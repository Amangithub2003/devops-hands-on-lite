pipeline {
    agent any
    environment {
        DOCKER_IMAGE = 'amandock8252/devops-hands-on-lite:latest'
    }
    stages {
        stage('Build Docker Image') {
            steps {
                sh '''
                echo "=== Building Docker Image ==="
                # Clean up local containers and images
                docker ps -a -q --filter "ancestor=$DOCKER_IMAGE" | xargs -r docker rm -f
                docker images -q $DOCKER_IMAGE | xargs -r docker rmi -f
                
                # Build new image
                docker build -t $DOCKER_IMAGE .
                echo "✅ Docker image built successfully"
                '''
            }
        }
        stage('Push Docker Image') {
            steps {
                withCredentials([string(credentialsId: 'dockerhub-pass', variable: 'DOCKER_PASS')]) {
                    sh '''
                    echo "=== Pushing to Docker Hub ==="
                    echo $DOCKER_PASS | docker login -u amandock8252 --password-stdin
                    docker push $DOCKER_IMAGE
                    echo "✅ Docker image pushed successfully"
                    '''
                }
            }
        }
        stage('Deploy to EC2') {
            steps {
                withCredentials([sshUserPrivateKey(credentialsId: 'ansible-ssh-key', keyFileVariable: 'ANSIBLE_KEY')]) {
                    sh '''
                    echo "=== Deploying to EC2 ==="
                    mkdir -p ~/.ssh
                    ssh-keyscan -H 54.86.122.223 >> ~/.ssh/known_hosts
                    
                    ssh -i ${ANSIBLE_KEY} ubuntu@54.86.122.223 "
                        echo '🚀 Starting Deployment Process...'
                        
                        # Stop ALL containers using this image (more aggressive)
                        echo '⏹️  Stopping all containers with image: $DOCKER_IMAGE'
                        RUNNING_CONTAINERS=\\$(docker ps -q --filter ancestor=$DOCKER_IMAGE)
                        if [ ! -z \\\"\\$RUNNING_CONTAINERS\\\" ]; then
                            echo \\$RUNNING_CONTAINERS | xargs docker stop
                            echo '✅ Containers stopped'
                        else
                            echo 'ℹ️  No running containers found'
                        fi
                        
                        # Remove ALL containers with this image (both running and stopped)
                        echo '🗑️  Removing all containers with image: $DOCKER_IMAGE'
                        ALL_CONTAINERS=\\$(docker ps -aq --filter ancestor=$DOCKER_IMAGE)
                        if [ ! -z \\\"\\$ALL_CONTAINERS\\\" ]; then
                            echo \\$ALL_CONTAINERS | xargs docker rm -f
                            echo '✅ Containers removed'
                        else
                            echo 'ℹ️  No containers to remove'
                        fi
                        
                        # Remove the image completely (force fresh download)
                        echo '📦 Removing old image: $DOCKER_IMAGE'
                        docker rmi -f $DOCKER_IMAGE || echo 'ℹ️  Image not found locally'
                        
                        # Clean up any dangling images to save space
                        echo '🧹 Cleaning up dangling images'
                        docker image prune -f || true
                        
                        # Pull the latest image
                        echo '⬇️  Pulling latest image: $DOCKER_IMAGE'
                        docker pull $DOCKER_IMAGE
                        
                        # Start new container with unique name
                        echo '🔄 Starting new container on port 80'
                        TIMESTAMP=\\$(date +%s)
                        NEW_CONTAINER_ID=\\$(docker run -d -p 80:80 --name devops-app-\\$TIMESTAMP --restart unless-stopped $DOCKER_IMAGE)
                        echo \\\"✅ New container started: \\$NEW_CONTAINER_ID\\\"
                        
                        # Wait a moment for container to initialize
                        echo '⏳ Waiting for container to initialize...'
                        sleep 5
                        
                        # Verify deployment
                        echo '🔍 Verifying deployment...'
                        if docker ps | grep $DOCKER_IMAGE; then
                            echo '✅ SUCCESS: Container is running!'
                            echo '🌐 Application available at: http://54.86.122.223'
                            
                            # Test if the web server is responding
                            if curl -f -s http://localhost > /dev/null; then
                                echo '✅ Web server is responding'
                            else
                                echo '⚠️  Web server may not be ready yet'
                            fi
                        else
                            echo '❌ FAILURE: Container is not running!'
                            echo '📋 Container logs:'
                            docker logs \\$NEW_CONTAINER_ID || true
                            exit 1
                        fi
                        
                        echo '🎉 Deployment Process Completed Successfully!'
                        echo '📊 Current running containers:'
                        docker ps --format \\\"table {{.Names}}\\t{{.Image}}\\t{{.Status}}\\t{{.Ports}}\\\"
                    "
                    '''
                }
            }
        }
    }
    post {
        success {
            echo '🎉 ==============================================='
            echo '✅ Pipeline completed successfully!'
            echo '🌐 Application is live at: http://54.86.122.223'
            echo '🔄 Deployment completed with fresh container!'
            echo '==============================================='
        }
        failure {
            echo '❌ ==============================================='
            echo '💥 Pipeline failed!'
            echo '📋 Check the console output for error details'
            echo '🔧 Common issues: SSH keys, Docker, or network'
            echo '==============================================='
        }
        always {
            sh '''
            echo "🧹 Cleaning up..."
            docker logout || true
            echo "✅ Cleanup completed"
            '''
        }
    }
}
