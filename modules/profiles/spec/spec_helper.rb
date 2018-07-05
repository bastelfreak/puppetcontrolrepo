require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'
include RspecPuppetFacts

# This file is managed via modulesync
# https://github.com/voxpupuli/modulesync
# https://github.com/voxpupuli/modulesync_config

if Dir.exist?(File.expand_path('../../lib', __FILE__))
  require 'coveralls'
  require 'simplecov'
  require 'simplecov-console'
  SimpleCov.formatters = [
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::Console
  ]
  SimpleCov.start do
    track_files 'lib/**/*.rb'
    add_filter '/spec'
    add_filter '/vendor'
    add_filter '/.vendor'
  end
end

RSpec.configure do |c|
  default_facts = {
    puppetversion: Puppet.version,
    facterversion: Facter.version
  }
  default_facts.merge!(YAML.load(File.read(File.expand_path('../default_facts.yaml', __FILE__)))) if File.exist?(File.expand_path('../default_facts.yaml', __FILE__))
  c.default_facts = default_facts
  c.mock_with :rspec
  c.raise_errors_for_deprecations!
  c.hiera_config = 'spec/fixtures/hiera/hiera.yaml'
  c.after(:suite) do
    RSpec::Puppet::Coverage.report!
  end
end

# vim: syntax=ruby
