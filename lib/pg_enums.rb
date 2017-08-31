# frozen_string_literal: true
module PGEnums

  def update_enum(table:, column:, enum_type:, old_value:, new_value:)
    # Select default store it and drop it if defined
    default = default(table, column, enum_type, old_value, new_value)
    drop_default(table, column) if default
    # Generate the new labels
    new_enumlabels = new_enumlabels(enum_type, old_value, new_value)
    # Add the new label to the enum
    ActiveRecord::Base.connection.execute <<-SQL
      ALTER TYPE #{enum_type} ADD VALUE IF NOT EXISTS '#{new_value}';
    SQL
    # update the enum and the column
    change_enum_labels(table, column, enum_type, old_value, new_value, new_enumlabels)
    # restaure the default value
    restaure_default(table, column, default, enum_type) if default
  end

  def delete_from_enum(table:, column:, enum_type:, value_to_drop:, map_to:)
    # Select default store it and drop it if defined
    default = default(table, column, enum_type, value_to_drop, map_to)
    drop_default(table, column) if default
    # Generate the new labels
    new_enumlabels = new_enumlabels(enum_type, value_to_drop)
    # update the enum and the column
    change_enum_labels(table, column, enum_type, value_to_drop, map_to, new_enumlabels)
    # restaure the default value
    restaure_default(table, column, default, enum_type) if default
  end

  def add_to_enum(enum_type:, new_value:)
    ActiveRecord::Base.connection.execute <<-SQL
      ALTER TYPE #{enum_type} ADD VALUE IF NOT EXISTS '#{new_value}';
    SQL
  end

  def rename_enum(enum:, new_name:)
    ActiveRecord::Base.connection.execute <<-SQL
      ALTER TYPE #{enum} RENAME TO #{new_name};
    SQL
  end

  def delete_enum(enum:, table:, column:)
    remove_column table, column
    ActiveRecord::Base.connection.execute <<-SQL
      DROP TYPE #{enum};
    SQL
  end

  def create_enum(enum_type:, table:, column:, values:)
    ActiveRecord::Base.connection.execute <<-SQL
      CREATE TYPE #{enum_type} AS ENUM (#{"'" + values.join("', '") + "'"});
    SQL
    add_column table, column, enum_type
  end

  private

  def change_enum_labels(table, column, enum_type, old_value, new_value, new_enumlabels)
    # Rename the enum
    # Create a new enum with the new labels
    # Update the table to set each old value to the new one
    # Update the table to map the column to the new enum
    # Drop the old enum
    ActiveRecord::Base.connection.execute <<-SQL
      ALTER TYPE #{enum_type} RENAME TO old_#{enum_type};
      CREATE TYPE #{enum_type} AS ENUM (#{new_enumlabels});
      UPDATE #{table} SET #{column} = '#{new_value}' WHERE #{table}.#{column} = '#{old_value}';
      ALTER TABLE #{table} ALTER COLUMN #{column} TYPE #{enum_type} USING #{column}::text::#{enum_type};
      DROP TYPE old_#{enum_type};
    SQL
  end

  # Fetch the enum labels from the data base
  def new_enumlabels(enum_type, old_value, new_value = nil)
    enumlabels = ActiveRecord::Base.connection.execute <<-SQL
      SELECT enumlabel from pg_enum
      WHERE enumtypid=(
        SELECT oid FROM pg_type WHERE typname='#{enum_type}'
      )
      ORDER BY enumsortorder;
    SQL
    enumlabels = enumlabels.map { |e| "'#{e["enumlabel"]}'" } - ["'#{old_value}'"]
    enumlabels << "'#{new_value}'" if new_value
    enumlabels.uniq.join(", ").chomp(", ")
  end

  def default(table, column, enum_type, old_value, new_value)
    default = ActiveRecord::Base.connection.execute <<-SQL
      SELECT column_default FROM information_schema.columns
      WHERE (table_schema, table_name, column_name) = ('public', '#{table}', '#{column}')
    SQL
    return unless default.first["column_default"]
    default = default.first["column_default"]
    default.slice!("::#{enum_type}")
    (default == "'#{old_value}'") ? "'#{new_value}'" : default
  end

  def drop_default(table, column)
    ActiveRecord::Base.connection.execute <<-SQL
      ALTER TABLE #{table} ALTER #{column} DROP default
    SQL
  end

  def restaure_default(table, column, default, enum_type)
    ActiveRecord::Base.connection.execute <<-SQL
      ALTER TABLE #{table} ALTER #{column} SET DEFAULT #{default}::#{enum_type}
    SQL
  end

end
