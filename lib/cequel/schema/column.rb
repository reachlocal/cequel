module Cequel

  class Column

    attr_reader :name, :type

    def initialize(name, type, key = nil, partition = nil)
      @name, @type, @key, @partition = name, type, key, partition
    end

    def key?
      !!@key
    end

    def partition_key?
      !!@key && !!@partition
    end

  end

end
