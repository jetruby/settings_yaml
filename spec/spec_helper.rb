require 'bundler/setup'
Bundler.setup

require 'settings_yaml'

require 'test_construct'

RSpec.configure do |config|
  config.include TestConstruct::Helpers

  # Many RSpec users commonly either run the entire suite or an individual
  # file, and it's useful to allow more verbose output when running an
  # individual spec file.
  if config.files_to_run.one?
    # Use the documentation formatter for detailed output,
    # unless a formatter has already been configured
    # (e.g. via a command-line flag).
    config.default_formatter = 'doc'
  end
end
