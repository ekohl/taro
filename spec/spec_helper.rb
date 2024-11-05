require_relative "support/coverage"
require "rails"
require "taro"
require "debug"

# aliases for convenience
F = Taro::Types::Field
S = Taro::Types::Scalar
T = Taro::Types

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
