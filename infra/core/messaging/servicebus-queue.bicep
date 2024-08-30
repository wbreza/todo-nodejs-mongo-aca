metadata description = 'Creates an Azure App Service in an existing Azure App Service plan.'
param name string
param serviceBusNamespace string

resource queue 'Microsoft.ServiceBus/namespaces/queues@2022-10-01-preview' = {
  parent: namespace
  name: name
}

resource namespace 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' existing = {
  name: serviceBusNamespace
}
