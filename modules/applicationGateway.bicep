param subnetId string
param privateIpAddress string
param location string
param resourcePrefix string
param zones array

var applicationGatewayName = '${resourcePrefix}applicationGateway'

resource applicationGatewayPublicIp 'Microsoft.Network/publicIPAddresses@2021-08-01' = {
  name : '${resourcePrefix}applicationGatewayPublicIp'
  location : location
  zones: zones
  sku:{
    name: 'Standard'
    tier: 'Regional'
  }  
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource applicationGatewayIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2021-09-30-preview' = {
  name: '${resourcePrefix}applicationGatewayIdentity'
  location: location
}

resource applicationGateway 'Microsoft.Network/applicationGateways@2021-08-01' = {
  name: applicationGatewayName
  zones: zones
  location: location
  identity:{
    type:'UserAssigned'
    userAssignedIdentities:{
      '${applicationGatewayIdentity.id}': {}
    }
  }  
  properties: {
    sku: {
      name: 'Standard_v2'
      tier: 'Standard_v2'
    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        properties: {
          subnet: {
            id: subnetId
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'appGwPublicFrontendIp'
        properties: {
          publicIPAddress: {
            id: applicationGatewayPublicIp.id
          }
        }
      }
      {
        name: 'appGwPrivateFrontendIp'
        properties: {
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: subnetId
          }
          privateIPAddress: privateIpAddress
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port_80'
        properties: {
          port: 80
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'empty_backend_pool'
        properties: {}
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'http_80_settings'
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: false
          requestTimeout: 20
        }
      }
    ]
    httpListeners: [
      {
        name: 'http_80_listener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, 'appGwPublicFrontendIp')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, 'port_80')
          }
          protocol: 'Http'
          requireServerNameIndication: false
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'default_rule'
        properties: {
          priority: 20000
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, 'http_80_listener')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, 'empty_backend_pool')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, 'http_80_settings')
          }
        }
      }
    ]
    enableHttp2: false
    autoscaleConfiguration: {
      minCapacity: 0
      maxCapacity: 10
    }
  }
}
