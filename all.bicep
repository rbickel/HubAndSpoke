/*
  Deploy 1 Hub and 1 spoke
  e.g.: az deployment sub create --location westeurope --template-file .\all.bicep
*/

targetScope = 'subscription'
param location string = 'westeurope'

module hub 'hub.bicep' = {
  name: 'hub'
  params: {
    location: location
  }   
}

module policy 'policies.bicep' = {
  name: 'policy'
  params: {
    udrFirewallId: hub.outputs.udrFirewallId
    location: location
  }
}

module spoke 'spoke.bicep' = {
  name: 'spoke'
  params: {
    location: location
  }  
  dependsOn:[
    hub
  ]
}
