@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

var abbrs = loadJsonContent('../../../infra/abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))

param name string = ''
param location string = resourceGroup().location
param tags object = {}

param containerAppsEnvironmentName string
@description('Hostname suffix for container registry. Set when deploying to sovereign clouds')
param containerRegistryHostSuffix string = 'azurecr.io'
param containerRegistryName string
param serviceName string = 'web'
param imageName string = ''

resource webIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: '${abbrs.managedIdentityUserAssignedIdentities}${serviceName}-${resourceToken}'
  location: location
}

module app '../../../infra/core/host/container-app.bicep' = {
  name: '${serviceName}-container-app'
  params: {
    name: !empty(name) ? name : '${abbrs.appContainerApps}${serviceName}-${resourceToken}'
    location: location
    tags: union(tags, { 'azd-service-name': serviceName })
    identityType: 'UserAssigned'
    identityName: webIdentity.name
    containerAppsEnvironmentName: containerAppsEnvironmentName
    containerRegistryName: containerRegistryName
    containerRegistryHostSuffix: containerRegistryHostSuffix
    targetPort: 80
    imageName: imageName
  }
}

output SERVICE_WEB_IDENTITY_PRINCIPAL_ID string = webIdentity.properties.principalId
output SERVICE_WEB_NAME string = app.outputs.name
output SERVICE_WEB_URI string = app.outputs.uri
output SERVICE_WEB_IMAGE_NAME string = app.outputs.imageName
