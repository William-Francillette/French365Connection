//param resourcePrefix string
param spId string
var contributor = resourceId('microsoft.authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')

resource rgAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: resourceGroup()
  name: guid(resourceGroup().name)
  properties: {
    roleDefinitionId: contributor
    principalId: spId
    principalType: 'ServicePrincipal'
  }
}
