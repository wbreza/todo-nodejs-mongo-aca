@export()
@description('Optional resource definition - Support custom prompting within `azd` CLI')
type OptionalResource = {
  name: string
  subscriptionId: string?
  resourceGroup: string?
  exists: bool
}
