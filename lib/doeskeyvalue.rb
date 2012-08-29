# AWEXOME LABS
# DoesKeyValue

require "doeskeyvalue"
require "rails"
require "active_record"
require "hashie"

require "doeskeyvalue/state"
require "doeskeyvalue/column_storage"
require "doeskeyvalue/table_storage"

module DoesKeyValue

  # Create a Rails Engine
  class Engine < Rails::Engine
  end
  
  # Return the current working version from VERSION file:
  def self.version
    @@version ||= File.open(File.join(File.dirname(__FILE__), "..", "VERSION"), "r").read
  end
    
end # DoesKeyValue


module ActiveRecord
  class Base

    # Call this "acts as" method within your ActiveRecord class to establish key-
    # value behavior and prepare internal storage structures
    def self.does_keys(opts={})
      if storage_column = opts[:column]
        self.instance_eval do
          DoesKeyValue::State.instance.add_class(self, :column=>storage_column)
          extend DoesKeyValue::ColumnStorage
        end

      elsif storage_table = opts[:table]
        self.instance_eval do
          DoesKeyValue::State.instance.add_class(self, :table=>storage_table)
          extend DoesKeyValue::TableStorage
        end
      end
    end
    
  end # Base
end # ActiveRecord
