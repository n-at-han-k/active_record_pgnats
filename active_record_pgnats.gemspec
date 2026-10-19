# frozen_string_literal: true

require_relative "lib/active_record_pgnats/version"

Gem::Specification.new do |spec|
  spec.name = "active_record_pgnats"
  spec.version = ActiveRecordPgnats::VERSION
  spec.authors = ["Nathan K"]
  spec.summary = "Active Record migrations for the pgnats extension"
  spec.description = <<~DESCRIPTION
    Adds methods to ActiveRecord::Migration to manage pgnats: its foreign server,
    its subject subscriptions, and triggers that publish row changes to NATS.
    Active Record only -- no Rails.
  DESCRIPTION
  spec.license = "MIT"

  spec.files = Dir["lib/**/*.rb", "README.md", "LICENSE"]
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", ">= 7.2"

  spec.required_ruby_version = ">= 3.1"
end
