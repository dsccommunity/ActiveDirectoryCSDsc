# Change log for ActiveDirectoryCSDsc

The format is based on and uses the types of changes according to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [5.0.0] - 2020-06-20

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
- Corrected MOF formatting of `DSC_AdcsAuthorityInformationAccess.schema.mof`
  to fix issue with auto documentation generation.
- Updated CI pipeline files.
- No longer run integration tests when running the build task `test`, e.g.
  `.\build.ps1 -Task test`. To manually run integration tests, run the
  following:
  ```powershell
  .\build.ps1 -Tasks test -PesterScript 'tests/Integration' -CodeCoverageThreshold 0
  ```
- Removed unused files repository - Fixes [Issue #112](https://github.com/dsccommunity/ActiveDirectoryCSDsc/issues/112).
- Change Azure DevOps Pipeline definition to include `source/*` - Fixes [Issue #114](https://github.com/dsccommunity/ActiveDirectoryCSDsc/issues/114).
- Updated pipeline to use `latest` version of `ModuleBuilder` - Fixes [Issue #115](https://github.com/dsccommunity/ActiveDirectoryCSDsc/issues/115).
- Merge `HISTORIC_CHANGELOG.md` into `CHANGELOG.md` - Fixes [Issue #115](https://github.com/dsccommunity/ActiveDirectoryCSDsc/issues/115).
- Fixed build failures caused by changes in `ModuleBuilder` module v1.7.0
  by changing `CopyDirectories` to `CopyPaths` - Fixes [Issue #119](https://github.com/dsccommunity/ActiveDirectoryCSDsc/issues/119).
- Updated to use the common module _DscResource.Common_ - Fixes [Issue #117](https://github.com/dsccommunity/ActiveDirectoryCSDsc/issues/117).
- Pin `Pester` module to 4.10.1 because Pester 5.0 is missing code
  coverage - Fixes [Issue #118](https://github.com/dsccommunity/ActiveDirectoryCSDsc/issues/118).

### Added

- Added build task `Generate_Conceptual_Help` to generate conceptual help
  for the DSC resource.
- Added build task `Generate_Wiki_Content` to generate the wiki content
  that can be used to update the GitHub Wiki.

## [4.1.0.0] - 2019-09-19

### Changed

- AdcsCertificationAuthoritySettings:
  - Fix grammar in the resource README.md.
- Fix minor style issues in statement case.

## [4.0.0.0] - 2019-08-08

### Changed

- BREAKING CHANGE: ActiveDirectoryCSDsc module minimum requirements updated
  to WMF 5.0 because newly added AdcsCertificateAuthoritySettings resource
  requires WMF 5.0.
- Added new resource AdcsCertificateAuthoritySettings - see
  [Issue #13](https://github.com/dsccommunity/ActiveDirectoryCSDsc/issues/13).
- Added new resource AdcsTemplate.
- Replaced `switch` blocks with `if` blocks for evaluating 'Ensure' parameter
  because switch was missing `break` - fixes [Issue #87](https://github.com/dsccommunity/ActiveDirectoryCSDsc/issues/87).
- Added Comment Based Help for `New-NotImplementedException` common function.
- Moved code to create the user account for use in integration test into a
  `CommonTestHelper.psm1` function.
- Removed user account creation code from `AppVeyor.yml` and into integration
  tests themselves to make tests execution easier.
- Updated user account creation code to use local user/group management Powershell
  cmdlets available in WMF 5.1 - fixes [Issue #24](https://github.com/dsccommunity/ActiveDirectoryCSDsc/issues/24).
- AdcsCertificationAuthority:
  - Integration tests updated to create test user account in administrators
    group to make test execution easier.

## [3.3.0.0] - 2019-05-15

### Changed

- Remove reference to StorageDsc in README.md - fixes [Issue #76](https://github.com/dsccommunity/ActiveDirectoryCSDsc/issues/76).
- Combined all `ActiveDirectoryCSDsc.ResourceHelper` module functions into
  `ActiveDirectoryCSDsc.Common` module and renamed to `ActiveDirectoryCSDsc.CommonHelper`
  module.
- Opted into Common Tests 'Common Tests - Validate Localization' -
  fixes [Issue #82](https://github.com/dsccommunity/ActiveDirectoryCSDsc/issues/82).

## [3.2.0.0] - 2019-02-20

### Changed

- Added 'DscResourcesToExport' to manifest to improve information in
  PowerShell Gallery - fixes [Issue #68](https://github.com/dsccommunity/ActiveDirectoryCSDsc/issues/68).
- Removed unused CAType variables and references in AdcsOnlineResponder - fixes
  [issue #52](https://github.com/dsccommunity/ActiveDirectoryCSDsc/issues/52).
- Updated Examples to enable publising to PowerShell Gallery - fixes
  [issue #54](https://github.com/dsccommunity/ActiveDirectoryCSDsc/issues/54).
- Cleaned up property alignment in module manifest file.
- Added new resource AdcsOcspExtension - see [Issue #70](https://github.com/dsccommunity/ActiveDirectoryCSDsc/issues/70).
  - Added new ActiveDirectoryCSDsc.CommonHelper.psm1 helper module and unit test.
  - Added stub function to /Tests/TestHelpers (ADCSStub.psm1) so Pester tests
    can run without having to install ADCSAdministration module.
- Converted module to auto-documentation Wiki - fixes [Issue #53](https://github.com/dsccommunity/ActiveDirectoryCSDsc/issues/53).
- Enabled Example publishing to PSGallery.
- Moved change log to CHANGELOG.MD.
- Opted into Common Tests 'Validate Example Files To Be Published',
  'Validate Markdown Links' and 'Relative Path Length'.
- Correct AppVeyor `Invoke-AppveyorAfterTestTask` - fixes [Issue #73](https://github.com/dsccommunity/ActiveDirectoryCSDsc/issues/73).

## [3.1.0.0] - 2019-01-10

### Changed

- Updated LICENSE file to match the Microsoft Open Source Team standard.
- Added .VSCode settings for applying DSC PSSA rules - fixes [Issue #60](https://github.com/dsccommunity/ActiveDirectoryCSDsc/issues/60).
- Added fix for two tier PKI deployment fails on initial deployment,
  not error - fixes [Issue #57](https://github.com/dsccommunity/ActiveDirectoryCSDsc/issues/57).

## [3.0.0.0] - 2018-06-13

### Changed

- Changed `Assert-VerifiableMocks` to be `Assert-VerifiableMock` to meet
  Pester standards.
- Updated license year in LICENSE.MD and module manifest to 2018.
- Removed requirement for Pester maximum version 4.0.8.
- Added new resource EnrollmentPolicyWebService - see
  [issue #43](https://github.com/dsccommunity/ActiveDirectoryCSDsc/issues/43).
- BREAKING CHANGE: New Key for AdcsCertificationAuthority, IsSingleInstance - see
  [issue #47](https://github.com/dsccommunity/ActiveDirectoryCSDsc/issues/47).
- Added:
  - MSFT_xADCSOnlineResponder resource to install the Online Responder service.
- Corrected filename of MSFT_AdcsCertificationAuthority integration test file.

## [2.0.0.0] - 2018-05-02

### Changed

- BREAKING CHANGE: Renamed module to ActiveDirectoryCSDsc - see
  [issue #38](https://github.com/dsccommunity/xAdcsDeployment/issues/38)
- Enabled PSSA rule violations to fail build - Fixes [Issue #44](https://github.com/dsccommunity/ActiveDirectoryCSDsc/issues/44).

## [1.4.0.0] - 2017-12-20

### Changed

- xAdcsCertificateAuthority: CertFilePassword invalid type - fixes
  [issue #36](https://github.com/dsccommunity/xAdcsDeployment/issues/36)

## [1.3.0.0] - 2017-11-15

### Changed

- Updated to meet HQRM guidelines - fixes
  [issue #33](https://github.com/dsccommunity/xAdcsDeployment/issues/33).
- Fixed markdown rule violations in README.MD.
- Change examples to meet HQRM standards and optin to Example validation
  tests.
- Replaced examples in README.MD to links to Example files.
- Added the VS Code PowerShell extension formatting settings that cause PowerShell
  files to be formatted as per the DSC Resource kit style guidelines.
- Opted into Common Tests 'Validate Module Files' and 'Validate Script Files'.
- Corrected description in manifest.
- Added .github support files:
  - CONTRIBUTING.md
  - ISSUE_TEMPLATE.md
  - PULL_REQUEST_TEMPLATE.md
- Resolved all PSScriptAnalyzer warnings and style guide warnings.
- Converted all tests to meet Pester V4 guidelines - fixes
  [issue #32](https://github.com/dsccommunity/xAdcsDeployment/issues/32).
- Fixed spelling mistakes in README.MD.
- Fix to ensure exception thrown if failed to install or uninstall service - fixes
  [issue #3](https://github.com/dsccommunity/xAdcsDeployment/issues/3).
- Converted AppVeyor.yml to use shared AppVeyor module in DSCResource.Tests - fixes
  [issue #29](https://github.com/dsccommunity/xAdcsDeployment/issues/29).

## [1.2.0.0] - 2017-10-05

### Changed

- xAdcsWebEnrollment:
  - xAdcsWebEnrollment.psm1 - Change reference and variable from CAType to CAConfig

## [1.1.0.0] - 2016-12-14

### Changed

- Converted AppVeyor.yml to pull Pester from PSGallery instead of Chocolatey.
- Changed AppVeyor.yml to use default image.
- xAdcsCertificateAuthority:
  - Change property format in Readme.md to be standard layout.
  - Converted style to meet HQRM guidelines.
  - Added verbose logging support.
  - Added string localization.
  - Fixed Get-TargetResource by removing IsCA and changing Ensure to return whether
    or not CA is installed.
  - Added unit tests.
  - Updated parameter format to meet HQRM guidelines.
- xAdcsOnlineResponder:
  - Change property format in Readme.md to be standard layout.
  - Added unit test header to be latest version.
  - Added function help.
  - Updated parameter format to meet HQRM guidelines.
  - Updated resource to meet HQRM guidelines.
- xAdcsWebEnrollment:
  - Change property format in Readme.md to be standard layout.
  - Added unit test header to be latest version.
  - Added function help.
  - Updated parameter format to meet HQRM guidelines.
  - Updated resource to meet HQRM guidelines.
- Added CommonResourceHelper.psm1 (copied from xPSDesiredStateConfiguration).
- Removed Technet Documentation HTML file from root folder.
- Removed redundant code from AppVeyor.yml.
- Fix markdown violations in Readme.md.
- Updated readme.md to match DSCResource.Template\Readme.md.

## [1.0.0.0] - 2016-05-18

### Changed

- Moved Examples folder into root.
- Removed legacy xCertificateServices folder.
- Prevented Unit tests from Violating PSSA rules.
- MSFT_xAdcsWebEnrollment: Created unit tests based on v1.0 Test Template.
                           Update to meet Style Guidelines and ensure consistency.
                           Updated to IsSingleInstance model. **Breaking change**
- MSFT_xAdcsOnlineResponder: Update Unit tests to use v1.0 Test Template.
                             Unit tests can be run without AD CS installed.
                             Update to meet Style Guidelines and ensure consistency.
- Usage of WinRm.exe replaced in Config-SetupActiveDirectory.ps1 example file
  with Set-WSManQuickConfig cmdlet.

## [0.2.0.0] - 2016-02-02

### Changed

- Added the following resources:
  - MSFT_xADCSOnlineResponder resource to install the Online Responder service.
- Correction to xAdcsCertificationAuthority property title in Readme.md.
- Addition of .gitignore to ensure DSCResource.Tests folder is committed.
- Updated AppVeyor.yml to use WMF 5 build environment.

## [0.1.0.0] - 2014-09-27

### Changed

- Initial release with the following resources
  - xAdcsCertificationAuthority and xAdcsWebEnrollment.
