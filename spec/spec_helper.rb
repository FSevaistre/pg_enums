# frozen_string_literal: true
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "pg_enums"
require "rails"
require "active_record"
require "pg"
require "pry"

ActiveRecord::Base.establish_connection(
  :adapter => "postgresql",
  :database => "postgres",
  :encoding => "utf8",
  :host => "localhost",
  :username => "postgres",
  :password => "postgres"
)

ActiveRecord::Base.connection.drop_database("pg_enums_test") rescue nil
ActiveRecord::Base.connection.create_database(
  "pg_enums_test",
  :encoding=>"utf8",
)

ActiveRecord::Base.establish_connection(
  :adapter => "postgresql",
  :database => "pg_enums_test",
  :encoding => "utf8",
  :host => "localhost",
  :username => "postgres",
  :password => "postgres"
)
