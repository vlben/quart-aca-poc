targetScope = 'subscription'

// Imports from 'main.parameters.json'
param environmentName string
param location string
param projectName string

var abbrs = loadJsonContent('abbreviations.json')
var environmentInitial = string(first(toLower(environmentName)))
var tags = { 'azd-env-name': environmentName }

// Resource names
var logAnalyticsName = string('${projectName}-${abbrs.logAnalyticsWorkspace}${environmentInitial}')
var appInsightsName = string('${projectName}-${abbrs.insightsComponents}${environmentInitial}')
var containerAppEnvName = string('${projectName}-${abbrs.appManagedEnvironments}${environmentInitial}')
var containerAppName = string('${projectName}-${abbrs.appContainerApps}${environmentInitial}')
var containerRegistryName = string('${abbrs.containerRegistryRegistries}${projectName}${environmentInitial}')
var managedUserIdentityName = string('${projectName}-${abbrs.managedIdentityUserAssignedIdentities}${environmentInitial}')

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
    logAnalyticsName: logAnalyticsName
  }
}

module appInsights 'logs/appinsights.bicep' = {
  name: 'appInsightsDeployment'
  scope: resourceGroup
  params: {
    appInsightsName: appInsightsName
    logAnalyticsId: logAnalytics.outputs.logAnalyticsId
  }
}

module containerAppEnv 'environment/containerapp-environment.bicep' = {
  name: 'containerEnvDeployment'
  scope: resourceGroup
  params: {
    containerAppEnvName: containerAppEnvName
    logAnalyticsName: logAnalyticsName
  }
}

module containerApp 'containerapp/containerapp.bicep' = {
  name: 'containerAppDeployment'
  scope: resourceGroup
  params: {
    containerAppName: containerAppName
    containerAppsEnvName: containerAppEnvName
    containerRegistryName: containerRegistryName
    managedUserIdentityName: managedUserIdentityName
    tags: union(tags, { 'azd-service-name': 'backend' })
  }
}

module containerRegistry './environment/containerregistry.bicep' = {
  name: 'containerRegistryDeployment'
  scope: resourceGroup
  params: {
    containerRegistryName: containerRegistryName
  }
}
