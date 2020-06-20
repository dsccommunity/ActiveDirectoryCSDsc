$modulePath = Join-Path -Path (Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent) -ChildPath 'Modules'

# Import the ADCS Deployment Resource Common Module.
Import-Module -Name (Join-Path -Path $modulePath `
        -ChildPath (Join-Path -Path 'ActiveDirectoryCSDsc.Common' `
            -ChildPath 'ActiveDirectoryCSDsc.Common.psm1'))

Import-Module -Name (Join-Path -Path $modulePath -ChildPath 'DscResource.Common')

# Import Localization Strings.
$script:localizedData = Get-LocalizedData -DefaultUICulture 'en-US'

<#
    .SYNOPSIS
        Returns an object containing the current state information for the ADCS Online Responder.

    .PARAMETER IsSingleInstance
        Specifies the resource is a single instance, the value must be 'Yes'.

    .PARAMETER Credential
        If the Online Responder service is configured to use Standalone certification authority,
        then an account that is a member of the local Administrators on the CA is required. If
        the Online Responder service is configured to use an Enterprise CA, then an account that
        is a member of Domain Admins is required.

    .PARAMETER Ensure
        Specifies whether the Online Responder feature should be installed or uninstalled.

    .OUTPUTS
        Returns an object containing the ADCS Online Responder state information.
#>
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [System.String]
        $IsSingleInstance,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($script:localizedData.GettingAdcsOnlineResponderStatusMessage)
        ) -join '' )

    $adcsParameters = @{ } + $PSBoundParameters
    $null = $adcsParameters.Remove('IsSingleInstance')
    $null = $adcsParameters.Remove('Ensure')
    $null = $adcsParameters.Remove('Debug')
    $null = $adcsParameters.Remove('ErrorAction')

    try
    {
        $null = Install-AdcsOnlineResponder @adcsParameters -WhatIf
        # CA is not installed
        $Ensure = 'Absent'
    }
    catch [Microsoft.CertificateServices.Deployment.Common.OCSP.OnlineResponderSetupException]
    {
        # CA is already installed
        $Ensure = 'Present'
    }
    catch
    {
        # Something else went wrong
        throw $_
    }

    return @{
        Ensure     = $Ensure
        Credential = $Credential
    }
} # function Get-TargetResource

<#
    .SYNOPSIS
        Installs or uinstalls the ADCS Online Responder from the server.

    .PARAMETER IsSingleInstance
        Specifies the resource is a single instance, the value must be 'Yes'.

    .PARAMETER Credential
        If the Online Responder service is configured to use Standalone certification authority,
        then an account that is a member of the local Administrators on the CA is required. If
        the Online Responder service is configured to use an Enterprise CA, then an account that
        is a member of Domain Admins is required.

    .PARAMETER Ensure
        Specifies whether the Online Responder feature should be installed or uninstalled.
#>
function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [System.String]
        $IsSingleInstance,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($script:localizedData.SettingAdcsOnlineResponderStatusMessage)
        ) -join '' )

    $adcsParameters = @{ } + $PSBoundParameters
    $null = $adcsParameters.Remove('IsSingleInstance')
    $null = $adcsParameters.Remove('Ensure')
    $null = $adcsParameters.Remove('Debug')
    $null = $adcsParameters.Remove('ErrorAction')

    $errorMessage = ''

    if ($Ensure -eq 'Present')
    {
        Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($script:localizedData.InstallingAdcsOnlineResponderMessage)
            ) -join '' )

        $errorMessage = (Install-AdcsOnlineResponder @adcsParameters -Force).ErrorString
    }
    else
    {
        Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($script:localizedData.UninstallingAdcsOnlineResponderMessage)
            ) -join '' )

        $errorMessage = (Uninstall-AdcsOnlineResponder -Force).ErrorString
    }

    if (-not [System.String]::IsNullOrEmpty($errorMessage))
    {
        New-InvalidOperationException -Message $errorMessage
    }
} # function Set-TargetResource

<#
    .SYNOPSIS
        Tests is the ADCS Online Responder is in the desired state.

    .PARAMETER IsSingleInstance
        Specifies the resource is a single instance, the value must be 'Yes'.

    .PARAMETER Credential
        If the Online Responder service is configured to use Standalone certification authority,
        then an account that is a member of the local Administrators on the CA is required. If
        the Online Responder service is configured to use an Enterprise CA, then an account that
        is a member of Domain Admins is required.

    .PARAMETER Ensure
        Specifies whether the Online Responder feature should be installed or uninstalled.

    .OUTPUTS
        Returns true if the ADCS Online Responder is in the desired state.
#>
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [System.String]
        $IsSingleInstance,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present'
    )

    Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $script:localizedData.TestingAdcsOnlineResponderStatusMessage
        ) -join '' )

    $adcsParameters = @{ } + $PSBoundParameters
    $null = $adcsParameters.Remove('IsSingleInstance')
    $null = $adcsParameters.Remove('Ensure')
    $null = $adcsParameters.Remove('Debug')
    $null = $adcsParameters.Remove('ErrorAction')

    try
    {
        $null = Install-AdcsOnlineResponder @adcsParameters -WhatIf
        # Online Responder is not installed
        if ($Ensure -eq 'Present')
        {
            # Online Responder is not installed but should be - change required
            Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($script:localizedData.AdcsOnlineResponderNotInstalledButShouldBeMessage)
                ) -join '' )

            return $false
        }
        else
        {
            # Online Responder is not installed and should not be - change not required
            Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($script:localizedData.AdcsOnlineResponderNotInstalledAndShouldNotBeMessage)
                ) -join '' )

            return $true
        }
    }
    catch [Microsoft.CertificateServices.Deployment.Common.OCSP.OnlineResponderSetupException]
    {
        # Online Responder is already installed
        if ($Ensure -eq 'Present')
        {
            # Online Responder is installed and should be - change not required
            Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($script:localizedData.AdcsOnlineResponderInstalledAndShouldBeMessage)
                ) -join '' )

            return $true
        }
        else
        {
            # Online Responder is installed and should not be - change required
            Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($script:localizedData.AdcsOnlineResponderInstalledButShouldNotBeMessage)
                ) -join '' )

            return $false
        }
    }
    catch
    {
        # Something else went wrong
        throw $_
    } # try
} # function Test-TargetResource

Export-ModuleMember -Function *-TargetResource
