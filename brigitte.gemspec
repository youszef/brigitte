# frozen_string_literal: true

require_relative 'lib/brigitte/version'

Gem::Specification.new do |spec|
  spec.name          = 'brigitte'
  spec.version       = Brigitte::VERSION
  spec.authors       = ['youszef']
  spec.email         = ['zouhariy@gmail.com']

  spec.summary       = 'Card game based on Shithead'
  spec.description   = "Card game where player needs to get rid of all it's cards"
  spec.homepage      = 'https://github.com/youszef/brigitte'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.7.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  # spec.metadata['changelog_uri'] = "#{spec.homepage}/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
end
