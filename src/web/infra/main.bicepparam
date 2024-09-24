using 'main.bicep'

param environmentName = readEnvironmentVariable('AZURE_ENV_NAME', '')
param containerAppsEnvironmentName = readEnvironmentVariable('AZURE_CONTAINER_ENVIRONMENT_NAME', '')
param containerRegistryName = readEnvironmentVariable('AZURE_CONTAINER_REGISTRY_NAME', '')
param imageName = readEnvironmentVariable('SERVICE_WEB_IMAGE_NAME', '')
