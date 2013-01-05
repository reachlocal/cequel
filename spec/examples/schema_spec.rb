require File.expand_path('../spec_helper', __FILE__)

describe Cequel::Schema do
  describe '#create_table' do
    describe 'with simple skinny table' do
      before do
        cequel.schema.create_table(:posts) do
          key :permalink, :ascii
          column :title, :text
        end
      end

      it 'should create key alias' do
        columnfamilies['posts']['key_aliases'].should == %w(permalink).to_json
      end

      it 'should set key validator' do
        columnfamilies['posts']['key_validator'].
          should == 'org.apache.cassandra.db.marshal.AsciiType'
      end
    end
  end

  def columnfamilies
    columnfamilies = cequel.execute("SELECT * FROM system.schema_columnfamilies WHERE keyspace_name = cequel_test")
    {}.tap do |map|
      columns.first.to_hash.except('keyspace_name').each_pair do |column, value|
        unpack_composite_column!(map, column, value)
      end
    end
  end

  def columns
    columns = cequel.execute("SELECT * FROM system.schema_columns WHERE keyspace_name = cequel_test")
    {}.tap do |map|
      columns.first.to_hash.except('keyspace_name').each_pair do |column, value|
        unpack_composite_column!(map, column, value)
      end
    end
  end

  def unpack_composite_column!(map, column, value)
    components = column.scan(/\x00.(.+?)\x00/).map(&:first)
    last_component = components.pop
    components.each do |component|
      map[component] ||= {}
      map = map[component]
    end
    map[last_component] = value
  end
end
