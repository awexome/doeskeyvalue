# AWEXOME LABS
# DoesKeyValue
#
# TableStorage -- Accessor and update methods for keys managed under the
#  key-value store defined for given classes.

module DoesKeyValue

  # Define our types for strongly-typed results storage:
  SUPPORTED_DATA_TYPES = %w(string integer decimal boolean datetime)

  module Accessors

    # Define a supported key
    def has_key(key_name, opts={})
      opts = {
        index: true,
        type: "string",
        default: nil
      }.merge(opts)

      # Table-based storage dictates an index:
      opts[:index] = true if table_storage?

      # Cache values of common options:
      key_indexed = opts[:index]
      key_type = opts[:type].to_sym
      key_default_value = opts[:default]

      # Ensure we are invoked with a supported data type:
      raise Exception.new("Data type not supported: #{key_type}") unless DoesKeyValue::SUPPORTED_DATA_TYPES.include?(key_type.to_s)

      # Save a representation of this key in the State:
      define_key(key_name, opts)

      # Accessor for new key with support for default value:
      define_method(key_name) do
        DoesKeyValue.log("Accessing key:#{key_name} for class:#{self.class}")
        blob = if self.class.column_storage?
          Hashie::Mash.new( self.send(:read_attribute, self.class.storage_column) || Hash.new )
        elsif self.class.table_storage?
          # TODO: Proper cache-through hash for Table-based storage
          Hashie::Mash.new( {key_name => DoesKeyValue::Index.read_index(self, key_name)} )
        end

        value = blob.send(key_name)

        return value unless value.nil?
        return key_default_value
      end

      # Manipulator for new key:
      define_method("#{key_name}=") do |value|
        DoesKeyValue.log("Modifying value for key:#{key_name} to value:#{value}")

        if self.class.column_storage?
          blob = Hashie::Mash.new( self.send(:read_attribute, self.class.storage_column) || Hash.new )
          typed_value = DoesKeyValue::Util.to_type(value, key_type)
          blob[key_name] = typed_value
          self.send(:write_attribute, self.class.storage_column, blob.to_hash)

        elsif self.class.table_storage?
          # TODO: Proper cache-through hash for Table-based storage:
          DoesKeyValue::Index.update_index(self, key_name, value) unless self.new_record?
        end
      end

      # If key is indexed, add scopes, finders, and callbacks for index management:
      if key_indexed

        # With scope:
        scope "with_#{key_name}", lambda {|value|
          DoesKeyValue::Index.find_objects(self, key_name, value)
        }
        DoesKeyValue.log("Scope with_#{key_name} added for indexed key #{key_name}")

        # Update the index after save:
        if column_storage?
          define_method("update_index_for_#{key_name}") do
            DoesKeyValue::Index.update_index(self, key_name, self.send(key_name))
          end
          after_save "update_index_for_#{key_name}"
        end

        # Delete the index after destroy:
        define_method("destroy_index_for_#{key_name}") do
          DoesKeyValue::Index.delete_index(self, key_name)
        end
        after_destroy "destroy_index_for_#{key_name}"

      end # if key_indexed


    end


    # Return true if this class uses column-based storage for key-value pairs:
    def column_storage?
      !storage_column.nil?
    end

    # Return the column used for storing key values for this class:
    def storage_column
      @storage_column ||= DoesKeyValue::State.instance.options_for_class(self)[:column]
    end

    # Return true if this class uses table-based storage for key-value pairs:
    def table_storage?
      !storage_table.nil?
    end

    # Return the table used for storing key values for this class:
    def storage_table
      @storage_table ||= DoesKeyValue::State.instance.options_for_class(self)[:table]
    end

    # Return a list of currently supported keys:
    def keys
      DoesKeyValue::State.instance.keys[self.to_s]
    end

    # Return the specific configuration for a given key:
    def key_options(key_name)
      DoesKeyValue::State.instance.options_for_key(self, key_name)
    end


    private

    # Define a new key for a class:
    def define_key(key_name, opts={})
      DoesKeyValue::State.instance.add_key(self, key_name, opts)
    end

  end # Accessors
end # DoesKeyValue
