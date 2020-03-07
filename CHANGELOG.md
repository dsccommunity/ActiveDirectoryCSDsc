# Change log for ActiveDirectoryCSDsc

The format is based on and uses the types of changes according to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Updated common function `Test-DscParameterState` to support ordered comparison
  of arrays by copying function and tests from `ComputerManagementDsc`.
- Added new resource AdcsAuthorityInformationAccess - see
  [Issue #101](https://github.com/dsccommunity/ActiveDirectoryCSDsc/issues/101).
- BREAKING CHANGE: Deprecate AdcsOcspExtension. This has been superceeded by
  AdcsAuthorityInformationAccess.
- AdcsCertificateAuthoritySettings:
  - Correct types returned by `CRLPeriodUnits` and `AuditFilter` properties
    from Get-TargetResource.
- Updated module ownership to DSC Community.
- BREAKING CHANGE: Changed resource prefix from MSFT to DSC.
- Updated to use continuous delivery pattern using Azure DevOps - Fixes
  [Issue #105](https://github.com/dsccommunity/ActiveDirectoryCSDsc/issues/105).
- Fixed build badge IDs - Fixes [Issue #108](https://github.com/dsccommunity/ActiveDirectoryCSDsc/issues/108).
