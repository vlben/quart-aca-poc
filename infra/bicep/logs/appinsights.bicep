param projectName string
param environmentInitial string
param abbrs object
param location string = resourceGroup().location
param logAnalyticsId string

var appInsightsName = string('${projectName}-${abbrs.insightsComponents}${environmentInitial}')

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsId
  }
}
