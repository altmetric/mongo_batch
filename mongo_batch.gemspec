Gem::Specification.new do |spec|
  spec.name          = 'mongo_batch'
  spec.version       = '0.0.1'
  spec.authors       = ['Oliver Martell']
  spec.email         = ['support@altmetric.com']
  spec.summary       = 'A library to batch Mongo queries'
  spec.description   = <<-EOF
    A library to iterate over entire Mongo collections or large queries
    exposing an API to control things like batch size, order and limit.
  EOF
  spec.license       = 'MIT'
  spec.files         = %w(README.md LICENSE) + Dir['lib/**/*.rb']
  spec.test_files    = Dir['spec/**/*.rb']
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.3.0'
  spec.add_development_dependency 'mongoid', '~> 4.0.0'
  spec.add_development_dependency 'database_cleaner', '~> 1.5.1'
  spec.add_development_dependency 'factory_girl', '~> 4.5'
end
