//Input parameters
param spId string
@minLength(1)
@maxLength(21)
param resourcePrefix string

@description('Username for the Virtual Machine.')
param adminUsername string

@description('Password for the Virtual Machine.')
@secure()
param adminPassword string 

@description('Location for all resources.')
param location string = resourceGroup().location

//Compute parameters
@description('The Windows version for the VM. This will pick a fully patched image of this given Windows version.')
@allowed([
  '2016-datacenter-gensecond'
  '2016-datacenter-server-core-g2'
  '2016-datacenter-server-core-smalldisk-g2'
  '2016-datacenter-smalldisk-g2'
  '2016-datacenter-with-containers-g2'
  '2016-datacenter-zhcn-g2'
  '2019-datacenter-core-g2'
  '2019-datacenter-core-smalldisk-g2'
  '2019-datacenter-core-with-containers-g2'
  '2019-datacenter-core-with-containers-smalldisk-g2'
  '2019-datacenter-gensecond'
  '2019-datacenter-smalldisk-g2'
  '2019-datacenter-with-containers-g2'
  '2019-datacenter-with-containers-smalldisk-g2'
  '2019-datacenter-zhcn-g2'
  '2022-datacenter-azure-edition'
  '2022-datacenter-azure-edition-core'
  '2022-datacenter-azure-edition-core-smalldisk'
  '2022-datacenter-azure-edition-smalldisk'
  '2022-datacenter-core-g2'
  '2022-datacenter-core-smalldisk-g2'
  '2022-datacenter-g2'
  '2022-datacenter-smalldisk-g2'
])
param OSVersion string = '2022-datacenter-azure-edition'

@description('Size of the virtual machine.')
param vmSize string = 'Standard_D2s_v5'

@description('Name of the virtual machine.')
param vmName string = '${resourcePrefix}-vm'

@description('Security Type of the Virtual Machine.')
@allowed([
  'Standard'
  'TrustedLaunch'
])
param securityType string = 'TrustedLaunch'
var securityProfileJson = {
  uefiSettings: {
    secureBootEnabled: true
    vTpmEnabled: true
  }
  securityType: securityType
}

// Networking parameters
var nicName = '${resourcePrefix}-nic'
var addressPrefix = '10.0.0.0/16'
var subnetName = '${resourcePrefix}-subnet'
var subnetPrefix = '10.0.0.0/24'
var virtualNetworkName = '${resourcePrefix}-vnet'
var networkSecurityGroupName = '${resourcePrefix}-nsg'

//VM extensions parameters
var extensionName = 'GuestAttestation'
var extensionPublisher = 'Microsoft.Azure.Security.WindowsAttestation'
var extensionVersion = '1.0'
var maaTenantName = 'GuestAttestation'
var maaEndpoint = substring('emptyString', 0, 0)


//Networking
resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2022-05-01' = {
  name: networkSecurityGroupName
  location: location
  properties: {
    securityRules: [
      {
        name: 'WinRM'
        properties : {
            protocol : 'Tcp' 
            sourcePortRange :  '*'
            destinationPortRange :  '5986'
            sourceAddressPrefix :  'AzureCloud.${location}'
            destinationAddressPrefix: '*'
            access:  'Allow'
            priority : 101
            direction : 'Inbound'
            sourcePortRanges : []
            destinationPortRanges : []
            sourceAddressPrefixes : []
            destinationAddressPrefixes : []
        }
      }
    ]
  }
  dependsOn: [ ]
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-05-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetPrefix
          networkSecurityGroup: {
            id: networkSecurityGroup.id
          }
        }
      }
    ]
  }
  dependsOn: []
}
resource sa 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: '${resourcePrefix}sa'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2' 
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    encryption: {
      keySource: 'Microsoft.Storage'
      services: {
        blob: {
          enabled: true
          keyType: 'Account'
        }
        file: {
          enabled: true
          keyType: 'Account'
        }
      }
    }
    minimumTlsVersion: 'TLS1_2'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
      ipRules: []
    }
    supportsHttpsTrafficOnly: true
  }
  dependsOn: []
}

resource publicIP 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: '${resourcePrefix}-publicip'
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    publicIPAddressVersion: 'IPv4'
    idleTimeoutInMinutes: 4
  }
  sku: {
    name: 'Basic'
  }
  dependsOn: []
}
resource nic 'Microsoft.Network/networkInterfaces@2022-05-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: '${resourcePrefix}-ipconfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnetName)
          }
          publicIPAddress: {
            id: publicIP.id
          }
        }
      }
        
    ]
  }
  dependsOn: [
    virtualNetwork
  ]
}


//Compute
resource vm 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: vmName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${resourceId('F365C','Microsoft.ManagedIdentity/userAssignedIdentities','${resourcePrefix}-mi')}':{}
    }
  }
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: OSVersion
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        deleteOption: 'Delete'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }

    securityProfile: ((securityType == 'TrustedLaunch') ? securityProfileJson : null)
  }
  dependsOn: []
}

//Extensions
resource vmExtension 'Microsoft.Compute/virtualMachines/extensions@2022-03-01' = if ((securityType == 'TrustedLaunch') && ((securityProfileJson.uefiSettings.secureBootEnabled == true) && (securityProfileJson.uefiSettings.vTpmEnabled == true))) {
  parent: vm
  name: extensionName
  location: location
  properties: {
    publisher: extensionPublisher
    type: extensionName
    typeHandlerVersion: extensionVersion
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
    settings: {
      AttestationConfig: {
        MaaSettings: {
          maaEndpoint: maaEndpoint
          maaTenantName: maaTenantName
        }
      }
    }
  }
  dependsOn: []
}

//AMA agent extension
resource windowsAgent 'Microsoft.Compute/virtualMachines/extensions@2021-11-01' = {
  parent: vm
  name: 'AzureMonitorWindowsAgent'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Monitor'
    type: 'AzureMonitorWindowsAgent'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
  }
  dependsOn: []
}

//Log Analytics Workspace retrieval
param workspaceName string = 'F365C-Sentinel' 
param workspaceRG string = 'F365C' 

// AMA Data Collection Rule configuration
resource CADCR 'Microsoft.Insights/dataCollectionRules@2022-06-01' = {
  name: '${resourcePrefix}-dcr'
  location: location
  kind: 'Windows'
  properties: {
    dataSources: {
      windowsEventLogs: [
        {
          streams: [
              'Microsoft-Event'
          ]
          xPathQueries: [
              'M365DSC!*[System[(Level=3) and (EventID=1)]]'
          ]
          name: 'eventLogsDataSource'
        }
      ]
    }
    description: 'DCR'
    destinations: {
      logAnalytics: [
        {
          name: workspaceName
          workspaceResourceId: resourceId(workspaceRG,'Microsoft.OperationalInsights/workspaces',workspaceName)
        }
      ]
    }
    dataFlows: [
      {
        destinations: [
          workspaceName
        ]
        outputStream: 'Microsoft-Event'
        streams: [
          'Microsoft-Event'
        ]
        transformKql: 'source'
      }
    ]
  }
  dependsOn: []
}

resource association 'Microsoft.Insights/dataCollectionRuleAssociations@2022-06-01' = {
  name: '${resourcePrefix}-dcra'
  scope: vm
  properties: {
    description: 'Association of data collection rule. Deleting this association will break the data collection for this virtual machine.'
    dataCollectionRuleId: CADCR.id
  }
  dependsOn: []
}
var blobcontributor = resourceId('microsoft.authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')
var roleAssignmentName = guid(resourceGroup().id,blobcontributor,spId)
resource saAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: sa
  name: roleAssignmentName
  properties: {
    roleDefinitionId: blobcontributor
    principalId: spId
    principalType: 'ServicePrincipal'
  }
  dependsOn: []
}


