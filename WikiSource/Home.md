# Welcome to the ActiveDirectoryCSDsc wiki

Here you will find all the information you need to make use of the ActiveDirectoryCSDsc
DSC resources, including details of the resources that are available, current
capabilities and known issues, and information to help plan a DSC based
implementation of ActiveDirectoryCSDsc.

Please leave comments, feature requests, and bug reports in then
[issues section](https://github.com/PowerShell/ActiveDirectoryCSDsc/issues) for this module.

## Getting started

To get started download ActiveDirectoryCSDsc from the [PowerShell Gallery](http://www.powershellgallery.com/packages/ActiveDirectoryCSDsc/)
and then unzip it to one of your PowerShell modules folders
(such as $env:ProgramFiles\WindowsPowerShell\Modules).

To install from the PowerShell gallery using PowerShellGet (in PowerShell 5.0)
run the following command:

```powershell
Find-Module -Name ActiveDirectoryCSDsc -Repository PSGallery | Install-Module
```

To confirm installation, run the below command and ensure you see the ActiveDirectoryCSDsc
DSC resources available:

```powershell
Get-DscResource -Module ActiveDirectoryCSDsc
```
