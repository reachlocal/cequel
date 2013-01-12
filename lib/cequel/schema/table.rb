require 'stringio'

module Cequel

  module Schema

    class Table

      attr_reader :name

      def initialize(name)
        @name = name
        @partition_keys, @nonpartition_keys, @columns = [], [], []
      end

      def add_partition_key(name, type)
        column = Column.new(name, type)
        @columns << column
        @partition_keys << column
      end

      def add_key(name, type)
        column = Column.new(name, type)
        @columns << column
        if @partition_keys.empty?
          @partition_keys << column
        else
          @nonpartition_keys << column
        end
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
        partition_cql = @partition_keys.map { |key| key.name }.join(', ')
        if @nonpartition_keys.any?
          nonpartition_cql =
            @nonpartition_keys.map { |key| key.name }.join(', ')
          "PRIMARY KEY ((#{partition_cql}), #{nonpartition_cql})"
        else
          "PRIMARY KEY ((#{partition_cql}))"
        end
      end

    end

  end

end
