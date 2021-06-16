$RgName = 'Web-RG'

Get-AzContext

# Login-AzAccount -Credential ...

Add-AzAccount -Identity

New-AzRouteTable -Name Table1 -ResourceGroupName $RgName -Location westeurope 
