@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

var abbrs = loadJsonContent('../../../infra/abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))

param name string = ''
param location string = resourceGroup().location
param tags object = {}

param applicationInsightsName string
param containerAppsEnvironmentName string
param containerRegistryName string
@description('Hostname suffix for container registry. Set when deploying to sovereign clouds')
param containerRegistryHostSuffix string = 'azurecr.io'
param keyVaultName string
param serviceName string = 'api'
param corsAcaUrl string
param imageName string = ''

resource apiIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: '${abbrs.managedIdentityUserAssignedIdentities}${serviceName}-${resourceToken}'
  location: location
}

// Give the API access to KeyVault
module apiKeyVaultAccess '../../../infra/core/security/keyvault-access.bicep' = {
  name: 'api-keyvault-access'
  params: {
    keyVaultName: keyVaultName
    principalId: apiIdentity.properties.principalId
  }
}

module app '../../../infra/core/host/container-app.bicep' = {
  name: '${serviceName}-container-app'
  dependsOn: [ apiKeyVaultAccess ]
  params: {
    name: !empty(name) ? name : '${abbrs.appContainerApps}${serviceName}-${resourceToken}'
    location: location
    tags: union(tags, { 'azd-service-name': serviceName })
    identityType: 'UserAssigned'
    identityName: apiIdentity.name
    containerAppsEnvironmentName: containerAppsEnvironmentName
    containerRegistryName: containerRegistryName
    containerRegistryHostSuffix: containerRegistryHostSuffix
    containerCpuCoreCount: '1.0'
    containerMemory: '2.0Gi'
    env: [
      {
        name: 'AZURE_CLIENT_ID'
        value: apiIdentity.properties.clientId
      }
      {
        name: 'AZURE_KEY_VAULT_ENDPOINT'
        value: keyVault.properties.vaultUri
      }
      {
        name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
        value: applicationInsights.properties.ConnectionString
      }
      {
        name: 'API_ALLOW_ORIGINS'
        value: corsAcaUrl
      }
    ]
    targetPort: 3100
    imageName: imageName
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: applicationInsightsName
}

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}

output SERVICE_API_IDENTITY_PRINCIPAL_ID string = apiIdentity.properties.principalId
output SERVICE_API_NAME string = app.outputs.name
output SERVICE_API_URI string = app.outputs.uri
output SERVICE_API_IMAGE_NAME string = app.outputs.imageName
