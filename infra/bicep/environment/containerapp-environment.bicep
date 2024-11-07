param projectName string
param environmentInitial string
param abbrs object
param location string = resourceGroup().location

param logAnalyticsName string

var containerAppEnvName = string('${projectName}-${abbrs.appManagedEnvironments}${environmentInitial}')

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = {
  name: logAnalyticsName
}

resource containerAppEnv 'Microsoft.App/managedEnvironments@2024-03-01' = {
  name: containerAppEnvName
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalytics.properties.customerId
        sharedKey: logAnalytics.listKeys().primarySharedKey
      }
    }
  }
}

output containerAppEnvName string = containerAppEnv.name
