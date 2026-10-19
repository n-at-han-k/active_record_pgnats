# Changelog

All notable changes to `active_record_pgnats-rails` are documented here. The
format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and
the gem follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2026-10-19

### Added

- `ActiveRecordPgnats::Rails::Railtie`, whose `active_record_pgnats.load`
  initializer calls `ActiveRecordPgnats.load` under `ActiveSupport.on_load
  :active_record`, so Active Record is not loaded earlier than Rails would load
  it. The core installs its own hooks when required outside Rails.
- `rails generate active_record_pgnats:server NAME [--host --port]`.
- `rails generate active_record_pgnats:subscription SUBJECT FUNCTION`.
- `rails generate active_record_pgnats:publish_trigger TABLE [--subject]`, which
  writes `revert_to_subject:` so the migration rolls back.
