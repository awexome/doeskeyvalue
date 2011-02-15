# AWEXOME LABS
# DoesKeyValue

require 'doeskeyvalue'
require 'rails'
require 'active_record'

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
    def initialize(msg="A document column name must be provided to build a document_field."); super(msg); end
  end
  class NoKeyNameSpecified < Exception
    def initialize(msg="A document field name must be provided to build a document_field"); super(msg); end
  end
  class NoKeyForThatIndex < Exception
    def initialize(msg="A document field must exist before an index can be applied to it"); super(msg); end
  end
  class KeyAndIndexOptionsMustBeHash < Exception
    def initialize(msg="Options passed to declarations of keys and indexes must of class Hash"); super(msg); end
  end
  
end # DoesKeyValue


module ActiveRecord
  class Base
    
    # Call this method within your class to establish key-value behavior and prep
    # the internal structure that will hold the blob
    def self.doeskeyvalue(column, opts={})
      puts "DOES_KEY_VALUE: Turned on for AR Column:#{column}"
      self.instance_eval do
        extend DoesKeyValue::Keys
        extend DoesKeyValue::Indexes
        
        # Identify the AR text column holding our data and serialize it:
        @@key_value_column = column.to_sym
        cattr_accessor :key_value_column
        serialize @@key_value_column, Hash
      end
      
      Array.class_eval do
        include DoesKeyValue::Util::CondArray
      end
      
      instance_eval <<-EOS
        def #{@@key_value_column}_key(key_name, opts={})
          puts "DOES_KEY_VALUE: Inside defined method #{@@key_value_column}_key"
          key_name = key_name.to_sym
          declare_key(@@key_value_column, key_name, opts)
        end
        
        def #{@@key_value_column}_index(key_name, opts={})
          puts "DOES_KEY_VALUE: Inside defined method #{@@key_value_column}_index"
          key_name = key_name.to_sym
          declare_index(@@key_value_column, key_name, opts)
        end
      EOS
      puts "DOES_KEY_VALUE: key and index methods declared"
    end
    
    
  end # ActiveRecord::Base
end # ActiveRecord
