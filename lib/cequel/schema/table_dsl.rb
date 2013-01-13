module Cequel

  module Schema

    class TableDSL < BasicObject

      def self.apply(table, &block)
        dsl = new(table)
        dsl.instance_eval(&block)
      end

      def initialize(table)
        @table = table
      end

      def partition_key(name, type)
        @table.add_partition_key(name, type)
      end

      def key(name, type)
        @table.add_key(name, type)
      end

      def column(name, type)
        @table.add_column(name, type)
      end

      def list(name, type)
        @table.add_list(name, type)
      end

      def set(name, type)
        @table.add_set(name, type)
      end

      def map(name, key_type, value_type)
        @table.add_map(name, key_type, value_type)
      end

      def with(name, value)
        @table.add_property(name, value)
      end

    end

  end

end
