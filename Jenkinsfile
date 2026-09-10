pipeline {
    agent any

    parameters {
        booleanParam(name: 'DEPLOY_DEV', defaultValue: true)
        booleanParam(name: 'DEPLOY_QA', defaultValue: true)
        booleanParam(name: 'DEPLOY_STAGING', defaultValue: true)
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build') {
            steps {
                sh '''
                    echo "Building application..."
                    # mvn clean package
                    # or npm build
                    # or your application build command
                '''
            }
        }

        stage('Deploy') {
            parallel {

                stage('Deploy DEV') {
                    when {
                        expression {
                            return params.DEPLOY_DEV
                        }
                    }
                    steps {
                        echo "Deploying to DEV..."

                        sh '''
                            git fetch origin
                            git checkout dev
                            git pull origin dev

                            # DEV deployment commands
                            # docker compose up -d
                            # kubectl apply ...
                            # etc.
                        '''
                    }
                }

                stage('Deploy QA') {
                    when {
                        expression {
                            return params.DEPLOY_QA
                        }
                    }
                    steps {
                        echo "Deploying to QA..."

                        sh '''
                            git fetch origin
                            git checkout qa
                            git pull origin qa

                            # QA deployment commands
                        '''
                    }
                }

                stage('Deploy STAGING') {
                    when {
                        expression {
                            return params.DEPLOY_STAGING
                        }
                    }
                    steps {
                        echo "Deploying to STAGING..."

                        sh '''
                            git fetch origin
                            git checkout staging
                            git pull origin staging

                            # STAGING deployment commands
                        '''
                    }
                }
            }
        }
    }

    post {
        success {
            echo "DEV, QA and STAGING deployment completed successfully."
        }

        failure {
            echo "One or more deployments failed."
        }
    }
}
