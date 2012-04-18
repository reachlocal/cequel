module Cequel

  module Model

    module Persistence

      extend ActiveSupport::Concern

      module ClassMethods

        delegate :update_all, :to => :all

        def find(*keys)
          coerce_array = keys.first.is_a?(Array)
          keys.flatten!
          if keys.length == 1
            instance = find_one(keys.first)
            coerce_array ? [instance] : instance
          else
            find_many(keys)
          end
        end

        def create(attributes = {}, &block)
          new(attributes, &block).tap { |instance| instance.save }
        end

        def column_family_name
          @_cequel.column_family_name
        end

        def column_family
          keyspace[column_family_name]
        end

        def keyspace
          Cequel::Model.keyspace
        end

        def _hydrate(row)
          unless row.length == 1
            type_column_name = @_cequel.type_column.try(:name)
            if type_column_name && row[type_column_name]
              clazz = row[type_column_name].constantize
            else
              clazz = self
            end
            clazz.new._hydrate(row.except(:type))
          end
        end

        private
        
        def find_one(key)
          all.where(key_alias => key).first.tap do |result|
            raise RecordNotFound,
              "Couldn't find #{name} with #{key_alias}=#{key}" if result.nil?
          end
        end

        def find_many(keys)
          results = all.where(key_alias => keys).to_a
          results.compact!

          if results.length < keys.length
            raise RecordNotFound,
              "Couldn't find all #{name.pluralize} with #{key_alias} (#{keys.join(', ')})" <<
                "(found #{results.length} results, but was looking for #{keys.length}"
          end
          results
        end

      end

      def save
        persisted? ? update : insert
      end

      def update_attributes(attributes)
        self.attributes = attributes
        save
      end

      def insert
        raise MissingKey if @_cequel.key.nil?
        return if @_cequel.attributes.empty?
        self.class.column_family.insert(attributes)
        persisted!
      end

      def update
        update_attributes, delete_attributes = {}, []
        changes.each_pair do |attr, (old, new)|
          if new.nil?
            delete_attributes << attr
          else
            update_attributes[attr] = new
          end
        end
        data_set.update(update_attributes) if update_attributes.any?
        data_set.delete(*delete_attributes) if delete_attributes.any?
        transient! if @_cequel.attributes.empty?
      end

      def destroy
        data_set.delete
      end

      def _hydrate(row)
        tap do
          key_alias = self.class.key_alias.to_s
          @_cequel.key = row[key_alias]
          @_cequel.attributes = row.except(key_alias)
          persisted!
        end
      end

      def persisted!
        @_cequel.persisted = true
      end

      def transient!
        @_cequel.persisted = false
      end

      def persisted?
        !!@_cequel.persisted
      end

      private

      def data_set
        raise MissingKey if @_cequel.key.nil?
        self.class.column_family.
          where(self.class.key_alias => @_cequel.key)
      end

    end

  end

end
