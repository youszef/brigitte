# frozen_string_literal: true

require 'bundler/setup'

require 'brigitte'
require 'brigitte/player'
require 'brigitte/game'
require 'brigitte/card'
require 'brigitte/deck'
require 'brigitte/commands/pile'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
