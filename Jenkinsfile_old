pipeline {

    agent any

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
    }

    stages {

        stage('Checkout') {

            steps {

                echo "======================================"
                echo "Checking out source code"
                echo "======================================"

                checkout scm

                sh '''
                    echo "Current branch:"
                    git branch --show-current

                    echo "Current commit:"
                    git rev-parse HEAD

                    echo "Commit message:"
                    git log -1 --pretty=%B
                '''
            }
        }


        stage('Build') {

            steps {

                echo "======================================"
                echo "BUILD"
                echo "======================================"

                sh '''
                    set -e

                    ./scripts/build.sh
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

                        echo "======================================"
                        echo "DEPLOYING TO DEV"
                        echo "======================================"

                        sh '''
                            set -e

                            chmod +x deploy/deploy-dev.sh

                            ./deploy/deploy-dev.sh
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

                        echo "======================================"
                        echo "DEPLOYING TO QA"
                        echo "======================================"

                        sh '''
                            set -e

                            chmod +x deploy/deploy-qa.sh

                            ./deploy/deploy-qa.sh
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

                        echo "======================================"
                        echo "DEPLOYING TO STAGING"
                        echo "======================================"

                        sh '''
                            set -e

                            chmod +x deploy/deploy-staging.sh

                            ./deploy/deploy-staging.sh
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

                echo "======================================"
                echo "VERIFICATION"
                echo "======================================"

                sh '''
                    set -e

                    chmod +x scripts/verify.sh

                    ./scripts/verify.sh
                '''
            }
        }
    }


    post {

        success {

            echo """
            ======================================
            PIPELINE SUCCESSFUL
            ======================================

            Build       : ${env.BUILD_NUMBER}
            Job         : ${env.JOB_NAME}
            Branch      : ${env.BRANCH_NAME}

            DEV         : ${params.DEPLOY_DEV}
            QA          : ${params.DEPLOY_QA}
            STAGING     : ${params.DEPLOY_STAGING}

            ======================================
            """
        }

        failure {

            echo """
            ======================================
            PIPELINE FAILED
            ======================================

            Check the failed stage above.

            ======================================
            """
        }

        always {

            echo "Jenkins Build Number: ${env.BUILD_NUMBER}"
            echo "Jenkins Job: ${env.JOB_NAME}"
        }
    }
}