# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'devise'
require 'spec_helper'
require_relative 'support/controller_macros'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
require 'vcr'
require 'hyperkit'
require 'json'
require 'ostruct'

RSpec.configure do |config|
   config.use_transactional_fixtures = false
   config.infer_spec_type_from_file_location!
   config.include Devise::Test::ControllerHelpers, :type => :controller
   config.extend ControllerMacros, :type => :controller
   VCR.configure do |c|
    c.cassette_library_dir     = 'spec/cassettes'
    c.hook_into                :webmock
    c.default_cassette_options = { :record => :new_episodes }
    c.allow_http_connections_when_no_cassette = true
    c.configure_rspec_metadata!
  end

  lxd_client = Hyperkit::Client.new(api_endpoint: "https://172.16.33.33:8443", verify_ssl: false)
  config.after(:each, delete_profile_after: true) do |example|
    lxd_client.delete_profile(example.metadata[:profile_name])
  end
end
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
