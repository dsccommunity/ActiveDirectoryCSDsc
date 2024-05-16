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
        Returns an object containing the current state information for the ADCS CA on the server.

    .PARAMETER IsSingleInstance
        Specifies the resource is a single instance, the value must be 'Yes'.

    .PARAMETER CAType
        Specifies the type of certification authority to install.

    .PARAMETER Credential
        To install an enterprise certification authority, the computer must be joined to an Active
        Directory Domain Services domain and a user account that is a member of the Enterprise Admin
        group is required. To install a standalone certification authority, the computer can be in a
        workgroup or AD DS domain. If the computer is in a workgroup, a user account that is a member
        of Administrators is required. If the computer is in an AD DS domain, a user account that is
        a member of Domain Admins is required.

    .PARAMETER Ensure
        Specifies whether the Certificate Authority should be installed or uninstalled.

    .PARAMETER CACommonName
        Specifies the certification authority common name.

    .PARAMETER CADistinguishedNameSuffix
        Specifies the certification authority distinguished name suffix.

    .PARAMETER CertFile
        Specifies the file name of certification authority PKCS 12 formatted certificate file.

    .PARAMETER CertFilePassword
        Specifies the password for certification authority certificate file.

    .PARAMETER CertificateID
        Specifies the thumbprint or serial number of certification authority certificate.

    .PARAMETER CryptoProviderName
        The name of the cryptographic service provider or key storage provider that is used to generate
        or store the private key for the CA.

    .PARAMETER DatabaseDirectory
        Specifies the folder location of the certification authority database.

    .PARAMETER HashAlgorithmName
        Specifies the signature hash algorithm used by the certification authority.

    .PARAMETER IgnoreUnicode
        Specifies that Unicode characters are allowed in certification authority name string.

    .PARAMETER KeyContainerName
        Specifies the name of an existing private key container.

    .PARAMETER KeyLength
        Specifies the bit length for new certification authority key.

    .PARAMETER LogDirectory
        Specifies the folder location of the certification authority database log.

    .PARAMETER OutputCertRequestFile
        Specifies the folder location for certificate request file.

    .PARAMETER OverwriteExistingCAinDS
        Specifies that the computer object in the Active Directory Domain Service domain should be
        overwritten with the same computer name.

    .PARAMETER OverwriteExistingDatabase
        Specifies that the existing certification authority database should be overwritten.

    .PARAMETER OverwriteExistingKey
        Overwrite existing key container with the same name.

    .PARAMETER ParentCA
        Specifies the configuration string of the parent certification authority that will certify this
        CA.

    .PARAMETER ValidityPeriod
        Specifies the validity period of the certification authority certificate in hours, days, weeks,
        months or years. If this is a subordinate CA, do not use this parameter, because the validity
        period is determined by the parent CA.

    .PARAMETER ValidityPeriodUnits
        Validity period of the certification authority certificate. If this is a subordinate CA, do not
        specify this parameter because the validity period is determined by the parent CA.

    .OUTPUTS
        Returns an object containing the ADCS CA state information.
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
        [ValidateSet('EnterpriseRootCA', 'EnterpriseSubordinateCA', 'StandaloneRootCA', 'StandaloneSubordinateCA')]
        [System.String]
        $CAType,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [System.String]
        $CACommonName,

        [Parameter()]
        [System.String]
        $CADistinguishedNameSuffix,

        [Parameter()]
        [System.String]
        $CertFile,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $CertFilePassword,

        [Parameter()]
        [System.String]
        $CertificateID,

        [Parameter()]
        [System.String]
        $CryptoProviderName,

        [Parameter()]
        [System.String]
        $DatabaseDirectory,

        [Parameter()]
        [System.String]
        $HashAlgorithmName,

        [Parameter()]
        [System.Boolean]
        $IgnoreUnicode,

        [Parameter()]
        [System.String]
        $KeyContainerName,

        [Parameter()]
        [System.UInt32]
        $KeyLength,

        [Parameter()]
        [System.String]
        $LogDirectory,

        [Parameter()]
        [System.String]
        $OutputCertRequestFile,

        [Parameter()]
        [System.Boolean]
        $OverwriteExistingCAinDS,

        [Parameter()]
        [System.Boolean]
        $OverwriteExistingDatabase,

        [Parameter()]
        [System.Boolean]
        $OverwriteExistingKey,

        [Parameter()]
        [System.String]
        $ParentCA,

        [Parameter()]
        [ValidateSet('Hours', 'Days', 'Months', 'Years')]
        [System.String]
        $ValidityPeriod,

        [Parameter()]
        [System.UInt32]
        $ValidityPeriodUnits
    )

    Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($script:localizedData.GettingAdcsCAStatusMessage -f $CAType)
        ) -join '' )

    $adcsParameters = @{} + $PSBoundParameters
    $null = $adcsParameters.Remove('IsSingleInstance')
    $null = $adcsParameters.Remove('Ensure')
    $null = $adcsParameters.Remove('Debug')
    $null = $adcsParameters.Remove('ErrorAction')

    if ($CertFilePassword)
    {
        $adcsParameters['CertFilePassword'] = $CertFilePassword.Password
    }

    try
    {
        $null = Install-AdcsCertificationAuthority @adcsParameters -WhatIf
        # CA is not installed
        $Ensure = 'Absent'
    }
    catch [Microsoft.CertificateServices.Deployment.Common.CA.CertificationAuthoritySetupException]
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
        IsSingleInstance = 'Yes'
        Ensure           = $Ensure
        CAType           = $CAType
        Credential       = $Credential
    }
} # function Get-TargetResource

<#
    .SYNOPSIS
        Installs or uinstalls the ADCS CA from the server.

    .PARAMETER IsSingleInstance
        Specifies the resource is a single instance, the value must be 'Yes'.

    .PARAMETER CAType
        Specifies the type of certification authority to install.

    .PARAMETER Credential
        To install an enterprise certification authority, the computer must be joined to an Active
        Directory Domain Services domain and a user account that is a member of the Enterprise Admin
        group is required. To install a standalone certification authority, the computer can be in a
        workgroup or AD DS domain. If the computer is in a workgroup, a user account that is a member
        of Administrators is required. If the computer is in an AD DS domain, a user account that is
        a member of Domain Admins is required.

    .PARAMETER Ensure
        Specifies whether the Certificate Authority should be installed or uninstalled.

    .PARAMETER CACommonName
        Specifies the certification authority common name.

    .PARAMETER CADistinguishedNameSuffix
        Specifies the certification authority distinguished name suffix.

    .PARAMETER CertFile
        Specifies the file name of certification authority PKCS 12 formatted certificate file.

    .PARAMETER CertFilePassword
        Specifies the password for certification authority certificate file.

    .PARAMETER CertificateID
        Specifies the thumbprint or serial number of certification authority certificate.

    .PARAMETER CryptoProviderName
        The name of the cryptographic service provider or key storage provider that is used to generate
        or store the private key for the CA.

    .PARAMETER DatabaseDirectory
        Specifies the folder location of the certification authority database.

    .PARAMETER HashAlgorithmName
        Specifies the signature hash algorithm used by the certification authority.

    .PARAMETER IgnoreUnicode
        Specifies that Unicode characters are allowed in certification authority name string.

    .PARAMETER KeyContainerName
        Specifies the name of an existing private key container.

    .PARAMETER KeyLength
        Specifies the bit length for new certification authority key.

    .PARAMETER LogDirectory
        Specifies the folder location of the certification authority database log.

    .PARAMETER OutputCertRequestFile
        Specifies the folder location for certificate request file.

    .PARAMETER OverwriteExistingCAinDS
        Specifies that the computer object in the Active Directory Domain Service domain should be
        overwritten with the same computer name.

    .PARAMETER OverwriteExistingDatabase
        Specifies that the existing certification authority database should be overwritten.

    .PARAMETER OverwriteExistingKey
        Overwrite existing key container with the same name.

    .PARAMETER ParentCA
        Specifies the configuration string of the parent certification authority that will certify this
        CA.

    .PARAMETER ValidityPeriod
        Specifies the validity period of the certification authority certificate in hours, days, weeks,
        months or years. If this is a subordinate CA, do not use this parameter, because the validity
        period is determined by the parent CA.

    .PARAMETER ValidityPeriodUnits
        Validity period of the certification authority certificate. If this is a subordinate CA, do not
        specify this parameter because the validity period is determined by the parent CA.
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
        [ValidateSet('EnterpriseRootCA', 'EnterpriseSubordinateCA', 'StandaloneRootCA', 'StandaloneSubordinateCA')]
        [System.String]
        $CAType,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [System.String]
        $CACommonName,

        [Parameter()]
        [System.String]
        $CADistinguishedNameSuffix,

        [Parameter()]
        [System.String]
        $CertFile,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $CertFilePassword,

        [Parameter()]
        [System.String]
        $CertificateID,

        [Parameter()]
        [System.String]
        $CryptoProviderName,

        [Parameter()]
        [System.String]
        $DatabaseDirectory,

        [Parameter()]
        [System.String]
        $HashAlgorithmName,

        [Parameter()]
        [System.Boolean]
        $IgnoreUnicode,

        [Parameter()]
        [System.String]
        $KeyContainerName,

        [Parameter()]
        [System.UInt32]
        $KeyLength,

        [Parameter()]
        [System.String]
        $LogDirectory,

        [Parameter()]
        [System.String]
        $OutputCertRequestFile,

        [Parameter()]
        [System.Boolean]
        $OverwriteExistingCAinDS,

        [Parameter()]
        [System.Boolean]
        $OverwriteExistingDatabase,

        [Parameter()]
        [System.Boolean]
        $OverwriteExistingKey,

        [Parameter()]
        [System.String]
        $ParentCA,

        [Parameter()]
        [ValidateSet('Hours', 'Days', 'Months', 'Years')]
        [System.String]
        $ValidityPeriod,

        [Parameter()]
        [System.UInt32]
        $ValidityPeriodUnits
    )

    Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($script:localizedData.SettingAdcsCAStatusMessage -f $CAType)
        ) -join '' )

    $adcsParameters = @{} + $PSBoundParameters
    $null = $adcsParameters.Remove('IsSingleInstance')
    $null = $adcsParameters.Remove('Ensure')
    $null = $adcsParameters.Remove('Debug')
    $null = $adcsParameters.Remove('ErrorAction')

    $resultObject = $Null

    if ($CertFilePassword)
    {
        $adcsParameters['CertFilePassword'] = $CertFilePassword.Password
    }

    if ($Ensure -eq 'Present')
    {
        Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($script:localizedData.InstallingAdcsCAMessage -f $CAType)
            ) -join '' )

        $resultObject = Install-AdcsCertificationAuthority @adcsParameters -Force

        # when a multi-tier ADCS is installed ErrorId 398 is returned, but is only a warning and can be safely ignored
        if (($resultObject.ErrorId -eq 398) -or ($resultObject.ErrorString -like "*The Active Directory Certificate Services installation is incomplete*"))
        {
            Write-Warning -Message $resultObject.ErrorString
            $resultObject = $Null
        }
    }
    else
    {
        Write-Verbose -Message ( @(
                "$($MyInvocation.MyCommand): "
                $($script:localizedData.UninstallingAdcsCAMessage -f $CAType)
            ) -join '' )

        $resultObject = Uninstall-AdcsCertificationAuthority -Force
    }

    if (-not [System.String]::IsNullOrEmpty($resultObject.ErrorString))
    {
        New-InvalidOperationException -Message $resultObject.ErrorString
    }
} # function Set-TargetResource

<#
    .SYNOPSIS
        Tests is the ADCS CA is in the desired state.

    .PARAMETER IsSingleInstance
        Specifies the resource is a single instance, the value must be 'Yes'.

    .PARAMETER CAType
        Specifies the type of certification authority to install.

    .PARAMETER Credential
        To install an enterprise certification authority, the computer must be joined to an Active
        Directory Domain Services domain and a user account that is a member of the Enterprise Admin
        group is required. To install a standalone certification authority, the computer can be in a
        workgroup or AD DS domain. If the computer is in a workgroup, a user account that is a member
        of Administrators is required. If the computer is in an AD DS domain, a user account that is
        a member of Domain Admins is required.

    .PARAMETER Ensure
        Specifies whether the Certificate Authority should be installed or uninstalled.

    .PARAMETER CACommonName
        Specifies the certification authority common name.

    .PARAMETER CADistinguishedNameSuffix
        Specifies the certification authority distinguished name suffix.

    .PARAMETER CertFile
        Specifies the file name of certification authority PKCS 12 formatted certificate file.

    .PARAMETER CertFilePassword
        Specifies the password for certification authority certificate file.

    .PARAMETER CertificateID
        Specifies the thumbprint or serial number of certification authority certificate.

    .PARAMETER CryptoProviderName
        The name of the cryptographic service provider or key storage provider that is used to generate
        or store the private key for the CA.

    .PARAMETER DatabaseDirectory
        Specifies the folder location of the certification authority database.

    .PARAMETER HashAlgorithmName
        Specifies the signature hash algorithm used by the certification authority.

    .PARAMETER IgnoreUnicode
        Specifies that Unicode characters are allowed in certification authority name string.

    .PARAMETER KeyContainerName
        Specifies the name of an existing private key container.

    .PARAMETER KeyLength
        Specifies the bit length for new certification authority key.

    .PARAMETER LogDirectory
        Specifies the folder location of the certification authority database log.

    .PARAMETER OutputCertRequestFile
        Specifies the folder location for certificate request file.

    .PARAMETER OverwriteExistingCAinDS
        Specifies that the computer object in the Active Directory Domain Service domain should be
        overwritten with the same computer name.

    .PARAMETER OverwriteExistingDatabase
        Specifies that the existing certification authority database should be overwritten.

    .PARAMETER OverwriteExistingKey
        Overwrite existing key container with the same name.

    .PARAMETER ParentCA
        Specifies the configuration string of the parent certification authority that will certify this
        CA.

    .PARAMETER ValidityPeriod
        Specifies the validity period of the certification authority certificate in hours, days, weeks,
        months or years. If this is a subordinate CA, do not use this parameter, because the validity
        period is determined by the parent CA.

    .PARAMETER ValidityPeriodUnits
        Validity period of the certification authority certificate. If this is a subordinate CA, do not
        specify this parameter because the validity period is determined by the parent CA.

    .OUTPUTS
        Returns true if the ADCS CA is in the desired state.
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
        [ValidateSet('EnterpriseRootCA', 'EnterpriseSubordinateCA', 'StandaloneRootCA', 'StandaloneSubordinateCA')]
        [System.String]
        $CAType,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [System.String]
        $CACommonName,

        [Parameter()]
        [System.String]
        $CADistinguishedNameSuffix,

        [Parameter()]
        [System.String]
        $CertFile,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $CertFilePassword,

        [Parameter()]
        [System.String]
        $CertificateID,

        [Parameter()]
        [System.String]
        $CryptoProviderName,

        [Parameter()]
        [System.String]
        $DatabaseDirectory,

        [Parameter()]
        [System.String]
        $HashAlgorithmName,

        [Parameter()]
        [System.Boolean]
        $IgnoreUnicode,

        [Parameter()]
        [System.String]
        $KeyContainerName,

        [Parameter()]
        [System.UInt32]
        $KeyLength,

        [Parameter()]
        [System.String]
        $LogDirectory,

        [Parameter()]
        [System.String]
        $OutputCertRequestFile,

        [Parameter()]
        [System.Boolean]
        $OverwriteExistingCAinDS,

        [Parameter()]
        [System.Boolean]
        $OverwriteExistingDatabase,

        [Parameter()]
        [System.Boolean]
        $OverwriteExistingKey,

        [Parameter()]
        [System.String]
        $ParentCA,

        [Parameter()]
        [ValidateSet('Hours', 'Days', 'Months', 'Years')]
        [System.String]
        $ValidityPeriod,

        [Parameter()]
        [System.UInt32]
        $ValidityPeriodUnits
    )

    Write-Verbose -Message ( @(
            "$($MyInvocation.MyCommand): "
            $($script:localizedData.TestingAdcsCAStatusMessage -f $CAType)
        ) -join '' )

    $adcsParameters = @{} + $PSBoundParameters
    $null = $adcsParameters.Remove('IsSingleInstance')
    $null = $adcsParameters.Remove('Ensure')
    $null = $adcsParameters.Remove('Debug')
    $null = $adcsParameters.Remove('ErrorAction')

    if ($CertFilePassword)
    {
        $adcsParameters['CertFilePassword'] = $CertFilePassword.Password
    }

    try
    {
        $null = Install-AdcsCertificationAuthority @adcsParameters -WhatIf
        # CA is not installed
        if ($Ensure -eq 'Present')
        {
            # CA is not installed but should be - change required
            Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($script:localizedData.AdcsCANotInstalledButShouldBeMessage -f $CAType)
                ) -join '' )

            return $false
        }
        else
        {
            # CA is not installed and should not be - change not required
            Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($script:localizedData.AdcsCANotInstalledAndShouldNotBeMessage -f $CAType)
                ) -join '' )

            return $true
        }
    }
    catch [Microsoft.CertificateServices.Deployment.Common.CA.CertificationAuthoritySetupException]
    {
        # CA is already installed
        if ($Ensure -eq 'Present')
        {
            # CA is installed and should be - change not required
            Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($script:localizedData.AdcsCAInstalledAndShouldBeMessage -f $CAType)
                ) -join '' )

            return $true
        }
        else
        {
            # CA is installed and should not be - change required
            Write-Verbose -Message ( @(
                    "$($MyInvocation.MyCommand): "
                    $($script:localizedData.AdcsCAInstalledButShouldNotBeMessage -f $CAType)
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
