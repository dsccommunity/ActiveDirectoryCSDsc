<#
    .SYNOPSIS
        The `AdcsOnlineResponder` DSC resource is used to configure the
        ADCS Online Responder after the feature has been installed on the server.

    .DESCRIPTION
        This resource can be used to install an ADCS Online Responder after the feature
        has been installed on the server.
        Using this DSC Resource to configure an ADCS Certificate Authority assumes that
        the ```ADCS-Online-Responder``` feature has already been installed.

    .PARAMETER IsSingleInstance
        Specifies the resource is a single instance, the value must be 'Yes'.

    .PARAMETER Credential
        If the Online Responder service is configured to use Standalone certification authority,
        then an account that is a member of the local Administrators on the CA is required. If
        the Online Responder service is configured to use an Enterprise CA, then an account that
        is a member of Domain Admins is required.

    .PARAMETER Ensure
        Specifies whether the Online Responder feature should be installed or uninstalled.

    .PARAMETER Reasons
        Returns the reason a property is not in desired state.

    .NOTES
        Used Functions:
            Name                          | Module
            ----------------------------- |-------------------
            Install-AdcsOnlineResponder   | ADCSDeployment
            Uninstall-AdcsOnlineResponder | ADCSDeployment
            Assert-Module                 | DscResource.Common
            New-InvalidOperationException | DscResource.Common
#>

[DscResource()]
class AdcsOnlineResponder : ResourceBase
{
    [DscProperty(Key)]
    [System.String]
    $IsSingleInstance = 'Yes'

    [DscProperty(Mandatory)]
    [System.Management.Automation.PSCredential]
    [System.Management.Automation.Credential()]
    $Credential

    [DscProperty()]
    [Ensure]
    $Ensure = [Ensure]::Present

    [DscProperty(NotConfigurable)]
    [AdcsReason[]]
    $Reasons

    AdcsOnlineResponder () : base ($PSScriptRoot)
    {
        # These properties will not be enforced.
        $this.ExcludeDscProperties = @(
            'IsSingleInstance'
            'Credential'
        )
    }

    [AdcsOnlineResponder] Get()
    {
        # Call the base method to return the properties.
        return ([ResourceBase] $this).Get()
    }

    # Base method Get() calls this method to get the current state as a Hashtable.
    [System.Collections.Hashtable] GetCurrentState([System.Collections.Hashtable] $properties)
    {
        try
        {
            $null = Install-AdcsOnlineResponder -Credential $this.Credential -WhatIf

            return @{}
        }
        catch
        {
            return @{
                IsSingleInstance = 'Yes'
                Credential = $this.Credential
            }
        }
        # catch
        # {
        #     New-InvalidOperationException -Message $this.localizedData.ErrorGetCurrentState -ErrorRecord $_
        # }
    }

    [void] Set()
    {
        # Call the base method to enforce the properties.
        ([ResourceBase] $this).Set()
    }

    <#
        Base method Set() call this method with the properties that should be
        enforced and that are not in desired state.
    #>
    hidden [void] Modify([System.Collections.Hashtable] $properties)
    {
        $errorMessage = ''

        if ($properties.ContainsKey('Ensure') -and $properties.Ensure -eq [Ensure]::Absent)
        {
            $errorMessage = (Uninstall-AdcsOnlineResponder -Force).ErrorString
        }
        else
        {
            $errorMessage = (Install-AdcsOnlineResponder -Credential $this.Credential -Force).ErrorString
        }

        if (-not [System.String]::IsNullOrEmpty($errorMessage))
        {
            New-InvalidOperationException -Message $errorMessage
        }
    }

    [System.Boolean] Test()
    {
        # Call the base method to test all of the properties that should be enforced.
        return ([ResourceBase] $this).Test()
    }

    <#
        Base method Assert() call this method with the properties that was assigned
        a value.
    #>
    hidden [void] AssertProperties([System.Collections.Hashtable] $properties)
    {
        Assert-Module -ModuleName 'ADCSDeployment'
    }
}
