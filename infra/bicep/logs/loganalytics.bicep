param projectName string
param environmentInitial string
param abbrs object
param location string = resourceGroup().location

var logAnalyticsName = string('${projectName}-${abbrs.logAnalyticsWorkspace}${environmentInitial}')

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: logAnalyticsName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

output logAnalyticsId string = logAnalytics.id
output logAnalyticsName string = logAnalytics.name
