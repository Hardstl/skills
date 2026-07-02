targetScope = 'resourceGroup'

@description('Azure region for all regional resources.')
param location string = resourceGroup().location

@description('Short project name used for resource names and tags.')
param projectName string

@description('Deployment environment name, such as dev, test, qa, or prod.')
param environment string

@description('Virtual network address space.')
param virtualNetworkAddressPrefix string = '10.40.0.0/24'

@description('Application integration subnet address prefix.')
param appSubnetAddressPrefix string = '10.40.0.0/26'

@description('Private endpoint subnet address prefix.')
param privateEndpointSubnetAddressPrefix string = '10.40.0.64/26'

@description('Function App Linux runtime stack.')
param functionLinuxFxVersion string = 'DOTNET-ISOLATED|8.0'

@description('Function worker runtime app setting.')
param functionWorkerRuntime string = 'dotnet-isolated'

@description('Web App Linux runtime stack.')
param webLinuxFxVersion string = 'DOTNETCORE|8.0'

var nameToken = toLower(replace('${projectName}-${environment}', '_', '-'))
var compactToken = take(toLower(replace(replace('${projectName}${environment}', '-', ''), '_', '')), 18)

var tags = {
  project: projectName
  environment: environment
  managedBy: 'bicep'
}

var vnetName = 'vnet-${nameToken}'
var appSubnetName = 'snet-app'
var privateEndpointSubnetName = 'snet-pe'
var appNsgName = 'nsg-${nameToken}-app'
var privateEndpointNsgName = 'nsg-${nameToken}-pe'
var keyVaultName = take('kv-${compactToken}', 24)
var storageAccountName = take('st${compactToken}', 24)
var appServicePlanName = 'asp-${nameToken}'
var functionAppName = take('func-${nameToken}', 60)
var webAppName = take('app-${nameToken}', 60)
var functionIdentityName = 'id-${nameToken}-func'
var webIdentityName = 'id-${nameToken}-web'
var keyVaultUri = 'https://${keyVaultName}${az.environment().suffixes.keyvaultDns}/'
var appServicePlanSkuName = 'P1v3'

// Golden examples show shape. Replace versions with the current metadata-resolved AVM versions.
module appNsg 'br/public:avm/res/network/network-security-group:0.5.3' = {
  params: {
    name: appNsgName
    location: location
    tags: tags
  }
}

module privateEndpointNsg 'br/public:avm/res/network/network-security-group:0.5.3' = {
  params: {
    name: privateEndpointNsgName
    location: location
    tags: tags
  }
}

module network 'br/public:avm/res/network/virtual-network:0.9.0' = {
  params: {
    name: vnetName
    location: location
    tags: tags
    addressPrefixes: [
      virtualNetworkAddressPrefix
    ]
    subnets: [
      {
        name: appSubnetName
        addressPrefix: appSubnetAddressPrefix
        networkSecurityGroupResourceId: appNsg.outputs.resourceId
        delegation: 'Microsoft.Web/serverFarms'
        privateEndpointNetworkPolicies: 'Enabled'
      }
      {
        name: privateEndpointSubnetName
        addressPrefix: privateEndpointSubnetAddressPrefix
        networkSecurityGroupResourceId: privateEndpointNsg.outputs.resourceId
        privateEndpointNetworkPolicies: 'Enabled'
      }
    ]
  }
}

module functionIdentity 'br/public:avm/res/managed-identity/user-assigned-identity:0.5.1' = {
  params: {
    name: functionIdentityName
    location: location
    tags: tags
  }
}

module webIdentity 'br/public:avm/res/managed-identity/user-assigned-identity:0.5.1' = {
  params: {
    name: webIdentityName
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
      {
        roleDefinitionIdOrName: 'Key Vault Secrets User'
        principalId: webIdentity.outputs.principalId
        principalType: 'ServicePrincipal'
      }
    ]
    privateEndpoints: [
      {
        name: '${keyVaultName}-pe'
        service: 'vault'
        subnetResourceId: network.outputs.subnetResourceIds[1]
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
        subnetResourceId: network.outputs.subnetResourceIds[1]
      }
      {
        name: '${storageAccountName}-file-pe'
        service: 'file'
        subnetResourceId: network.outputs.subnetResourceIds[1]
      }
      {
        name: '${storageAccountName}-queue-pe'
        service: 'queue'
        subnetResourceId: network.outputs.subnetResourceIds[1]
      }
      {
        name: '${storageAccountName}-table-pe'
        service: 'table'
        subnetResourceId: network.outputs.subnetResourceIds[1]
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
    virtualNetworkSubnetResourceId: network.outputs.subnetResourceIds[0]
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
        storageAccountResourceId: storage.outputs.resourceId
        storageAccountUseIdentityAuthentication: true
        properties: {
          FUNCTIONS_EXTENSION_VERSION: '~4'
          FUNCTIONS_WORKER_RUNTIME: functionWorkerRuntime
          KEY_VAULT_URI: keyVaultUri
        }
      }
    ]
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
        subnetResourceId: network.outputs.subnetResourceIds[1]
      }
    ]
  }
}

module webApp 'br/public:avm/res/web/site:0.23.1' = {
  params: {
    name: webAppName
    location: location
    tags: tags
    kind: 'app,linux'
    reserved: true
    serverFarmResourceId: appServicePlan.outputs.resourceId
    virtualNetworkSubnetResourceId: network.outputs.subnetResourceIds[0]
    outboundVnetRouting: {
      allTraffic: true
      applicationTraffic: true
      backupRestoreTraffic: true
      contentShareTraffic: true
      imagePullTraffic: true
    }
    publicNetworkAccess: 'Disabled'
    httpsOnly: true
    clientAffinityEnabled: false
    keyVaultAccessIdentityResourceId: webIdentity.outputs.resourceId
    managedIdentities: {
      userAssignedResourceIds: [
        webIdentity.outputs.resourceId
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
        properties: {
          KEY_VAULT_URI: keyVaultUri
        }
      }
    ]
    siteConfig: {
      alwaysOn: true
      ftpsState: 'FtpsOnly'
      linuxFxVersion: webLinuxFxVersion
      minTlsVersion: '1.2'
    }
    privateEndpoints: [
      {
        name: '${webAppName}-pe'
        service: 'sites'
        subnetResourceId: network.outputs.subnetResourceIds[1]
      }
    ]
  }
}

output keyVaultResourceId string = keyVault.outputs.resourceId
output functionAppResourceId string = functionApp.outputs.resourceId
output webAppResourceId string = webApp.outputs.resourceId
output functionIdentityResourceId string = functionIdentity.outputs.resourceId
output webIdentityResourceId string = webIdentity.outputs.resourceId
