
param location string = 'westeurope'
param spokeNumber int = 1
param prefix string = ''
param hubVNetName string = 'hub'
param hubVNetResourceGroup string = 'hub'

var spokeVNetName = '${resourcePrefix}spoke-${spokeNumber}'
var resourcePrefix = empty(prefix) ? '' : '${prefix}-'
var addressPrefix = '10.${spokeNumber}'
var addressRange = '${addressPrefix}.0.0/16'

resource firewall 'Microsoft.Network/azureFirewalls@2021-03-01' existing = {
  name: '${resourcePrefix}firewall'
  scope: resourceGroup(hubVNetResourceGroup)
}

resource webInboudNsg 'Microsoft.Network/networkSecurityGroups@2021-03-01' = {
  name: '${resourcePrefix}webInboudNsg'
  location: location
  properties: {
    securityRules: [
    ]
  }
}

resource spoke 'Microsoft.Network/virtualNetworks@2021-03-01' = {
  name: spokeVNetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressRange
      ]
    }
    subnets:[
      {
        name: 'AKSSubnet'
        properties: {
          addressPrefix: '${addressPrefix}.0.0/17'
          networkSecurityGroup: {
            id: webInboudNsg.id
          }
        }
      }      
    ]
  }
}

resource hub 'Microsoft.Network/virtualNetworks@2021-08-01' existing = {
  name: hubVNetName
  scope: resourceGroup(hubVNetResourceGroup)
}

output spokeVNetId string = spoke.id
output spokeVNetName string = spokeVNetName
