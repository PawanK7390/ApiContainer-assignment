pipeline {
    agent any

    environment {
        AZURE_CREDENTIALS_ID = 'azure-service-principal'
        RESOURCE_GROUP = 'rg-assignment'
        IMAGE_NAME = 'apicontainer'
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'master', url: 'https://github.com/PawanK7390/ApiContainer-assignment.git'
            }
        }

        stage('Terraform Init & Apply') {
            steps {
                dir('terraform') {
                    withCredentials([azureServicePrincipal(credentialsId: AZURE_CREDENTIALS_ID)]) {
                        bat 'az login --service-principal -u %AZURE_CLIENT_ID% -p %AZURE_CLIENT_SECRET% --tenant %AZURE_TENANT_ID%'
                        bat 'terraform init'
                        bat 'terraform apply -auto-approve'
                    }
                }
            }
        }

        stage('Get Terraform Outputs') {
            steps {
                script {
                    def tfOutput = bat(script: 'cd terraform && terraform output -json', returnStdout: true).trim()
                    tfOutput = tfOutput.replaceAll("(?s)^.*\\{", "{") // Trim output to clean JSON if needed
                    def parsed = readJSON text: tfOutput
                    env.ACR_LOGIN_SERVER = parsed.acr_login_server.value
                    env.RESOURCE_GROUP = parsed.resource_group.value
                    env.AKS_NAME = parsed.aks_name.value
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                bat "docker build -t %ACR_LOGIN_SERVER%/%IMAGE_NAME%:latest ."
            }
        }

        stage('Push Docker Image to ACR') {
            steps {
                withCredentials([azureServicePrincipal(credentialsId: AZURE_CREDENTIALS_ID)]) {
                    script {
                        def acrName = env.ACR_LOGIN_SERVER.tokenize('.')[0]
                        bat "az login --service-principal -u %AZURE_CLIENT_ID% -p %AZURE_CLIENT_SECRET% --tenant %AZURE_TENANT_ID%"
                        bat "az acr login --name ${acrName}"
                        bat "docker push %ACR_LOGIN_SERVER%/%IMAGE_NAME%:latest"
                    }
                }
            }
        }

        stage('Deploy to AKS') {
            steps {
                withCredentials([azureServicePrincipal(credentialsId: AZURE_CREDENTIALS_ID)]) {
                    bat 'az login --service-principal -u %AZURE_CLIENT_ID% -p %AZURE_CLIENT_SECRET% --tenant %AZURE_TENANT_ID%'
                    bat 'az aks get-credentials --resource-group %RESOURCE_GROUP% --name %AKS_NAME% --overwrite-existing'
                    bat 'kubectl apply -f deployment.yaml'
                    bat 'kubectl get service dotnet-api-service'
                }
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
