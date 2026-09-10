pipeline {
agent any

```
options {
    skipDefaultCheckout(true)
    timestamps()
}

parameters {
    booleanParam(
        name: 'PUSH_DOCKER',
        defaultValue: true,
        description: 'Build and push Docker image to Docker Hub'
    )

    booleanParam(
        name: 'RUN_VERIFICATION',
        defaultValue: true,
        description: 'Run deployment verification'
    )
}

environment {
    DOCKER_REPO = 'mstr6789/git_push'
}

stages {

    stage('Checkout') {
        steps {
            echo "=============================================="
            echo "              CHECKOUT STARTED"
            echo "=============================================="

            checkout scm

            sh '''
                set -e

                echo "Branch:"
                echo "${BRANCH_NAME}"

                echo ""
                echo "Git branch:"
                git branch --show-current

                echo ""
                echo "Git commit:"
                git rev-parse HEAD

                echo ""
                echo "Commit message:"
                git log -1 --pretty=%B

                echo ""
                echo "=============================================="
                echo "              CHECKOUT COMPLETED"
                echo "=============================================="
            '''
        }
    }

    stage('Build') {
        steps {
            echo "=============================================="
            echo "                BUILD STARTED"
            echo "=============================================="

            sh '''
                set -e

                echo "Running application build..."

                chmod +x scripts/build.sh

                ./scripts/build.sh

                echo ""
                echo "Build directory:"
                ls -lah build/

                echo ""
                echo "=============================================="
                echo "                BUILD COMPLETED"
                echo "=============================================="
            '''
        }
    }

    stage('Docker Build & Push') {
        when {
            expression {
                return params.PUSH_DOCKER
            }
        }

        steps {
            script {
                def branch = env.BRANCH_NAME

                if (!(branch in ['dev', 'qa', 'staging'])) {
                    error(
                        "Unsupported branch '${branch}'. " +
                        "Only dev, qa and staging branches are allowed."
                    )
                }

                env.IMAGE_TAG = "${branch}-${env.BUILD_NUMBER}"
                env.DOCKER_IMAGE = "${env.DOCKER_REPO}:${env.IMAGE_TAG}"

                echo "=============================================="
                echo "           DOCKER BUILD & PUSH"
                echo "=============================================="

                echo "Branch       : ${env.BRANCH_NAME}"
                echo "Build Number : ${env.BUILD_NUMBER}"
                echo "Docker Repo  : ${env.DOCKER_REPO}"
                echo "Docker Tag   : ${env.IMAGE_TAG}"
                echo "Docker Image : ${env.DOCKER_IMAGE}"

                withCredentials([
                    usernamePassword(
                        credentialsId: 'YOUR_DOCKER_CREDENTIAL_ID',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASSWORD'
                    )
                ]) {
                    sh '''
                        set -e

                        echo ""
                        echo "----------------------------------------------"
                        echo "Checking Docker"
                        echo "----------------------------------------------"

                        docker --version
                        docker info

                        echo ""
                        echo "----------------------------------------------"
                        echo "Logging in to Docker Hub"
                        echo "----------------------------------------------"

                        echo "$DOCKER_PASSWORD" | \
                            docker login \
                            --username "$DOCKER_USER" \
                            --password-stdin

                        echo "Docker Hub login successful."

                        echo ""
                        echo "----------------------------------------------"
                        echo "Building Docker Image"
                        echo "----------------------------------------------"

                        docker build \
                            --pull \
                            -t "$DOCKER_IMAGE" \
                            .

                        echo ""
                        echo "Docker image created successfully."

                        echo ""
                        echo "----------------------------------------------"
                        echo "Docker Image Details"
                        echo "----------------------------------------------"

                        docker image inspect "$DOCKER_IMAGE" \
                            --format='Image: {{.RepoTags}}'

                        docker images "$DOCKER_REPO"

                        echo ""
                        echo "----------------------------------------------"
                        echo "Pushing Docker Image to Docker Hub"
                        echo "----------------------------------------------"

                        docker push "$DOCKER_IMAGE"

                        echo ""
                        echo "Docker image push successful."

                        echo ""
                        echo "Image pushed:"
                        echo "$DOCKER_IMAGE"

                        echo ""
                        echo "----------------------------------------------"
                        echo "Logging out from Docker Hub"
                        echo "----------------------------------------------"

                        docker logout

                        echo ""
                        echo "=============================================="
                        echo "       DOCKER BUILD & PUSH COMPLETED"
                        echo "=============================================="
                    '''
                }
            }
        }
    }

    stage('Deploy') {
        parallel {

            stage('Deploy DEV') {
                when {
                    allOf {
                        branch 'dev'
                        expression {
                            return params.PUSH_DOCKER
                        }
                    }
                }

                steps {
                    sh '''
                        set -e

                        echo "=============================================="
                        echo "             DEV DEPLOYMENT"
                        echo "=============================================="

                        echo "Branch       : ${BRANCH_NAME}"
                        echo "Docker Image : ${DOCKER_IMAGE}"

                        chmod +x deploy/deploy-dev.sh

                        ./deploy/deploy-dev.sh

                        echo ""
                        echo "=============================================="
                        echo "          DEV DEPLOYMENT COMPLETED"
                        echo "=============================================="
                    '''
                }
            }

            stage('Deploy QA') {
                when {
                    allOf {
                        branch 'qa'
                        expression {
                            return params.PUSH_DOCKER
                        }
                    }
                }

                steps {
                    sh '''
                        set -e

                        echo "=============================================="
                        echo "              QA DEPLOYMENT"
                        echo "=============================================="

                        echo "Branch       : ${BRANCH_NAME}"
                        echo "Docker Image : ${DOCKER_IMAGE}"

                        chmod +x deploy/deploy-qa.sh

                        ./deploy/deploy-qa.sh

                        echo ""
                        echo "=============================================="
                        echo "           QA DEPLOYMENT COMPLETED"
                        echo "=============================================="
                    '''
                }
            }

            stage('Deploy STAGING') {
                when {
                    allOf {
                        branch 'staging'
                        expression {
                            return params.PUSH_DOCKER
                        }
                    }
                }

                steps {
                    sh '''
                        set -e

                        echo "=============================================="
                        echo "           STAGING DEPLOYMENT"
                        echo "=============================================="

                        echo "Branch       : ${BRANCH_NAME}"
                        echo "Docker Image : ${DOCKER_IMAGE}"

                        chmod +x deploy/deploy-staging.sh

                        ./deploy/deploy-staging.sh

                        echo ""
                        echo "=============================================="
                        echo "        STAGING DEPLOYMENT COMPLETED"
                        echo "=============================================="
                    '''
                }
            }
        }
    }

    stage('Verification') {
        when {
            expression {
                return params.RUN_VERIFICATION
            }
        }

        steps {
            echo "=============================================="
            echo "             VERIFICATION STARTED"
            echo "=============================================="

            sh '''
                set -e

                chmod +x scripts/verify.sh

                ./scripts/verify.sh

                echo ""
                echo "=============================================="
                echo "          VERIFICATION COMPLETED"
                echo "=============================================="
            '''
        }
    }
}

post {
    success {
        echo "=============================================="
        echo "             PIPELINE SUCCESSFUL"
        echo "=============================================="

        echo "Branch       : ${env.BRANCH_NAME}"
        echo "Build Number : ${env.BUILD_NUMBER}"
        echo "Docker Image : ${env.DOCKER_IMAGE ?: 'Not built'}"

        echo ""
        echo "Build completed successfully."
        echo "Docker image build and push completed."
        echo "Environment deployment completed."
        echo "Verification completed successfully."

        echo ""
        echo "=============================================="
    }

    failure {
        echo "=============================================="
        echo "               PIPELINE FAILED"
        echo "=============================================="

        echo "Branch       : ${env.BRANCH_NAME}"
        echo "Build Number : ${env.BUILD_NUMBER}"

        echo ""
        echo "Please check the failed stage and Jenkins console log."

        echo ""
        echo "=============================================="
    }

    always {
        echo "Pipeline execution completed."
    }
}
```

}
