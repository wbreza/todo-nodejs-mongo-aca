using 'main.bicep'

param environmentName = readEnvironmentVariable('AZURE_ENV_NAME', '')
param applicationInsightsName = readEnvironmentVariable('APPLICATIONINSIGHTS_NAME', '')
param containerAppsEnvironmentName = readEnvironmentVariable('AZURE_CONTAINER_ENVIRONMENT_NAME', '')
param containerRegistryName = readEnvironmentVariable('AZURE_CONTAINER_REGISTRY_NAME', '')
param imageName = readEnvironmentVariable('SERVICE_API_IMAGE_NAME', '')
param keyVaultName = readEnvironmentVariable('AZURE_KEY_VAULT_NAME', '')
param corsAcaUrl = readEnvironmentVariable('SERVICE_WEB_URI', '')
