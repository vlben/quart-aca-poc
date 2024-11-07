// resource acrPullRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
//   name: guid(acr.id, containerApp.id, acrPullRoleId)
//   scope: acr
//   properties: {
//     principalId: containerApp.identity.principalId
//     roleDefinitionId: acrPullRoleId
//     principalType: 'ServicePrincipal'
//   }
// }
