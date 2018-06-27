require 'vcr'
RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.example_status_persistence_file_path = "spec/examples.txt"

  config.disable_monkey_patching!

  if config.files_to_run.one?
    config.default_formatter = "doc"
  end

  config.profile_examples = 10

  config.order = :random
  config.before :each do
    DatabaseCleaner.clean_with(:truncation)
  end

  Kernel.srand config.seed

  VCR.configure do |c|
    c.cassette_library_dir     = 'spec/cassettes'
    c.hook_into                :faraday
    c.default_cassette_options = { :record => :new_episodes }
    c.allow_http_connections_when_no_cassette = true
    c.configure_rspec_metadata!
  end
end
