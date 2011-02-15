# AWEXOME LABS
# DoesKeyValue
#
# Keys -- ActiveRecord::Base methods for setting schemaless keys

module DoesKeyValue
  module Keys
    
    def declare_key(key_value_column, key_name, opts={})
      raise DoesKeyValue::NoColumnNameSpecified unless key_value_column
      raise DoesKeyValue::NoKeyNameSpecified unless key_name
      
      # self.send("document_fields").send("<<", field_name)
      # self.send("#{column_name}_fields").send("<<", field_name)

      # Define an accessor for the key column in the AR class:
      define_method(key_name) do
        return (self.send(key_value_column) || Hash.new)[key_name]
      end
      
      # Define a manipulator for the key column and given value in the AR class:
      define_method("#{key_name}=") do |value|
        key_set = self.send(key_value_column) || Hash.new
        key_set[key_name] = value
        self.send("#{key_value_column}=", key_set)
      end
      
    end
    
        
  end # Keys
end # DoesKeyValue