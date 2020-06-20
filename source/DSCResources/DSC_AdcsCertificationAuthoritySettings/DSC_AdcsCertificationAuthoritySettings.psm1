#Requires -Version 5.0

$modulePath = Join-Path -Path (Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent) -ChildPath 'Modules'

# Import the ADCS Deployment Resource Common Module.
Import-Module -Name (Join-Path -Path $modulePath `
        -ChildPath (Join-Path -Path 'ActiveDirectoryCSDsc.Common' `
            -ChildPath 'ActiveDirectoryCSDsc.Common.psm1'))

Import-Module -Name (Join-Path -Path $modulePath -ChildPath 'DscResource.Common')

# Import Localization Strings.
$script:localizedData = Get-LocalizedData -DefaultUICulture 'en-US'

<#
    This is an array of all the parameters used by this resource.
    The CurrentValue, NewValue and MockedValue properties are only used by
    tests but are stored here so that a duplicate table does not have
    to be created.
#>
$script:parameterList = Import-LocalizedData `
    -BaseDirectory $PSScriptRoot `
    -FileName 'DSC_AdcsCertificationAuthoritySettings.data.psd1'

# A flags enum containing the Certificate Authority audit filter flags
[flags()]
enum CertificateAuthorityAuditFilter
{
    StartAndStopADCS = 1
    BackupAndRestoreCADatabase = 2
    IssueAndManageCertificateRequests = 4
    RevokeCertificatesAndPublishCRLs = 8
    ChangeCASecuritySettings = 16
    StoreAndRetrieveArchivedKeys = 32
    ChangeCAConfiguration = 64
}

<#
    This it the registry settings path that Certificate Authority settings
    can be found.
#>
$script:certificateAuthorityRegistrySettingsPath = 'HKLM:\System\CurrentControlSet\Services\CertSvc\Configuration'

<#
    .SYNOPSIS
        Returns an object containing the current state information for the Active Directory
        Certificate Authority settings.

    .PARAMETER IsSingleInstance
        Specifies the resource is a single instance, the value must be 'Yes'.

    .OUTPUTS
        Returns an object containing the Active Directory Certificate Authority Settings.
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
            $($script:localizedData.GettingAdcsCaSettingsMessage)
        ) -join '' )

    $currentcertificateAuthoritySettings = Get-CertificateAuthoritySettings

    # Generate the return object
    $returnValue = @{
        IsSingleInstance = 'Yes'
    }

    # Loop through each of the parameters and add it to the return object
    foreach ($parameter in $script:parameterList.GetEnumerator())
    {
        switch ($parameter.Value.Type)
        {
            'String[]'
            {
                if ($null -ne $currentcertificateAuthoritySettings.$($parameter.Name))
                {
                    $parameterValue = $currentcertificateAuthoritySettings.$($parameter.Name) -split '\\n'
                }
                else
                {
                    $parameterValue = [System.String[]] @()
                }
                break
            }

            'Flags'
            {
                if ($null -ne $currentcertificateAuthoritySettings.AuditFilter)
                {
                    $parameterValue = [System.String[]] (Convert-AuditFilterToStringArray `
                        -AuditFilter $currentcertificateAuthoritySettings.AuditFilter)
                }
                else
                {
                    $parameterValue = [System.String[]] @()
                }
                break
            }

            'UInt32'
            {
                $parameterValue = [System.UInt32] $currentcertificateAuthoritySettings.$($parameter.Name)
                break
            }

            default
            {
                $parameterValue = $currentcertificateAuthoritySettings.$($parameter.Name)
                break
            }
        }

        $returnValue += @{
            $($parameter.Name) = $parameterValue
        }
    } # foreach

    return $returnValue
} # function Get-TargetResource

<#
    .SYNOPSIS
        Updates the Active Directory Certificate Authority settings.

    .PARAMETER IsSingleInstance
        Specifies the resource is a single instance, the value must be 'Yes'.

    .PARAMETER CACertPublicationURLs
        Specifies an array of Certificate Authority certificate publication URLs,
        each prepended with an integer representing the type of URL endpoint.

    .PARAMETER CRLPublicationURLs
        Specifies an array of Certificate Revocation List publication URLs,
        each prepended with an integer representing the type of URL endpoint.

    .PARAMETER CRLOverlapUnits
        Specifies the number of units for the certificate revocation list
        overlap period.

    .PARAMETER CRLOverlapPeriod
        Specifies the units of measurement for the certificate revocation list
        overlap period.

    .PARAMETER CRLPeriodUnits
        Specifies the number of units for the certificate revocation period.

    .PARAMETER CRLPeriod
        Specifies the units of measurement for the certificate revocation period.

    .PARAMETER ValidityPeriodUnits
        Specifies the number of units for the validity period of certificates
        issued by this certificate authority.

    .PARAMETER ValidityPeriod
        Specifies the units of measurement for the validity period of certificates
        issued by this certificate authority.

    .PARAMETER DSConfigDN
        Specifies the distinguished name of the directory services configuration
        object that contains this certificate authority in the Active
        Directory.

    .PARAMETER DSDomainDN
        Specifies the distinguished name of the directory services object that contains
        this certificate authority in the Active Directory.

    .PARAMETER AuditFilter
        Specifies an array of audit categories to enable audit logging for.
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
        [System.String[]]
        $CACertPublicationURLs,

        [Parameter()]
        [System.String[]]
        $CRLPublicationURLs,

        [Parameter()]
        [System.UInt32]
        $CRLOverlapUnits,

        [Parameter()]
        [ValidateSet('Hours', 'Days', 'Weeks', 'Months', 'Years')]
        [System.String]
        $CRLOverlapPeriod,

        [Parameter()]
        [System.UInt32]
        $CRLPeriodUnits,

        [Parameter()]
        [ValidateSet('Hours', 'Days', 'Weeks', 'Months', 'Years')]
        [System.String]
        $CRLPeriod,

        [Parameter()]
        [System.UInt32]
        $ValidityPeriodUnits,

        [Parameter()]
        [ValidateSet('Hours', 'Days', 'Weeks', 'Months', 'Years')]
        [System.String]
        $ValidityPeriod,

        [Parameter()]
        [System.String]
        $DSConfigDN,

        [Parameter()]
        [System.String]
        $DSDomainDN,

        [Parameter()]
        [ValidateSet('StartAndStopADCS', 'BackupAndRestoreCADatabase', 'IssueAndManageCertificateRequests', 'RevokeCertificatesAndPublishCRLs', 'ChangeCASecuritySettings', 'StoreAndRetrieveArchivedKeys', 'ChangeCAConfiguration')]
        [System.String[]]
        $AuditFilter
    )

    Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $script:localizedData.SettingAdcsCaSettingsMessage
        ) -join '' )

    $currentSettings = Get-TargetResource `
        -IsSingleInstance $IsSingleInstance `
        -Verbose:$VerbosePreference

    $settingUpdated = $false

    <#
        Step through each parameter and update any that are passed
        and the current value differs from the desired value.
    #>
    foreach ($parameter in $script:parameterList.GetEnumerator())
    {
        $updateParameter = $false
        $parameterName = $parameter.Name
        $parameterCurrentValue = $currentSettings.$parameterName
        $parameterDesiredValue = (Get-Variable -Name $parameterName).Value

        if ($PSBoundParameters.ContainsKey($parameterName))
        {
            switch ($parameter.Value.Type)
            {
                'String[]'
                {
                    $updateParameter = (Compare-Object `
                            -ReferenceObject $parameterCurrentValue `
                            -DifferenceObject $parameterDesiredValue).Count -ne 0
                    $parameterNewValue = $parameterDesiredValue -join '\n'
                    break
                }

                'Flags'
                {
                    $updateParameter = (Compare-Object `
                            -ReferenceObject $parameterCurrentValue `
                            -DifferenceObject $parameterDesiredValue).Count -ne 0
                    $parameterNewValue = Convert-StringArrayToAuditFilter -StringArray $parameterDesiredValue
                    break
                }

                default
                {
                    $updateParameter = $parameterCurrentValue -ne $parameterDesiredValue
                    $parameterNewValue = $parameterDesiredValue
                }
            }

            # A parameter needs to be updated
            if ($updateParameter)
            {
                $parameterUpdated = $true

                Set-CertificateAuthoritySetting `
                    -Name $parameterName `
                    -Value $parameterNewValue `
                    -Verbose:$VerbosePreference
            }
        } # if
    } # foreach

    if ($parameterUpdated)
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
        Updates the Active Directory Certificate Authority settings.

    .PARAMETER IsSingleInstance
        Specifies the resource is a single instance, the value must be 'Yes'.

    .PARAMETER CACertPublicationURLs
        Specifies an array of Certificate Authority certificate publication URLs,
        each prepended with an integer representing the type of URL endpoint.

    .PARAMETER CRLPublicationURLs
        Specifies an array of Certificate Revocation List publication URLs,
        each prepended with an integer representing the type of URL endpoint.

    .PARAMETER CRLOverlapUnits
        Specifies the number of units for the certificate revocation list
        overlap period.

    .PARAMETER CRLOverlapPeriod
        Specifies the units of measurement for the certificate revocation list
        overlap period.

    .PARAMETER CRLPeriodUnits
        Specifies the number of units for the certificate revocation period.

    .PARAMETER CRLPeriod
        Specifies the units of measurement for the certificate revocation period.

    .PARAMETER ValidityPeriodUnits
        Specifies the number of units for the validity period of certificates
        issued by this certificate authority.

    .PARAMETER ValidityPeriod
        Specifies the units of measurement for the validity period of certificates
        issued by this certificate authority.

    .PARAMETER DSConfigDN
        Specifies the distinguished name of the directory services configuration
        object that contains this certificate authority in the Active
        Directory.

    .PARAMETER DSDomainDN
        Specifies the distinguished name of the directory services object that contains
        this certificate authority in the Active Directory.

    .PARAMETER AuditFilter
        Specifies an array of audit categories to enable audit logging for.
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
        [System.String[]]
        $CACertPublicationURLs,

        [Parameter()]
        [System.String[]]
        $CRLPublicationURLs,

        [Parameter()]
        [System.UInt32]
        $CRLOverlapUnits,

        [Parameter()]
        [ValidateSet('Hours', 'Days', 'Weeks', 'Months', 'Years')]
        [System.String]
        $CRLOverlapPeriod,

        [Parameter()]
        [System.UInt32]
        $CRLPeriodUnits,

        [Parameter()]
        [ValidateSet('Hours', 'Days', 'Weeks', 'Months', 'Years')]
        [System.String]
        $CRLPeriod,

        [Parameter()]
        [System.UInt32]
        $ValidityPeriodUnits,

        [Parameter()]
        [ValidateSet('Hours', 'Days', 'Weeks', 'Months', 'Years')]
        [System.String]
        $ValidityPeriod,

        [Parameter()]
        [System.String]
        $DSConfigDN,

        [Parameter()]
        [System.String]
        $DSDomainDN,

        [Parameter()]
        [ValidateSet('StartAndStopADCS', 'BackupAndRestoreCADatabase', 'IssueAndManageCertificateRequests', 'RevokeCertificatesAndPublishCRLs', 'ChangeCASecuritySettings', 'StoreAndRetrieveArchivedKeys', 'ChangeCAConfiguration')]
        [System.String[]]
        $AuditFilter
    )

    Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $script:localizedData.TestingAdcsCaSettingsMessage
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
        Return the settings for the installed certificate authotity.

    .DESCRIPTION
        Get the settings for the installed certificate authotity
        from the registry and return them.

        If no active certificate authority is found in the registry
        then an exception is thrown.
#>
function Get-CertificateAuthoritySettings
{
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject[]])]
    param ()

    $activeCertificateAuthority = Get-ItemPropertyValue `
        -Path $script:certificateAuthorityRegistrySettingsPath `
        -Name 'Active' `
        -ErrorAction SilentlyContinue

    if ([System.String]::IsNullOrEmpty($activeCertificateAuthority))
    {
        New-ObjectNotFoundException -Message ($script:localizedData.CertificateAuthorityNoneActive -f `
                $script:certificateAuthorityRegistrySettingsPath)
    }

    $certificateAuthorityRegistryPath = Join-Path `
        -Path $script:certificateAuthorityRegistrySettingsPath `
        -ChildPath $activeCertificateAuthority

    return Get-ItemProperty `
        -Path $certificateAuthorityRegistryPath
} # function Get-CertificateAuthoritySettings

<#
    .SYNOPSIS
        Convers an audit filter flags bit field into an array of strings
        containing the friendly names of the audit filter flag.

    .PARAMETER AuditFilter
        The audit filter bit field to convert to an array of strings.
#>
function Convert-AuditFilterToStringArray
{
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param
    (
        [Parameter()]
        [ValidateRange(0, 127)]
        [System.Int32]
        $AuditFilter
    )

    if ($AuditFilter -eq 0)
    {
        return [System.String[]] @()
    }

    return ([CertificateAuthorityAuditFilter] $AuditFilter -split ', ')
} # function Convert-AuditFilterToStringArray

<#
    .SYNOPSIS
        Convers an array of strings containing audit filter friendly
        names into an audit filter flags field.

    .PARAMETER AuditFilter
        The audit filter bit field to convert to an array of strings.
#>
function Convert-StringArrayToAuditFilter
{
    [CmdletBinding()]
    [OutputType([System.Int32])]
    param
    (
        [Parameter()]
        [ValidateSet('StartAndStopADCS', 'BackupAndRestoreCADatabase', 'IssueAndManageCertificateRequests', 'RevokeCertificatesAndPublishCRLs', 'ChangeCASecuritySettings', 'StoreAndRetrieveArchivedKeys', 'ChangeCAConfiguration')]
        [System.String[]]
        $StringArray
    )

    if ($StringArray.Count -eq 0)
    {
        return 0
    }

    return ([CertificateAuthorityAuditFilter] $StringArray).value__
} # function Convert-StringArrayToAuditFilter

<#
    .SYNOPSIS
        Convers an array of strings containing audit filter friendly
        names into an audit filter flags field.

    .PARAMETER AuditFilter
        The audit filter bit field to convert to an array of strings.
#>
function Set-CertificateAuthoritySetting
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.String]
        $Name,

        [Parameter()]
        [System.String]
        $Value
    )

    & "$($ENV:SystemRoot)\system32\certutil.exe" @('-setreg', "CA\$Name", $Value)

    Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            ($script:localizedData.UpdatingAdcsCaSettingMessage -f $Name, $Value)
        ) -join '' )
} # function Set-CertificateAuthoritySetting

Export-ModuleMember -Function *-TargetResource
