pipeline {
    agent any

    options {
        skipDefaultCheckout(true)
    }

    parameters {
        booleanParam(
            name: 'DEPLOY_DEV',
            defaultValue: true,
            description: 'Deploy to DEV'
        )

        booleanParam(
            name: 'DEPLOY_QA',
            defaultValue: true,
            description: 'Deploy to QA'
        )

        booleanParam(
            name: 'DEPLOY_STAGING',
            defaultValue: true,
            description: 'Deploy to STAGING'
        )

        booleanParam(
            name: 'RUN_VERIFICATION',
            defaultValue: true,
            description: 'Run deployment verification'
        )

        booleanParam(
            name: 'PUSH_DOCKER',
            defaultValue: true,
            description: 'Build and push Docker image to Docker Hub'
        )
    }

    environment {
        DOCKER_REPO = 'mstr6789/git_push'
    }

    stages {

        /*
         * =========================================================
         * 1. CHECKOUT
         * =========================================================
         */
        stage('Checkout') {
            steps {
                echo "======================================"
                echo "        CHECKOUT STARTED"
                echo "======================================"

                checkout scm

                sh '''
                    echo "Branch:"
                    git branch --show-current

                    echo "Commit:"
                    git rev-parse HEAD

                    echo "Commit message:"
                    git log -1 --pretty=%B

                    echo "======================================"
                    echo "        CHECKOUT COMPLETED"
                    echo "======================================"
                '''
            }
        }


        /*
         * =========================================================
         * 2. BUILD
         * =========================================================
         */
        stage('Build') {
            steps {
                echo "======================================"
                echo "          BUILD STARTED"
                echo "======================================"

                sh '''
                    set -e

                    echo "Running application build..."

                    ./scripts/build.sh

                    echo "Build directory:"
                    ls -lah build/

                    echo "======================================"
                    echo "          BUILD COMPLETED"
                    echo "======================================"
                '''
            }
        }


        /*
         * =========================================================
         * 3. DEPLOY
         * =========================================================
         */
        stage('Deploy') {
            parallel {

                /*
                 * -------------------------
                 * DEV
                 * -------------------------
                 */
                stage('Deploy DEV') {

                    when {
                        expression {
                            return params.DEPLOY_DEV
                        }
                    }

                    steps {
                        sh '''
                            set -e

                            echo "======================================"
                            echo "       DEV DEPLOYMENT STARTED"
                            echo "======================================"

                            ./deploy/deploy-dev.sh

                            echo "======================================"
                            echo "       DEV DEPLOYMENT COMPLETED"
                            echo "======================================"
                        '''
                    }
                }


                /*
                 * -------------------------
                 * QA
                 * -------------------------
                 */
                stage('Deploy QA') {

                    when {
                        expression {
                            return params.DEPLOY_QA
                        }
                    }

                    steps {
                        sh '''
                            set -e

                            echo "======================================"
                            echo "       QA DEPLOYMENT STARTED"
                            echo "======================================"

                            ./deploy/deploy-qa.sh

                            echo "======================================"
                            echo "       QA DEPLOYMENT COMPLETED"
                            echo "======================================"
                        '''
                    }
                }


                /*
                 * -------------------------
                 * STAGING
                 * -------------------------
                 */
                stage('Deploy STAGING') {

                    when {
                        expression {
                            return params.DEPLOY_STAGING
                        }
                    }

                    steps {
                        sh '''
                            set -e

                            echo "======================================"
                            echo "    STAGING DEPLOYMENT STARTED"
                            echo "======================================"

                            ./deploy/deploy-staging.sh

                            echo "======================================"
                            echo "    STAGING DEPLOYMENT COMPLETED"
                            echo "======================================"
                        '''
                    }
                }
            }
        }


        /*
         * =========================================================
         * 4. VERIFICATION
         * =========================================================
         */
        stage('Verification') {

            when {
                expression {
                    return params.RUN_VERIFICATION
                }
            }

            steps {
                echo "======================================"
                echo "       VERIFICATION STARTED"
                echo "======================================"

                sh '''
                    set -e

                    ./scripts/verify.sh

                    echo "======================================"
                    echo "       VERIFICATION COMPLETED"
                    echo "======================================"
                '''
            }
        }


        /*
         * =========================================================
         * 5. DOCKER BUILD & PUSH
         * =========================================================
         *
         * This is intentionally the LAST stage.
         *
         * Docker image will only be built and pushed if all
         * previous stages are successful.
         */
        stage('Docker Build & Push') {

            when {
                expression {
                    return params.PUSH_DOCKER
                }
            }

            steps {

                script {

                    /*
                     * Convert branch name to a Docker-safe value.
                     *
                     * Examples:
                     * dev     -> dev
                     * qa      -> qa
                     * staging -> staging
                     */
                    def safeBranch = env.BRANCH_NAME
                        .toLowerCase()
                        .replaceAll(/[^a-z0-9_.-]/, '-')

                    /*
                     * Image tag
                     *
                     * Example:
                     * dev-25
                     * qa-17
                     * staging-8
                     */
                    env.IMAGE_TAG = "${safeBranch}-${env.BUILD_NUMBER}"

                    env.DOCKER_IMAGE = "${env.DOCKER_REPO}:${env.IMAGE_TAG}"

                    echo "======================================"
                    echo "      DOCKER BUILD & PUSH"
                    echo "======================================"

                    echo "Branch       : ${env.BRANCH_NAME}"
                    echo "Build Number : ${env.BUILD_NUMBER}"
                    echo "Docker Repo  : ${env.DOCKER_REPO}"
                    echo "Docker Image : ${env.DOCKER_IMAGE}"

                    /*
                     * Docker Hub login
                     *
                     * Jenkins credential ID:
                     * dockerhub-credentials
                     */
                    withCredentials([
                        usernamePassword(
                            credentialsId: 'dockerhub-credentials',
                            usernameVariable: 'DOCKER_USER',
                            passwordVariable: 'DOCKER_PASSWORD'
                        )
                    ]) {

                        sh '''
                            set -e

                            echo "--------------------------------------"
                            echo "Checking Docker"
                            echo "--------------------------------------"

                            docker --version

                            echo "--------------------------------------"
                            echo "Logging in to Docker Hub"
                            echo "--------------------------------------"

                            echo "$DOCKER_PASSWORD" | \
                                docker login \
                                -u "$DOCKER_USER" \
                                --password-stdin

                            echo "Docker Hub login successful."

                            echo "--------------------------------------"
                            echo "Building Docker Image"
                            echo "--------------------------------------"

                            docker build \
                                -t "$DOCKER_IMAGE" \
                                .

                            echo "Docker image created:"
                            docker images "$DOCKER_REPO"

                            echo "--------------------------------------"
                            echo "Pushing Docker Image"
                            echo "--------------------------------------"

                            docker push "$DOCKER_IMAGE"

                            echo "--------------------------------------"
                            echo "Docker Image Push Successful"
                            echo "--------------------------------------"

                            echo "Image:"
                            echo "$DOCKER_IMAGE"

                            echo "--------------------------------------"
                            echo "Logging out from Docker Hub"
                            echo "--------------------------------------"

                            docker logout

                            echo "======================================"
                            echo "   DOCKER BUILD & PUSH COMPLETED"
                            echo "======================================"
                        '''
                    }
                }
            }
        }
    }


    /*
     * =============================================================
     * POST ACTIONS
     * =============================================================
     */
    post {

        success {
            echo "======================================"
            echo "        PIPELINE SUCCESSFUL"
            echo "======================================"

            echo "Branch       : ${env.BRANCH_NAME}"
            echo "Build Number : ${env.BUILD_NUMBER}"

            echo "Docker Image : ${env.DOCKER_IMAGE ?: 'Not built'}"

            echo "DEV / QA / STAGING deployment completed."
            echo "Verification completed."
            echo "Docker image build and push completed."

            echo "======================================"
        }

        failure {
            echo "======================================"
            echo "          PIPELINE FAILED"
            echo "======================================"

            echo "Branch       : ${env.BRANCH_NAME}"
            echo "Build Number : ${env.BUILD_NUMBER}"

            echo "Please check the failed stage in Jenkins."

            echo "======================================"
        }

        always {
            echo "Pipeline execution completed."
        }
    }
}