# frozen_string_literal: true

require "spec_helper"

describe PGEnums do
  include PGEnums

  describe "#update_enum" do
    before do
      ActiveRecord::Base.connection.execute <<-SQL
        CREATE TYPE test_enum AS ENUM ('Plapp', 'Zou');
        CREATE TABLE test_table (test_enum test_enum);
        INSERT INTO test_table (test_enum) VALUES ('Plapp');
        INSERT INTO test_table (test_enum) VALUES ('Zou');
      SQL
    end
    after do
      ActiveRecord::Base.connection.execute <<-SQL
        DROP TABLE test_table;
        DROP TYPE test_enum;
      SQL
    end
    let(:test_table) do
      ActiveRecord::Base.connection.execute <<-SQL
        SELECT * FROM test_table
      SQL
    end
    let(:expected_array) do
      [
        { "test_enum" => "Zdé" },
        { "test_enum" => "Zou" }
      ]
    end
    subject do
      update_enum(
        table: "test_table",
        column: "test_enum",
        enum_type: "test_enum",
        old_value: "Plapp",
        new_value: "Zdé"
      )
    end
    it "should update the table" do
      subject
      expect(test_table).to match_array expected_array
    end
    it "should delete the old enum value" do
      subject
      expect do
        ActiveRecord::Base.connection.execute <<-SQL
          INSERT INTO test_table (test_enum) VALUES ('Plapp');
        SQL
      end.to raise_error ActiveRecord::StatementInvalid
    end
  end

  describe "#delete_from_enum" do
    before do
      ActiveRecord::Base.connection.execute <<-SQL
        CREATE TYPE test_enum AS ENUM ('Plapp', 'Zou');
        CREATE TABLE test_table (test_enum test_enum DEFAULT 'Zou'::test_enum NOT NULL);
        INSERT INTO test_table (test_enum) VALUES ('Plapp');
        INSERT INTO test_table (test_enum) VALUES ('Zou');
      SQL
    end
    after do
      ActiveRecord::Base.connection.execute <<-SQL
        DROP TABLE test_table;
        DROP TYPE test_enum;
      SQL
    end
    let(:test_table) do
      ActiveRecord::Base.connection.execute <<-SQL
        SELECT * FROM test_table
      SQL
    end
    let(:expected_array) do
      [
        { "test_enum" => "Zou" },
        { "test_enum" => "Zou" }
      ]
    end
    subject do
      delete_from_enum(
        table: "test_table",
        column: "test_enum",
        enum_type: "test_enum",
        value_to_drop: "Plapp",
        map_to: "Zou"
      )
    end
    it "should update the table" do
      subject
      expect(test_table).to match_array expected_array
    end
    it "should delete the old enum value" do
      subject
      expect do
        ActiveRecord::Base.connection.execute <<-SQL
          INSERT INTO test_table (test_enum) VALUES ('Plapp');
        SQL
      end.to raise_error ActiveRecord::StatementInvalid
    end
    context "droping the default value" do
      subject do
        delete_from_enum(
          table: "test_table",
          column: "test_enum",
          enum_type: "test_enum",
          value_to_drop: "Zou",
          map_to: "Plapp"
        )
      end
      let(:expected_array) do
        [
          { "test_enum" => "Plapp" },
          { "test_enum" => "Plapp" }
        ]
      end
      it "should update the table" do
        subject
        expect(test_table).to match_array expected_array
      end
      it "should delete the old enum value" do
        subject
        expect do
          ActiveRecord::Base.connection.execute <<-SQL
            INSERT INTO test_table (test_enum) VALUES ('Zou');
          SQL
        end.to raise_error ActiveRecord::StatementInvalid
      end
    end
  end

  describe "#add_to_enum" do
    before do
      ActiveRecord::Base.connection.execute <<-SQL
        CREATE TYPE test_enum AS ENUM ('Plapp', 'Zou');
        CREATE TABLE test_table (test_enum test_enum);
        INSERT INTO test_table (test_enum) VALUES ('Plapp');
        INSERT INTO test_table (test_enum) VALUES ('Zou');
      SQL
    end
    after do
      ActiveRecord::Base.connection.execute <<-SQL
        DROP TABLE test_table;
        DROP TYPE test_enum;
      SQL
    end
    let(:test_table) do
      ActiveRecord::Base.connection.execute <<-SQL
        SELECT * FROM test_table
      SQL
    end
    let(:expected_array) do
      [
        { "test_enum" => "Zou" },
        { "test_enum" => "Plapp" },
        { "test_enum" => "Zdé" }
      ]
    end
    subject { add_to_enum(enum_type: "test_enum", new_value: "Zdé") }

    it "should add the new enum value" do
      subject
      expect do
        ActiveRecord::Base.connection.execute <<-SQL
          INSERT INTO test_table (test_enum) VALUES ('Zdé');
        SQL
      end.not_to raise_error ActiveRecord::StatementInvalid
      expect(test_table).to match_array expected_array
    end
  end

  describe "#delete_enum" do
    before do
      ActiveRecord::Base.connection.execute <<-SQL
        CREATE TYPE test_enum AS ENUM ('Plapp', 'Zou');
        CREATE TABLE test_table (id integer, test_enum test_enum);
        INSERT INTO test_table (id, test_enum) VALUES ('1', 'Plapp');
        INSERT INTO test_table (id, test_enum) VALUES ('2', 'Zou');
      SQL
    end
    after do
      ActiveRecord::Base.connection.execute <<-SQL
        DROP TABLE test_table;
      SQL
    end
    let(:test_table) do
      ActiveRecord::Base.connection.execute <<-SQL
        SELECT * FROM test_table
      SQL
    end
    let(:expected_array) do
      [
        { "id" => 1 },
        { "id" => 2 }
      ]
    end
    subject { delete_enum(enum: "test_enum", table: "test_table", column: "test_enum") }

    it "should delete the enum and the column" do
      subject
      expect(test_table).to match_array expected_array
    end
  end

  describe "#create_enum" do
    before do
      ActiveRecord::Base.connection.execute <<-SQL
        CREATE TABLE test_table (id integer);
        INSERT INTO test_table (id) VALUES ('1');
        INSERT INTO test_table (id) VALUES ('2');
      SQL
    end
    after do
      ActiveRecord::Base.connection.execute <<-SQL
        DROP TABLE test_table;
        DROP TYPE test_enum;
      SQL
    end
    let(:test_table) do
      ActiveRecord::Base.connection.execute <<-SQL
        SELECT * FROM test_table
      SQL
    end
    let(:expected_array) do
      [
        { "id" => 1, "test_enum" => nil },
        { "id" => 2, "test_enum" => nil }
      ]
    end
    subject { create_enum(enum_type: "test_enum", table: "test_table", column: "test_enum", values: ["Plapp", "Zou"]) }


    it "should delete the enum and the column" do
      subject
      expect(test_table).to match_array expected_array
    end
  end
end
