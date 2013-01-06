require File.expand_path('../../environment', __FILE__)

Dir.glob(File.expand_path('../../support/**/*.rb', __FILE__)).each do |file|
  require file
end
Dir.glob(File.expand_path('../../shared/**/*.rb', __FILE__)).each do |file|
  require file
end

RSpec.configure do |config|
  config.include(Cequel::SpecSupport::Helpers)

  config.before(:all) do
    connection = CassandraCQL::Database.new(Cequel::SpecSupport::Helpers.host)
    keyspace = Cequel::SpecSupport::Helpers.keyspace_name
    connection.execute <<-CQL
      CREATE KEYSPACE #{keyspace}
      WITH strategy_class = 'SimpleStrategy'
      AND strategy_options:replication_factor = 1
    CQL
  end

  config.after(:all) do
    keyspace = Cequel::SpecSupport::Helpers.keyspace_name
    cequel.execute("DROP KEYSPACE #{keyspace}")
  end
end
