targetScope = 'resourceGroup'

@description('Azure region for all regional resources.')
param location string = resourceGroup().location

@description('Short project name used for resource names and tags.')
param projectName string

@description('Deployment environment name, such as dev, test, qa, or prod.')
param environment string

@description('Resource ID of the subnet used for private endpoints.')
param privateEndpointSubnetResourceId string

@description('Azure AD object ID for the SQL administrator group.')
param sqlAdminObjectId string

@description('Azure AD display name for the SQL administrator group.')
param sqlAdminLogin string

var nameToken = toLower(replace('${projectName}-${environment}', '_', '-'))
var compactToken = take(toLower(replace(replace('${projectName}${environment}', '-', ''), '_', '')), 18)

var tags = {
  project: projectName
  environment: environment
  managedBy: 'bicep'
}

var sqlServerName = 'sql-${nameToken}'
var sqlDatabaseName = 'sqldb-${nameToken}'
var keyVaultName = take('kv-${compactToken}', 24)
var storageAccountName = take('st${compactToken}', 24)
var serviceBusName = take('sb-${nameToken}', 50)

// Golden examples show shape. Replace versions with the current metadata-resolved AVM versions.
module keyVault 'br/public:avm/res/key-vault/vault:0.11.0' = {
  name: 'mod-${keyVaultName}'
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
    ]
    privateEndpoints: [
      {
        name: '${keyVaultName}-pe'
        subnetResourceId: privateEndpointSubnetResourceId
      }
    ]
  }
}

module storage 'br/public:avm/res/storage/storage-account:0.18.0' = {
  name: 'mod-${storageAccountName}'
  params: {
    name: storageAccountName
    location: location
    tags: tags
    skuName: 'Standard_LRS'
    kind: 'StorageV2'
    publicNetworkAccess: 'Disabled'
    allowBlobPublicAccess: false
    roleAssignments: [
      {
        roleDefinitionIdOrName: 'Storage Blob Data Contributor'
        principalId: deployer().objectId
        principalType: empty(deployer().userPrincipalName) ? 'ServicePrincipal' : 'User'
      }
    ]
    privateEndpoints: [
      {
        name: '${storageAccountName}-blob-pe'
        service: 'blob'
        subnetResourceId: privateEndpointSubnetResourceId
      }
    ]
  }
}

module sqlServer 'br/public:avm/res/sql/server:0.10.0' = {
  name: 'mod-${sqlServerName}'
  params: {
    name: sqlServerName
    location: location
    tags: tags
    publicNetworkAccess: 'Disabled'
    administrators: {
      administratorType: 'ActiveDirectory'
      azureADOnlyAuthentication: true
      login: sqlAdminLogin
      sid: sqlAdminObjectId
      principalType: 'Group'
    }
    databases: [
      {
        name: sqlDatabaseName
        sku: {
          name: 'GP_S_Gen5_1'
          tier: 'GeneralPurpose'
          family: 'Gen5'
          capacity: 1
        }
        autoPauseDelay: 60
        minCapacity: '0.5'
      }
    ]
    privateEndpoints: [
      {
        name: '${sqlServerName}-pe'
        subnetResourceId: privateEndpointSubnetResourceId
      }
    ]
  }
}

module serviceBus 'br/public:avm/res/service-bus/namespace:0.13.0' = {
  name: 'mod-${serviceBusName}'
  params: {
    name: serviceBusName
    location: location
    tags: tags
    publicNetworkAccess: 'Disabled'
    roleAssignments: [
      {
        roleDefinitionIdOrName: 'Azure Service Bus Data Owner'
        principalId: deployer().objectId
        principalType: empty(deployer().userPrincipalName) ? 'ServicePrincipal' : 'User'
      }
    ]
    privateEndpoints: [
      {
        name: '${serviceBusName}-pe'
        subnetResourceId: privateEndpointSubnetResourceId
      }
    ]
    queues: [
      {
        name: 'work'
      }
    ]
    topics: [
      {
        name: 'events'
        subscriptions: [
          {
            name: 'default'
          }
        ]
      }
    ]
  }
}

output sqlServerResourceId string = sqlServer.outputs.resourceId
output keyVaultResourceId string = keyVault.outputs.resourceId
output storageAccountResourceId string = storage.outputs.resourceId
output serviceBusResourceId string = serviceBus.outputs.resourceId
