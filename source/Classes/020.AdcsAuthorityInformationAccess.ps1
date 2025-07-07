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

    .PARAMETER Ensure
        Specifies whether the WS-Man Listener should exist.

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

    [DscProperty(Mandatory)]
    [Ensure]
    $Ensure = [Ensure]::Present

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

    # Base method Get() call this method to get the current state as a Hashtable.
    [System.Collections.Hashtable] GetCurrentState([System.Collections.Hashtable] $properties)
    {
        $state = @{}

        $aia = [System.String[]] (Get-CaAiaUriList -ExtensionType 'AddToCertificateAia')
        $ocsp = [System.String[]] (Get-CaAiaUriList -ExtensionType 'AddToCertificateOcsp')

        if ($aia -or $ocsp)
        {
            $state = @{
                IsSingleInstance = $properties.IsSingleInstance
                AiaUri           = $aia
                OcspUri          = $ocsp
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

        if ($properties.ContainsKey($this.AiaUri.Name))
        {
            # Add any missing AIA URIs
            foreach ($desiredAiaUri in $this.CachedDesiredState.AiaUri)
            {
                if ($desiredAiaUri -notin $this.AiaUri)
                {
                    Write-Debug -Message ($script:localizedData.AddingAdcsAiaUriMessage -f 'AIA', $desiredAiaUri)

                    Add-CAAuthorityInformationAccess -Uri $desiredAiaUri -AddToCertificateAia -Force

                    $RestartRequired = $true
                }
            }

            # Remove any AIA URIs that aren't required
            foreach ($currentAiaUri in $this.AiaUri)
            {
                if ($currentAiaUri -notin $this.AiaUri)
                {
                    Write-Debug -Message ($script:localizedData.RemovingAdcsAiaUriMessage -f 'AIA', $currentAiaUri)

                    Remove-CAAuthorityInformationAccess -Uri $currentAiaUri -AddToCertificateAia -Force

                    $RestartRequired = $true
                }
            }
        }

        # if ($properties.ContainsKey($this.AiaUri.Name))
        # {
        #     # Add any missing OCSP URIs
        #     foreach ($desiredOcspUri in $OcspUri)
        #     {
        #         if ($desiredOcspUri -notin $currentResource.OcspUri)
        #         {
        #             Write-Debug -Message ($script:localizedData.AddingAdcsAiaUriMessage -f 'OCSP', $desiredOcspUri)

        #             Add-CAAuthorityInformationAccess -Uri $desiredOcspUri -AddToCertificateOcsp -Force

        #             $RestartRequired = $true
        #         }
        #     }

        #     # Remove any OCSP URIs that aren't required
        #     foreach ($currentOcspUri in $currentResource.OcspUri)
        #     {
        #         if ($currentOcspUri -notin $OcspUri)
        #         {
        #             Write-Debug -Message ($script:localizedData.RemovingAdcsAiaUriMessage -f 'OCSP', $currentOcspUri)

        #             Remove-CAAuthorityInformationAccess -Uri $currentOcspUri -AddToCertificateOcsp -Force

        #             $RestartRequired = $true
        #         }
        #     }
        # }

        if ($RestartRequired -and $this.AllowRestartService)
        {
            Write-Debug -Message $script:localizedData.RestartingCertSvcMessage

            $null = Restart-ServiceIfExists -Name 'CertSvc'
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
        Assert-Module -Name ADCSAdministration

        $assertBoundParameterParameters = @{
            BoundParameterList = $properties
            RequiredParameter  = @(
                'AiaUri'
                'OcspUri'
            )
            RequiredBehavior   = 'All'
        }

        Assert-BoundParameter @assertBoundParameterParameters
    }
}
