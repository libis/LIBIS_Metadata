# require 'codeclimate-test-reporter'
# ::CodeClimate::TestReporter.start

# if !defined?(RUBY_ENGINE) || RUBY_ENGINE != 'jruby'
require 'coveralls'
Coveralls.wear!
# end

require 'bundler/setup'
Bundler.setup

require 'rspec'
require 'rspec/matchers'
require 'equivalent-xml'

require 'libis-metadata'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # original_stderr = $stderr
  # original_stdout = $stdout
  # config.before(:all) do
  #   # Redirect stderr and stdout
  #   $stderr = File.open(File::NULL, 'w')
  #   $stdout = File.open(File::NULL, 'w')
  # end
  # config.after(:all) do
  #   $stderr = original_stderr
  #   $stdout = original_stdout
  # end

end
