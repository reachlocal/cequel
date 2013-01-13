module Cequel

  module Schema

    class TableProperty

      attr_reader :name, :value

      def initialize(name, value)
        @name, @value = name, value
      end

      def to_cql
        if Hash === @value
          map_pairs = @value.each_pair.
            map { |key, value| "#{quote(key.to_s)} : #{quote(value)}" }.
            join(', ')
          value_cql = "{ #{map_pairs} }"
        else
          value_cql = quote(@value)
        end
        "#{@name} = #{value_cql}"
      end

      private

      def quote(value)
        CassandraCQL::Statement.quote(value)
      end

    end

  end

end
