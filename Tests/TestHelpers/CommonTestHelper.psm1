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
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Message,

        [Parameter()]
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

<#
    .SYNOPSIS
        Create a new local user account to be created and added to the
        local Administrators group for use by integration tests.

        If the user account already exists but is not in the administrators
        group then add it to the group and make sure the password is set
        to the provided value.

    .PARAMETER Username
        The username of the local user to create and add to the administrators
        group.

    .PARAMETER Password
        The password of the local user account.
#>
function New-LocalUserInAdministratorsGroup
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Username,

        [Parameter(Mandatory = $true)]
        [System.Security.SecureString]
        $Password
    )

    if (Get-LocalUser -Name $Username -ErrorAction SilentlyContinue)
    {
        $null = Set-LocalUser -Name $Username -Password $Password
    }
    else
    {
        $null = New-LocalUser -Name $Username -Password $Password
    }

    if (-not (Get-LocalGroupMember -Group 'administrators' -Member $Username -ErrorAction SilentlyContinue))
    {
        $null = Add-LocalGroupMember -Group 'administrators' -Member $Username
    }
}

<#
    .SYNOPSIS
        Returns an object not found exception.

    .PARAMETER Message
        The message explaining why this error is being thrown.

    .PARAMETER ErrorRecord
        The error record containing the exception that is causing
        this terminating error.
#>
function Get-ObjectNotFoundException
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Message,

        [Parameter()]
        [ValidateNotNull()]
        [System.Management.Automation.ErrorRecord]
        $ErrorRecord
    )

    if ($null -eq $ErrorRecord)
    {
        $exception = New-Object -TypeName 'System.Exception' `
            -ArgumentList @($Message)
    }
    else
    {
        $exception = New-Object -TypeName 'System.Exception' `
            -ArgumentList @($Message, $ErrorRecord.Exception)
    }

    $newObjectParameters = @{
        TypeName     = 'System.Management.Automation.ErrorRecord'
        ArgumentList = @(
            $exception.ToString(),
            'MachineStateIncorrect',
            'ObjectNotFound',
            $null
        )
    }

    return New-Object @newObjectParameters
}

Export-ModuleMember -Function @(
    'Get-InvalidArgumentRecord'
    'Get-InvalidOperationRecord'
    'Test-WindowsFeature'
    'New-LocalUserInAdministratorsGroup'
    'Get-ObjectNotFoundException'
)
