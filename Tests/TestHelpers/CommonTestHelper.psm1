<#
    .SYNOPSIS
        Returns an invalid argument exception object

    .PARAMETER Message
        The message explaining why this error is being thrown

    .PARAMETER ArgumentName
        The name of the invalid argument that is causing this error to be thrown
#>
function Get-InvalidArgumentRecord
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Message,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ArgumentName
    )

    $argumentException = New-Object -TypeName 'ArgumentException' -ArgumentList @( $Message, $ArgumentName )

    $newObjectParams = @{
        TypeName     = 'System.Management.Automation.ErrorRecord'
        ArgumentList = @(
            $argumentException
            $ArgumentName
            'InvalidArgument'
            $null
        )
    }

    return New-Object @newObjectParams
}

<#
    .SYNOPSIS
        Returns an invalid operation exception object

    .PARAMETER Message
        The message explaining why this error is being thrown

    .PARAMETER ErrorRecord
        The error record containing the exception that is causing this terminating error
#>
function Get-InvalidOperationRecord
{
    [CmdletBinding()]
    param
    (
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Message,

        [ValidateNotNull()]
        [System.Management.Automation.ErrorRecord]
        $ErrorRecord
    )

    if ($null -eq $Message)
    {
        $invalidOperationException = New-Object -TypeName 'InvalidOperationException'
    }
    elseif ($null -eq $ErrorRecord)
    {
        $invalidOperationException = New-Object -TypeName 'InvalidOperationException' -ArgumentList @( $Message )
    }
    else
    {
        $invalidOperationException = New-Object -TypeName 'InvalidOperationException' -ArgumentList @( $Message, $ErrorRecord.Exception )
    }

    $newObjectParams = @{
        TypeName     = 'System.Management.Automation.ErrorRecord'
        ArgumentList = @(
            $invalidOperationException.ToString()
            'MachineStateIncorrect'
            'InvalidOperation'
            $null
        )
    }

    return New-Object @newObjectParams
}

<#
    .SYNOPSIS
        Tests if a specific Server Feature is installed on this OS.

    .OUTPUTS
        False if this is a non-Windows Server OS.
        True if a specific Server feature is installed, otherwise False is returned.

#>
function Test-WindowsFeature
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name
    )

    # Ensure that the tests can be performed on this computer
    $productType = (Get-CimInstance Win32_OperatingSystem).productType

    if ($productType -ne 3)
    {
        # Unsupported OS type for testing
        Write-Verbose -Message "Integration tests cannot be run on this operating system." -Verbose
        return $false
    }

    # Server OS
    if (-not (Get-WindowsFeature @PSBoundParameters).Installed)
    {
        Write-Verbose -Message "Integration tests cannot be run because $Name is not installed." -Verbose
        return $false
    }

    return $True
} # end function Test-WindowsFeature

Export-ModuleMember -Function @(
    'Get-InvalidArgumentRecord'
    'Get-InvalidOperationRecord'
    'Test-WindowsFeature'
)
