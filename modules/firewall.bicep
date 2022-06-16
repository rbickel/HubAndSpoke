param location string
param zones array
param resourcePrefix string
param subnetId string

resource firewallPublicIp 'Microsoft.Network/publicIPAddresses@2021-08-01' = {
  name: '${resourcePrefix}firewallPublicIp'
  location: location
  zones: zones
  sku:{
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

module firewallPolicy 'firewall-policy.bicep' = {
  name: 'firewallPolicy'
  params:{
    location: location
  }
}

resource firewall 'Microsoft.Network/azureFirewalls@2021-08-01' = {
  name: '${resourcePrefix}firewall'
  location: location
  properties: {  
    ipConfigurations: [
      {
        name: 'firewallIpConfig'
        properties: {
          publicIPAddress: {
            id: firewallPublicIp.id
          }
          subnet: {
            id: subnetId
          }
        }
      }
    ]
    firewallPolicy: {
      id: firewallPolicy.outputs.policyId
    }
    sku:{
      tier: 'Standard'
    }
  }
}

resource udrFirewall 'Microsoft.Network/routeTables@2021-08-01' = {
  name: '${resourcePrefix}udr-firewall'
  location: location
  properties:{
    routes:[
      {
        name: '${resourcePrefix}udr-firewall'
        properties: {
          addressPrefix: '0.0.0.0/32'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: firewall.properties.ipConfigurations[0].properties.privateIPAddress
        }        
      }
    ]
  }
}

output udrFirewallId string = udrFirewall.id
