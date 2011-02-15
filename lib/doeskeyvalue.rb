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
  
end # DoesKeyValue


module ActiveRecord
  class Base
    
    # Call this method within your class to establish key-value behavior and prep
    # the internal structure that will hold the blob
    def self.doeskeyvalue(column, opts={})
      puts "DOES_KEY_VALUE: Turned on for AR Column:#{column}"
      self.instance_eval do
        include DoesKeyValue::Keys
        include DoesKeyValue::Indexes
        
        # Identify the AR text column holding our data and serialize it:
        @@key_value_column = column.to_sym
        cattr_accessor :key_value_column
        serialize @@key_value_column, Hash
      end
      
      Array.class_eval do
        include DoesKeyValue::Util::CondArray
      end
      
      define_method("#{@@key_value_column}_key") do |key_name|
        puts "DOES_KEY_VALUE: Inside defined method #{@@key_value_column}_key"
        key_name = key_name.to_sym
        declare_key(@@key_value_column, key_name)
      end
      
      instance_eval <<-EOS
        # def #{@@key_value_column}_key(*args)
        #   # TODO: Allow passing :index=>true to key declaration
        #   puts "DOES_KEY_VALUE: Declaring a key from custom method"
        #   declare_key(*args.unshift(:#{@@key_value_column}))
        # end
        def #{@@key_value_column}_index(*args)
          puts "DOES_KEY_VALUE: Declaring an index from custom method"
          declare_index(*args.unshift(:#{@@key_value_column}))
        end
      EOS
        
      puts "DOES_KEY_VALUE: key and index methods declared"
    end
    
    
  end # ActiveRecord::Base
end # ActiveRecord
