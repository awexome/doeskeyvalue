# AWEXOME LABS
# DoesKeyValue
#
# CreateKeyValueIndex -- generated migration template for key/value index table

class CreateKeyValueIndex < ActiveRecord::Migration
  def self.up
    create_table :key_value_index do |t|
      # The key is a composite of the grouping and key name (e.g., "settings.user_id")
      t.string :key_name
      
      # The stored value is saved as varchar(255), which limits indexability slightly:
      t.string :value
      
      # Store details about the target object:
      t.string :obj_type
      t.integer :obj_id
      
      # Track all touches:
      t.timestamps
    end
    
    # Index is important here:
    add_index :key_value_index, [:obj_type, :key_name, :value]
  end

  def self.down
    drop_table :key_value_index
  end
end