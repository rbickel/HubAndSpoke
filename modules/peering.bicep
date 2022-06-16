param sourceVNetName string
param destinationVNetName string
param destinationVNetId string

resource peering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-03-01' = {
  name: '${sourceVNetName}/${sourceVNetName}-${destinationVNetName}'
  properties:{
    remoteVirtualNetwork: {
      id: destinationVNetId
    }
    allowForwardedTraffic: true
  }
}
