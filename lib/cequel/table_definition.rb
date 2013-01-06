require 'stringio'
require 'cequel/table_column'

module Cequel

  class TableDefinition

    attr_reader :name

    def initialize(name)
      @name = name
      @keys = []
      @columns = []
    end

    def add_key(name, type)
      @keys << TableColumn.new(name, type)
    end

    def add_column(name, type)
      @columns << TableColumn.new(name, type)
    end

    def create_cql
      "CREATE TABLE #{@name} (#{columns_cql})"
    end

    private

    def columns_cql
      key = @keys.first #XXX handle composite keys
      key_columns_cql = "#{key.name} #{key.type} PRIMARY KEY"
      columns_cql = @columns.map { |key| "#{key.name} #{key.type}" }.join(', ')
      "#{key_columns_cql}, #{columns_cql}"
    end

  end

end
