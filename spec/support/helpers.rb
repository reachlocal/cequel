module Cequel

  module SpecSupport

    module Helpers
      def cequel
        @cequel ||= Cequel.connect(
          :host => 'localhost:9162',
          :keyspace => 'cequel_test'
        )
      end
    end

  end

end
