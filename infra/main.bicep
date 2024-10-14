targetScope = 'subscription'
import { OptionalResource } from 'azd.bicep'

@minLength(1)
@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

@metadata({
  azd: {
    type: 'resource'
    resource: {
      displayName: 'Key Vault'
      description: 'The key vault to use for storing secrets'
      type: 'Microsoft.KeyVault/vaults'
    }
  }
})
param keyVault OptionalResource

@metadata({
  azd: {
    type: 'resource'
    resource: {
      displayName: 'Container Registry'
      description: 'The container registry to use for storing images'
      type: 'Microsoft.ContainerRegistry/registries'
    }
  }
})
param containerRegistry OptionalResource

@metadata({
  azd: {
    type: 'resource'
    resource: {
      displayName: 'Storage Account'
      description: 'The storage account to use for storing files'
      type: 'Microsoft.Storage/storageAccounts'
    }
  }
})
param storageAccount OptionalResource

resource newResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-${environmentName}'
  location: location
}

resource existingKeyVault 'Microsoft.KeyVault/vaults@2021-06-01' existing = if (keyVault.exists) {
  name: keyVault.name
  scope: resourceGroup(keyVault.subscriptionId, keyVault.resourceGroup)
}

resource existingRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' existing = if (containerRegistry.exists) {
  name: containerRegistry.name
  scope: resourceGroup(containerRegistry.subscriptionId, containerRegistry.resourceGroup)
}

resource existingStorageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' existing = if (storageAccount.exists) {
  name: storageAccount.name
  scope: resourceGroup(storageAccount.subscriptionId, storageAccount.resourceGroup)
}

module newKeyVault 'core/security/keyvault.bicep' = if (!keyVault.exists) {
  name: 'keyVault'
  scope: resourceGroup(
    !empty(keyVault.subscriptionId) ? keyVault.subscriptionId : subscription().subscriptionId,
    !empty(keyVault.resourceGroup) ? keyVault.resourceGroup : newResourceGroup.name
  )
  params: {
    name: keyVault.name
    location: location
  }
}

module newRegistry 'core//host/container-registry.bicep' = if (!containerRegistry.exists) {
  name: 'containerRegistry'
  scope: resourceGroup(
    !empty(containerRegistry.subscriptionId) ? containerRegistry.subscriptionId : subscription().subscriptionId,
    !empty(containerRegistry.resourceGroup) ? containerRegistry.resourceGroup : newResourceGroup.name
  )
  params: {
    name: containerRegistry.name
    location: location
  }
}

module newStorageAccount 'core/storage/storage-account.bicep' = if (!storageAccount.exists) {
  name: 'storageAccount'
  scope: resourceGroup(
    !empty(storageAccount.subscriptionId) ? storageAccount.subscriptionId : subscription().subscriptionId,
    !empty(storageAccount.resourceGroup) ? storageAccount.resourceGroup : newResourceGroup.name
  )
  params: {
    name: storageAccount.name
    location: location
  }
}

output keyVaultResourceId string = keyVault.exists ? existingKeyVault.id : newKeyVault.outputs.id
output registryResourceId string = containerRegistry.exists ? existingRegistry.id : newRegistry.outputs.id
output storageAccountResourceId string = storageAccount.exists
  ? existingStorageAccount.id
  : newStorageAccount.outputs.id
