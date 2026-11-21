# Get-VMStatus.ps1
# Lists Azure VMs in the current subscription with their power state and size,
# so you can check what is running before you get charged.
# Built for the Azure portfolio lab (WinVM-01 in AlvinLab-RG, East US 2).
#
# Requires: Az PowerShell module (Install-Module Az)
# Run:      Connect-AzAccount
#           .\Get-VMStatus.ps1
#           .\Get-VMStatus.ps1 -ResourceGroupName "AlvinLab-RG"   (one resource group only)
#
# Output: a table of VM name, resource group, location, size, and power state.
# A VM that is "VM deallocated" costs nothing for compute; "VM running" is billed.

param(
    [string]$ResourceGroupName
)

if ($ResourceGroupName) {
    $vms = Get-AzVM -ResourceGroupName $ResourceGroupName -Status
} else {
    $vms = Get-AzVM -Status
}

if (-not $vms) {
    Write-Host "No VMs found in this subscription."
    return
}

$rows = foreach ($vm in $vms) {
    [PSCustomObject]@{
        Name          = $vm.Name
        ResourceGroup = $vm.ResourceGroupName
        Location      = $vm.Location
        Size          = $vm.HardwareProfile.VmSize
        PowerState    = $vm.PowerState
    }
}

$rows | Format-Table -AutoSize

$running = @($rows | Where-Object { $_.PowerState -eq "VM running" }).Count
$stopped = @($rows | Where-Object { $_.PowerState -ne "VM running" }).Count
Write-Host ""
Write-Host "Total: $($rows.Count) VM(s) - $running running, $stopped stopped/deallocated."
if ($running -gt 0) {
    Write-Host "Note: running VMs bill compute from the Azure free credit. Stop (deallocate) any VM you are not using."
}
