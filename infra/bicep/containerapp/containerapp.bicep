param containerAppName string
param containerAppsEnvName string
param containerRegistryName string
param managedUserIdentityName string
param tags object

param location string = resourceGroup().location
param subscriptionId string = subscription().subscriptionId
param resourceGroupName string = resourceGroup().name

var containerAppParams = json(loadTextContent('./containerapp.parameters.json'))
var containerName = string(containerAppParams.containerName)
var containerCpuCoreCount = string(containerAppParams.cpu)
var containerMemoryCount = string(containerAppParams.memory)
var containerMinReplicas = int(containerAppParams.minReplicas)
var containerMaxReplicas = int(containerAppParams.maxReplicas)
var containerImageName = string(containerAppParams.containerImageName)
var targetPort = int(containerAppParams.targetPort)
var external = bool(containerAppParams.external)

resource containerAppEnvironment 'Microsoft.App/managedEnvironments@2024-03-01' existing = {
  name: containerAppsEnvName
}

resource managedUserIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31'  = {
  name: managedUserIdentityName
  location: location
}

module acrPullRoleAssignment '../security/acr-pull-role.bicep' = {
  name: 'acrPullRoleAssignment'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    containerRegistryName: containerRegistryName
    principalId: managedUserIdentity.properties.principalId
  }
}

resource containerApp 'Microsoft.App/containerApps@2024-03-01' = {
  name: containerAppName
  location: location
  tags: tags
  dependsOn: [ containerAppEnvironment, acrPullRoleAssignment ]
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedUserIdentity.id}': {}
    }
  }
  properties: {
    environmentId: containerAppEnvironment.id
    configuration: {
      ingress: {
        external: external
        transport: 'auto'
        targetPort: targetPort
        allowInsecure: false
        corsPolicy: {
          allowedOrigins: ['http://localhost:3000']
        }
      }
      registries: [
        {
          server: '${containerRegistryName}.azurecr.io'
          identity: managedUserIdentity.id
        }
      ]
    }
    template: {
      containers: [
        {
          name: containerName
          image: '${containerRegistryName}.azurecr.io/${containerImageName}:latest'
          resources: {
            cpu: json(containerCpuCoreCount)
            memory: containerMemoryCount
          }
        }
      ]
      scale: {
        minReplicas: containerMinReplicas
        maxReplicas: containerMaxReplicas
      }
    }
  }
}
