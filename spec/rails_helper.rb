# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'devise'
require 'spec_helper'
require_relative 'support/controller_macros'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'


RSpec.configure do |config|
   config.use_transactional_fixtures = false
   config.infer_spec_type_from_file_location!
   config.include Devise::Test::ControllerHelpers, :type => :controller
   config.extend ControllerMacros, :type => :controller
end
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
