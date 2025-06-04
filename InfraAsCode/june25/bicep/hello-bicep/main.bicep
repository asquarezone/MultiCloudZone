param network object = {
  addressSpace: '10.0.0.0/16'
  subnets: [{
    name: 'web'
    addressSpace: '10.0.0.0/24'
  }
  {
    name: 'db'
    addressSpace: '10.0.1.0/24'
  }
  ]
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: 'ntier'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        network.addressSpace
      ]
    }
    subnets: [
      {
        name: network.subnets[0].name
        properties: {
          addressPrefix: network.subnets[0].addressSpace
        }
      }
      {
        name: network.subnets[1].name
        properties: {
          addressPrefix: network.subnets[1].addressSpace
        }
      }
    ]
  }
}


resource webNsg 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: 'webnsg'
  location: resourceGroup().location
  properties: {
    securityRules: [
      {
        name: 'openalltcp'
        properties: {
          description: 'description'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 1000
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2019-11-01' = {
  name: 'web'
  location: resourceGroup().location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}


resource networkInterface 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: 'webnic'
  location: resourceGroup().location
  properties: {
    ipConfigurations: [
      {
        name: 'test'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', 'ntier', 'web')
          }
          publicIPAddress: {
            id: publicIPAddress.id
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: webNsg.id
    }
  }
}


