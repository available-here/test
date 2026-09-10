pipeline {
    agent any

    options {
        skipDefaultCheckout(true)
        timestamps()
        disableConcurrentBuilds()
    }

    environment {
        DOCKER_REPO = 'mstr6789/git_push'
    }

    stages {

        stage('Checkout') {
            steps {
                echo '=================================================='
                echo '                  CHECKOUT'
                echo '=================================================='

                checkout scm

                sh '''
                    set -e

                    echo "Workspace:"
                    pwd

                    echo ""
                    echo "Branch:"
                    echo "${BRANCH_NAME}"

                    echo ""
                    echo "Git branch:"
                    git branch --show-current

                    echo ""
                    echo "Git commit:"
                    git rev-parse HEAD

                    echo ""
                    echo "Commit:"
                    git log -1 --oneline

                    echo ""
                    echo "Jenkins build:"
                    echo "${BUILD_NUMBER}"

                    echo ""
                    echo "Checking required files..."

                    test -f Jenkinsfile
                    test -f Dockerfile
                    test -f scripts/build.sh
                    test -f scripts/verify.sh

                    echo "Required files found."

                    echo ""
                    echo "Checkout completed successfully."
                '''
            }
        }

        stage('Validate Branch') {
            steps {
                script {
                    def branch = env.BRANCH_NAME

                    if (!(branch in ['dev', 'qa', 'staging'])) {
                        error(
                            "Unsupported branch: ${env.BRANCH_NAME}. " +
                            "Allowed branches are: dev, qa, staging."
                        )
                    }

                    env.IMAGE_TAG = "${env.BRANCH_NAME}-${env.BUILD_NUMBER}"
                    env.DOCKER_IMAGE = "${env.DOCKER_REPO}:${env.IMAGE_TAG}"

                    echo '=================================================='
                    echo '                BRANCH VALIDATION'
                    echo '=================================================='

                    echo "Branch       : ${env.BRANCH_NAME}"
                    echo "Build Number : ${env.BUILD_NUMBER}"
                    echo "Docker Repo  : ${env.DOCKER_REPO}"
                    echo "Docker Tag   : ${env.IMAGE_TAG}"
                    echo "Docker Image : ${env.DOCKER_IMAGE}"

                    echo ""
                    echo "Branch validation successful."
                }
            }
        }

        stage('Application Build') {
            steps {
                echo '=================================================='
                echo '              APPLICATION BUILD'
                echo '=================================================='

                sh '''
                    set -e

                    echo "Starting application build..."

                    chmod +x scripts/build.sh

                    ./scripts/build.sh

                    echo ""
                    echo "Checking build output..."

                    if [ ! -d "build" ]; then
                        echo "ERROR: build directory was not created."
                        exit 1
                    fi

                    echo ""
                    echo "Build directory:"
                    ls -lah build/

                    echo ""
                    echo "Application build completed successfully."
                '''
            }
        }

        stage('Docker Build') {
            steps {
                echo '=================================================='
                echo '                 DOCKER BUILD'
                echo '=================================================='

                sh '''
                    set -e

                    echo "Docker version:"
                    docker --version

                    echo ""
                    echo "Docker image:"
                    echo "${DOCKER_IMAGE}"

                    echo ""
                    echo "Checking Dockerfile..."

                    if [ ! -f "Dockerfile" ]; then
                        echo "ERROR: Dockerfile not found."
                        exit 1
                    fi

                    echo "Dockerfile found."

                    echo ""
                    echo "Starting Docker image build..."

                    docker build \
                        --pull \
                        --tag "${DOCKER_IMAGE}" \
                        .

                    echo ""
                    echo "Docker image build completed successfully."

                    echo ""
                    echo "Docker image details:"

                    docker image inspect "${DOCKER_IMAGE}" \
                        --format='Repository: {{.RepoTags}}'

                    docker image inspect "${DOCKER_IMAGE}" \
                        --format='Image ID: {{.Id}}'

                    docker image inspect "${DOCKER_IMAGE}" \
                        --format='Created: {{.Created}}'

                    echo ""
                    echo "Local Docker images:"
                    docker images "${DOCKER_REPO}"
                '''
            }
        }

        stage('Docker Push') {
            steps {
                echo '=================================================='
                echo '                  DOCKER PUSH'
                echo '=================================================='

                withCredentials([
                    usernamePassword(
                        credentialsId: 'YOUR_DOCKER_CREDENTIAL_ID',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASSWORD'
                    )
                ]) {
                    sh '''
                        set -e

                        echo "Logging in to Docker Hub..."

                        echo "${DOCKER_PASSWORD}" | \
                            docker login \
                            --username "${DOCKER_USER}" \
                            --password-stdin

                        echo ""
                        echo "Docker Hub login successful."

                        echo ""
                        echo "Pushing image:"
                        echo "${DOCKER_IMAGE}"

                        docker push "${DOCKER_IMAGE}"

                        echo ""
                        echo "Docker image pushed successfully."

                        echo ""
                        echo "Image:"
                        echo "${DOCKER_IMAGE}"

                        echo ""
                        echo "Logging out from Docker Hub..."

                        docker logout

                        echo ""
                        echo "Docker push completed successfully."
                    '''
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    echo '=================================================='
                    echo '                    DEPLOY'
                    echo '=================================================='

                    echo "Branch       : ${env.BRANCH_NAME}"
                    echo "Docker Image : ${env.DOCKER_IMAGE}"

                    if (env.BRANCH_NAME == 'dev') {
                        echo ""
                        echo "Starting DEV deployment..."

                        sh '''
                            set -e
                            chmod +x deploy/deploy-dev.sh
                            ./deploy/deploy-dev.sh
                        '''

                        echo ""
                        echo "DEV deployment completed successfully."

                    } else if (env.BRANCH_NAME == 'qa') {
                        echo ""
                        echo "Starting QA deployment..."

                        sh '''
                            set -e
                            chmod +x deploy/deploy-qa.sh
                            ./deploy/deploy-qa.sh
                        '''

                        echo ""
                        echo "QA deployment completed successfully."

                    } else if (env.BRANCH_NAME == 'staging') {
                        echo ""
                        echo "Starting STAGING deployment..."

                        sh '''
                            set -e
                            chmod +x deploy/deploy-staging.sh
                            ./deploy/deploy-staging.sh
                        '''

                        echo ""
                        echo "STAGING deployment completed successfully."

                    } else {
                        error("Deployment blocked. Unsupported branch: ${env.BRANCH_NAME}")
                    }
                }
            }
        }

        stage('Verification') {
            steps {
                echo '=================================================='
                echo '                 VERIFICATION'
                echo '=================================================='

                sh '''
                    set -e

                    chmod +x scripts/verify.sh

                    ./scripts/verify.sh

                    echo ""
                    echo "Verification completed successfully."
                '''
            }
        }
    }

    post {
        success {
            echo '=================================================='
            echo '             PIPELINE SUCCESSFUL'
            echo '=================================================='

            echo "Branch       : ${env.BRANCH_NAME}"
            echo "Build Number : ${env.BUILD_NUMBER}"
            echo "Docker Image : ${env.DOCKER_IMAGE}"

            echo ""
            echo "Application build : SUCCESS"
            echo "Docker build      : SUCCESS"
            echo "Docker push       : SUCCESS"
            echo "Deployment        : SUCCESS"
            echo "Verification      : SUCCESS"

            echo ""
            echo "Complete pipeline finished successfully."

            echo '=================================================='
        }

        failure {
            echo '=================================================='
            echo '               PIPELINE FAILED'
            echo '=================================================='

            echo "Branch       : ${env.BRANCH_NAME}"
            echo "Build Number : ${env.BUILD_NUMBER}"
            echo "Docker Image : ${env.DOCKER_IMAGE ?: 'Not created'}"

            echo ""
            echo "Pipeline failed."
            echo "Check the Jenkins console log for the failed stage."

            echo '=================================================='
        }

        aborted {
            echo '=================================================='
            echo '              PIPELINE ABORTED'
            echo '=================================================='
        }

        always {
            echo "Pipeline execution completed."
        }
    }
}