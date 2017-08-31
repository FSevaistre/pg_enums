# frozen_string_literal: true
Gem::Specification.new do |s|
  s.name        = "pg_enums"
  s.version     = "0.0.1"
  s.date        = "2017-09-01"
  s.summary     = "PG Enums"
  s.description = "Simple usage of postgreSQL for Rails"
  s.authors     = ["François Sevaistre"]
  s.email       = "frasevaistre+github@gmail.com"
  s.files       = Dir["lib/**/*.rb"]
  s.homepage    =
    "http://rubygems.org/gems/pg_enums"
  s.license       = "MIT"

  s.add_dependency "rails", "~> 5.1"
  s.add_dependency "pg"

  s.add_development_dependency "rspec", "~> 3.0"
end
