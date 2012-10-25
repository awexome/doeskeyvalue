# AWEXOME LABS
# DoesKeyValue

require "doeskeyvalue"
require "active_record"
require "active_support"
require "hashie"

require "doeskeyvalue/configuration"
require "doeskeyvalue/state"
require "doeskeyvalue/util"
require "doeskeyvalue/index"
require "doeskeyvalue/accessors"
# require "doeskeyvalue/column_storage"   # <= Deprecating in favor of combined Accessors
# require "doeskeyvalue/table_storage"    # <= Deprecating in favor of combined Accessors

module DoesKeyValue

  # Return the current working version from VERSION file:
  def self.version
    Gem.loaded_specs["doeskeyvalue"].version.to_s
  end

  # Log messages
  def self.log(msg)
    puts "DoesKeyValue: #{msg}" unless configuration.log_level == :silent
  end
    
end # DoesKeyValue


module ActiveRecord
  class Base

    # Call this "acts as" method within your ActiveRecord class to establish key-
    # value behavior and prepare internal storage structures
    def self.does_keys(opts={})
      DoesKeyValue.log("Adding key-value support to class #{self.to_s}")
      # TODO: Raise exception to improper opts passed
      self.instance_eval do
        DoesKeyValue::State.instance.add_class(self, opts)
        self.send(:serialize, opts[:column], Hash) if opts[:column]
        self.send(:attr_accessor, :key_value_cache) if opts[:table]
        extend DoesKeyValue::Accessors
      end


      # if storage_column = opts[:column]
      #   DoesKeyValue.log("Adding key-value support via column #{storage_column} to class #{self.to_s}")
      #   self.instance_eval do
      #     DoesKeyValue::State.instance.add_class(self, :column=>storage_column)
      #     self.send(:serialize, storage_column, Hash)
      #     extend DoesKeyValue::ColumnStorage
      #   end

      # elsif storage_table = opts[:table]
      #   DoesKeyValue.log("Adding key-value support via table #{storage_table} to class #{self.to_s}")
      #   self.instance_eval do
      #     DoesKeyValue::State.instance.add_class(self, :table=>storage_table)
      #     extend DoesKeyValue::TableStorage
      #   end
      # end

    end
    
  end # Base
end # ActiveRecord
