@description('The name of the Azure Function app.')
param functionAppName string = 'func-${uniqueString(resourceGroup().id)}'

@description('The name of the Azure Key Vault.')
param keyVaultName string = 'kv-${uniqueString(resourceGroup().id)}'

@description('The location into which the resources should be deployed.')
param location string = resourceGroup().location

@description('The language worker runtime to load in the function app.')
@allowed([
  'dotnet'
  'node'
  'python'
  'java'
  'powershell'
])
param functionWorkerRuntime string = 'powershell'

@description('Specifies the OS used for the Azure Function hosting plan.')
@allowed([
  'Windows'
  'Linux'
])
param functionPlanOS string = 'Windows'

@description('Specifies the Azure Function hosting plan SKU.')
@allowed([
  'EP1'
  'EP2'
  'EP3'
])
param functionAppPlanSku string = 'EP1'

@description('The name of the Azure Function hosting plan.')
param functionAppPlanName string = 'plan-${uniqueString(resourceGroup().id)}'

@description('The name of the backend Azure storage account used by the Azure Function app.')
param functionStorageAccountName string = 'st${uniqueString(resourceGroup().id)}'

@description('The name of the virtual network for virtual network integration.')
param vnetName string = 'vnet-${uniqueString(resourceGroup().id)}'

@description('The name of the virtual network subnet to be associated with the Azure Function app.')
param functionSubnetName string = 'snet-func'

@description('The name of the virtual network subnet used for allocating IP addresses for private endpoints.')
param privateEndpointSubnetName string = 'snet-pe'

@description('The IP adddress space used for the virtual network.')
param vnetAddressPrefix string = '10.100.0.0/16'

@description('The IP address space used for the Azure Function integration subnet.')
param functionSubnetAddressPrefix string = '10.100.0.0/24'

@description('The IP address space used for the private endpoints.')
param privateEndpointSubnetAddressPrefix string = '10.100.1.0/24'

@description('Only required for Linux app to represent runtime stack in the format of \'runtime|runtimeVersion\'. For example: \'python|3.9\'')
param linuxFxVersion string = ''

var applicationInsightsName = 'appi-${uniqueString(resourceGroup().id)}'
var privateStorageFileDnsZoneName = 'privatelink.file.${environment().suffixes.storage}'
var privateEndpointStorageFileName = '${functionStorageAccountName}-file-private-endpoint'
var privateStorageTableDnsZoneName = 'privatelink.table.${environment().suffixes.storage}'
var privateEndpointStorageTableName = '${functionStorageAccountName}-table-private-endpoint'
var privateStorageBlobDnsZoneName = 'privatelink.blob.${environment().suffixes.storage}'
var privateEndpointStorageBlobName = '${functionStorageAccountName}-blob-private-endpoint'
var privateStorageQueueDnsZoneName = 'privatelink.queue.${environment().suffixes.storage}'
var privateEndpointStorageQueueName = '${functionStorageAccountName}-queue-private-endpoint'
var privateKeyVaultDnsZoneName = 'privatelink.vaultcore.azure.net'
var privateEndpointKeyVaultName = '${keyVaultName}-private-endpoint'
var functionAppRoleAssignmentId = '/providers/Microsoft.Authorization/roleDefinitions/0c867c2a-1d8c-454a-a3db-ab2ea1bdc8bb'
// var privateFunctionAppDnsZoneName = 'privatelink.azurewebsites.net'
// var privateEndpointFunctionAppName = '${functionAppName}-private-endpoint'

var TibiID = '32970abe-f31d-4d35-96f5-f6407c2c69e5'

var functionContentShareName = 'function-content-share'
var isReserved = ((functionPlanOS == 'Linux') ? true : false)
// var repoURL = 'https://tiborszucs@dev.azure.com/tiborszucs/TestEnv/_git/Functions'
// var branch = 'master'

// resource vnet 'Microsoft.Network/virtualNetworks@2022-05-01' = {
//   name: vnetName
//   location: location
//   properties: {
//     addressSpace: {
//       addressPrefixes: [
//         vnetAddressPrefix
//       ]
//     }
//     subnets: [
//       {
//         name: functionSubnetName
//         properties: {
//           privateEndpointNetworkPolicies: 'Enabled'
//           privateLinkServiceNetworkPolicies: 'Enabled'
//           delegations: [
//             {
//               name: 'webapp'
//               properties: {
//                 serviceName: 'Microsoft.Web/serverFarms'
//               }
//             }
//           ]
//           addressPrefix: functionSubnetAddressPrefix
//         }
//       }
//       {
//         name: privateEndpointSubnetName
//         properties: {
//           privateEndpointNetworkPolicies: 'Disabled'
//           privateLinkServiceNetworkPolicies: 'Enabled'
//           addressPrefix: privateEndpointSubnetAddressPrefix
//         }
//       }
//     ]
//   }
// }

// resource privateStorageFileDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
//   name: privateStorageFileDnsZoneName
//   location: 'global'
// }

// resource privateStorageBlobDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
//   name: privateStorageBlobDnsZoneName
//   location: 'global'
// }

// resource privateStorageQueueDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
//   name: privateStorageQueueDnsZoneName
//   location: 'global'
// }

// resource privateStorageTableDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
//   name: privateStorageTableDnsZoneName
//   location: 'global'
// }

// resource privateKeyVaultDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
//   name: privateKeyVaultDnsZoneName
//   location: 'global'
// }

// resource privateFunctionAppDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
//   name: privateFunctionAppDnsZoneName
//   location: 'global'
// }

// resource privateStorageFileDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
//   parent: privateStorageFileDnsZone
//   name: '${privateStorageFileDnsZoneName}-link'
//   location: 'global'
//   properties: {
//     registrationEnabled: false
//     virtualNetwork: {
//       id: vnet.id
//     }
//   }
// }

// resource privateStorageBlobDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
//   parent: privateStorageBlobDnsZone
//   name: '${privateStorageBlobDnsZoneName}-link'
//   location: 'global'
//   properties: {
//     registrationEnabled: false
//     virtualNetwork: {
//       id: vnet.id
//     }
//   }
// }

// resource privateStorageTableDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
//   parent: privateStorageTableDnsZone
//   name: '${privateStorageTableDnsZoneName}-link'
//   location: 'global'
//   properties: {
//     registrationEnabled: false
//     virtualNetwork: {
//       id: vnet.id
//     }
//   }
// }

// resource privateStorageQueueDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
//   parent: privateStorageQueueDnsZone
//   name: '${privateStorageQueueDnsZoneName}-link'
//   location: 'global'
//   properties: {
//     registrationEnabled: false
//     virtualNetwork: {
//       id: vnet.id
//     }
//   }
// }

// resource privateKeyVaultDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
//   parent: privateKeyVaultDnsZone
//   name: '${privateKeyVaultDnsZoneName}-link'
//   location: 'global'
//   properties: {
//     registrationEnabled: false
//     virtualNetwork: {
//       id: vnet.id
//     }
//   }
// }

// resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
//   parent: privateFunctionAppDnsZone
//   name: '${privateFunctionAppDnsZoneName}-link'
//   location: 'global'
//   properties: {
//     registrationEnabled: false
//     virtualNetwork: {
//       id: vnet.id
//     }
//   }
// }

// resource privateEndpointStorageFilePrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-05-01' = {
//   parent: privateEndpointStorageFile
//   name: 'filePrivateDnsZoneGroup'
//   properties: {
//     privateDnsZoneConfigs: [
//       {
//         name: 'config'
//         properties: {
//           privateDnsZoneId: privateStorageFileDnsZone.id
//         }
//       }
//     ]
//   }
// }

// resource privateEndpointStorageBlobPrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-05-01' = {
//   parent: privateEndpointStorageBlob
//   name: 'blobPrivateDnsZoneGroup'
//   properties: {
//     privateDnsZoneConfigs: [
//       {
//         name: 'config'
//         properties: {
//           privateDnsZoneId: privateStorageBlobDnsZone.id
//         }
//       }
//     ]
//   }
// }

// resource privateEndpointStorageTablePrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-05-01' = {
//   parent: privateEndpointStorageTable
//   name: 'tablePrivateDnsZoneGroup'
//   properties: {
//     privateDnsZoneConfigs: [
//       {
//         name: 'config'
//         properties: {
//           privateDnsZoneId: privateStorageTableDnsZone.id
//         }
//       }
//     ]
//   }
// }

// resource privateEndpointStorageQueuePrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-05-01' = {
//   parent: privateEndpointStorageQueue
//   name: 'queuePrivateDnsZoneGroup'
//   properties: {
//     privateDnsZoneConfigs: [
//       {
//         name: 'config'
//         properties: {
//           privateDnsZoneId: privateStorageQueueDnsZone.id
//         }
//       }
//     ]
//   }
// }

// resource privateEndpointKeyVaultPrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-05-01' = {
//   parent: privateEndpointKeyVault
//   name: 'vaultPrivateDnsZoneGroup'
//   properties: {
//     privateDnsZoneConfigs: [
//       {
//         name: 'config'
//         properties: {
//           privateDnsZoneId: privateKeyVaultDnsZone.id
//         }
//       }
//     ]
//   }
// }

// resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-05-01' = {
//   parent: privateEndpoint
//   name: 'funcPrivateDnsZoneGroup'
//   properties: {
//     privateDnsZoneConfigs: [
//       {
//         name: 'config'
//         properties: {
//           privateDnsZoneId: privateFunctionAppDnsZone.id
//         }
//       }
//     ]
//   }
// }

// resource privateEndpointStorageFile 'Microsoft.Network/privateEndpoints@2022-05-01' = {
//   name: privateEndpointStorageFileName
//   location: location
//   properties: {
//     subnet: {
//       id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, privateEndpointSubnetName)
//     }
//     privateLinkServiceConnections: [
//       {
//         name: 'MyStorageFilePrivateLinkConnection'
//         properties: {
//           privateLinkServiceId: functionStorageAccount.id
//           groupIds: [
//             'file'
//           ]
//         }
//       }
//     ]
//   }
//   dependsOn: [
//     vnet
//   ]
// }

// resource privateEndpointStorageBlob 'Microsoft.Network/privateEndpoints@2022-05-01' = {
//   name: privateEndpointStorageBlobName
//   location: location
//   properties: {
//     subnet: {
//       id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, privateEndpointSubnetName)
//     }
//     privateLinkServiceConnections: [
//       {
//         name: 'MyStorageBlobPrivateLinkConnection'
//         properties: {
//           privateLinkServiceId: functionStorageAccount.id
//           groupIds: [
//             'blob'
//           ]
//         }
//       }
//     ]
//   }
//   dependsOn: [
//     vnet
//   ]
// }

// resource privateEndpointStorageTable 'Microsoft.Network/privateEndpoints@2022-05-01' = {
//   name: privateEndpointStorageTableName
//   location: location
//   properties: {
//     subnet: {
//       id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, privateEndpointSubnetName)
//     }
//     privateLinkServiceConnections: [
//       {
//         name: 'MyStorageTablePrivateLinkConnection'
//         properties: {
//           privateLinkServiceId: functionStorageAccount.id
//           groupIds: [
//             'table'
//           ]
//         }
//       }
//     ]
//   }
//   dependsOn: [
//     vnet
//   ]
// }

// resource privateEndpointStorageQueue 'Microsoft.Network/privateEndpoints@2022-05-01' = {
//   name: privateEndpointStorageQueueName
//   location: location
//   properties: {
//     subnet: {
//       id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, privateEndpointSubnetName)
//     }
//     privateLinkServiceConnections: [
//       {
//         name: 'MyStorageQueuePrivateLinkConnection'
//         properties: {
//           privateLinkServiceId: functionStorageAccount.id
//           groupIds: [
//             'queue'
//           ]
//         }
//       }
//     ]
//   }
//   dependsOn: [
//     vnet
//   ]
// }

// resource privateEndpointKeyVault 'Microsoft.Network/privateEndpoints@2022-05-01' = {
//   name: privateEndpointKeyVaultName
//   location: location
//   properties: {
//     subnet: {
//       id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, privateEndpointSubnetName)
//     }
//     privateLinkServiceConnections: [
//       {
//         name: 'MyKeyVaultPrivateLinkConnection'
//         properties: {
//           privateLinkServiceId: keyVault.id
//           groupIds: [
//             'vault'
//           ]
//         }
//       }
//     ]
//   }
//   dependsOn: [
//     vnet
//   ]
// }

// resource privateEndpoint 'Microsoft.Network/privateEndpoints@2022-05-01' = {
//   name: privateEndpointFunctionAppName
//   location: location
//   properties: {
//     subnet: {
//       id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, privateEndpointSubnetName)
//     }
//     privateLinkServiceConnections: [
//       {
//         name: 'MyFunctionAppPrivateLinkConnection'
//         properties: {
//           privateLinkServiceId: functionApp.id
//           groupIds: [
//             'sites'
//           ]
//         }
//       }
//     ]
//   }
//   dependsOn: [
//     vnet
//   ]
// }

resource functionStorageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: functionStorageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    publicNetworkAccess: 'Enabled'
    allowBlobPublicAccess: false
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
    }
  }
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  scope: functionStorageAccount
  name: '${functionApp.name}RoleAssignment'
  properties: {
    roleDefinitionId: functionAppRoleAssignmentId
    principalId: functionApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource share 'Microsoft.Storage/storageAccounts/fileServices/shares@2022-05-01' = {
  name: '${functionStorageAccountName}/default/${functionContentShareName}'
  dependsOn: [
    functionStorageAccount
  ]
}

resource applicationInsight 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

resource functionAppPlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: functionAppPlanName
  location: location
  sku: {
    tier: 'ElasticPremium'
    name: functionAppPlanSku
    size: functionAppPlanSku
    family: 'EP'
  }
  kind: 'elastic'
  properties: {
    maximumElasticWorkerCount: 20
    reserved: isReserved
  }
}

resource functionApp 'Microsoft.Web/sites@2022-03-01' = {
  name: functionAppName
  location: location
  kind: (isReserved ? 'functionapp,linux' : 'functionapp')
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    reserved: isReserved
    serverFarmId: functionAppPlan.id
    siteConfig: {
      functionsRuntimeScaleMonitoringEnabled: true
      linuxFxVersion: (isReserved ? linuxFxVersion : null)
      appSettings: [
        {
          name: 'ADOPAT'
          value: '@Microsoft.KeyVault(SecretUri=https://${keyVaultName}.vault.azure.net/secrets/ADOPAT/)'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsight.properties.InstrumentationKey
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${functionStorageAccountName};AccountKey=${functionStorageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${functionStorageAccountName};AccountKey=${functionStorageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: functionContentShareName
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: functionWorkerRuntime
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~14'
        }
        {
          name: 'WEBSITE_VNET_ROUTE_ALL'
          value: '1'
        }
        {
          name: 'WEBSITE_CONTENTOVERVNET'
          value: '1'
        }
      ]
    }
  }
  dependsOn: [
    share
    // privateStorageFileDnsZoneLink
    // privateEndpointStorageFilePrivateDnsZoneGroup
    // privateStorageBlobDnsZoneLink
    // privateEndpointStorageBlobPrivateDnsZoneGroup
    // privateStorageTableDnsZoneLink
    // privateEndpointStorageTablePrivateDnsZoneGroup
    // privateStorageQueueDnsZoneLink
    // privateEndpointStorageQueuePrivateDnsZoneGroup
  ]
}

// resource functionAppName_web 'Microsoft.Web/sites/sourcecontrols@2018-11-01' = {
//   parent: functionApp
//   name: 'web'
//   properties: {
//     repoUrl: repoURL
//     branch: branch
//   }
// }

// resource networkConfig 'Microsoft.Web/sites/networkConfig@2022-03-01' = {
//   parent: functionApp
//   name: 'virtualNetwork'
//   properties: {
//     subnetResourceId: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, functionSubnetName)
//     swiftSupported: true
//   }
//   dependsOn: [
//     vnet
//   ]
// }

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    accessPolicies: [
      {
        objectId: functionApp.identity.principalId
        permissions: {
          secrets: [
            'get'
          ]
        }
        tenantId: subscription().tenantId
      }
      {
        objectId: TibiID
        permissions: {
          certificates: [
            'all'
          ]
          keys: [
            'all'
          ]
          secrets: [
            'all'
          ]
        }
        tenantId: subscription().tenantId
      }
    ]
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
    }
    publicNetworkAccess: 'Enabled'
    enabledForTemplateDeployment: true
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId:  subscription().tenantId
  }
}

resource secret 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: keyVault
  name: 'ADOPAT'
  properties: {
    value: 'Titok'
  }
}

resource secret2 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: keyVault
  name: 'TestyTest'
  properties: {
    value: 'Oh! Not my testies!'
  }
}

output outFunctionAppName string = functionAppName
