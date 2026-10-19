# frozen_string_literal: true

require_relative "lib/active_record_pgnats/rails/version"
require_relative "lib/active_record_pgnats/version"

Gem::Specification.new do |spec|
  spec.name = "active_record_pgnats-rails"
  spec.version = ActiveRecordPgnats::Rails::VERSION
  spec.authors = ["Nathan K"]
  spec.email = ["nathankidd@hey.com"]

  spec.summary = "Rails integration for active_record_pgnats."

  spec.description = <<~DESC
    Hooks active_record_pgnats into Rails at the on_load :active_record moment
    and adds generators for the migrations: the pgnats foreign server, a subject
    subscription, and a trigger publishing a table's row changes.
  DESC

  spec.homepage = "https://github.com/n-at-han-k/active-record-pgnats"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG-active_record_pgnats-rails.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Shares the lib/ tree; ships the railtie and the generators only.
  spec.files = Dir[
    "lib/active_record_pgnats/rails.rb",
    "lib/active_record_pgnats/rails/**/*.rb",
    "lib/generators/**/*"
  ] + %w[README.md LICENSE]
  spec.require_paths = ["lib"]

  # Derived: this gem tracks the core beside it in-repo. While the core is 0.x
  # its minor is the breaking axis, so the constraint pins both segments.
  spec.add_dependency "active_record_pgnats", "~> #{ActiveRecordPgnats::VERSION.split(".").first(2).join(".")}"
  spec.add_dependency "railties", ">= 7.2"

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.13"
end
