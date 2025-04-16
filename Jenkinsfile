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
                    tfOutput = tfOutput.replaceAll("(?s)^.*\\{", "{") // clean JSON if needed
                    def parsed = readJSON text: tfOutput
                    env.ACR_LOGIN_SERVER = parsed.acr_login_server.value
                    env.RESOURCE_GROUP = parsed.resource_group.value
                    env.AKS_NAME = parsed.aks_name.value
                    env.ACR_NAME = parsed.acr_login_server.value.tokenize('.')[0]
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                bat "docker build -t %ACR_LOGIN_SERVER%/%IMAGE_NAME%:%IMAGE_TAG% -f ApiContainer/Dockerfile ."
            }
        }

        stage('Login to ACR') {
            steps {
                withCredentials([azureServicePrincipal(credentialsId: AZURE_CREDENTIALS_ID)]) {
                    bat "az login --service-principal -u %AZURE_CLIENT_ID% -p %AZURE_CLIENT_SECRET% --tenant %AZURE_TENANT_ID%"
                    bat "az acr login --name %ACR_NAME%"
                }
            }
        }

        stage('Push Docker Image to ACR') {
            steps {
                bat "docker push %ACR_LOGIN_SERVER%/%IMAGE_NAME%:%IMAGE_TAG%"
            }
        }

        stage('Get AKS Credentials') {
            steps {
                withCredentials([azureServicePrincipal(credentialsId: AZURE_CREDENTIALS_ID)]) {
                    bat "az login --service-principal -u %AZURE_CLIENT_ID% -p %AZURE_CLIENT_SECRET% --tenant %AZURE_TENANT_ID%"
                    bat "az aks get-credentials --resource-group %RESOURCE_GROUP% --name %AKS_NAME% --overwrite-existing"
                }
            }
        }

        stage('Deploy to AKS') {
            steps {
                bat "kubectl apply -f deployment.yaml"
            }
        }

        stage('Check Deployment') {
            steps {
                bat 'kubectl get nodes && kubectl get svc dotnet-api-service'
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
