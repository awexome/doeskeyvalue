# AWEXOME LABS
# DoesKeyValue
#
# Keys -- ActiveRecord::Base methods for setting schemaless keys

module DoesKeyValue
  module Keys
    
    def declare_key(key_value_column, key_name, opts={})
      # printf("DECLARE_KEY: %s.%s key declaration beginning\n", key_value_column, key_name)

      raise DoesKeyValue::NoColumnNameSpecified unless key_value_column
      raise DoesKeyValue::NoKeyNameSpecified unless key_name
      raise DoesKeyValue::KeyAndIndexOptionsMustBeHash unless opts.is_a?(Hash)
      
      # TODO: Allow :as option to set an enforced data type
      # TODO: Allow :default option to set a default return value
  
      # Define accessors for the key column in the AR class:
      class_eval <<-EOS
        def #{key_name}
          all_keys = self.send(:read_attribute, :#{key_value_column}) || Hash.new
          all_keys = Hashie::Mash.new(all_keys)
          return all_keys.send(:#{key_name})
        end
      
        def #{key_name}=(value)
          all_keys = self.send(:read_attribute, :#{key_value_column}) || Hash.new
          all_keys = Hashie::Mash.new(all_keys)
          all_keys.send("#{key_name}=", value)
          self.send(:write_attribute, :#{key_value_column}, all_keys.to_hash)
        end
      EOS
    
      # Check for opts[:index=>true] and if present, call declare_index
      if opts[:index] == true
        declare_index(key_value_column, key_name)   # TODO: Provide mechanism for passing index options
      end
      
      # Check for type declaration on the key:
      if opts[:as]
        puts "Specific type #{opts[:as]} declared for key #{key_name}"
        # TODO: Provide enforcement for this key type declaration
      end
      
      # Check for a default value that is provided:
      if opts[:default]
        puts "Default value of #{opts[:default]} declared for key #{key_name}"
        # TODO: Provide enforcement of this default value
      end
      
      # Add the key to the key and column manager:
      DoesKeyValue::KeyManager.instance.declare_key(self, key_value_column, key_name, opts)
    
    end
    
    
        
  end # Keys
end # DoesKeyValue