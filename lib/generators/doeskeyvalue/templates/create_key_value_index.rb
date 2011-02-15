# AWEXOME LABS
# DoesKeyValue
#
# CreateKeyValueIndex -- generated migration template for key/value index table

class CreateKeyValueIndex < ActiveRecord::Migration
  def self.up
    create_table :key_value_index do |t|
      t.string :obj_type
      t.string :key_name
      t.string :value
      t.integer :obj_id
      
      t.timestamps
    end
    
    # Index is important here:
    add_index :key_value_index, [:obj_type, :key_name, :value]
  end

  def self.down
    drop_table :key_value_index
  end
end