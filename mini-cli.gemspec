# frozen_string_literal: true

require_relative './lib/mini-cli/version'

GemSpec = Gem::Specification.new do |gem|
  gem.name = 'mini-cli'
  gem.version = MiniCli::VERSION
  gem.summary = 'The lean CLI framework for Ruby'
  gem.description = <<~DESC
    This gem is a lean, easy to use CLI framework with a very small footprint.
    It provides an easy to use argument parsing, help displaying and
    minimalistic error handling.
  DESC
  gem.author = 'Mike Blumtritt'
  gem.homepage = 'https://github.com/mblumtritt/mini-cli'
  gem.metadata = {
    'source_code_uri' => 'https://github.com/mblumtritt/mini-cli',
    'bug_tracker_uri' => 'https://github.com/mblumtritt/mini-cli/issues'
  }

  gem.required_ruby_version = '>= 2.5.0'

  gem.add_development_dependency 'bundler'
  gem.add_development_dependency 'minitest'
  gem.add_development_dependency 'rake'

  all_files = %x(git ls-files -z).split(0.chr)
  gem.test_files = all_files.grep(%r{^(spec|test)/})
  gem.files = all_files - gem.test_files
  gem.extra_rdoc_files = %w[README.md]
end
