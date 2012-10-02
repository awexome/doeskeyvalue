# AWEXOME LABS
# DoesKeyValue
#
# DoesKeyValueIndex -- An AR model used for updating indexes

class DoesKeyValueIndex < ActiveRecord::Base

  # The default index table (overidden individually for custom tables):
  self.table_name = "key_value_index"

  # All attributes of an index row are mass-editable:
  attr_accessible :obj_type, :obj_id, :key_name, :key_type, 
                  :value_string, :value_integer, :value_decimal, :value_boolean, :value_datetime


  # Update the appropriate index with new/changed information for the given
  # object/key/value combination:
  def self.update_index(object, key_name, value)
    # Log our index column values:
    object_type = object.class.to_s
    object_id = object.id
    key_type = object.class.key_options(key_name)[:type]

    # Prepare update conditions and manipulators:
    update_set = {key_type: key_type}
    condition_set = {obj_type: object_type, obj_id: object_id, key_name: key_name}
    create_set = {obj_type: object_type, obj_id: object_id, key_name: key_name, key_type: key_type}

    # Insert the new value of the correct type:
    update_set["value_#{key_type}"] = value
    create_set["value_#{key_type}"] = value

    DoesKeyValue.log("Updating Index for class:#{object_type} key:#{key_name}:")
    DoesKeyValue.log("update_set: #{update_set.inspect}")
    DoesKeyValue.log("condition_set: #{condition_set.inspect}")
    DoesKeyValue.log("create_set: #{create_set.inspect}")


    # TODO: Change table_name to match the specified table for this class

    updated_count = DoesKeyValueIndex.update_all( update_set, condition_set )
    if !value.nil? && updated_count == 0
      DoesKeyValueIndex.create( create_set )
    end

    # TODO: Change the value for table_name back to the original value

  end


  # Delete an index record for a given object/key combination:
  def self.delete_index(object, key_name)
    object_type = object.class.to_s
    object_id = object.id

    # TODO: Change table_name to match the specified table for this class

    deleted_count = DoesKeyValueIndex.delete_all(
      obj_type: object_type, obj_id: object_id, key_name: key_name
    )

    # TODO: Change the value for table_name back to the original value
    
  end



end
