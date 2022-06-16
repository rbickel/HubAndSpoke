/*
  Deploy 1 spoke environment
  e.g.: az deployment sub create --location westeurope --template-file .\spoke.bicep
*/
targetScope = 'subscription'

param prefix string = ''
param location string = 'westeurope'
param zones array = ['1','2','3']
param spokeNumber int = 1
param hubVNetName string = 'hub'
param hubVNetResourceGroup string = 'hub'

var spokeVNetResourceGroup = 'spoke-${spokeNumber}'

resource spokeResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  location: location
  name: spokeVNetResourceGroup
}

module spoke 'modules/spoke-vnet.bicep' = {
  name: 'spoke-${spokeNumber}'
  scope: spokeResourceGroup
  params:{
    location: location
    spokeNumber: spokeNumber
    hubVNetName: hubVNetName
    hubVNetResourceGroup: hubVNetResourceGroup
    prefix: prefix
  }
}

module peeringhub 'modules/peering.bicep' = {
  name: 'peering-${hubVNetName}-spoke${spokeNumber}'
  scope: resourceGroup(hubVNetResourceGroup)
  params:{
    sourceVNetName: hubVNetName
    destinationVNetName: spoke.outputs.spokeVNetName
    destinationVNetId: spoke.outputs.spokeVNetId
  }
}

module peeringspoke 'modules/peering.bicep' = {
  name: 'peering-spoke${spokeNumber}-${hubVNetName}'
  scope: spokeResourceGroup
  params:{
    sourceVNetName: spoke.outputs.spokeVNetName
    destinationVNetName: hubVNetName
    destinationVNetId: resourceId(subscription().subscriptionId, hubVNetResourceGroup, 'Microsoft.Network/virtualNetworks', hubVNetName)
  }
}
