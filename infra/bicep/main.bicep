targetScope = 'subscription'

param environmentName string
param location string
param projectName string

var environmentInitial = string(first(toLower(environmentName)))

var abbrs = loadJsonContent('abbreviations.json')

resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-07-01' = {
  name: environmentName == 'test' 
    ? '${projectName}-test-datascience' 
    : environmentName == 'production' 
      ? '${projectName}-datascience'
      : '${projectName}-${environmentInitial}-datascience'
  location: location
}

module logAnalytics 'logs/loganalytics.bicep' = {
  name: 'logAnalyticsDeployment'
  scope: resourceGroup
  params: {
    projectName: projectName
    environmentInitial: environmentInitial
    abbrs: abbrs
  }
}

module appInsights 'logs/appinsights.bicep' = {
  name: 'appInsightsDeployment'
  scope: resourceGroup
  params: {
    projectName: projectName
    environmentInitial: environmentInitial
    abbrs: abbrs
    logAnalyticsId: logAnalytics.outputs.logAnalyticsId
  }
}

module containerAppEnv 'environment/containerapp-environment.bicep' = {
  name: 'containerEnvDeployment'
  scope: resourceGroup
  params: {
    projectName: projectName
    environmentInitial: environmentInitial
    abbrs: abbrs
    logAnalyticsName: logAnalytics.outputs.logAnalyticsName
  }
}

module containerApp 'containerapp/containerapp.bicep' = {
  name: 'containerAppDeployment'
  scope: resourceGroup
  params: {
    projectName: projectName
    environmentInitial: environmentInitial
    containerAppsEnvironmentName: containerAppEnv.outputs.containerAppEnvName
    abbrs: abbrs
  }
}
