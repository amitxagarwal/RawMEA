<#
.SYNOPSIS
  Deploys the Azure resources for Momentum External API. This requires you to login to Azure first.
.DESCRIPTION
  Deploys the Azure resources for invoicing. If you haven't already logged in, execute `Connect-AzAccount`
  and `Select-AzSubscription -Subscription "LoGIC DEV"'. Depending on your account, you might need to use something
  like `Connect-AzAccount -Subscription "LoGIC DEV" -TenantId "1aaaea9d-df3e-4ce7-a55d-43de56e79442"`.
.PARAMETER $MarkForAutoDelete
  When $true, the resource group will be tagged for auto-deletion. Useful for temporary personal or phoenix environments.
.PARAMETER $InstanceId
  The unique instance identifier (e.g. "shareddev" or "udvdev" or "prod") which will be used to name the azure resources.
.PARAMETER $ResourceGroupLocation
  The azure location of the created resource group (e.g. "australiaeast" or "centralindia" or "westeurope").
.PARAMETER $ApplicationInsightsName
  The name of the application insights instance. E.g. 'kmd-momentum-mea-shareddev-ai' or 'kmd-momentum-mea-shareddev-ai'.
.PARAMETER $DiagnosticSeqServerUrl
  The url of diagnostics seq instance (e.g. "https://myseq.kmdlogic.io/") which will help in diagnosing.
.PARAMETER $DiagnosticSeqApiKey
  Optional. An api key for diagnostics seq if required.
.PARAMETER $WebAppServicePlanSku
  Optional. F1,FREE,D1,SHARED,B1,B2,B3,S1,S2,S3,P1V2,P2V2,P3V2,PC2,PC3,PC4,I1,I2,I3
.PARAMETER $WebAppConfigAlwaysOn
  Optional. If set to $true, the web site will be 'always on' - this does not work with certain plans like D1 Shared
.INPUTS
  none
.OUTPUTS
  none
.NOTES
  Version:        1.0
  Author:         Adam Chester
  Creation Date:  22 Nov 2019
  Purpose/Change: Deploy sts bridge azure infrastructure.

.EXAMPLE
  ./deploy-infrastructure.ps1 -InstanceId udvdev -DiagnosticSeqServerUrl "https://xxx.kmdlogic.io/" -DiagnosticSeqApiKey "xxx" -MarkForAutoDelete -ResourceGroupLocation "australiaeast" -ApplicationInsightsName "kmd-momentum-mea-udvdev-ai" -ApplicationInsightsResourceGroup "kmd-momentum-mea-udvdev-rg" -WebAppServicePlanSku P1V2 -WebAppConfigAlwaysOn $true -AuditEventHubsConnectionString "xxx"

  Deploys a personal environment for 'udvdev', which is marked for auto-deletion, and uses a personal Seq and application insights.
#>
Param
(
  [Parameter(Mandatory=$false)]
  [switch]
  $MarkForAutoDelete = $false,

  [Parameter(Mandatory=$true)]
  [string]
  $InstanceId,

  [Parameter(Mandatory=$false)]
  [string]
  $ResourceGroupLocation = "westeurope",

  [Parameter(Mandatory=$true)]
  [string]
  $ApplicationInsightsName,

  [Parameter(Mandatory=$true)]
  [string]
  $ApplicationInsightsResourceGroup,

  [Parameter(Mandatory=$true)]
  [string]
  $DiagnosticSeqServerUrl,

  [Parameter(Mandatory=$true)]
  [string]
  $DiagnosticSeqApiKey,

  [Parameter(Mandatory=$false)]
  [string]
  [ValidateSet("F1","FREE","D1","SHARED","B1","B2","B3","S1","S2","S3","P1V2","P2V2","P3V2","PC2","PC3","PC4","I1","I2","I3")]
  $WebAppServicePlanSku = "F1",

  [Parameter(Mandatory=$false)]
  [bool]
  $WebAppConfigAlwaysOn = $false,

  [switch] 
  $ValidateOnly
)

Push-Location $PSScriptRoot
Write-Host "Deploying from '$PSScriptRoot'"

$ResourceNamePrefix = "kmd-momentum-mea-$InstanceId"
$TemplateFile = "azuredeploy.json"

try {
  [Microsoft.Azure.Common.Authentication.AzureSession]::ClientFactory.AddUserAgent("VSAzureTools-$UI$($host.name)".replace(' ','_'), '3.0.0')
} catch { }

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3

function Format-ValidationOutput {
  param ($ValidationOutput, [int] $Depth = 0)
  Set-StrictMode -Off
  return @($ValidationOutput | Where-Object { $_ -ne $null } | ForEach-Object { @('  ' * $Depth + ': ' + $_.Message) + @(Format-ValidationOutput @($_.Details) ($Depth + 1)) })
}

$ResourceGroupName = "$ResourceNamePrefix-rg"

# Set ARM template parameter values
$TemplateParameters = @{
  instanceId = $InstanceId;
  resourceNamePrefix = $ResourceNamePrefix;
  applicationInsightsName = $ApplicationInsightsName;
  applicationInsightsResourceGroup = $ApplicationInsightsResourceGroup;
  diagnosticSeqServerUrl = $DiagnosticSeqServerUrl;
  diagnosticSeqApiKey = $DiagnosticSeqApiKey;
  webAppServicePlanSku = $WebAppServicePlanSku;
  webAppConfigAlwaysOn = $WebAppConfigAlwaysOn;
}

# Create or update the resource group using the specified template file and template parameter values
$Tags = @{}
if ($MarkForAutoDelete) {
  $Tags["keep"] = "false";
} else {
  $Tags["important"] = "true";
}

New-AzResourceGroup -Name $ResourceGroupName -Location $ResourceGroupLocation -Tags $Tags -Verbose -Force

if ($ValidateOnly) {
  $ErrorMessages = Format-ValidationOutput (Test-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName `
                                                                                -TemplateFile $TemplateFile `
                                                                                @TemplateParameters)
  if ($ErrorMessages) {
      Write-Output '', 'Validation returned the following errors:', @($ErrorMessages), '', 'Template is invalid.'
  }
  else {
      Write-Output '', 'Template is valid.'
  }
}
else {
  New-AzResourceGroupDeployment -Name ((Get-ChildItem $TemplateFile).BaseName + '-' + ((Get-Date).ToUniversalTime()).ToString('MMdd-HHmm')) `
                                      -ResourceGroupName $ResourceGroupName `
                                      -TemplateFile $TemplateFile `
                                      @TemplateParameters `
                                      -Force -Verbose `
                                      -ErrorVariable ErrorMessages
  if ($ErrorMessages) {
      Write-Output '', 'Template deployment returned the following errors:', @(@($ErrorMessages) | ForEach-Object { $_.Exception.Message.TrimEnd("`r`n") })
  }
}

Pop-Location