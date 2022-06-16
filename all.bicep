/*
  Deploy 1 Hub and 1 spoke
  e.g.: az deployment sub create --location westeurope --template-file .\all.bicep
*/

targetScope = 'subscription'

module hub 'hub.bicep' = {
  name: 'hub'
}

module policy 'policies.bicep' = {
  name: 'policy'
  params: {
    udrFirewallId: hub.outputs.udrFirewallId
  }
}

module spoke 'spoke.bicep' = {
  name: 'spoke'
  dependsOn:[
    hub
  ]
}
