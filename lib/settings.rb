require 'data_mapper'

# Initialize the DataMapper to use a database, if available. Fall back to an
# sqlite file, if no database has been set up.
DataMapper.setup(:default, ENV['DATABASE_URL'] || 'sqlite:persistent.db')

# Set object model for settings
class Setting
  include DataMapper::Resource

  property :name, String, :key => true
  property :value, Text
end

# Finalize all models
DataMapper.finalize

# Up-migrate the schema
DataMapper.auto_upgrade!
