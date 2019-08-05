# ActiveDirectoryCSDsc

The **ActiveDirectoryCSDsc** DSC resources have been specifically tested as a method
to populate a Certificate Services server role on Windows Server 2012 R2 and above
after the Certificate Services role and the Web Enrollment feature have been enabled.
Active Directory Certificate Services (AD CS) is used to create certification
authorities and related role services that allow you to issue and manage certificates
used in a variety of applications.

This DSC resource can be used to address some of the most common scenarios including
the need for a Stand-Alone Certificate Authority or an Active Directory Trusted
Root Certificate Authority and the Certificate Services website for users to submit
and complete certificate requests.
In a specific example, when building out a web server workload such as an internal
website that provides confidential information to be accessed from computers that
are members of an Active Directory domain, AD CS can provide a source for the SSL
certificates that will automatically be trusted.

- **AdcsCertificationAuthority**: This resource can be used to install the ADCS
  Certificate Authority after the feature has been installed on the server.
- **AdcsEnrollmentPolicyWebService**: This resource can be used to
  install an ADCS Certificate Enrollment Policy Web Service on the server after
  the feature has been installed on the server.
- **AdcsOnlineResponder**: This resource can be used to install an ADCS Online
  Responder after the feature has been installed on the server.
- **AdcsWebEnrollment**: This resource can be used to install the ADCS Web
  Enrollment service after the feature has been installed on the server.
- **AdcsOcspExtension**: This resource can be used to configure OCSP URI
  extensions on a Certificate Authority after the feature has been installed
  on the server.
- **AdcsTemplate**: This resource can be used to add or remove Certificate
  Authority templates to an Enterprise CA, after the feature has been installed
  on the server and the `AdcsCertificationAuthority` resource installed with a
  `CAType` of `EnterpriseRootCA` or `EnterpriseSubordinateCA`.

This project has adopted [this code of conduct](CODE_OF_CONDUCT.md).

## Documentation and Examples

For a full list of resources in ActiveDirectoryCSDsc and examples on their use, check
out the [ActiveDirectoryCSDsc wiki](https://github.com/PowerShell/ActiveDirectoryCSDsc/wiki).

## Branches

### master

[![Build status](https://ci.appveyor.com/api/projects/status/2uua9s0qgmfmqqrh/branch/master?svg=true)](https://ci.appveyor.com/project/PowerShell/ActiveDirectoryCSDsc/branch/master)
[![codecov](https://codecov.io/gh/PowerShell/ActiveDirectoryCSDsc/branch/master/graph/badge.svg)](https://codecov.io/gh/PowerShell/ActiveDirectoryCSDsc/branch/master)

This is the branch containing the latest release - no contributions should be made
directly to this branch.

### dev

[![Build status](https://ci.appveyor.com/api/projects/status/2uua9s0qgmfmqqrh/branch/dev?svg=true)](https://ci.appveyor.com/project/PowerShell/ActiveDirectoryCSDsc/branch/dev)
[![codecov](https://codecov.io/gh/PowerShell/ActiveDirectoryCSDsc/branch/dev/graph/badge.svg)](https://codecov.io/gh/PowerShell/ActiveDirectoryCSDsc/branch/dev)

This is the development branch to which contributions should be proposed by contributors
as pull requests. This development branch will periodically be merged to the master
branch, and be released to [PowerShell Gallery](https://www.powershellgallery.com/).

## Contributing

Please check out common DSC Resources [contributing guidelines](https://github.com/PowerShell/DscResource.Kit/blob/master/CONTRIBUTING.md).
