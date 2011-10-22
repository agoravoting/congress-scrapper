# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'rspec'
require 'webmock/rspec'

RSpec.configure do |config|
  config.include WebMock::API
end