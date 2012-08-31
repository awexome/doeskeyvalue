# AWEXOME LABS
# DoesKeyValue
#
# Generator -- Migration generator for the column-backed index table and/or
#  the table-backed storage tables

require "rails/generators"
require "rails/generators/migration"

class DoeskeyvalueGenerator < Rails::Generators::Base
  include Rails::Generators::Migration
  source_root File.expand_path("../templates", __FILE__)
  
  def self.next_migration_number(path)
    if ActiveRecord::Base.timestamped_migrations
      Time.now.utc.strftime("%Y%m%d%H%M%S")
    else
      "%.3d" % (current_migration_number(path) + 1)
    end
  end
  
  def create_migration_file
    puts "Creating DoesKeyValue index table migration"

    if table_name = ARGV.first
      puts "=> #{table_name} table to be created"
      migration_template "create_key_value_index.rb", "db/migrate/create_key_value_index_#{table_name}.rb", table_name:table_name
    else
      puts "=> Generic index table to be created"
      migration_template "create_key_value_index.rb", "db/migrate/create_key_value_index.rb", table_name:"key_value_index"
    end

  end
  
end
