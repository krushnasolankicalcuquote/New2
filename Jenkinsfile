pipeline {
    agent any

    parameters {
        booleanParam(name: 'BuildAll', defaultValue: true, description: 'Build all services?')
        booleanParam(name: 'BuildOnlyAPI', defaultValue: false, description: 'Build only CalcuQuote API?')
        booleanParam(name: 'CQ_Currency', defaultValue: false, description: 'Build CQ_Currency Service?')
        booleanParam(name: 'CQ_CustomReport', defaultValue: false, description: 'Build CQ_CustomReport Service?')
        booleanParam(name: 'CQ_MaintenanceService', defaultValue: false, description: 'Build CQ_MaintenanceService Service?')
        // Add additional parameters for other services as needed.
    }

    environment {
        BUILD_CONFIGURATION = "Release"
        ARTIFACT_DIR = "$WORKSPACE/Artifacts"
    }

    stages {
        stage('Checkout Code') {
            steps {
                echo "Cloning repositories..."
                git branch: 'feature/Krushna', url: 'https://your-repo-url.git'
            }
        }

        stage('Build Services') {
            parallel {
                stage('Build CalcuQuote API') {
                    when {
                        expression { params.BuildAll || params.BuildOnlyAPI }
                    }
                    steps {
                        echo "Building CalcuQuote API..."
                        sh """
                        dotnet publish CalcuQuote.API/CalcuQuote.API.csproj \
                            -c $BUILD_CONFIGURATION \
                            -o $ARTIFACT_DIR/CalcuQuoteAPI
                        """
                    }
                }

                stage('Build CQ_Currency') {
                    when {
                        expression { params.BuildAll || params.CQ_Currency }
                    }
                    steps {
                        echo "Building CQ_Currency..."
                        sh """
                        dotnet publish Services/CalcuQuote.CurrencyService/CalcuQuote.CurrencyService.csproj \
                            -c $BUILD_CONFIGURATION \
                            -o $ARTIFACT_DIR/CQ_Currency
                        """
                    }
                }

                stage('Build CQ_CustomReport') {
                    when {
                        expression { params.BuildAll || params.CQ_CustomReport }
                    }
                    steps {
                        echo "Building CQ_CustomReport..."
                        sh """
                        dotnet publish Services/CalcuQuote.CustomReportService/CalcuQuote.CustomReportService.csproj \
                            -c $BUILD_CONFIGURATION \
                            -o $ARTIFACT_DIR/CQ_CustomReport
                        """
                    }
                }

                stage('Build CQ_MaintenanceService') {
                    when {
                        expression { params.BuildAll || params.CQ_MaintenanceService }
                    }
                    steps {
                        echo "Building CQ_MaintenanceService..."
                        sh """
                        dotnet publish Services/CalcuQuote.MaintenanceService/CalcuQuote.MaintenanceService.csproj \
                            -c $BUILD_CONFIGURATION \
                            -o $ARTIFACT_DIR/CQ_MaintenanceService
                        """
                    }
                }

                // Add additional stages for other services as needed.
            }
        }

        stage('Archive Artifacts') {
            steps {
                echo "Archiving build artifacts..."
                archiveArtifacts artifacts: 'Artifacts/**', fingerprint: true
            }
        }
    }

    post {
        success {
            echo "Build pipeline completed successfully!"
        }
        failure {
            echo "Build pipeline failed. Check logs for details."
        }
    }
}

