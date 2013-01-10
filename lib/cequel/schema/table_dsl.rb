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

      def key(name, type)
        @table.add_key(name, type)
      end

      def column(name, type)
        @table.add_column(name, type)
      end

    end

  end

end
