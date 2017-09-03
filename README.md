# PostgreSQL enums made simple [![Build Status](https://travis-ci.org/FSevaistre/pg_enums.svg?branch=master)](https://travis-ci.org/FSevaistre/pg_enums)

Simple usage of postgreSQL enums for Rails.

This gems provides some helpers to create, edit and delete enums in a postgreSQL base using ActiveRecord migrations.

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

The transactions has to be disabled to run the migrations. 
It is a pain, but pg doesn't allow some operation within a transaction :'(

### Example

Add the possibility to store bananas in the shelfs table

```ruby
require "pg_enums"
include PGEnums

class AddSingle < ActiveRecord::Migration[5.1]

  self.disable_ddl_transaction!

  def up
    add_to_enum(enum_type: "fruits", new_value: "banana")
  end

  def down
    delete_from_enum(
      table: "shelfs",
      column: "fruits",
      enum_type: "fruits",
      value_to_drop: "banana",
      map_to: "not_a_fruit"
    )
  end

end
```

### List of the available methods: 

```ruby
create_enum(enum_type:, table:, column:, values:)
delete_enum(enum:, table:, column:)
add_to_enum(enum_type:, new_value:)
rename_enum(enum:, new_name:)
update_enum(table:, column: enum_type:, old_value:, new_value:)
delete_from_enum(table:, column: enum_type:, value_to_drop:, map_to:)
```

### Details

#### create_enum
Add a new column to the table, with a new type "enum_type"
values is an array of the different values the new enum will be able to take
```ruby
create_enum(enum_type:, table:, column:, values:)
```
#### delete_enum
Delete the column of the table and the enum associated
```ruby
delete_enum(enum:, table:, column:)
```
#### add_to_enum
Add a new value to an existing enum
```ruby
add_to_enum(enum_type:, new_value:)
```
#### rename_enum
Change the name of the enum
```ruby
rename_enum(enum:, new_name:)
```
#### update_enum
Change the name of one of the values and map the existing records to the new value
Can be really usefull if a typo has be made on a previous migration 
```ruby
update_enum(table:, column: enum_type:, old_value:, new_value:)
```
#### delete_from_enum
Delete one value and map the existing records to the "map_to" value. 
The map_to value has to be an existing value of the enum
```ruby
delete_from_enum(table:, column: enum_type:, value_to_drop:, map_to:)
```

## Author

François Sevaistre

## License

MIT License

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/FSevaistre/pg_enums
