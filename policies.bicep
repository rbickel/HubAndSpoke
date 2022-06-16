targetScope = 'subscription'

param udrFirewallId string
param location string = 'westeurope'

var policyName = 'enforce-traffic-through-firewall'
var policyDisplayName = 'Enforce internet traffic through Azure Firewall'
var policyDescription = 'Adds a subnet UDR to enforce internet traffic through Azure Firewall'
var roleDefinitionId =  '/providers/Microsoft.Authorization/roleDefinitions/4d97b98b-1d4f-4787-a291-c67834d212e7'

resource policy 'Microsoft.Authorization/policyDefinitions@2020-09-01' = {
  name: policyName
  properties: {
    displayName: policyDisplayName
    description: policyDescription
    policyType: 'Custom'
    mode: 'All'
    metadata: {
      category: 'Network'
    }
    parameters: {
      routeId: {
        type: 'String'
        defaultValue: udrFirewallId
      }
      excludedSubnets: {
        type: 'Array'
        'defaultValue': [
          'AzureBastionSubnet'
          'AzureFirewallSubnet'
          'GatewaySubnet'
        ]
      }
    }

    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.Network/virtualNetworks/subnets'
          }
          {
            field: 'name'
            notIn: '[parameters(\'excludedSubnets\')]'
          }
          {
            anyOf: [
              {
                field: 'Microsoft.Network/virtualNetworks/subnets/routeTable'
                exists: 'false'
              }
              {
                field: 'Microsoft.Network/virtualNetworks/subnets/routeTable.id'
                notEquals: '[parameters(\'routeId\')]'
              }
            ]
          }
        ]
      }
      then: {
        effect: 'Modify'
        details: {
          roleDefinitionIds: [
            roleDefinitionId
          ]
          operations: [
            {
              operation: 'addOrReplace'
              field: 'Microsoft.Network/virtualNetworks/subnets/routeTable.id'
              value: '[parameters(\'routeId\')]'
            }
          ]
        }
      }
    }
  }
}

resource assignment 'Microsoft.Authorization/policyAssignments@2020-09-01' = {
  name: policyName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    displayName: policyDisplayName
    policyDefinitionId: policy.id
  }
}

resource systemIdentityPermissions 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: guid(policyName)
  properties:{
    principalId: assignment.identity.principalId
    roleDefinitionId: roleDefinitionId
  }
}
