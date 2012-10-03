# AWEXOME LABS
# DoesKeyValue

require "doeskeyvalue"
require "active_record"
require "active_support"
require "hashie"

require "doeskeyvalue/state"
require "doeskeyvalue/util"
require "doeskeyvalue/does_key_value_index"
require "doeskeyvalue/column_storage"
require "doeskeyvalue/table_storage"

module DoesKeyValue

  # Return the current working version from VERSION file:
  def self.version
    @@version ||= File.open(File.join(File.dirname(__FILE__), "..", "VERSION"), "r").read.strip
  end

  # Log messages
  def self.log(msg)
    puts "DoesKeyValue: #{msg}"
  end
    
end # DoesKeyValue


module ActiveRecord
  class Base

    # Call this "acts as" method within your ActiveRecord class to establish key-
    # value behavior and prepare internal storage structures
    def self.does_keys(opts={})
      if storage_column = opts[:column]
        DoesKeyValue.log("Adding key-value support via column #{storage_column} to class #{self.to_s}")
        self.instance_eval do
          DoesKeyValue::State.instance.add_class(self, :column=>storage_column)
          self.send(:serialize, storage_column, Hash)
          extend DoesKeyValue::ColumnStorage
        end

      elsif storage_table = opts[:table]
        DoesKeyValue.log("Adding key-value support via table #{storage_table} to class #{self.to_s}")
        self.instance_eval do
          DoesKeyValue::State.instance.add_class(self, :table=>storage_table)
          extend DoesKeyValue::TableStorage
        end
      end
    end
    
  end # Base
end # ActiveRecord
