targetScope = 'resourceGroup'

@description('Azure region for all regional resources.')
param location string = resourceGroup().location

@description('Short project name used for resource names and tags.')
param projectName string

@description('Deployment environment name, such as dev, test, qa, or prod.')
param environment string

@description('Resource ID of the existing subnet used for App Service regional VNet integration.')
param appSubnetResourceId string

@description('Resource ID of the existing subnet used for private endpoints.')
param privateEndpointSubnetResourceId string

@description('Resource ID of the existing Log Analytics workspace used for diagnostic settings.')
param logAnalyticsWorkspaceResourceId string

@description('Resource ID of the existing Application Insights component used by the Function App.')
param applicationInsightsResourceId string

@description('Function App Linux runtime stack.')
param functionLinuxFxVersion string = 'DOTNET-ISOLATED|8.0'

@description('Function worker runtime app setting.')
param functionWorkerRuntime string = 'dotnet-isolated'

var nameToken = toLower(replace('${projectName}-${environment}', '_', '-'))
var compactToken = take(toLower(replace(replace('${projectName}${environment}', '-', ''), '_', '')), 18)

var tags = {
  project: projectName
  environment: environment
  managedBy: 'bicep'
}

var keyVaultName = take('kv-${compactToken}', 24)
var storageAccountName = take('st${compactToken}', 24)
var appServicePlanName = 'asp-${nameToken}'
var functionAppName = take('func-${nameToken}', 60)
var functionIdentityName = 'id-${nameToken}-func'
var keyVaultUri = 'https://${keyVaultName}${az.environment().suffixes.keyvaultDns}/'
var appServicePlanSkuName = 'P1v3'

var logsAndMetricsDiagnosticSettings = [
  {
    name: 'to-log-analytics'
    workspaceResourceId: logAnalyticsWorkspaceResourceId
    logCategoriesAndGroups: [
      {
        categoryGroup: 'allLogs'
      }
    ]
    metricCategories: [
      {
        category: 'AllMetrics'
      }
    ]
  }
]

var metricsDiagnosticSettings = [
  {
    name: 'to-log-analytics'
    workspaceResourceId: logAnalyticsWorkspaceResourceId
    metricCategories: [
      {
        category: 'AllMetrics'
      }
    ]
  }
]

// Golden examples show shape. Replace versions with the current metadata-resolved AVM versions.
module functionIdentity 'br/public:avm/res/managed-identity/user-assigned-identity:0.5.1' = {
  params: {
    name: functionIdentityName
    location: location
    tags: tags
  }
}

module keyVault 'br/public:avm/res/key-vault/vault:0.13.3' = {
  params: {
    name: keyVaultName
    location: location
    tags: tags
    enableRbacAuthorization: true
    publicNetworkAccess: 'Disabled'
    diagnosticSettings: logsAndMetricsDiagnosticSettings
    roleAssignments: [
      {
        roleDefinitionIdOrName: 'Key Vault Secrets User'
        principalId: deployer().objectId
        principalType: empty(deployer().userPrincipalName) ? 'ServicePrincipal' : 'User'
      }
      {
        roleDefinitionIdOrName: 'Key Vault Secrets User'
        principalId: functionIdentity.outputs.principalId
        principalType: 'ServicePrincipal'
      }
    ]
    privateEndpoints: [
      {
        name: '${keyVaultName}-pe'
        service: 'vault'
        subnetResourceId: privateEndpointSubnetResourceId
      }
    ]
  }
}

module storage 'br/public:avm/res/storage/storage-account:0.32.1' = {
  params: {
    name: storageAccountName
    location: location
    tags: tags
    skuName: 'Standard_LRS'
    kind: 'StorageV2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: false
    defaultToOAuthAuthentication: true
    minimumTlsVersion: 'TLS1_2'
    publicNetworkAccess: 'Disabled'
    supportsHttpsTrafficOnly: true
    diagnosticSettings: metricsDiagnosticSettings
    roleAssignments: [
      {
        roleDefinitionIdOrName: 'Storage Blob Data Contributor'
        principalId: deployer().objectId
        principalType: empty(deployer().userPrincipalName) ? 'ServicePrincipal' : 'User'
      }
      {
        roleDefinitionIdOrName: 'Storage Blob Data Owner'
        principalId: functionIdentity.outputs.principalId
        principalType: 'ServicePrincipal'
      }
      {
        roleDefinitionIdOrName: 'Storage Queue Data Contributor'
        principalId: functionIdentity.outputs.principalId
        principalType: 'ServicePrincipal'
      }
      {
        roleDefinitionIdOrName: 'Storage Table Data Contributor'
        principalId: functionIdentity.outputs.principalId
        principalType: 'ServicePrincipal'
      }
    ]
    privateEndpoints: [
      {
        name: '${storageAccountName}-blob-pe'
        service: 'blob'
        subnetResourceId: privateEndpointSubnetResourceId
      }
      {
        name: '${storageAccountName}-file-pe'
        service: 'file'
        subnetResourceId: privateEndpointSubnetResourceId
      }
      {
        name: '${storageAccountName}-queue-pe'
        service: 'queue'
        subnetResourceId: privateEndpointSubnetResourceId
      }
      {
        name: '${storageAccountName}-table-pe'
        service: 'table'
        subnetResourceId: privateEndpointSubnetResourceId
      }
    ]
  }
}

module appServicePlan 'br/public:avm/res/web/serverfarm:0.7.0' = {
  params: {
    name: appServicePlanName
    location: location
    tags: tags
    kind: 'linux'
    reserved: true
    skuName: appServicePlanSkuName
    zoneRedundant: true
    diagnosticSettings: metricsDiagnosticSettings
  }
}

module functionApp 'br/public:avm/res/web/site:0.23.1' = {
  params: {
    name: functionAppName
    location: location
    tags: tags
    kind: 'functionapp,linux'
    reserved: true
    serverFarmResourceId: appServicePlan.outputs.resourceId
    virtualNetworkSubnetResourceId: appSubnetResourceId
    outboundVnetRouting: {
      allTraffic: true
      applicationTraffic: true
      backupRestoreTraffic: true
      contentShareTraffic: true
      imagePullTraffic: true
    }
    publicNetworkAccess: 'Disabled'
    httpsOnly: true
    keyVaultAccessIdentityResourceId: functionIdentity.outputs.resourceId
    managedIdentities: {
      userAssignedResourceIds: [
        functionIdentity.outputs.resourceId
      ]
    }
    basicPublishingCredentialsPolicies: [
      {
        name: 'ftp'
        allow: false
      }
      {
        name: 'scm'
        allow: false
      }
    ]
    configs: [
      {
        name: 'appsettings'
        applicationInsightResourceId: applicationInsightsResourceId
        storageAccountResourceId: storage.outputs.resourceId
        storageAccountUseIdentityAuthentication: true
        properties: {
          FUNCTIONS_EXTENSION_VERSION: '~4'
          FUNCTIONS_WORKER_RUNTIME: functionWorkerRuntime
          KEY_VAULT_URI: keyVaultUri
        }
      }
    ]
    diagnosticSettings: logsAndMetricsDiagnosticSettings
    siteConfig: {
      alwaysOn: true
      ftpsState: 'FtpsOnly'
      linuxFxVersion: functionLinuxFxVersion
      minTlsVersion: '1.2'
    }
    privateEndpoints: [
      {
        name: '${functionAppName}-pe'
        service: 'sites'
        subnetResourceId: privateEndpointSubnetResourceId
      }
    ]
  }
}

output keyVaultResourceId string = keyVault.outputs.resourceId
output storageAccountResourceId string = storage.outputs.resourceId
output appServicePlanResourceId string = appServicePlan.outputs.resourceId
output functionAppResourceId string = functionApp.outputs.resourceId
output functionIdentityResourceId string = functionIdentity.outputs.resourceId
