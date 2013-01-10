module Cequel

  module Schema

    class Keyspace

      def initialize(keyspace)
        @keyspace = keyspace
      end

      def create_table(name, &block)
        table = Table.new(name)
        TableDSL.apply(table, &block)
        @keyspace.execute(table.create_cql)
      end

      def drop_table(name)
        @keyspace.execute("DROP TABLE #{name}")
      end

    end

  end

end
