targetScope = 'subscription'
param resourcePrefix string
param location string
param spId string 
var rgName = '${resourcePrefix}-rg'

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: rgName
  location: location
}

module rgRoleModule '../Bicep/rgRole.bicep' ={
  name: 'rgRoleDeploy'
  scope: rg
  params:{
    spId: spId
  }
  dependsOn: []
}
