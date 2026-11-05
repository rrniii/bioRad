# Avocet BioRad reader fix

This is a local maintenance build, version `0.12.0.1`, based on official
BioRad `0.12.0` tag commit `4f3a8c7ee12af26d5ca799a2b9a4b6c522702623`.
It is not an official BioRad release.

The VPTS schema reader and regression tests are backported from local proposal
commit `533438e9aa913074090af7a4cc0391c3ead25935` (`codex/vpts-schema-types`).
The backport resolves only obsolete comments around the original CSV read call.
It assigns schema-defined CSV column types so sparse numeric fields remain
numeric while preserving the distinction between missing (`NA`) and undetect
(`NaN`) values. Existing `bioRad::read_vpts()` calls remain unchanged.

Relative to the official release, changes are confined to `R/read_vpts.R`,
`tests/testthat/test-read_vpts-sparse.R`, the version in `DESCRIPTION`, and this
provenance file. Integration calculations and dependency requirements retain
their official `0.12.0` behavior. In particular, this build does not require an
upgrade of readr or vroom.

The original proposal was tested separately. This stable backport must pass its
own installed-package regression and data validation before activation.
