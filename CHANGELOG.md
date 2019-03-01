# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [0.9.1] - 2019-03-01

### Changed

- ComputerName property always displays in uppercase

### Fixed

- Issue #5 - Inventory date on Get-SecurityUpdate and Get-Software incorrect

## [0.9.0] - 2019-02-28

### Added

- Working Pester tests

### Changed

- Updated build scripts
- Updated Changelog and Contribution documentation

### Removed

- Old scripts that were no longer used/required

### Known Issues

- Pester test for help files on Get-RemoteCertificate script provides an error on the StoreLocation and StoreName type

## [Unreleased]

### Changed

- Cleaning up folder structure and moving all parts to the correct location
- Adding comment based help for all public functions
