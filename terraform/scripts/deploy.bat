@echo off
REM ==========================================
REM FreteAPI Multi-Cloud Deployment Script (Windows)
REM ==========================================

setlocal enabledelayedexpansion

REM Default values
set ENVIRONMENT=dev
set CLOUD_PROVIDER=
set BUILD_IMAGE=true
set RUN_MIGRATIONS=true

REM Parse command line arguments
:parse_args
if "%~1"=="" goto validate_args
if "%~1"=="-e" (
    set ENVIRONMENT=%~2
    shift
    shift
    goto parse_args
)
if "%~1"=="--environment" (
    set ENVIRONMENT=%~2
    shift
    shift
    goto parse_args
)
if "%~1"=="-c" (
    set CLOUD_PROVIDER=%~2
    shift
    shift
    goto parse_args
)
if "%~1"=="--cloud" (
    set CLOUD_PROVIDER=%~2
    shift
    shift
    goto parse_args
)
if "%~1"=="-b" (
    set BUILD_IMAGE=%~2
    shift
    shift
    goto parse_args
)
if "%~1"=="--build" (
    set BUILD_IMAGE=%~2
    shift
    shift
    goto parse_args
)
if "%~1"=="-m" (
    set RUN_MIGRATIONS=%~2
    shift
    shift
    goto parse_args
)
if "%~1"=="--migrate" (
    set RUN_MIGRATIONS=%~2
    shift
    shift
    goto parse_args
)
if "%~1"=="-h" goto show_usage
if "%~1"=="--help" goto show_usage
echo Unknown option: %~1
goto show_usage

:validate_args
if "%CLOUD_PROVIDER%"=="" (
    echo ERROR: Cloud provider is required
    goto show_usage
)

if not "%ENVIRONMENT%"=="dev" if not "%ENVIRONMENT%"=="prod" (
    echo ERROR: Environment must be 'dev' or 'prod'
    goto error_exit
)

if not "%CLOUD_PROVIDER%"=="aws" if not "%CLOUD_PROVIDER%"=="azure" if not "%CLOUD_PROVIDER%"=="gcp" if not "%CLOUD_PROVIDER%"=="all" (
    echo ERROR: Cloud provider must be 'aws', 'azure', 'gcp', or 'all'
    goto error_exit
)

goto main

:show_usage
echo Usage: %0 [OPTIONS]
echo.
echo Options:
echo   -e, --environment    Environment (dev^|prod) [default: dev]
echo   -c, --cloud         Cloud provider (aws^|azure^|gcp^|all) [required]
echo   -b, --build         Build Docker image (true^|false) [default: true]
echo   -m, --migrate       Run database migrations (true^|false) [default: true]
echo   -h, --help          Show this help message
echo.
echo Examples:
echo   %0 --environment dev --cloud aws
echo   %0 -e prod -c azure --build true
echo   %0 --environment dev --cloud all
goto end

:check_prerequisites
echo [INFO] Checking prerequisites...

REM Check Docker
docker --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker is not installed or not in PATH
    goto error_exit
)

docker info >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker is not running
    goto error_exit
)

REM Check Terraform
terraform --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Terraform is not installed or not in PATH
    goto error_exit
)

REM Check cloud CLI tools
if "%CLOUD_PROVIDER%"=="aws" (
    aws --version >nul 2>&1
    if errorlevel 1 echo [WARNING] AWS CLI is not installed. Required for AWS deployment.
) else if "%CLOUD_PROVIDER%"=="azure" (
    az --version >nul 2>&1
    if errorlevel 1 echo [WARNING] Azure CLI is not installed. Required for Azure deployment.
) else if "%CLOUD_PROVIDER%"=="gcp" (
    gcloud --version >nul 2>&1
    if errorlevel 1 echo [WARNING] Google Cloud CLI is not installed. Required for GCP deployment.
) else if "%CLOUD_PROVIDER%"=="all" (
    aws --version >nul 2>&1
    if errorlevel 1 echo [WARNING] AWS CLI is not installed.
    az --version >nul 2>&1
    if errorlevel 1 echo [WARNING] Azure CLI is not installed.
    gcloud --version >nul 2>&1
    if errorlevel 1 echo [WARNING] Google Cloud CLI is not installed.
)

echo [SUCCESS] Prerequisites check completed
goto :eof

:build_docker_image
if "%BUILD_IMAGE%"=="true" (
    echo [INFO] Building Docker image...
    
    pushd "%~dp0..\.."
    
    docker build -t freteapi:latest -f Dockerfile .
    if errorlevel 1 (
        echo [ERROR] Docker build failed
        popd
        goto error_exit
    )
    
    docker tag freteapi:latest freteapi:v1.0.0
    
    echo [SUCCESS] Docker image built successfully
    popd
) else (
    echo [INFO] Skipping Docker image build
)
goto :eof

:deploy_terraform
set ENV_DIR=%~dp0..\environments\%ENVIRONMENT%

echo [INFO] Starting Terraform deployment for %ENVIRONMENT% environment...

if not exist "%ENV_DIR%" (
    echo [ERROR] Environment directory not found: %ENV_DIR%
    goto error_exit
)

pushd "%ENV_DIR%"

if not exist "terraform.tfvars" (
    echo [WARNING] terraform.tfvars not found. Please create it from terraform.tfvars.example
    if exist "terraform.tfvars.example" (
        echo [INFO] Copying terraform.tfvars.example to terraform.tfvars...
        copy terraform.tfvars.example terraform.tfvars
        echo [WARNING] Please edit terraform.tfvars with your actual values before proceeding
        popd
        goto error_exit
    )
)

echo [INFO] Initializing Terraform...
terraform init
if errorlevel 1 (
    echo [ERROR] Terraform init failed
    popd
    goto error_exit
)

echo [INFO] Validating Terraform configuration...
terraform validate
if errorlevel 1 (
    echo [ERROR] Terraform validation failed
    popd
    goto error_exit
)

echo [INFO] Planning deployment...

set TF_VARS=
if "%CLOUD_PROVIDER%"=="aws" (
    set TF_VARS=-var="deploy_to_aws=true" -var="deploy_to_azure=false" -var="deploy_to_gcp=false"
) else if "%CLOUD_PROVIDER%"=="azure" (
    set TF_VARS=-var="deploy_to_aws=false" -var="deploy_to_azure=true" -var="deploy_to_gcp=false"
) else if "%CLOUD_PROVIDER%"=="gcp" (
    set TF_VARS=-var="deploy_to_aws=false" -var="deploy_to_azure=false" -var="deploy_to_gcp=true"
) else if "%CLOUD_PROVIDER%"=="all" (
    set TF_VARS=-var="deploy_to_aws=true" -var="deploy_to_azure=true" -var="deploy_to_gcp=true"
)

set TF_VARS=%TF_VARS% -var="run_migrations=%RUN_MIGRATIONS%"

terraform plan %TF_VARS% -out=tfplan
if errorlevel 1 (
    echo [ERROR] Terraform plan failed
    popd
    goto error_exit
)

echo [INFO] Applying Terraform configuration...
set /p REPLY="Do you want to proceed with the deployment? (y/N): "
if /i "%REPLY%"=="y" (
    terraform apply tfplan
    if errorlevel 1 (
        echo [ERROR] Terraform apply failed
        popd
        goto error_exit
    )
    echo [SUCCESS] Deployment completed successfully!
    
    echo [INFO] Deployment outputs:
    terraform output
) else (
    echo [WARNING] Deployment cancelled by user
    if exist tfplan del tfplan
    popd
    goto end
)

if exist tfplan del tfplan
popd
goto :eof

:main
echo [INFO] Starting FreteAPI deployment...
echo [INFO] Environment: %ENVIRONMENT%
echo [INFO] Cloud Provider: %CLOUD_PROVIDER%
echo [INFO] Build Image: %BUILD_IMAGE%
echo [INFO] Run Migrations: %RUN_MIGRATIONS%
echo.

call :check_prerequisites
call :build_docker_image
call :deploy_terraform

echo [SUCCESS] FreteAPI deployment completed successfully!
goto end

:error_exit
exit /b 1

:end
endlocal