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
                dir("${TF_WORKING_DIR}") {
                    script {
                        def rawOutput = bat(script: 'terraform output -json', returnStdout: true).trim()

                        // Remove any lines that are not JSON
                        def jsonStart = rawOutput.indexOf('{')
                        def jsonEnd = rawOutput.lastIndexOf('}') + 1
                        def cleanedJson = rawOutput.substring(jsonStart, jsonEnd)

                        // Parse it safely
                        def outputs = readJSON text: cleanedJson

                        // Set environment variables
                        env.ACR_LOGIN_SERVER = outputs.acr_login_server.value
                        env.AKS_NAME = outputs.aks_name.value
                        env.RESOURCE_GROUP = outputs.resource_group.value

                        echo " Parsed Terraform Outputs:"
                        echo "ACR: ${env.ACR_LOGIN_SERVER}"
                        echo "AKS: ${env.AKS_NAME}"
                        echo "RG : ${env.RESOURCE_GROUP}"
                    }
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
