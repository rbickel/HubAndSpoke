/*
  Deploy 1 hub environment
  e.g.: az deployment sub create --location westeurope --template-file .\hub.bicep
*/
targetScope = 'subscription'

param location string = 'westeurope'
param zones array = ['1','2','3']
param hubVNetResourceGroup string = 'hub'
param prefix string = ''

resource hubResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  location: location
  name: hubVNetResourceGroup
}

module hub 'modules/hub-vnet.bicep' = {
  name: 'hub'
  scope: hubResourceGroup
  params:{
    zones: zones
    location: location
    prefix: prefix
  }
}

output udrFirewallId string = hub.outputs.udrFirewallId
