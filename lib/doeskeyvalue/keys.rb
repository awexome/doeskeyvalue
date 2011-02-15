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
      
      # TODO: Allow :type option to set an enforced data type
      # TODO: Allow :default option to set a default return value
  
      # Define accessors for the key column in the AR class:
      class_eval <<-EOS
        def #{key_name}
          all_keys = self.send(:read_attribute, :#{key_value_column}) || Hash.new
          return all_keys[:#{key_name}]
        end
      
        def #{key_name}=(value)
          all_keys = self.send(:read_attribute, :#{key_value_column}) || Hash.new
          all_keys[:#{key_name}] = value
          self.send(:write_attribute, :#{key_value_column}, all_keys)
        end
      EOS
    
      # Check for opts[:index=>true] and if present, call declare_index
      if opts[:index] == true
        declare_index(key_value_column, key_name)   # TODO: Provide mechanism for passing index options
      end
    
    end
    
    
        
  end # Keys
end # DoesKeyValue