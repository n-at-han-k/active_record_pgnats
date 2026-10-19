# Changelog

All notable changes to `active_record_pgnats` are documented here. The format is
based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the gem
follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2026-10-19

### Added

- `create_nats_server` / `update_nats_server` / `drop_nats_server` for pgnats'
  foreign server, which holds its entire configuration. Options are validated
  against the eight pgnats reads and cast to text; `update_nats_server` is
  declarative, diffing the catalog to pick `SET` or `ADD` per option and
  dropping anything omitted, and every change is followed by
  `pgnats_reload_conf()`.
- `create_nats_subscription` / `drop_nats_subscription` for `nats_subscribe`.
- `create_nats_publish_trigger` / `drop_nats_publish_trigger`, writing a trigger
  that publishes a table's row changes as `{table, op, at, row}`. The publish
  cannot roll the write back.
- Reversibility through `ActiveRecord::Migration::CommandRecorder`, with
  `revert_to:` for the server and `revert_to_subject:` for a publish trigger.
- A schema dumper appending the server and its subscriptions to `schema.rb`.
- Every statement is a no-op when the extension is not installed.
