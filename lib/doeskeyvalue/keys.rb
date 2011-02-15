# AWEXOME LABS
# DoesKeyValue
#
# Keys -- ActiveRecord::Base methods for setting schemaless keys

module DoesKeyValue
  module Keys
    
    def declare_key(key_value_column, key_name, opts={})
      raise DoesKeyValue::NoColumnNameSpecified unless key_value_column
      raise DoesKeyValue::NoKeyNameSpecified unless key_name
      raise DoesKeyValue::KeyAndIndexOptionsMustBeHash unless opts.is_a?(Hash)
    
      # Define accessors for the key column in the AR class:
      class_eval <<-EOS
        def #{key_name}
          return (self.send(:#{key_value_column}) || Hash.new)[:#{key_name}]
        end
      
        def #{key_name}=(value)
          key_set = self.send(:#{key_value_column}) || Hash.new
          key_set[:#{key_name}] = value
          self.send("#{key_value_column}=", key_set)
        end
      EOS
    
      # Check for opts[:index=>true] and if present, call declare_index
      if opts[:index] == true
        declare_index(key_value_column, key_name)   # TODO: Provide mechanism for passing index options
      end
    
    end
        
  end # Keys
end # DoesKeyValue