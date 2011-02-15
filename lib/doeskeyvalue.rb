# AWEXOME LABS
# DoesKeyValue

require 'doeskeyvalue'
require 'rails'
require 'active_record'

require 'doeskeyvalue/keys'
require 'doeskeyvalue/indexes'


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
      self.instance_eval do
        include DoesKeyValue::Keys
        include DoesKeyValue::Indexes
        
        Array.class_eval do
          include DoesKeyValue::Util::CondArray
        end
        
        # Identify the AR text column holding our data and serialize it:
        @@key_value_column = column.to_sym
        cattr_accessor :key_value_column
        serialize @@key_value_column, Hash
        
        # Create a convenience method allowing declaration of internal keys by using
        # the AR column passed to this builder:
        instance_eval <<-EOS
          def #{@@key_value_column}_key(*args)
            # TODO: Allow passing :index=>true to key declaration
            self.declare_key(*args.unshift(:#{@@key_value_column}))
          end
          def #{@@key_value_column}_index(*args)
            self.declare_index(*args.unshift(:#{@@key_value_column}))
          end
        EOS
      end
    end
    
    
  end # ActiveRecord::Base
end # ActiveRecord
