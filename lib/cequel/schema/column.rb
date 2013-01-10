module Cequel

  class Column

    attr_reader :name, :type

    def initialize(name, type, key = nil)
      @name, @type, @key = name, type, key
    end

    def key?
      !!@key
    end

  end

end
