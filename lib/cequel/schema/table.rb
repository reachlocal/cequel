require 'stringio'

module Cequel

  module Schema

    class Table

      attr_reader :name

      def initialize(name)
        @name = name
        @keys = []
        @columns = []
      end

      def add_key(name, type)
        @columns << Column.new(name, type, true)
      end

      def add_column(name, type)
        @columns << Column.new(name, type)
      end

      def create_cql
        "CREATE TABLE #{@name} (#{columns_cql}, #{keys_cql})"
      end

      private

      def columns_cql
        @columns.map { |key| "#{key.name} #{key.type}" }.join(', ')
      end

      def key_columns_cql
        @keys.map { |key| "#{key.name} #{key.type}" }.join(', ')
      end

      def keys_cql
        key_columns = @columns.select { |column| column.key? }
        "PRIMARY KEY (#{key_columns.map { |key| key.name }.join(', ')})"
      end

    end

  end

end
