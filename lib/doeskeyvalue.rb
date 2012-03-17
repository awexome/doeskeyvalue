# AWEXOME LABS
# DoesKeyValue

require 'doeskeyvalue'
require 'rails'
require 'active_record'
require 'hashie'

require 'doeskeyvalue/key_manager'
require 'doeskeyvalue/keys'
require 'doeskeyvalue/indexes'
require 'doeskeyvalue/util'


module DoesKeyValue

  # Create a Rails Engine
  class Engine < Rails::Engine
  end
  
  # Return the current working version from VERSION file:
  def self.version
    @@version ||= File.open(File.join(File.dirname(__FILE__), "..", "VERSION"), "r").read
  end
  
  # Exception Types for DoesKeyValue
  class NoColumnNameSpecified < Exception
    def initialize(msg="A class column name must be provided for storing key values in blob"); super(msg); end
  end
  class NoKeyNameSpecified < Exception
    def initialize(msg="A key name must be provided to build a DoesKeyValue key"); super(msg); end
  end
  class NoKeyForThatIndex < Exception
    def initialize(msg="A key must exist before an index can be applied to it"); super(msg); end
  end
  class KeyAndIndexOptionsMustBeHash < Exception
    def initialize(msg="Options passed to declarations of keys and indexes must of class Hash"); super(msg); end
  end
  class KeyValueIndexTableDoesNotExist < Exception
    def initialize(msg="DoesKeyValue requires an index table be generated to use key indexes. Use generator to generate migration"); super(msg); end
  end
  
end # DoesKeyValue


module ActiveRecord
  class Base
    
    # Call this method within your class to establish key-value behavior and prep
    # the internal structure that will hold the blob
    def self.doeskeyvalue(column, opts={})
      self.instance_eval do
        extend DoesKeyValue::Keys
        extend DoesKeyValue::Indexes
        
        # Identify the AR text column holding our data and serialize it:
        @column_name = column.to_sym
        cattr_accessor :column_name
        #serialize @column_name, Hashie::Mash
        serialize @column_name, Hash
        
        # Add the column to the key and column manager so we can reference it later:
        DoesKeyValue::KeyManager.instance.declare_column(self, @column_name)
      end
      
      Array.class_eval do
        include DoesKeyValue::Util::CondArray
      end
      
      instance_eval <<-EOS
        def #{@column_name}_key(key_name, opts={})
          column_name = :#{@column_name}
          key_name = key_name.to_sym
          declare_key(column_name, key_name, opts)
        end
        
        def #{@column_name}_index(key_name, opts={})
          column_name = :#{@column_name}
          key_name = key_name.to_sym
          declare_index(column_name, key_name, opts)
        end
        
        def key_value_columns
          return DoesKeyValue::KeyManager.instance.columns_for(self)
        end
                  
        def #{@column_name}_keys
          column_name = :#{@column_name}
          return DoesKeyValue::KeyManager.instance.keys_for(self, column_name)
        end
        
        def #{@column_name}_indexes
          column_name = :#{@column_name}
          return DoesKeyValue::KeyManager.instance.indexes_for(self, column_name)
        end
      EOS
    end
    
    
  end # ActiveRecord::Base
end # ActiveRecord
