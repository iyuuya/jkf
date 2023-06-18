# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Others

* Fixed link to json-kifu-format

## [0.5.0] - 2023-06-18

### Changed

* Set required Ruby version to 2.7; this will be updated to 3.0 or
  later in the next release.

### Fixed

* Remove `Fixnum` usage with integrated `Integer` for Ruby 3.2 or
  later.

### Others

* Remove Rake version constraint
* Support development on Guix
* Enable RubyGems MFA required to true (for maintainers)

Documents:

* Fixed readme usages
* Update English readme; introduce translation management
* Update readme links about CI or code coverage services

CI:

* Migrate CI from Travis CI to GitHub Actions
* Migrate from Code Climate to SimpleCov

Lint tool:

* Update RuboCop versin and config
* Lint source codes with RuboCop

and,

* Add this changelog
