param containerRegistryName string
param principalId string

var registryPullRole = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' existing = {
  name: containerRegistryName
}

resource acrPullRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(containerRegistry.id, registryPullRole, principalId)
  scope: containerRegistry
  properties: {
    roleDefinitionId: registryPullRole
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}
