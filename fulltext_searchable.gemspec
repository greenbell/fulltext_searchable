# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fulltext_searchable/version'

Gem::Specification.new do |spec|
  spec.name          = "fulltext_searchable"
  spec.version       = FulltextSearchable::VERSION
  spec.authors       = ["M.Shibuya"]
  spec.email         = ["mit.shibuya@gmail.com"]
  spec.summary       = %q{Rails engine that provides fulltext-search capability using mroonga}
  spec.description   = %q{Rails engine that provides fulltext-search capability using mroonga(formerly. groonga storage engine). Requires Rails >= 3.0}
  spec.homepage      = "https://github.com/greenbell/fulltext_searchable"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", [">= 3.0", "< 7.1"]
  spec.add_dependency "mysql2"
  spec.add_dependency "htmlentities"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "database_cleaner"
  spec.add_development_dependency "factory_girl"
  spec.add_development_dependency "faker"
  spec.add_development_dependency "jeweler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rdoc"
  spec.add_development_dependency "rspec-rails"
end
