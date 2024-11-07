param projectName string
param environmentInitial string
param containerAppsEnvironmentName string
param abbrs object
param location string = resourceGroup().location

var containerAppName = string('${projectName}-${abbrs.appContainerApps}${environmentInitial}')

var containerAppParams = json(loadTextContent('./containerapp.parameters.json'))
var containerCpuCoreCount = string(containerAppParams.cpu)
var containerMemoryCount = string(containerAppParams.memory)
var containerMinReplicas = int(containerAppParams.minReplicas)
var containerMaxReplicas = int(containerAppParams.maxReplicas)
var containerImage = string(containerAppParams.containerImage)


resource containerAppEnvironment 'Microsoft.App/managedEnvironments@2024-03-01' existing = {
  name: containerAppsEnvironmentName
}

// Container app with private image settings
resource containerApp 'Microsoft.App/containerApps@2024-03-01' = {
  name: containerAppName
  location: location
  properties: {
    environmentId: containerAppEnvironment.id
    configuration: {
      ingress: {
        transport: 'auto'
        allowInsecure: false
      }
    }
    template: {
      containers: [
        {
          name: containerAppName
          image: containerImage
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

