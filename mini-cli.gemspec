# frozen_string_literal: true

require_relative './lib/mini-cli/version'

Gem::Specification.new do |spec|
  spec.name = 'mini-cli'
  spec.version = MiniCli::VERSION
  spec.required_ruby_version = '>= 2.5.0'

  spec.summary = 'The lean CLI framework for Ruby'
  spec.description = <<~DESC
    This gem is a lean, easy to use CLI framework with a very small footprint.
    It provides an easy to use argument parsing, help displaying and
    minimalistic error handling.
  DESC

  spec.author = 'Mike Blumtritt'
  spec.homepage = 'https://github.com/mblumtritt/mini-cli'
  spec.metadata['source_code_uri'] = 'https://github.com/mblumtritt/mini-cli'
  spec.metadata['bug_tracker_uri'] =
    'https://github.com/mblumtritt/mini-cli/issues'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'rake'

  all_files = Dir.chdir(__dir__) { `git ls-files -z`.split(0.chr) }
  spec.test_files = all_files.grep(%r{^(spec|test)/})
  spec.files = all_files - spec.test_files
  spec.extra_rdoc_files = %w[README.md]
end
