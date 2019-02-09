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

This project has adopted [this code of conduct](CODE_OF_CONDUCT.md).

## Documentation and Examples

For a full list of resources in StorageDsc and examples on their use, check out
the [ActiveDirectoryCSDsc wiki](https://github.com/PowerShell/ActiveDirectoryCSDsc/wiki).

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


### AdcsCertificationAuthority

This resource can be used to install the ADCS Certificate Authority after the
feature has been installed on the server.
Using this DSC Resource to configure an ADCS Certificate Authority assumes that
the `ADCS-Cert-Authority` feature has already been installed.

- **`[String]` IsSingleInstance** (_Key_): Specifies the resource is a single
  instance, the value must be 'Yes'.
- **`[String]` CAType** (_Required_): Specifies the type of certification
  authority to install. { EnterpriseRootCA | EnterpriseSubordinateCA |
  StandaloneRootCA | StandaloneSubordinateCA }
- **`[PSCredential]` Credential** (_Required_): To
  install an enterprise certification authority, the computer must be joined to
  an Active Directory Domain Services domain and a user account that is a member
  of the Enterprise Admin group is required. To install a standalone certification
  authority, the computer can be in a workgroup or AD DS domain. If the computer
  is in a workgroup, a user account that is a member of Administrators is required.
  If the computer is in an AD DS domain, a user account that is a member of Domain
  Admins is required.
- **`[String]` Ensure** (_Write_): Specifies whether the Certificate Authority
  should be installed or uninstalled. { *Present* | Absent }
- **`[String]` CACommonName** (_Write_): Specifies the certification authority
  common name.
- **`[String]` CADistinguishedNameSuffix** (_Write_): Specifies the certification
  authority distinguished name suffix.
- **`[String]` CertFile** (_Write_): Specifies the file name of certification
  authority PKCS 12 formatted certificate file.
- **`[PSCredential]` CertFilePassword** (_Write_):
  Specifies the password for certification authority certificate file.
- **`[String]` CertificateID** (_Write_): Specifies the thumbprint or serial
  number of certification authority certificate.
- **`[String]` CryptoProviderName** (_Write_): The name of the cryptographic
  service provider or key storage provider that is used to generate or store the
  private key for the CA.
- **`[String]` DatabaseDirectory** (_Write_): Specifies the folder location of
  the certification authority database.
- **`[String]` HashAlgorithmName** (_Write_): Specifies the signature hash
  algorithm used by the certification authority.
- **`[Boolean]` IgnoreUnicode** (_Write_): Specifies that Unicode characters are
  allowed in certification authority name string.
- **`[String]` KeyContainerName** (_Write_): Specifies the name of an existing
  private key container.
- **`[Uint32]` KeyLength** (_Write_): Specifies the bit length for new certification
  authority key.
- **`[String]` LogDirectory** (_Write_): Specifies the folder location of the
  certification authority database log.
- **`[String]` OutputCertRequestFile** (_Write_): Specifies the folder location
  for certificate request file.
- **`[Boolean]` OverwriteExistingCAinDS** (_Write_): Specifies that the computer
  object in the Active Directory Domain Service domain should be overwritten with
  the same computer name.
- **`[Boolean]` OverwriteExistingDatabase** (_Write_): Specifies that the existing
  certification authority database should be overwritten.
- **`[Boolean]` OverwriteExistingKey** (_Write_): Overwrite existing key container
  with the same name.
- **`[String]` ParentCA** (_Write_): Specifies the configuration string of the
  parent certification authority that will certify this CA.
- **`[String]` ValidityPeriod** (_Write_): Specifies the validity period of the
  certification authority certificate in hours, days, weeks, months or years. If
  this is a subordinate CA, do not use this parameter, because the validity period
  is determined by the parent CA. { Hours | Days | Months | Years }
- **`[Uint32]` ValidityPeriodUnits** (_Write_): Validity period of the certification
  authority certificate. If this is a subordinate CA, do not specify this parameter
    because the validity period is determined by the parent CA.
