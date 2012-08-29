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

      define_method(key_name) do
        puts "Accessing key:#{key_name} for class:#{self}"
      end

      define_method("#{key_name}=") do |val|
        puts "Modifying value for key:#{key_name} to value:#{val}"
      end

    end


  end # ColumnStorage
end # DoesKeyValue
