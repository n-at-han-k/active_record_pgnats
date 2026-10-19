# active_record_pgnats

Active Record migrations for [pgnats](https://github.com/luxms/pgnats), the
Postgres extension that publishes to and subscribes from NATS.

Modelled on [F(x)](https://github.com/teoljungberg/fx) and
[pg_cron-rails](https://github.com/n-at-han-k/pg_cron-rails): migration
statements, reversibility through the command recorder, and a schema dumper so
`schema.rb` carries what the extension holds. **Active Record only** — no
`railties`, no `Rails.root`, no railtie. Requiring the gem installs the hooks.

```ruby
# Gemfile
gem "active_record_pgnats"
```

```ruby
require "active_record_pgnats"   # installs the statements, recorder and dumper
```

pgnats itself has to be loaded by the server (`shared_preload_libraries =
'pgnats'`) and enabled in the database. That part is Active Record's own:

```ruby
enable_extension "pgnats"
```

Every statement below is a no-op when the extension is not installed, so a
migration still runs against a database without pgnats instead of needing its
own guard.

## The server

pgnats keeps its entire configuration on a foreign server, and allows exactly
one per database — its own event trigger raises on a second.

```ruby
class ConfigureNats < ActiveRecord::Migration[7.2]
  def change
    create_nats_server :nats, host: "127.0.0.1", port: 4222
  end
end
```

Options: `host`, `port`, `capacity`, `tls_ca_path`, `tls_cert_path`,
`tls_key_path`, `notify_subject`, `patroni_url`. Anything else raises — the
wrapper's validator accepts a typo that pgnats then ignores, which is a bad way
to find out. Values are cast to text, because every FDW option is text.

Changing them is declarative: the hash is the desired state, and an option left
out is dropped.

```ruby
update_nats_server :nats,
  host: "127.0.0.1", capacity: 256,
  revert_to: {host: "127.0.0.1"}
```

The adapter diffs against the catalog to pick `SET` or `ADD` per option, since
`ALTER SERVER` rejects the wrong one, and follows every change with
`pgnats_reload_conf()` so the running background worker picks it up instead of
waiting for its next connect.

`revert_to:` is what makes `update_nats_server` and `drop_nats_server`
reversible. Without it a rollback raises `IrreversibleMigration` rather than
leaving the database unconfigured.

## Subscriptions

```ruby
create_nats_subscription "events.user.created", function: "handle_user_created"
```

The function has to exist already and must take a single `bytea` — the message
payload. Create it in an earlier migration; F(x) coexists with this gem and is
the obvious way. A subscription needs no `revert_to`: the subject and the
function are the whole of it.

Note what this buys you: a core NATS subscription, so no replay and no acks.
Messages published while the database is down are gone.

## Publishing row changes

```ruby
create_nats_publish_trigger :maps_devices, subject: "pg_changes.%s.%s"
```

Writes a trigger function and an `AFTER INSERT OR UPDATE OR DELETE` trigger,
both named `nats_publish_<table>`. `subject` is a format string given the table
name and the lowercased operation, so one definition covers all three. The
payload is `{table, op, at, row}`, with `row` the new tuple (the old one on a
delete).

The publish is wrapped in its own `BEGIN … EXCEPTION WHEN OTHERS THEN NULL`, so
a NATS problem can never roll back the write that fired the trigger. Put another
way: this is best-effort, and pgnats' JetStream publish does not wait for an
ack, so a subject no stream covers is dropped silently. Create the stream first.

`drop_nats_publish_trigger :maps_devices, revert_to_subject: "pg_changes.%s.%s"`
to go the other way.

## schema.rb

The dumper appends the server and its subscriptions after the tables:

```ruby
  create_nats_server :nats, host: "127.0.0.1", port: "4222"

  create_nats_subscription "events.user.created", function: "handle_user_created"
```

It hooks `#tables` rather than `#extensions`, which is F(x)'s choice and is
load-bearing: `#extensions` is private and is redefined by the PostgreSQL
dumper, so a prepended module never intercepts it and the section silently never
appears.

Publish triggers are **not** dumped here. Once created they are an ordinary
function and trigger, which F(x) dumps as `create_function` / `create_trigger`
and `structure.sql` carries anyway; emitting them twice would make a schema load
fail.

## Using another connection

```ruby
ActiveRecordPgnats.configure do |config|
  config.adapter = ActiveRecordPgnats::Adapters::Postgres.new(SomeOtherModel)
end
```

It defaults to `ActiveRecord::Base`, which is almost always right: the foreign
server and `pgnats.subscriptions` live in the application's own database.

## Alongside F(x)

Safe to load together. Every helper here, private ones included, is prefixed
`nats_` / `_nats_` on purpose — both modules are included into
`ActiveRecord::ConnectionAdapters::AbstractAdapter`, and a shared private name
shadows F(x)'s copy for every migration in the application. pg_cron-rails
learned this the hard way: its `resolve_sql_definition` took one argument fewer
than F(x)'s, so every `create_function` in the host app died with
`ArgumentError: wrong number of arguments (given 4, expected 3)`.

## Specs

```sh
bundle exec rspec                                    # no database needed
DATABASE_URL=postgres:///my_db bundle exec rspec spec/integration
```

The unit suite runs against a fake adapter. The integration spec skips itself
unless `DATABASE_URL` is set and pgnats is installed there.
