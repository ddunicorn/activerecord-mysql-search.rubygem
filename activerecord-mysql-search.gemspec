# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = 'activerecord-mysql-search'
  spec.version = '0.1.3'
  spec.authors = ['Daydream Unicorn GmbH & Co. KG']
  spec.email = ['hello@daydreamunicorn.com']

  spec.summary = 'Full Text Search for ActiveRecord with MySQL'
  spec.description = <<~DESC
    This gem provides a simple way to perform full-text search in MySQL databases using ActiveRecord.
    It allows you to define search scopes and perform searches on your models with ease.
  DESC
  spec.homepage = 'https://github.com/ddunicorn/activerecord-mysql-search.rubygem/blob/main/README.md'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/ddunicorn/activerecord-mysql-search.rubygem'
  spec.metadata['changelog_uri'] = 'https://github.com/ddunicorn/activerecord-mysql-search.rubygem/blob/main/CHANGELOG.md'
  spec.metadata['rubygems_mfa_required'] = 'true'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
