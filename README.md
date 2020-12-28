# ActiveDirectoryCSDsc

[![Build Status](https://dev.azure.com/dsccommunity/ActiveDirectoryCSDsc/_apis/build/status/dsccommunity.ActiveDirectoryCSDsc?branchName=main)](https://dev.azure.com/dsccommunity/ActiveDirectoryCSDsc/_build/latest?definitionId=24&branchName=main)
![Code Coverage](https://img.shields.io/azure-devops/coverage/dsccommunity/ActiveDirectoryCSDsc/24/main)
[![Azure DevOps tests](https://img.shields.io/azure-devops/tests/dsccommunity/ActiveDirectoryCSDsc/24/main)](https://dsccommunity.visualstudio.com/ActiveDirectoryCSDsc/_test/analytics?definitionId=24&contextType=build)
[![PowerShell Gallery (with prereleases)](https://img.shields.io/powershellgallery/vpre/ActiveDirectoryCSDsc?label=ActiveDirectoryCSDsc%20Preview)](https://www.powershellgallery.com/packages/ActiveDirectoryCSDsc/)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/v/ActiveDirectoryCSDsc?label=ActiveDirectoryCSDsc)](https://www.powershellgallery.com/packages/ActiveDirectoryCSDsc/)

## Code of Conduct

This project has adopted [this code of conduct](CODE_OF_CONDUCT.md).

## Releases

For each merge to the branch `main` a preview release will be
deployed to [PowerShell Gallery](https://www.powershellgallery.com/).
Periodically a release version tag will be pushed which will deploy a
full release to [PowerShell Gallery](https://www.powershellgallery.com/).

## Contributing

Please check out common DSC Community [contributing guidelines](https://dsccommunity.org/guidelines/contributing).

## Change log

A full list of changes in each version can be found in the [change log](CHANGELOG.md).

## Resources

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

- **AdcsAuthorityInformationAccess**: This resource can be used to configure the
  URIs in the Authority Information Access and Online Responder OCSP extensions
  of certificates issued by an Active Directory Certificate Authority.
- **AdcsCertificationAuthority**: This resource can be used to install the ADCS
  Certificate Authority after the feature has been installed on the server.
- **AdcsEnrollmentPolicyWebService**: This resource can be used to
  install an ADCS Certificate Enrollment Policy Web Service on the server after
  the feature has been installed on the server.
- **AdcsOnlineResponder**: This resource can be used to install an ADCS Online
  Responder after the feature has been installed on the server.
- **AdcsWebEnrollment**: This resource can be used to install the ADCS Web
  Enrollment service after the feature has been installed on the server.
- **AdcsTemplate**: This resource can be used to add or remove Certificate
  Authority templates to an Enterprise CA, after the feature has been installed
  on the server and the `AdcsCertificationAuthority` resource installed with a
  `CAType` of `EnterpriseRootCA` or `EnterpriseSubordinateCA`.

## Documentation and Examples

For a full list of resources in ActiveDirectoryCSDsc and examples on their use, check
out the [ActiveDirectoryCSDsc wiki](https://github.com/dsccommunity/ActiveDirectoryCSDsc/wiki).
