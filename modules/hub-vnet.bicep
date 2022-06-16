param location string
param zones array
param prefix string

var resourcePrefix = empty(prefix) ? '' : '${prefix}-'

resource webInboudNsg 'Microsoft.Network/networkSecurityGroups@2021-03-01' = {
  name: '${resourcePrefix}webInboudNsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'webInboudNsgRule80'
        properties: {
          description: 'Allow inbound traffic from the web'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '10.0.2.0/24'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'webInboudNsgRule443'
        properties: {
          description: 'Allow inbound traffic from the web (https)'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '10.0.2.0/24'
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
        }
      }
      {
        name: 'applicationGatewayManagementPort'
        properties: {
          description: 'Management port for application gateway'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'Internet'
          destinationPortRange: '65200-65535'
          destinationAddressPrefix: '10.0.2.0/24'
          access: 'Allow'
          priority: 120
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource hub 'Microsoft.Network/virtualNetworks@2021-03-01' = {
  name: '${resourcePrefix}hub'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets:[
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }      
      {
        name: 'ApplicationGatewaySubnet'
        properties: {
          addressPrefix: '10.0.2.0/24'
          // networkSecurityGroup: {
          //   id: webInboudNsg.id
          // }
        }
      }
    ]
  }
}

module firewall 'firewall.bicep' = {
  name: '${resourcePrefix}firewall'
  dependsOn: [
    hub
  ]
  params: {
    subnetId: resourceId('Microsoft.Network/virtualnetworks/subnets', '${resourcePrefix}hub', 'AzureFirewallSubnet')
    resourcePrefix: resourcePrefix
    location: location
    zones: zones
  }
}

module applicationGateway 'applicationGateway.bicep' = {
  name: '${resourcePrefix}applicationGateway'
  dependsOn: [
    hub
  ]  
  params: {
    resourcePrefix: resourcePrefix
    privateIpAddress: '10.0.2.5'
    location: location
    zones: zones
    subnetId: resourceId('Microsoft.Network/virtualnetworks/subnets', '${resourcePrefix}hub', 'ApplicationGatewaySubnet')
  }
}

output udrFirewallId string = firewall.outputs.udrFirewallId
