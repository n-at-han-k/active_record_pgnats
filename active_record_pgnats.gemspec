# frozen_string_literal: true

require_relative "lib/active_record_pgnats/version"

Gem::Specification.new do |spec|
  spec.name = "active_record_pgnats"
  spec.version = ActiveRecordPgnats::VERSION
  spec.authors = ["Nathan K"]
  spec.email = ["nathankidd@hey.com"]

  spec.summary = "Active Record migrations for the pgnats extension."

  spec.description = <<~DESC
    Adds methods to ActiveRecord::Migration to manage pgnats: its foreign server,
    its subject subscriptions, and triggers that publish row changes to NATS.
    Active Record only -- Rails support lives in the sibling
    active_record_pgnats-rails gem.
  DESC

  spec.homepage = "https://github.com/n-at-han-k/active-record-pgnats"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG-active_record_pgnats.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Rails support lives in a sibling gem sharing this lib/ tree. This gem ships
  # the statements, the adapter and the dumper only.
  spec.files = %w[
    lib/active_record_pgnats.rb
    lib/active_record_pgnats/version.rb
    lib/active_record_pgnats/command_recorder.rb
    lib/active_record_pgnats/configuration.rb
    lib/active_record_pgnats/publish_trigger.rb
    lib/active_record_pgnats/schema_dumper.rb
    lib/active_record_pgnats/server.rb
    lib/active_record_pgnats/statements.rb
    lib/active_record_pgnats/subscription.rb
    lib/active_record_pgnats/adapters/postgres.rb
    lib/active_record_pgnats/adapters/postgres/connection.rb
    lib/active_record_pgnats/adapters/postgres/query_executor.rb
    lib/active_record_pgnats/adapters/postgres/servers.rb
    lib/active_record_pgnats/adapters/postgres/subscriptions.rb
    README.md
    LICENSE
  ]
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", ">= 7.2"

  spec.add_development_dependency "pg", "~> 1.5"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.13"
end
