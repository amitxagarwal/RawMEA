<#
.SYNOPSIS
  Deploys the child webjobs/project binaries into azure app service for Momentum External API. Note this script
  requires you to login first into azure account.
.DESCRIPTION
  Deploys the web application binaries into azure app service. If you haven't logged into azure account already,
  execute `Connect-AzAccount` and `Select-AzSubscription -Subscription "XXX"'. Depending on your account,
  you might need to use something like `Connect-AzAccount -Subscription "XXX" -TenantId "1aaaea9d-df3e-4ce7-a55d-43de56e79442"`.
.PARAMETER $PublishedArtifactsPath
  The path of zip package to publish (e.g. "./PublishedArtifacts")
.PARAMETER $WebAppName
  The name of the web application  (e.g. "kmd-momentum-mea-shareddev-webapp")
.PARAMETER $ResourceGroupName
  The name of the resource group to deploy to (e.g. "kmd-momentum-mea-shareddev-rg")
.PARAMETER $AutoSwapSlots
  If set, the deployed "staging" slot will be swapped to become the "production" slot via `deploy-swapslots.ps1`.
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
  ./deploy-webapps.ps1 -PublishedArtifactsPath ../artifacts -WebAppName kmd-momentum-mea-udvdev-webapp -ResourceGroupName kmd-momentum-mea-udvdev-rg -AutoSwapSlots

  Deploys functions to the `udvdev` environment staging slot from the (relative) artifacts folder and automatically swaps staging to the production slot.
#>
Param(
    [Parameter(Mandatory=$true)]
    [string] $PublishedArtifactsPath,

    [Parameter(Mandatory=$true)]
    [string] $WebAppName,

    [Parameter(Mandatory=$true)]
    [string] $ResourceGroupName,

    [Parameter(Mandatory=$false)]
    [Switch] $AutoSwapSlots = $false
)

$ErrorActionPreference = "Stop"

$artifactFileName = "Kmd.Momentum.Mea.Api.zip"
$artifactFilePath = "$PublishedArtifactsPath/$artifactFileName"
$resolvedArtifactFilePath = Resolve-Path -Path "$artifactFilePath"
$SlotName = "staging"

Write-Host "Puslishing the archive from '$resolvedArtifactFilePath' to the slot '$SlotName'"

Publish-AzWebapp -Force -Slot $SlotName -ResourceGroupName $ResourceGroupName -Name $WebAppName -ArchivePath $resolvedArtifactFilePath

Write-Host "The web app is at https://$WebAppName-$SlotName.azurewebsites.net/ and SCM is at https://$WebAppName-$SlotName.scm.azurewebsites.net/"

# Verify the newly deployed function is responding
Write-Host "Displaying the last sucessful deployment for $ResourceGroupName"
$lastDeployment = Get-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName | Where-Object {$_.ProvisioningState -eq "Succeeded"} | Sort-Object Timestamp -Descending | Select-Object -First 1
$lastDeployment

$readinessUri = "https://$WebAppName-$SlotName.azurewebsites.net/health/ready"
Write-Host "Checking for a 200 response from $readinessUri"

try {
    Invoke-WebRequest -Uri $readinessUri
} catch {
    $statusCode = $_.Exception.Response.StatusCode
    Write-Host "The response was not 200, it was $statusCode"
    $_
    $_.Exception.Response
    $_.Exception.Response.RawContent
    $_.Exception.Response.Headers
    exit -1
}

if ($AutoSwapSlots) {
    Write-Host "Auto-swapping slots..."
    ./deploy-swapslots.ps1 -ResourceGroupName $ResourceGroupName -WebAppName $WebAppName
}
