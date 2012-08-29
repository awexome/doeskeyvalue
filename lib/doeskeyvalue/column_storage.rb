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

      define_method(key_name) do
        puts "Accessing key:#{key_name} for class:#{self}"
        blob = self.send(:read_attribute, storage_column) || Hash.new
        blob = Hashie::Mash.new(blob)
        return blob.send(key_name)
      end

      define_method("#{key_name}=") do |value|
        puts "Modifying value for key:#{key_name} to value:#{value}"
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


  end # ColumnStorage
end # DoesKeyValue
