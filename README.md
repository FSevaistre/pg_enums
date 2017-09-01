# PostgreSQL enums made simple [![Build Status](https://travis-ci.org/FSevaistre/pg_enums.svg?branch=master)](https://travis-ci.org/FSevaistre/pg_enums)

Simple usage of postgreSQL enums for Rails

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pg_enums'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pg_enums

## Usage

### List of the available methods: 
```ruby
update_enum(table:, column: enum_type:, old_value:, new_value:)
delete_from_enum(table:, column: enum_type:, value_to_drop:, map_to:)
add_to_enum(enum_type:, new_value:)
rename_enum(enum:, new_name:)
delete_enum(enum:, table:, column:)
create_enum(enum_type:, table:, column:, values:)
```

### Details

## Author

François Sevaistre

## License

MIT License

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/FSevaistre/pg_enums
