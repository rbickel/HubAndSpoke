param location string

resource policy 'Microsoft.Network/firewallPolicies@2021-08-01' = {
  name: 'main-firewall-policy'
  location: location
}

resource ruleCollection 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2021-08-01' = {
  name: 'main-rule-collection'
  parent: policy
  properties: {
    priority: 100
    ruleCollections: [
      {
        name: 'app-rule-collection'
        priority: 1000
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules:[
          {
            name: ' AKS'
            ruleType: 'ApplicationRule'
            fqdnTags: [
              'AzureKubernetesService'
            ]
            protocols:[
                {
                    protocolType: 'Http'
                    port: 80
                }
                {
                    protocolType: 'Https'
                    port: 443
                }
            ]
            sourceAddresses:['*']
          }
        ]
      }
    ]
  }
}

output policyId string = policy.id
