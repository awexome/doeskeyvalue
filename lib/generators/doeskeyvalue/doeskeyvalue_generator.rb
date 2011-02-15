# AWEXOME LABS
# DoesKeyValue
#
# IndexTableGenerator -- generator for the Index database table

require 'rails/generators'
require 'rails/generators/migration'

class DoeskeyvalueGenerator < Rails::Generators::Base
  include Rails::Generators::Migration
  source_root File.expand_path('../templates', __FILE__)
  
  def self.next_migration_number(path)
    if ActiveRecord::Base.timestamped_migrations
      Time.now.utc.strftime("%Y%m%d%H%M%S")
    else
      "%.3d" % (current_migration_number(path) + 1)
    end
  end
  
  def create_migration_file
    migration_template 'create_key_value_index.rb', 'db/migrate/create_key_value_index.rb'
  end
  
end
