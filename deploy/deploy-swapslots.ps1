<#
.SYNOPSIS
  Swaps slots for a webapp. Note this requires you to login first into an azure account.
.DESCRIPTION
  Swaps slots for a webapp.
  If you haven't logged into azure account already, execute `Connect-AzAccount` and `Select-AzSubscription -Subscription "XX"'.
  Depending on your account, you might need to use something
  like `Connect-AzAccount -Subscription "XX" -TenantId "1aaaea9d-df3e-4ce7-a55d-43de56e79442"`.
.PARAMETER $WebAppName
  The name of the web application  (e.g. "kmd-momentum-mea-shareddev-functions")
.PARAMETER $ResourceGroupName
  The name of the resource group to deploy to (e.g. "kmd-momentum-mea-shareddev-rg")
.INPUTS
  none
.OUTPUTS
  none
.NOTES
  Version:        1.0
  Author:         Adam Chester
  Creation Date:  22 Nov 2019
  Purpose/Change: Created

.EXAMPLE
  ./deploy-swapslots.ps1 -WebAppName "kmd-momentum-mea-udvdev-webapp" -ResourceGroupName "kmd-momentum-mea-udvdev-rg"

  Swaps the `udvdev` staging slot so it becomes the production slot.
#>
Param(
    [Parameter(Mandatory=$true)]
    [string] $WebAppName,

    [Parameter(Mandatory=$true)]
    [string] $ResourceGroupName,

    [Parameter(Mandatory=$false)]
    [string] $SourceSlotName = "staging",

    [Parameter(Mandatory=$false)]
    [string] $DestinationSlotName = "production"
)

Write-Host "Swapping slots from '$SourceSlotName' to '$DestinationSlotName'"
Switch-AzWebAppSlot -ResourceGroupName $ResourceGroupName -Name $WebAppName -SourceSlotName $SourceSlotName -DestinationSlotName $DestinationSlotName
