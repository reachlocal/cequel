require 'stringio'

module Cequel

  module Schema

    class Table

      attr_reader :name

      def initialize(name)
        @name = name
        @columns = []
      end

      def add_key(name, type, partition)
        @columns << Column.new(name, type, true, partition)
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
        partition_keys, nonpartition_keys = [], []
        @columns.each do |column|
          if column.partition_key? || column.key? && partition_keys.empty?
            partition_keys << column
          elsif column.key?
            nonpartition_keys << column
          end
        end
        partition_cql = partition_keys.map { |key| key.name }.join(', ')
        if nonpartition_keys.any?
          nonpartition_cql = nonpartition_keys.map { |key| key.name }.join(', ')
          "PRIMARY KEY ((#{partition_cql}), #{nonpartition_cql})"
        else
          "PRIMARY KEY ((#{partition_cql}))"
        end
      end

    end

  end

end
