$modulePath = Join-Path -Path (Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent) -ChildPath 'Modules'

# Import the ADCS Deployment Resource Common Module.
Import-Module -Name (Join-Path -Path $modulePath `
        -ChildPath (Join-Path -Path 'ActiveDirectoryCSDsc.Common' `
            -ChildPath 'ActiveDirectoryCSDsc.Common.psm1'))

# Import Localization Strings.
$script:localizedData = Get-LocalizedData -ResourceName 'MSFT_AdcsAuthorityInformationAccess'

<#
    .SYNOPSIS
        Gets the current state of the ADCS Authority Information Access settings.

    .PARAMETER IsSingleInstance
        Specifies the resource is a single instance, the value must be 'Yes'.
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
        $IsSingleInstance
    )

    Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($script:localizedData.GettingAdcsAiaMessage)
        ) -join '' )

    return @{
        IsSingleInstance = 'Yes'
        AiaUri = Get-CaAiaUriList -ExtensionType 'AddToCertificateAia'
        OcspUri = Get-CaAiaUriList -ExtensionType 'AddToCertificateOcsp'
        AllowRestartService = $false
    }
} # function Get-TargetResource

<#
    .SYNOPSIS
        Sets the current state of the ADCS Authority Information Access settings.

    .PARAMETER IsSingleInstance
        Specifies the resource is a single instance, the value must be 'Yes'.

    .PARAMETER AiaUri
        Specifies the list of URIs that should be included in the AIA extension of
        the issued certificate.

    .PARAMETER OcspUri
        Specifies the list of URIs that should be included in the Online Responder
        OCSP extension of the issued certificate.

    .PARAMETER AllowRestartService
        Allows the Certificate Authority service to be restarted if changes are made.
        Defaults to false.
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

        [Parameter()]
        [AllowNull()]
        [System.String[]]
        $AiaUri,

        [Parameter()]
        [AllowNull()]
        [System.String[]]
        $OcspUri,

        [Parameter()]
        [System.Boolean]
        $AllowRestartService = $false
    )

    Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $script:localizedData.SettingAdcsAiaMessage
        ) -join '' )

    $currentSettings = Get-TargetResource `
        -IsSingleInstance $IsSingleInstance `
        -Verbose:$VerbosePreference

    $parameterUpdated = $false

    if ($parameterUpdated -and $AllowRestartService)
    {
        Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $script:localizedData.RestartingCertSvcMessage
            ) -join '' )

        $null = Restart-ServiceIfExists -Name 'CertSvc'
    }
} # function Set-TargetResource

<#
    .SYNOPSIS
        Tests the current state of the ADCS Authority Information Access settings.

    .PARAMETER IsSingleInstance
        Specifies the resource is a single instance, the value must be 'Yes'.

    .PARAMETER AiaUri
        Specifies the list of URIs that should be included in the AIA extension of
        the issued certificate.

    .PARAMETER OcspUri
        Specifies the list of URIs that should be included in the Online Responder
        OCSP extension of the issued certificate.

    .PARAMETER AllowRestartService
        Allows the Certificate Authority service to be restarted if changes are made.
        Defaults to false.
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

        [Parameter()]
        [AllowNull()]
        [System.String[]]
        $AiaUri,

        [Parameter()]
        [AllowNull()]
        [System.String[]]
        $OcspUri,

        [Parameter()]
        [System.Boolean]
        $AllowRestartService = $false
    )

    Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $script:localizedData.TestingAdcsAiaMessage
        ) -join '' )

    $currentSettings = Get-TargetResource `
        -IsSingleInstance $IsSingleInstance `
        -Verbose:$VerbosePreference

    $null = $PSBoundParameters.Remove('IsSingleInstance')

    return Test-DscParameterState `
        -CurrentValues $currentSettings `
        -DesiredValues $PSBoundParameters `
        -Verbose:$VerbosePreference
} # function Test-TargetResource

<#
    .SYNOPSIS
        Return the current Authority Information Access list set on the
        certificate authority, either for the AIA or Online Responder OCSP
        extensions as an array of strings.

    .PARAMETER ExtensionType
        The type of the extension to return the URI list for.
#>
function Get-CaAiaUriList
{
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('AddToCertificateAia','AddToCertificateOcsp')]
        $ExtensionType
    )

    Write-Verbose -Message ($script:localizedData.GettingAiaUrisMessage -f $ExtensionType)

    return [System.String[]] (Get-CAAuthorityInformationAccess | Where-Object -Property $ExtensionType -Eq $true).Uri
}

Export-ModuleMember -Function *-TargetResource
