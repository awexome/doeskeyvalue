# AWEXOME LABS
# DoesKeyValue
#
# CreateKeyValueIndex -- generated migration template for key/value index table

<%
  table_name = config[:table_name]
-%>

class Create<%=table_name.camelize-%> < ActiveRecord::Migration
  def self.up
    create_table :<%=table_name-%> do |t|
      # The object is linked by class type and id:
      t.string :obj_type
      t.integer :obj_id

      # The key is identified by name and data type:
      t.string :key_name
      t.string :key_type
      
      # The value is stored in various possible formats:
      t.string :value_string
      t.integer :value_integer
      t.decimal :value_decimal
      t.boolean :value_boolean
      t.datetime :value_datetime

      # Traditional record-keeping for the index:
      t.timestamps
    end
    
    # Index is important here:
    add_index :<%=table_name-%>, [:obj_type, :key_name]
  end

  def self.down
    drop_table :<%=table_name%>
  end
end
