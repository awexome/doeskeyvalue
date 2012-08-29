# AWEXOME LABS
# DoesKeyValue
#
# ColumnStorage -- Support and methods for key-value pairs stored within TEXT
#  or BLOB fields on the same table as the parent object.

module DoesKeyValue
  module ColumnStorage

    # Define a supported key
    def has_key(key_name, opts={})
      opts = {
        index: true,
        type: "string",
        default: nil
      }.merge(opts)

      DoesKeyValue::State.instance.add_key(self, key_name, opts)

      storage_column = DoesKeyValue::State.instance.options_for_class(self)[:column]

      if opts[:index]
        scope "with_#{key_name}", lambda {|value| 
          where(["`#{storage_column}` LIKE ?", "%#{key_name}: #{value}%"])
        }
        DoesKeyValue.log("Scope with_#{key_name} added for indexed key #{key_name}")
      else
        DoesKeyValue.log("No search scope added for key #{key_name}; index set to false")
      end

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

      define_method("#{key_name}=") do |value|
        DoesKeyValue.log("Modifying value for key:#{key_name} to value:#{value}")
        blob = self.send(:read_attribute, storage_column) || Hash.new
        blob = Hashie::Mash.new(blob)
        blob[key_name] = value
        self.send(:write_attribute, storage_column, blob.to_hash)
      end

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
