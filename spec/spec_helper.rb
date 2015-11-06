require 'mongoid'
require 'database_cleaner'
require 'factory_girl'
require 'factories/posts'

Mongoid.load!(File.expand_path('../../config/mongoid.yml', __FILE__), 'test')

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner[:mongoid].strategy = :truncation
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
