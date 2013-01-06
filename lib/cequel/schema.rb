module Cequel

  class Schema

    def initialize(keyspace)
      @keyspace = keyspace
    end

    def create_table(name, &block)
      table = TableDefinition.new(name)
      TableDefinitionDSL.apply(table, &block)
      @keyspace.execute(table.create_cql)
    end

    def drop_table(name)
      @keyspace.execute("DROP TABLE #{name}")
    end

  end

end
