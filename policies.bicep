targetScope = 'subscription'

param udrFirewallId string

var policyName = 'enforce-traffic-through-firewall'
var policyDisplayName = 'Enforce internet traffic through Azure Firewall'
var policyDescription = 'Adds a subnet UDR to enforce internet traffic through Azure Firewall'

resource policy 'Microsoft.Authorization/policyDefinitions@2020-09-01' = {
  name: policyName
  properties: {
    displayName: policyDisplayName
    description: policyDescription
    policyType: 'Custom'
    mode: 'Indexed'
    metadata: {
      category: 'Networking'
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
        ]
      }
    }

    policyRule: {
      if: {
        allOf: [
          {
            equals: 'Microsoft.Network/virtualNetworks/subnets'
            field: 'type'
          }
          {
            field: 'name'
            notIn: '[parameters(\'excludedSubnets\')]'
          }
          {
            not: {
              anyOf: [
                {
                  equals: '[parameters(\'routeId\')]'
                  field: 'Microsoft.Network/virtualNetworks/subnets/routeTable.id'
                }
              ]
            }
          }
        ]
      }
      then: {
        effect: 'Modify'
        details: {
          roleDefinitionIds: [
            '/providers/Microsoft.Authorization/roleDefinitions/4d97b98b-1d4f-4787-a291-c67834d212e7'
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
