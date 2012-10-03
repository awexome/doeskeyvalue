# AWEXOME LABS
# DoesKeyValue
#
# TableStorage -- Support and methods for key-value pairs stored in an altogether
#  separate database table.

module DoesKeyValue
  module TableStorage

    # Define a supported key
    def has_key(key_name, opts={})
      opts = {
        index: true,
        type: "string",
        default: nil
      }.merge(opts)

      key_indexed = opts[:index]
      key_type = opts[:type].to_sym
      key_default_value = opts[:default]

      raise Exception.new("Data type not supported: #{key_type}") unless DoesKeyValue::SUPPORTED_DATA_TYPES.include?(key_type.to_s)

      DoesKeyValue::State.instance.add_key(self, key_name, opts)
      storage_table = DoesKeyValue::State.instance.options_for_class(self)[:table]

      # Accessor for new key with support for default value:
      define_method(key_name) do
        DoesKeyValue.log("Accessing BY TABLE key:#{key_name} for class:#{self.class}")
        if self.new_record?
          DoesKeyValue.log("-- Object does not have a database ID. No resource to query against.")
          return nil
        end

        value = DoesKeyValue::Index.read_index(self, key_name)
        if !value.nil?
          return value
        elsif default_value = self.class.key_options(key_name)[:default]
          return default_value
        end
      end

      # Manipulator for new key:
      define_method("#{key_name}=") do |value|
        DoesKeyValue.log("Modifying BY TABLE value for key:#{key_name} to value:#{value}")
        unless self.new_record?
          DoesKeyValue::Index.update_index(self, key_name, value)
        else
          DoesKeyValue.log("-- Object does not have a database ID. Holding back table index update.")
        end
      end

      # All table-based key-value stores have index finders and scopes:
      scope "with_#{key_name}", lambda {|value| 
        DoesKeyValue::Index.find_objects(self, key_name, value)
      }
      DoesKeyValue.log("Scope with_#{key_name} added for table-storage key #{key_name}")
      
      # Delete the index after destroy:
      define_method("destroy_index_for_#{key_name}") do
        DoesKeyValue::Index.delete_index(self, key_name)
      end
      after_destroy "destroy_index_for_#{key_name}"

    end


    # Return a list of currently supported keys:
    def keys
      DoesKeyValue::State.instance.keys[self.to_s]
    end

    # Return the specific configuration for a given key:
    def key_options(key_name)
      DoesKeyValue::State.instance.options_for_key(self, key_name)
    end

  end # TableStorage
end # DoesKeyValue
