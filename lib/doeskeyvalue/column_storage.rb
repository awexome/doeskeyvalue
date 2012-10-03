# AWEXOME LABS
# DoesKeyValue
#
# ColumnStorage -- Support and methods for key-value pairs stored within TEXT
#  or BLOB fields on the same table as the parent object.

module DoesKeyValue

  SUPPORTED_DATA_TYPES = %w(string integer decimal boolean datetime)

  module ColumnStorage

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
      storage_column = DoesKeyValue::State.instance.options_for_class(self)[:column]

      # Accessor for new key with support for default value:
      define_method(key_name) do
        DoesKeyValue.log("Accessing key:#{key_name} for class:#{self.class}")
        blob = self.send(:read_attribute, storage_column) || Hash.new
        blob = Hashie::Mash.new(blob)
        value = blob.send(key_name)

        if value
          return value
        elsif default_value = self.class.key_options(key_name)[:default]
          return default_value
        end
      end

      # Manipulator for new key:
      define_method("#{key_name}=") do |value|
        DoesKeyValue.log("Modifying value for key:#{key_name} to value:#{value}")
        blob = self.send(:read_attribute, storage_column) || Hash.new
        blob = Hashie::Mash.new(blob)

        typed_value = DoesKeyValue::Util.to_type(value, key_type)

        blob[key_name] = typed_value
        self.send(:write_attribute, storage_column, blob.to_hash)
      end

      # If key is indexed, add scopes, finders, and callbacks for index management:
      if key_indexed

        # With scope:
        scope "with_#{key_name}", lambda {|value| 
          DoesKeyValueIndex.find_objects(self, key_name, value)
        }
        DoesKeyValue.log("Scope with_#{key_name} added for indexed key #{key_name}")
      
        # Update the index after save:
        define_method("update_index_for_#{key_name}") do
          DoesKeyValueIndex.update_index(self, key_name, self.send(key_name))
        end
        after_save "update_index_for_#{key_name}"

        # Delete the index after destroy:
        define_method("destroy_index_for_#{key_name}") do
          DoesKeyValueIndex.delete_index(self, key_name)
        end
        after_destroy "destroy_index_for_#{key_name}"

      end # if key_indexed


    end


    # Return a list of currently supported keys:
    def keys
      DoesKeyValue::State.instance.keys[self.to_s]
    end

    # Return the specific configuration for a given key:
    def key_options(key_name)
      DoesKeyValue::State.instance.options_for_key(self, key_name)
    end


  end # ColumnStorage
end # DoesKeyValue
