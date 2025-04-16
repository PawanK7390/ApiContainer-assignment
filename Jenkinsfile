pipeline {
    agent any

    environment {
        AZURE_CREDENTIALS_ID = 'azure-service-principal'
        IMAGE_NAME = 'apicontainer'
        IMAGE_TAG = 'latest'
        TF_WORKING_DIR = 'terraform'
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'master', url: 'https://github.com/PawanK7390/ApiContainer-assignment.git'
            }
        }

        stage('Terraform Init') {
            steps {
                dir("${TF_WORKING_DIR}") {
                    withCredentials([azureServicePrincipal(credentialsId: AZURE_CREDENTIALS_ID)]) {
                        bat 'az login --service-principal -u %AZURE_CLIENT_ID% -p %AZURE_CLIENT_SECRET% --tenant %AZURE_TENANT_ID%'
                        bat 'terraform init'
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir("${TF_WORKING_DIR}") {
                    withCredentials([azureServicePrincipal(credentialsId: AZURE_CREDENTIALS_ID)]) {
                        bat 'terraform apply -auto-approve'
                    }
                }
            }
        }

        stage('Get Terraform Outputs') {
            steps {
                script {
                    def tfOutput = bat(script: "cd ${TF_WORKING_DIR} && terraform output -json", returnStdout: true).trim()
                    def parsed = readJSON text: tfOutput
                    env.ACR_LOGIN_SERVER = parsed.acr_login_server.value
                    env.RESOURCE_GROUP = parsed.resource_group.value
                    env.AKS_NAME = parsed.aks_name.value
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                bat "docker build -t ${env.ACR_LOGIN_SERVER}/${env.IMAGE_NAME}:${env.IMAGE_TAG} -f ApiContainer/Dockerfile ApiContainer"
            }
        }

        stage('Login to ACR') {
            steps {
                withCredentials([azureServicePrincipal(credentialsId: AZURE_CREDENTIALS_ID)]) {
                    bat "az login --service-principal -u %AZURE_CLIENT_ID% -p %AZURE_CLIENT_SECRET% --tenant %AZURE_TENANT_ID%"
                    script {
                        def acrName = env.ACR_LOGIN_SERVER.tokenize('.')[0]
                        bat "az acr login --name ${acrName}"
                    }
                }
            }
        }

        stage('Push Docker Image to ACR') {
            steps {
                bat "docker push ${env.ACR_LOGIN_SERVER}/${env.IMAGE_NAME}:${env.IMAGE_TAG}"
            }
        }

        stage('Get AKS Credentials') {
            steps {
                bat "az aks get-credentials --resource-group ${env.RESOURCE_GROUP} --name ${env.AKS_NAME} --overwrite-existing"
            }
        }

        stage('Deploy to AKS') {
            steps {
                bat "kubectl apply -f deployment.yaml"
            }
        }

        stage('Check Deployment') {
            steps {
                bat '''
                echo Getting AKS Nodes...
                kubectl get nodes

                echo Getting Service Info...
                kubectl get svc dotnet-api-service
                '''
            }
        }
    }

    post {
        success {
            echo ' Deployment Successful!'
        }
        failure {
            echo ' Deployment Failed!'
        }
    }
}
