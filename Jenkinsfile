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


        stage('Build Docker Image') {
            steps {
                bat "docker build -t ${env.ACR_LOGIN_SERVER}/${env.IMAGE_NAME}:${env.IMAGE_TAG} -f ApiContainer/Dockerfile ."
            }
        }

        stage('Login to ACR') {
            steps {
                bat "az acr login --name %ACR_NAME%"
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
                bat 'kubectl get nodes'
                bat 'kubectl get svc dotnet-api-service'
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