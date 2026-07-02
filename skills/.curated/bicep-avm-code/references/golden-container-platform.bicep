targetScope = 'resourceGroup'

@description('Azure region for all regional resources.')
param location string = resourceGroup().location

@description('Short project name used for resource names and tags.')
param projectName string

@description('Deployment environment name, such as dev, test, qa, or prod.')
param environment string

@description('Virtual network address space.')
param virtualNetworkAddressPrefix string = '10.50.0.0/22'

@description('Container Apps environment infrastructure subnet address prefix. Use at least /23 for workload profile environments.')
param containerAppsInfrastructureSubnetAddressPrefix string = '10.50.0.0/23'

@description('Private endpoint subnet address prefix.')
param privateEndpointSubnetAddressPrefix string = '10.50.2.0/26'

@description('Container image path inside the deployed Azure Container Registry.')
param containerImageRepositoryAndTag string = 'apps/hello-world:latest'

@description('Container target port for internal ingress.')
param containerTargetPort int = 8080

@secure()
@description('Example secret value stored in Key Vault and referenced by the Container App.')
param containerAppSecretValue string

var nameToken = toLower(replace('${projectName}-${environment}', '_', '-'))
var compactToken = take(toLower(replace(replace('${projectName}${environment}', '-', ''), '_', '')), 18)

var tags = {
  project: projectName
  environment: environment
  managedBy: 'bicep'
}

var vnetName = 'vnet-${nameToken}'
var containerAppsInfrastructureSubnetName = 'snet-aca'
var privateEndpointSubnetName = 'snet-pe'
var containerAppsInfrastructureNsgName = 'nsg-${nameToken}-aca'
var privateEndpointNsgName = 'nsg-${nameToken}-pe'
var logAnalyticsWorkspaceName = take('log-${nameToken}', 63)
var containerRegistryName = take('cr${compactToken}000', 50)
var keyVaultName = take('kv-${compactToken}', 24)
var containerAppsEnvironmentName = take('cae-${nameToken}', 32)
var containerAppName = take('ca-${nameToken}-api', 32)
var containerAppIdentityName = 'id-${nameToken}-aca'
var containerAppSecretName = 'app-secret'
var keyVaultUri = 'https://${keyVaultName}${az.environment().suffixes.keyvaultDns}/'
var workloadProfileName = 'workload-d4'

var logsAndMetricsDiagnosticSettings = [
  {
    name: 'to-log-analytics'
    workspaceResourceId: logAnalytics.outputs.resourceId
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
    workspaceResourceId: logAnalytics.outputs.resourceId
    metricCategories: [
      {
        category: 'AllMetrics'
      }
    ]
  }
]

// Golden examples show shape. Replace versions with the current metadata-resolved AVM versions.
module containerAppsInfrastructureNsg 'br/public:avm/res/network/network-security-group:0.5.3' = {
  params: {
    name: containerAppsInfrastructureNsgName
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
        name: containerAppsInfrastructureSubnetName
        addressPrefix: containerAppsInfrastructureSubnetAddressPrefix
        delegation: 'Microsoft.App/environments'
        networkSecurityGroupResourceId: containerAppsInfrastructureNsg.outputs.resourceId
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

module logAnalytics 'br/public:avm/res/operational-insights/workspace:0.15.1' = {
  params: {
    name: logAnalyticsWorkspaceName
    location: location
    tags: tags
    dataRetention: 30
    dailyQuotaGb: '2'
  }
}

module containerAppIdentity 'br/public:avm/res/managed-identity/user-assigned-identity:0.5.1' = {
  params: {
    name: containerAppIdentityName
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
        principalId: containerAppIdentity.outputs.principalId
        principalType: 'ServicePrincipal'
      }
    ]
    secrets: [
      {
        name: containerAppSecretName
        value: containerAppSecretValue
        contentType: 'text/plain'
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

module containerRegistry 'br/public:avm/res/container-registry/registry:0.12.1' = {
  params: {
    name: containerRegistryName
    location: location
    tags: tags
    acrSku: 'Premium'
    acrAdminUserEnabled: false
    anonymousPullEnabled: false
    publicNetworkAccess: 'Disabled'
    networkRuleSetDefaultAction: 'Deny'
    networkRuleSetIpRules: []
    diagnosticSettings: logsAndMetricsDiagnosticSettings
    roleAssignments: [
      {
        roleDefinitionIdOrName: 'AcrPush'
        principalId: deployer().objectId
        principalType: empty(deployer().userPrincipalName) ? 'ServicePrincipal' : 'User'
      }
      {
        roleDefinitionIdOrName: 'AcrPull'
        principalId: containerAppIdentity.outputs.principalId
        principalType: 'ServicePrincipal'
      }
    ]
    privateEndpoints: [
      {
        name: '${containerRegistryName}-pe'
        service: 'registry'
        subnetResourceId: network.outputs.subnetResourceIds[1]
      }
    ]
  }
}

module containerAppsEnvironment 'br/public:avm/res/app/managed-environment:0.13.3' = {
  params: {
    name: containerAppsEnvironmentName
    location: location
    tags: tags
    internal: true
    publicNetworkAccess: 'Disabled'
    infrastructureSubnetResourceId: network.outputs.subnetResourceIds[0]
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsWorkspaceResourceId: logAnalytics.outputs.resourceId
    }
    peerTrafficEncryption: true
    roleAssignments: [
      {
        roleDefinitionIdOrName: 'Container Apps Contributor'
        principalId: deployer().objectId
        principalType: empty(deployer().userPrincipalName) ? 'ServicePrincipal' : 'User'
      }
    ]
    workloadProfiles: [
      {
        name: workloadProfileName
        workloadProfileType: 'D4'
        minimumCount: 0
        maximumCount: 3
      }
    ]
  }
}

module containerApp 'br/public:avm/res/app/container-app:0.22.1' = {
  params: {
    name: containerAppName
    location: location
    tags: tags
    environmentResourceId: containerAppsEnvironment.outputs.resourceId
    workloadProfileName: workloadProfileName
    managedIdentities: {
      userAssignedResourceIds: [
        containerAppIdentity.outputs.resourceId
      ]
    }
    registries: [
      {
        server: containerRegistry.outputs.loginServer
        identity: containerAppIdentity.outputs.resourceId
      }
    ]
    secrets: [
      {
        name: containerAppSecretName
        keyVaultUrl: '${keyVaultUri}secrets/${containerAppSecretName}'
        identity: containerAppIdentity.outputs.resourceId
      }
    ]
    containers: [
      {
        name: 'api'
        image: '${containerRegistry.outputs.loginServer}/${containerImageRepositoryAndTag}'
        env: [
          {
            name: 'KEY_VAULT_URI'
            value: keyVaultUri
          }
          {
            name: 'KEY_VAULT_RESOURCE_ID'
            value: keyVault.outputs.resourceId
          }
          {
            name: 'APP_SECRET'
            secretRef: containerAppSecretName
          }
        ]
        resources: {
          cpu: json('0.5')
          memory: '1Gi'
        }
      }
    ]
    activeRevisionsMode: 'Single'
    ingressAllowInsecure: false
    ingressExternal: false
    ingressTargetPort: containerTargetPort
    ingressTransport: 'auto'
    scaleSettings: {
      minReplicas: 1
      maxReplicas: 5
      rules: [
        {
          name: 'http'
          http: {
            metadata: {
              concurrentRequests: '50'
            }
          }
        }
      ]
    }
    diagnosticSettings: metricsDiagnosticSettings
  }
}

output containerAppsEnvironmentResourceId string = containerAppsEnvironment.outputs.resourceId
output containerAppResourceId string = containerApp.outputs.resourceId
output containerRegistryResourceId string = containerRegistry.outputs.resourceId
output keyVaultResourceId string = keyVault.outputs.resourceId
output logAnalyticsWorkspaceResourceId string = logAnalytics.outputs.resourceId
output containerAppIdentityResourceId string = containerAppIdentity.outputs.resourceId
