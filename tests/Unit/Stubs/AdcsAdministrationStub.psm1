# This section suppresses rules PsScriptAnalyzer may catch in stub functions.
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '')]

# Name: ADCSAdministration
# Version: 2.0.0.0

[CmdletBinding()]
param ()

function Add-CAAuthorityInformationAccess
{
    <#
    .SYNOPSIS
        Add-CAAuthorityInformationAccess [-InputObject] <AuthorityInformationAccess> [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]

Add-CAAuthorityInformationAccess [-Uri] <string> -AddToCertificateOcsp [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]

Add-CAAuthorityInformationAccess [-Uri] <string> -AddToCertificateAia [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
    #>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    #[OutputType([Microsoft.CertificateServices.Administration.Commands.CA.AuthorityInformationAccessResult])]
    [OutputType([System.Object])]
    param (
        [Parameter(ParameterSetName = 'AddAsInputObject', Mandatory = $true, Position = 1, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        #[Microsoft.CertificateServices.Administration.Commands.CA.AuthorityInformationAccess]
        [System.Object]
        ${InputObject},

        [Parameter(ParameterSetName = 'AddAsOCSP', Mandatory = $true, Position = 1, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = 'AddAsAIA', Mandatory = $true, Position = 1, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Uri},

        [Parameter(ParameterSetName = 'AddAsAIA', Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [switch]
        ${AddToCertificateAia},

        [Parameter(ParameterSetName = 'AddAsOCSP', Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [switch]
        ${AddToCertificateOcsp},

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

function Add-CACrlDistributionPoint
{
    <#
    .SYNOPSIS
        Add-CACrlDistributionPoint [-Uri] <string> [-AddToCertificateCdp] [-AddToFreshestCrl] [-AddToCrlCdp] [-AddToCrlIdp] [-PublishToServer] [-PublishDeltaToServer] [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
    #>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    #[OutputType([Microsoft.CertificateServices.Administration.Commands.CA.CrlDistributionPointResult])]
    [OutputType([System.Object])]
    param (
        [Parameter(Mandatory = $true, Position = 1, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Uri},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [switch]
        ${AddToCertificateCdp},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [switch]
        ${AddToFreshestCrl},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [switch]
        ${AddToCrlCdp},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [switch]
        ${AddToCrlIdp},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [switch]
        ${PublishToServer},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [switch]
        ${PublishDeltaToServer},

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

function Add-CATemplate
{
    <#
    .SYNOPSIS
        Add-CATemplate [-Name] <string> [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
    #>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param (
        [Parameter(Mandatory = $true, Position = 1, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Name},

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

function Backup-CARoleService
{
    <#
    .SYNOPSIS
        Backup-CARoleService [-Path] <string> -KeyOnly [-Force] [-Password <securestring>] [<CommonParameters>]

Backup-CARoleService [-Path] <string> -DatabaseOnly [-Force] [-Incremental] [-KeepLog] [<CommonParameters>]

Backup-CARoleService [-Path] <string> [-Force] [-Password <securestring>] [-Incremental] [-KeepLog] [<CommonParameters>]
    #>

    [CmdletBinding()]
    [OutputType([System.Void])]
    param (
        [Parameter(Mandatory = $true, Position = 1, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Path},

        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [switch]
        ${Force},

        [Parameter(ParameterSetName = 'Key', Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [switch]
        ${KeyOnly},

        [Parameter(ParameterSetName = 'Database', Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [switch]
        ${DatabaseOnly},

        [Parameter(ParameterSetName = 'All', ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = 'Key', ValueFromPipelineByPropertyName = $true)]
        [securestring]
        ${Password},

        [Parameter(ParameterSetName = 'Database', ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = 'All', ValueFromPipelineByPropertyName = $true)]
        [switch]
        ${Incremental},

        [Parameter(ParameterSetName = 'Database', ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = 'All', ValueFromPipelineByPropertyName = $true)]
        [switch]
        ${KeepLog}
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

function Confirm-CAAttestationIdentityKeyInfo
{
    <#
    .SYNOPSIS
        Confirm-CAAttestationIdentityKeyInfo [-PublicKeyHash] <string> [<CommonParameters>]

Confirm-CAAttestationIdentityKeyInfo [-Certificate] <X509Certificate2> [<CommonParameters>]
    #>

    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter(ParameterSetName = 'PublicKeyHash', Mandatory = $true, Position = 1, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidatePattern('^[0-9a-fA-F]{64}$')]
        [string]
        ${PublicKeyHash},

        [Parameter(ParameterSetName = 'Certificate', Mandatory = $true, Position = 1, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNull()]
        [System.Security.Cryptography.X509Certificates.X509Certificate2]
        ${Certificate}
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

function Confirm-CAEndorsementKeyInfo
{
    <#
    .SYNOPSIS
        Confirm-CAEndorsementKeyInfo [-PublicKeyHash] <string> [<CommonParameters>]

Confirm-CAEndorsementKeyInfo [-Certificate] <X509Certificate2> [<CommonParameters>]
    #>

    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter(ParameterSetName = 'PublicKeyHash', Mandatory = $true, Position = 1, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidatePattern('^[0-9a-fA-F]{64}$')]
        [string]
        ${PublicKeyHash},

        [Parameter(ParameterSetName = 'Certificate', Mandatory = $true, Position = 1, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNull()]
        [System.Security.Cryptography.X509Certificates.X509Certificate2]
        ${Certificate}
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

function Get-CAAuthorityInformationAccess
{
    <#
    .SYNOPSIS
        Get-CAAuthorityInformationAccess [<CommonParameters>]
    #>

    [CmdletBinding()]
    #[OutputType([Microsoft.CertificateServices.Administration.Commands.CA.AuthorityInformationAccess])]
    [OutputType([System.Object])]
    param ( )
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

function Get-CACrlDistributionPoint
{
    <#
    .SYNOPSIS
        Get-CACrlDistributionPoint [<CommonParameters>]
    #>

    [CmdletBinding()]
    #[OutputType([Microsoft.CertificateServices.Administration.Commands.CA.CrlDistributionPoint])]
    [OutputType([System.Object])]
    param ( )
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

function Get-CATemplate
{
    <#
    .SYNOPSIS
        Get-CATemplate [<CommonParameters>]
    #>

    [CmdletBinding()]
    #[OutputType([Microsoft.CertificateServices.Administration.Commands.Common.CertificateTemplate])]
    [OutputType([System.Object])]
    param ( )
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

function Remove-CAAuthorityInformationAccess
{
    <#
    .SYNOPSIS
        Remove-CAAuthorityInformationAccess [-Uri] <string> [-AddToCertificateAia] [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]

Remove-CAAuthorityInformationAccess [-Uri] <string> [-AddToCertificateOcsp] [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
    #>

    [CmdletBinding(DefaultParameterSetName = 'RemoveAsAIA', SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    #[OutputType([Microsoft.CertificateServices.Administration.Commands.CA.AuthorityInformationAccessResult])]
    [OutputType([System.Object])]
    param (
        [Parameter(Mandatory = $true, Position = 1, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Uri},

        [Parameter(ParameterSetName = 'RemoveAsAIA', ValueFromPipelineByPropertyName = $true)]
        [switch]
        ${AddToCertificateAia},

        [Parameter(ParameterSetName = 'RemoveAsOCSP', ValueFromPipelineByPropertyName = $true)]
        [switch]
        ${AddToCertificateOcsp},

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

function Remove-CACrlDistributionPoint
{
    <#
    .SYNOPSIS
        Remove-CACrlDistributionPoint [-Uri] <string> [-AddToCertificateCdp] [-AddToFreshestCrl] [-AddToCrlCdp] [-AddToCrlIdp] [-PublishToServer] [-PublishDeltaToServer] [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
    #>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    #[OutputType([Microsoft.CertificateServices.Administration.Commands.CA.CrlDistributionPointResult])]
    [OutputType([System.Object])]
    param (
        [Parameter(Mandatory = $true, Position = 1, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Uri},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [switch]
        ${AddToCertificateCdp},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [switch]
        ${AddToFreshestCrl},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [switch]
        ${AddToCrlCdp},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [switch]
        ${AddToCrlIdp},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [switch]
        ${PublishToServer},

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [switch]
        ${PublishDeltaToServer},

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

function Remove-CATemplate
{
    <#
    .SYNOPSIS
        Remove-CATemplate [-Name] <string> [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]

Remove-CATemplate -AllTemplates [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
    #>

    [CmdletBinding(DefaultParameterSetName = 'Default', SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param (
        [Parameter(ParameterSetName = 'Default', Mandatory = $true, Position = 1, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Name},

        [Parameter(ParameterSetName = 'AllTemplates', Mandatory = $true)]
        [switch]
        ${AllTemplates},

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

function Restore-CARoleService
{
    <#
    .SYNOPSIS
        Restore-CARoleService [-Path] <string> -KeyOnly [-Force] [-Password <securestring>] [-WhatIf] [-Confirm] [<CommonParameters>]

Restore-CARoleService [-Path] <string> -DatabaseOnly [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]

Restore-CARoleService [-Path] <string> [-Force] [-Password <securestring>] [-WhatIf] [-Confirm] [<CommonParameters>]
    #>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    [OutputType([System.Void])]
    param (
        [Parameter(Mandatory = $true, Position = 1, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        ${Path},

        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [switch]
        ${Force},

        [Parameter(ParameterSetName = 'Key', Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [switch]
        ${KeyOnly},

        [Parameter(ParameterSetName = 'Database', Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [switch]
        ${DatabaseOnly},

        [Parameter(ParameterSetName = 'Key', ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = 'All', ValueFromPipelineByPropertyName = $true)]
        [securestring]
        ${Password}
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
