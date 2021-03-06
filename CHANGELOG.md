# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [1.0.8] - 2019-03-19

### Fixed

- [Issue #45](https://github.com/powershellpr0mpt/PSP-Inventory/issues/45) - `Get-PspLocalUser` and `Get-PspLocalGroup` give errors on PSSession - continued... Finally confirmed fixed this time :)

### Added

- [Issue #46](https://github.com/powershellpr0mpt/PSP-Inventory/issues/46) - Better error handling for improperly formatted dates in software registry when using `Get-PspSoftware`

---

## [1.0.7] - 2019-03-16

### Fixed

- [Issue #42](https://github.com/powershellpr0mpt/PSP-Inventory/issues/42) - `Get-PspLocalUser` and `Get-PspLocalGroup` give errors on PSSession

---

## [1.0.6] - 2019-03-16

### Changed

- [Issue #40](https://github.com/powershellpr0mpt/PSP-Inventory/issues/40) - `Get-PspSecurityUpdate` performance VERY slow

---

## [1.0.5] - 2019-03-16

### Fixed

- [Issue #36](https://github.com/powershellpr0mpt/PSP-Inventory/issues/36) - `Get-PspVMInfo` produces error when not a Hyper-V VM
- [Issue #37](https://github.com/powershellpr0mpt/PSP-Inventory/issues/37) - `Get-PspOSInfo` can give error on Productkey when not available
- [Issue #38](https://github.com/powershellpr0mpt/PSP-Inventory/issues/38) - `Get-PspLocalGroup` broken after update 1.0.4 when using PSSession

---

## [1.0.4] - 2019-03-16

### Added

- [Issue #34](https://github.com/powershellpr0mpt/PSP-Inventory/issues/34) - Added extra information to be gathered. Includes a new cmdlet: `Get-PspVMInfo`

---

## [1.0.3] - 2019-03-15

### Fixed

- Similar to [Issue #25](https://github.com/powershellpr0mpt/PSP-Inventory/issues/26) - Added a check to see if `Get-PspLocalGroup` is run on a Domain Controller or not.

---

## [1.0.2] - 2019-03-14

### Fixed

- [Issue #32](https://github.com/powershellpr0mpt/PSP-Inventory/issues/32) - Page file information not displayed when multiple page files configured

---

## [1.0.1] - 2019-03-14

### Added

- [Issue #24](https://github.com/powershellpr0mpt/PSP-Inventory/issues/25) - Added a check to see if `Get-PspServerRole` is run on a workstation or not.
- [Issue #25](https://github.com/powershellpr0mpt/PSP-Inventory/issues/26) - Added a check to see if `Get-PspLocalUser` is run on a Domain Controller or not.

### Fixed

- [Issue #24](https://github.com/powershellpr0mpt/PSP-Inventory/issues/24) - Correctly displays Hyper-V VMs as virtual machines now

---

## [1.0.0] - 2019-03-12

### BREAKING

- [Issue #1](https://github.com/powershellpr0mpt/PSP-Inventory/issues/1) - Added a Psp Prefix to cmdlets.
  Do note that old cmdlets are no longer available for use and current scripts using this module will have to be changed or aliases will have to be created.
  This does fix the issue of conflicting cmdlet such as `Get-LocalUser` which caused the module to require the `AllowClobber` parameter before it could be installed.

### Added

- [Issue #2](https://github.com/powershellpr0mpt/PSP-Inventory/issues/2) - Added external help.
- [Issue #10](https://github.com/powershellpr0mpt/PSP-Inventory/issues/10) - Added native PsProvider access to registry.
- [Issue #13](https://github.com/powershellpr0mpt/PSP-Inventory/issues/13) - Added CIM/PSSession functionality for improved performance.

### Fixed

- [Issue #7](https://github.com/powershellpr0mpt/PSP-Inventory/issues/7) - Due to new help system, new Pester test has been made to check availability of help.

---

## [0.9.2] - 2019-03-05

### Changed

- [Issue #8](https://github.com/powershellpr0mpt/PSP-Inventory/issues/8) - No longer exports private functions.
- [Issue #9](https://github.com/powershellpr0mpt/PSP-Inventory/issues/9) - InventoryDate property is now a proper `[datetime]` object.

### Fixed

- [Issue #17](https://github.com/powershellpr0mpt/PSP-Inventory/issues/17) - Various cmdlets now include custom display formats.
- [Issue #18](https://github.com/powershellpr0mpt/PSP-Inventory/issues/18) - The WinZIP build task now creates an archive as expected. when all tests are successful. Getting the tests to run successful is still an issue though, see [Issue #7](https://github.com/powershellpr0mpt/PSP-Inventory/issues/7).

---

## [0.9.1] - 2019-03-01

### Changed

- [Issue #3](https://github.com/powershellpr0mpt/PSP-Inventory/pull/3) - ComputerName property always displays in uppercase.
- `Get-RemoteCertificate` includes more properties [Subject/HasPrivateKey].
- Changed Notes and Link URLs to https.

### Fixed

- [Issue #5](https://github.com/powershellpr0mpt/PSP-Inventory/pull/5) - Inventory date on `Get-SecurityUpdate` and `Get-Software` incorrect.

---

## [0.9.0] - 2019-02-28

### Added

- Working Pester tests.

### Changed

- Updated build scripts.
- Updated Changelog and Contribution documentation.

### Removed

- Old scripts that were no longer used/required.

### Known Issues

- Pester test for help files on `Get-RemoteCertificate` script provides an error on the StoreLocation and StoreName type.

---

## [Unreleased]

### Changed

- Cleaning up folder structure and moving all parts to the correct location.
- Adding comment based help for all public functions.