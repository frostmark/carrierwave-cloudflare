# frozen_string_literal: true

require_relative 'lib/carrierwave/cloudflare/version'

Gem::Specification.new do |spec|
  spec.name          = 'carrierwave-cloudflare'
  spec.version       = Carrierwave::Cloudflare::VERSION
  spec.authors       = ['Mark Frost', 'Alexey Taktarov']
  spec.email         = ['cheerful.mf@gmail.com']

  spec.summary       = 'Wrapper for cloudflare transforming images'
  spec.homepage      = 'https://github.com/resume-io/carrierwave-cloudflare'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/resume-io/carrierwave-cloudflare'
  spec.metadata['changelog_uri'] = 'https://github.com/resume-io/carrierwave-cloudflare/blob/master/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'activesupport', '~> 5.2'
  spec.add_development_dependency 'actionview', '~> 5.2'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rack', '~> 2.0'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'

  spec.add_dependency 'carrierwave', '~> 1.3'
end
