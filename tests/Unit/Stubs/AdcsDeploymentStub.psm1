# This section suppresses rules PsScriptAnalyzer may catch in stub functions.
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '')]

# Name: adcsdeployment
# Version: 1.0.0.0

[CmdletBinding()]
param ()

function Install-AdcsCertificationAuthority
{
    <#
    .SYNOPSIS
        Install-AdcsCertificationAuthority [-AllowAdministratorInteraction] [-ValidityPeriod <ValidityPeriod>] [-ValidityPeriodUnits <int>] [-CACommonName <string>] [-CADistinguishedNameSuffix <string>] [-CAType <CAType>] [-CryptoProviderName <string>] [-DatabaseDirectory <string>] [-HashAlgorithmName <string>] [-IgnoreUnicode] [-KeyLength <int>] [-LogDirectory <string>] [-OutputCertRequestFile <string>] [-OverwriteExistingCAinDS] [-OverwriteExistingKey] [-ParentCA <string>] [-OverwriteExistingDatabase] [-Credential <pscredential>] [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]

Install-AdcsCertificationAuthority [-AllowAdministratorInteraction] [-CertFilePassword <securestring>] [-CertFile <string>] [-CAType <CAType>] [-CertificateID <string>] [-DatabaseDirectory <string>] [-LogDirectory <string>] [-OverwriteExistingKey] [-OverwriteExistingDatabase] [-Credential <pscredential>] [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]

Install-AdcsCertificationAuthority [-AllowAdministratorInteraction] [-ValidityPeriod <ValidityPeriod>] [-ValidityPeriodUnits <int>] [-CADistinguishedNameSuffix <string>] [-CAType <CAType>] [-CryptoProviderName <string>] [-DatabaseDirectory <string>] [-HashAlgorithmName <string>] [-IgnoreUnicode] [-KeyContainerName <string>] [-LogDirectory <string>] [-OutputCertRequestFile <string>] [-OverwriteExistingCAinDS] [-ParentCA <string>] [-OverwriteExistingDatabase] [-Credential <pscredential>] [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
    #>

    [CmdletBinding(DefaultParameterSetName = 'NewKeyParameterSet', SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    #[OutputType([Microsoft.CertificateServices.Deployment.Common.CA.CertificationAuthoritySetupResult])]
    [OutputType([System.Object])]
    param (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [switch]
        ${AllowAdministratorInteraction},

        [Parameter(ParameterSetName = 'ExistingCertificateParameterSet', ValueFromPipelineByPropertyName = $true)]
        [securestring]
        ${CertFilePassword},

        [Parameter(ParameterSetName = 'ExistingCertificateParameterSet', ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${CertFile},

        [Parameter(ParameterSetName = 'NewKeyParameterSet', ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = 'ExistingKeyParameterSet', ValueFromPipelineByPropertyName = $true)]
        [System.String]
        ${ValidityPeriod},

        [Parameter(ParameterSetName = 'ExistingKeyParameterSet', ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = 'NewKeyParameterSet', ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(1, 4294967295)]
        [System.UInt32]
        ${ValidityPeriodUnits},

        [Parameter(ParameterSetName = 'NewKeyParameterSet', ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${CACommonName},

        [Parameter(ParameterSetName = 'ExistingKeyParameterSet', ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = 'NewKeyParameterSet', ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${CADistinguishedNameSuffix},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [System.String]
        ${CAType},

        [Parameter(ParameterSetName = 'ExistingCertificateParameterSet', ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${CertificateID},

        [Parameter(ParameterSetName = 'NewKeyParameterSet', ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = 'ExistingKeyParameterSet', ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${CryptoProviderName},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${DatabaseDirectory},

        [Parameter(ParameterSetName = 'ExistingKeyParameterSet', ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = 'NewKeyParameterSet', ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${HashAlgorithmName},

        [Parameter(ParameterSetName = 'NewKeyParameterSet', ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = 'ExistingKeyParameterSet', ValueFromPipelineByPropertyName = $true)]
        [switch]
        ${IgnoreUnicode},

        [Parameter(ParameterSetName = 'ExistingKeyParameterSet', ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${KeyContainerName},

        [Parameter(ParameterSetName = 'NewKeyParameterSet', ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(1, 4294967295)]
        [System.UInt32]
        ${KeyLength},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${LogDirectory},

        [Parameter(ParameterSetName = 'NewKeyParameterSet', ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = 'ExistingKeyParameterSet', ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${OutputCertRequestFile},

        [Parameter(ParameterSetName = 'NewKeyParameterSet', ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = 'ExistingKeyParameterSet', ValueFromPipelineByPropertyName = $true)]
        [switch]
        ${OverwriteExistingCAinDS},

        [Parameter(ParameterSetName = 'NewKeyParameterSet', ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = 'ExistingCertificateParameterSet', ValueFromPipelineByPropertyName = $true)]
        [switch]
        ${OverwriteExistingKey},

        [Parameter(ParameterSetName = 'ExistingKeyParameterSet', ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = 'NewKeyParameterSet', ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${ParentCA},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [switch]
        ${OverwriteExistingDatabase},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [pscredential]
        ${Credential},

        [switch]
        ${Force}
    )
    end
    {
        $PSCmdlet.ThrowTerminatingError(
            [System.Management.Automation.ErrorRecord]::new(
                'StubNotImplemented',
                'StubCalledError',
                [System.Management.Automation.ErrorCategory]::InvalidOperation,
                $MyInvocation.MyCommand
            )
        )
    }
}

function Install-AdcsEnrollmentPolicyWebService
{
    <#
    .SYNOPSIS
        Install-AdcsEnrollmentPolicyWebService [-AuthenticationType <AuthenticationType>] [-SSLCertThumbprint <string>] [-KeyBasedRenewal] [-Force] [-Credential <pscredential>] [-WhatIf] [-Confirm] [<CommonParameters>]
    #>

    [CmdletBinding(DefaultParameterSetName = 'DefaultParameterSet', SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    #[OutputType([Microsoft.CertificateServices.Deployment.Common.CEP.EnrollmentPolicyServiceResult])]
    [OutputType([System.Object])]
    param (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [System.String]
        ${AuthenticationType},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${SSLCertThumbprint},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [switch]
        ${KeyBasedRenewal},

        [switch]
        ${Force},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [pscredential]
        ${Credential}
    )
    end
    {
        $PSCmdlet.ThrowTerminatingError(
            [System.Management.Automation.ErrorRecord]::new(
                'StubNotImplemented',
                'StubCalledError',
                [System.Management.Automation.ErrorCategory]::InvalidOperation,
                $MyInvocation.MyCommand
            )
        )
    }
}

function Install-AdcsEnrollmentWebService
{
    <#
    .SYNOPSIS
        Install-AdcsEnrollmentWebService [-CAConfig <string>] [-ApplicationPoolIdentity] [-AuthenticationType <AuthenticationType>] [-SSLCertThumbprint <string>] [-RenewalOnly] [-AllowKeyBasedRenewal] [-Force] [-Credential <pscredential>] [-WhatIf] [-Confirm] [<CommonParameters>]

Install-AdcsEnrollmentWebService -ServiceAccountName <string> -ServiceAccountPassword <securestring> [-CAConfig <string>] [-AuthenticationType <AuthenticationType>] [-SSLCertThumbprint <string>] [-RenewalOnly] [-AllowKeyBasedRenewal] [-Force] [-Credential <pscredential>] [-WhatIf] [-Confirm] [<CommonParameters>]
    #>

    [CmdletBinding(DefaultParameterSetName = 'DefaultParameterSet', SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    #[OutputType([Microsoft.CertificateServices.Deployment.Common.CES.EnrollmentServiceResult])]
    [OutputType([System.Object])]
    param (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${CAConfig},

        [Parameter(ParameterSetName = 'ServiceAccountParameterSet', Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${ServiceAccountName},

        [Parameter(ParameterSetName = 'ServiceAccountParameterSet', Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [securestring]
        ${ServiceAccountPassword},

        [Parameter(ParameterSetName = 'DefaultParameterSet', ValueFromPipelineByPropertyName = $true)]
        [switch]
        ${ApplicationPoolIdentity},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [System.String]
        ${AuthenticationType},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${SSLCertThumbprint},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [switch]
        ${RenewalOnly},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [switch]
        ${AllowKeyBasedRenewal},

        [switch]
        ${Force},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [pscredential]
        ${Credential}
    )
    end
    {
        $PSCmdlet.ThrowTerminatingError(
            [System.Management.Automation.ErrorRecord]::new(
                'StubNotImplemented',
                'StubCalledError',
                [System.Management.Automation.ErrorCategory]::InvalidOperation,
                $MyInvocation.MyCommand
            )
        )
    }
}

function Install-AdcsNetworkDeviceEnrollmentService
{
    <#
    .SYNOPSIS
        Install-AdcsNetworkDeviceEnrollmentService [-ApplicationPoolIdentity] [-RAName <string>] [-RAEmail <string>] [-RACompany <string>] [-RADepartment <string>] [-RACity <string>] [-RAState <string>] [-RACountry <string>] [-SigningProviderName <string>] [-SigningKeyLength <int>] [-EncryptionProviderName <string>] [-EncryptionKeyLength <int>] [-CAConfig <string>] [-Force] [-Credential <pscredential>] [-WhatIf] [-Confirm] [<CommonParameters>]

Install-AdcsNetworkDeviceEnrollmentService -ServiceAccountName <string> -ServiceAccountPassword <securestring> [-RAName <string>] [-RAEmail <string>] [-RACompany <string>] [-RADepartment <string>] [-RACity <string>] [-RAState <string>] [-RACountry <string>] [-SigningProviderName <string>] [-SigningKeyLength <int>] [-EncryptionProviderName <string>] [-EncryptionKeyLength <int>] [-CAConfig <string>] [-Force] [-Credential <pscredential>] [-WhatIf] [-Confirm] [<CommonParameters>]
    #>

    [CmdletBinding(DefaultParameterSetName = 'DefaultParameterSet', SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    #[OutputType([Microsoft.CertificateServices.Deployment.Common.NDES.NetworkDeviceEnrollmentServiceResult])]
    [OutputType([System.Object])]
    param (
        [Parameter(ParameterSetName = 'DefaultParameterSet', ValueFromPipelineByPropertyName = $true)]
        [switch]
        ${ApplicationPoolIdentity},

        [Parameter(ParameterSetName = 'ServiceAccountParameterSet', Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${ServiceAccountName},

        [Parameter(ParameterSetName = 'ServiceAccountParameterSet', Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [securestring]
        ${ServiceAccountPassword},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${RAName},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${RAEmail},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${RACompany},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${RADepartment},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${RACity},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${RAState},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${RACountry},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${SigningProviderName},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(1, 4294967295)]
        [int]
        ${SigningKeyLength},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${EncryptionProviderName},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(1, 4294967295)]
        [int]
        ${EncryptionKeyLength},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${CAConfig},

        [switch]
        ${Force},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [pscredential]
        ${Credential}
    )
    end
    {
        $PSCmdlet.ThrowTerminatingError(
            [System.Management.Automation.ErrorRecord]::new(
                'StubNotImplemented',
                'StubCalledError',
                [System.Management.Automation.ErrorCategory]::InvalidOperation,
                $MyInvocation.MyCommand
            )
        )
    }
}

function Install-AdcsOnlineResponder
{
    <#
    .SYNOPSIS
        Install-AdcsOnlineResponder [-Force] [-Credential <pscredential>] [-WhatIf] [-Confirm] [<CommonParameters>]
    #>

    [CmdletBinding(DefaultParameterSetName = 'DefaultParameterSet', SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    #[OutputType([Microsoft.CertificateServices.Deployment.Common.OCSP.OnlineResponderResult])]
    [OutputType([System.Object])]
    param (
        [switch]
        ${Force},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [pscredential]
        ${Credential}
    )
    end
    {
        $PSCmdlet.ThrowTerminatingError(
            [System.Management.Automation.ErrorRecord]::new(
                'StubNotImplemented',
                'StubCalledError',
                [System.Management.Automation.ErrorCategory]::InvalidOperation,
                $MyInvocation.MyCommand
            )
        )
    }
}

function Install-AdcsWebEnrollment
{
    <#
    .SYNOPSIS
        Install-AdcsWebEnrollment [-CAConfig <string>] [-Force] [-Credential <pscredential>] [-WhatIf] [-Confirm] [<CommonParameters>]
    #>

    [CmdletBinding(DefaultParameterSetName = 'DefaultParameterSet', SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    #[OutputType([Microsoft.CertificateServices.Deployment.Common.WEP.WebEnrollmentResult])]
    [OutputType([System.Object])]
    param (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${CAConfig},

        [switch]
        ${Force},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [pscredential]
        ${Credential}
    )
    end
    {
        $PSCmdlet.ThrowTerminatingError(
            [System.Management.Automation.ErrorRecord]::new(
                'StubNotImplemented',
                'StubCalledError',
                [System.Management.Automation.ErrorCategory]::InvalidOperation,
                $MyInvocation.MyCommand
            )
        )
    }
}

function Uninstall-AdcsCertificationAuthority
{
    <#
    .SYNOPSIS
        Uninstall-AdcsCertificationAuthority [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
    #>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    #[OutputType([Microsoft.CertificateServices.Deployment.Common.CA.CertificationAuthoritySetupResult])]
    [OutputType([System.Object])]
    param (
        [switch]
        ${Force}
    )
    end
    {
        $PSCmdlet.ThrowTerminatingError(
            [System.Management.Automation.ErrorRecord]::new(
                'StubNotImplemented',
                'StubCalledError',
                [System.Management.Automation.ErrorCategory]::InvalidOperation,
                $MyInvocation.MyCommand
            )
        )
    }
}

function Uninstall-AdcsEnrollmentPolicyWebService
{
    <#
    .SYNOPSIS
        Uninstall-AdcsEnrollmentPolicyWebService -AuthenticationType <AuthenticationType> [-KeyBasedRenewal] [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]

Uninstall-AdcsEnrollmentPolicyWebService [-AllPolicyServers] [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
    #>

    [CmdletBinding(DefaultParameterSetName = 'UninstallSingleInstance', SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    #[OutputType([Microsoft.CertificateServices.Deployment.Common.CEP.EnrollmentPolicyServiceResult])]
    [OutputType([System.Object])]
    param (
        [Parameter(ParameterSetName = 'UninstallAll', ValueFromPipelineByPropertyName = $true)]
        [switch]
        ${AllPolicyServers},

        [Parameter(ParameterSetName = 'UninstallSingleInstance', Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [System.String]
        ${AuthenticationType},

        [Parameter(ParameterSetName = 'UninstallSingleInstance', ValueFromPipelineByPropertyName = $true)]
        [switch]
        ${KeyBasedRenewal},

        [switch]
        ${Force}
    )
    end
    {
        $PSCmdlet.ThrowTerminatingError(
            [System.Management.Automation.ErrorRecord]::new(
                'StubNotImplemented',
                'StubCalledError',
                [System.Management.Automation.ErrorCategory]::InvalidOperation,
                $MyInvocation.MyCommand
            )
        )
    }
}

function Uninstall-AdcsEnrollmentWebService
{
    <#
    .SYNOPSIS
        Uninstall-AdcsEnrollmentWebService -CAConfig <string> -AuthenticationType <AuthenticationType> [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]

Uninstall-AdcsEnrollmentWebService [-AllEnrollmentServices] [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
    #>

    [CmdletBinding(DefaultParameterSetName = 'UninstallSingleInstance', SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    #[OutputType([Microsoft.CertificateServices.Deployment.Common.CES.EnrollmentServiceResult])]
    [OutputType([System.Object])]
    param (
        [Parameter(ParameterSetName = 'UninstallSingleInstance', Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${CAConfig},

        [Parameter(ParameterSetName = 'UninstallSingleInstance', Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [System.String]
        ${AuthenticationType},

        [Parameter(ParameterSetName = 'UninstallAll', ValueFromPipelineByPropertyName = $true)]
        [switch]
        ${AllEnrollmentServices},

        [switch]
        ${Force}
    )
    end
    {
        $PSCmdlet.ThrowTerminatingError(
            [System.Management.Automation.ErrorRecord]::new(
                'StubNotImplemented',
                'StubCalledError',
                [System.Management.Automation.ErrorCategory]::InvalidOperation,
                $MyInvocation.MyCommand
            )
        )
    }
}

function Uninstall-AdcsNetworkDeviceEnrollmentService
{
    <#
    .SYNOPSIS
        Uninstall-AdcsNetworkDeviceEnrollmentService [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
    #>

    [CmdletBinding(DefaultParameterSetName = 'DefaultParameterSet', SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    #[OutputType([Microsoft.CertificateServices.Deployment.Common.NDES.NetworkDeviceEnrollmentServiceResult])]
    [OutputType([System.Object])]
    param (
        [switch]
        ${Force}
    )
    end
    {
        $PSCmdlet.ThrowTerminatingError(
            [System.Management.Automation.ErrorRecord]::new(
                'StubNotImplemented',
                'StubCalledError',
                [System.Management.Automation.ErrorCategory]::InvalidOperation,
                $MyInvocation.MyCommand
            )
        )
    }
}

function Uninstall-AdcsOnlineResponder
{
    <#
    .SYNOPSIS
        Uninstall-AdcsOnlineResponder [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
    #>

    [CmdletBinding(DefaultParameterSetName = 'DefaultParameterSet', SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    #[OutputType([Microsoft.CertificateServices.Deployment.Common.OCSP.OnlineResponderResult])]
    [OutputType([System.Object])]
    param (
        [switch]
        ${Force}
    )
    end
    {
        $PSCmdlet.ThrowTerminatingError(
            [System.Management.Automation.ErrorRecord]::new(
                'StubNotImplemented',
                'StubCalledError',
                [System.Management.Automation.ErrorCategory]::InvalidOperation,
                $MyInvocation.MyCommand
            )
        )
    }
}

function Uninstall-AdcsWebEnrollment
{
    <#
    .SYNOPSIS
        Uninstall-AdcsWebEnrollment [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
    #>

    [CmdletBinding(DefaultParameterSetName = 'DefaultParameterSet', SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    #[OutputType([Microsoft.CertificateServices.Deployment.Common.WEP.WebEnrollmentResult])]
    [OutputType([System.Object])]
    param (
        [switch]
        ${Force}
    )
    end
    {
        $PSCmdlet.ThrowTerminatingError(
            [System.Management.Automation.ErrorRecord]::new(
                'StubNotImplemented',
                'StubCalledError',
                [System.Management.Automation.ErrorCategory]::InvalidOperation,
                $MyInvocation.MyCommand
            )
        )
    }
}
