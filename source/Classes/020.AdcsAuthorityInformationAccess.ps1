<#
    .SYNOPSIS
        The `AdcsAuthorityInformationAccess` DSC resource is used to configure the
        URIs in the Authority Information Access and Online Responder OCSP extensions.

    .DESCRIPTION
        This resource can be used to configure the URIs in the Authority Information
        Access and Online Responder OCSP extensions of certificates issued by an
        Active Directory Certificate Authority.

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

    .PARAMETER Reasons
        Returns the reason a property is not in desired state.
#>

[DscResource()]
class AdcsAuthorityInformationAccess : ResourceBase
{
    [DscProperty(Key)]
    [System.String]
    $IsSingleInstance = 'Yes'

    [DscProperty()]
    [System.String[]]
    $AiaUri

    [DscProperty()]
    [System.String[]]
    $OcspUri

    [DscProperty()]
    [Nullable[System.Boolean]]
    $AllowRestartService

    [DscProperty(NotConfigurable)]
    [AdcsReason[]]
    $Reasons

    AdcsAuthorityInformationAccess () : base ($PSScriptRoot)
    {
        # These properties will not be enforced.
        $this.ExcludeDscProperties = @(
            'IsSingleInstance'
            'AllowRestartService'
        )
    }

    [AdcsAuthorityInformationAccess] Get()
    {
        # Call the base method to return the properties.
        return ([ResourceBase] $this).Get()
    }

    # Base method Get() calls this method to get the current state as a Hashtable.
    [System.Collections.Hashtable] GetCurrentState([System.Collections.Hashtable] $properties)
    {
        $state = @{}

        $AiaList = [System.String[]] (Get-CaAiaUriList -ExtensionType 'AddToCertificateAia')
        $OcspList = [System.String[]] (Get-CaAiaUriList -ExtensionType 'AddToCertificateOcsp')

        if ($AiaList -or $OcspList)
        {
            $state = @{
                IsSingleInstance = $properties.IsSingleInstance
                AiaUri           = $AiaList
                OcspUri          = $OcspList
            }
        }

        return $state
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
        $RestartRequired = $false

        if ($properties.ContainsKey('AiaUri'))
        {
            # Get the array number of the entry
            $index = [System.Array]::IndexOf($this.PropertiesNotInDesiredState.Property, 'AiaUri')

            # Add any missing AIA URIs
            foreach ($desiredAiaUri in $this.PropertiesNotInDesiredState[$index].ExpectedValue)
            {
                if ($desiredAiaUri -notin $this.PropertiesNotInDesiredState[$index].ActualValue)
                {
                    Write-Debug -Message ($this.localizedData.AddingAdcsAiaUriMessage -f 'AIA', $desiredAiaUri)

                    Add-CAAuthorityInformationAccess -Uri $desiredAiaUri -AddToCertificateAia -Force -Verbose:$false

                    $RestartRequired = $true
                }
            }

            # Remove any AIA URIs that aren't required
            foreach ($currentAiaUri in $this.PropertiesNotInDesiredState[$index].ActualValue)
            {
                if ($currentAiaUri -notin $this.PropertiesNotInDesiredState[$index].ExpectedValue)
                {
                    Write-Debug -Message ($this.localizedData.RemovingAdcsAiaUriMessage -f 'AIA', $currentAiaUri)

                    Remove-CAAuthorityInformationAccess -Uri $currentAiaUri -AddToCertificateAia -Force -Verbose:$false

                    $RestartRequired = $true
                }
            }
        }

        if ($properties.ContainsKey('OcspUri'))
        {
            # Get the array number of the entry
            $index = [System.Array]::IndexOf($this.PropertiesNotInDesiredState.Property, 'OcspUri')

            # Add any missing OCSP URIs
            foreach ($desiredOcspUri in $this.PropertiesNotInDesiredState[$index].ExpectedValue)
            {
                if ($desiredOcspUri -notin $this.PropertiesNotInDesiredState[$index].ActualValue)
                {
                    Write-Debug -Message ($this.localizedData.AddingAdcsAiaUriMessage -f 'OCSP', $desiredOcspUri)

                    Add-CAAuthorityInformationAccess -Uri $desiredOcspUri -AddToCertificateOcsp -Force -Verbose:$false

                    $RestartRequired = $true
                }
            }

            # Remove any OCSP URIs that aren't required
            foreach ($currentOcspUri in $this.PropertiesNotInDesiredState[$index].ActualValue)
            {
                if ($currentOcspUri -notin $this.PropertiesNotInDesiredState[$index].ExpectedValue)
                {
                    Write-Debug -Message ($this.localizedData.RemovingAdcsAiaUriMessage -f 'OCSP', $currentOcspUri)

                    Remove-CAAuthorityInformationAccess -Uri $currentOcspUri -AddToCertificateOcsp -Force -Verbose:$false

                    $RestartRequired = $true
                }
            }
        }

        if ($RestartRequired -and $this.AllowRestartService)
        {
            Write-Debug -Message $this.localizedData.RestartingCertSvcMessage

            $null = Restart-ServiceIfExists -Name 'CertSvc' -Verbose:$false
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
        Assert-Module -ModuleName 'ADCSAdministration'

        $assertBoundParameterParameters = @{
            BoundParameterList = $properties
            RequiredParameter  = @(
                'AiaUri'
                'OcspUri'
            )
            RequiredBehavior   = 'Any'
        }

        Assert-BoundParameter @assertBoundParameterParameters
    }
}
