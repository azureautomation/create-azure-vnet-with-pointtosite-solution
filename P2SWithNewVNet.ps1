##Script Parameters##
#Resource Group Name
$RGName = <ResourceGroup Name>;
#Azure Region
$Location = <Azure Location>;
#Azure VNET Name
$VNetName = <VNet Name>;
#VNet Address Space
$VNetAddress = <VNET Address Space>;
#First Subnet Name
$SubnetName01 = <Subnet Name>;
#First Subnet Range
$SubnetRange01 = <Subnet Range>;
#Gateway Subnet Name – 'GatewaySubnet' is mandatory for the gateway to work (please do not change this name)
$SubnetGWName = "GatewaySubnet"
#Gateway Subnet Range
$SubnetGWRange = <Gateway Range>;
#Root Cert Name
$RootCertName = <RootCert Name>;
#Key of Root Self-Sigend Certficate Base64 format
$RootCertKey = <RootCert Key Base64>;
#Gateway Name
$GatewayName = <Gateway Name>;
#Gateway PublicIP Name
$GatewayPIPName = <Gateway Pubic IP Name>;
#VPN Client Pool Range (Point-To-Site Pool)
$VPNClientPool = <VPN Client Pool Range>;


##MAIN##
#Create ResourceGroup
New-AzureRmResourceGroup -Name:$RGName -Location:$Location;

#Create VNET
$Subnet01 = New-AzureRmVirtualNetworkSubnetConfig -Name $SubnetName01 -AddressPrefix $SubnetRange01;
$SubnetGW = New-AzureRmVirtualNetworkSubnetConfig -Name $SubnetGWName -AddressPrefix $SubnetGWRange;
New-AzureRmVirtualNetwork -Name:$VNetName -AddressPrefix:$VNetAddress -Subnet $Subnet01, $SubnetGW -ResourceGroupName:$RGName -Location:$Location;

#Create Azure VPN Root Cert "Upload the Root Cert"
$AZRRootCert = New-AzureRmVpnClientRootCertificate -Name:$RootCertName -PublicCertData:$RootCertKey;

#Get VNET Configuration
$VNet = Get-AzureRmVirtualNetwork -Name:$VNetName -ResourceGroupName:$RGName;
#Get Gateway Subnet VNET Configuration
$SubnetGateway = Get-AzureRmVirtualNetworkSubnetConfig -Name "GatewaySubnet" -VirtualNetwork:$VNET;

#Create Public IP
$PublicIP = New-AzureRmPublicIpAddress -Name $GatewayPIPName -AllocationMethod:"Dynamic" -ResourceGroupName:$RGName -Location:$Location;
#Create Gateway Configuration
$GatewayConf = New-AzureRmVirtualNetworkGatewayIpConfig -Name:"GWConf" -Subnet:$SubnetGateway -PublicIpAddress:$PublicIP;

#Create Gateway using Gateway Configuration and Point-To-Site Configuration
New-AzureRmVirtualNetworkGateway -Name:$GatewayName -IpConfigurations:$GatewayConf -GatewayType:Vpn -VpnType:RouteBased -EnableBgp:$false -GatewaySku:Standard -VpnClientAddressPool:$VPNClientPool -VpnClientRootCertificates:$AZRRootCert -ResourceGroupName:$RGName -Location:$Location;

#Get Azure VPN Client Package
Get-AzureRmVpnClientPackage -ResourceGroupName -VirtualNetworkGatewayName:$GatewayName -ProcessorArchitecture:"Amd64" -ResourceGroupName:$RGName