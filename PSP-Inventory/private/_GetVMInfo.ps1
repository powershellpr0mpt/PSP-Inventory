function _GetVMInfo {
    [cmdletbinding()]
    Param(
        [System.Management.Automation.Runspaces.PSSession]$PSSession
    )
    Write-Verbose "[$($PSSession.ComputerName)] - Gathering VM information"
    $VMInfo = Invoke-Command -Session $PSSession -ScriptBlock {
        $HVService = Get-Service -DisplayName '*Hyper-V*' | Where-Object {$_.Status -eq 'Running'}
        $HVProperties = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Virtual Machine\Guest\Parameters' -Name VirtualMachineName, PhysicalHostNameFullyQualified
        $VMService = Get-Service -Name VMTools -ErrorAction SilentlyContinue
        [PSCustomObject]@{
            HVIntegrationServicesRunning = if ($HVService) {$true}else {$false}
            HVHostName                   = if ($HVProperties) {$HVProperties.PhysicalHostNameFullyQualified}else {$null}
            HVVMName                     = if ($HVProperties) {$HVProperties.VirtualMachineName}else {$null}
            VMWareToolsRunning           = if ($VMService) {$true}else {$false}
        }
    }
    [PSCustomObject]@{
        PSTypeName                   = 'PSP.Inventory.VMInfo'
        ComputerName                 = $PSSession.ComputerName
        HVIntegrationServicesRunning = $VMInfo.HVIntegrationServicesRunning
        HVHostName                   = $VMInfo.HVHostName
        HVVMName                     = $VMInfo.HVVMName
        VMWareToolsRunning           = $VMInfo.VMWareToolsRunning
        InventoryDate                = (Get-Date)
    }
}