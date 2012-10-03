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


  # Search the database for objects matching the given query for the given key:
  def self.find_objects(klass, key_name, value)
    object_type = klass.to_s
    key_type = klass.key_options(key_name)[:type]

    condition_set = {obj_type: object_type, key_name: key_name, key_type: key_type, "value_#{key_type}"=>value}
    DoesKeyValue.log("Condition Set for index find: #{condition_set.inspect}")
    table_agnostic_exec(klass) do
      index_rows = DoesKeyValueIndex.where(condition_set)
      object_ids = index_rows.blank? ? [] : index_rows.collect {|i| i.obj_id }
      klass.where(:id=>object_ids)
    end
  end


  # Read the appropriate index values for the given object/key combination:
  def self.read_index(object, key_name)
    object_type = object.class.to_s
    object_id = object.id
    key_type = object.class.key_options(key_name)[:type]

    # Prepare the query conditions:
    condition_set = {obj_type: object_type, obj_id: object_id, key_name: key_name}

    # Access the appropriate value column of the returned index:
    table_agnostic_exec(object.class) do 
      DoesKeyValueIndex.where(condition_set).first().try(:send, "value_#{key_type}")
    end
  end


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

    # Update an index in a table-agnostic way to support table-based key-value storage in
    # database tables other than the universal table:
    table_agnostic_exec(object.class) do
      updated_count = DoesKeyValueIndex.update_all( update_set, condition_set )
      if !value.nil? && updated_count == 0
        DoesKeyValueIndex.create( create_set )
      end
    end

  end


  # Delete an index record for a given object/key combination:
  def self.delete_index(object, key_name)
    object_type = object.class.to_s
    object_id = object.id

    deleted_count = table_agnostic_exec(object.class) do
      DoesKeyValueIndex.delete_all(
        obj_type: object_type, obj_id: object_id, key_name: key_name
      )
    end
  end



  private

  # Return true only if the storage method for the given class is table:
  def self.table_storage_for_class?(klass)
    storage_options = DoesKeyValue::State.instance.options_for_class(klass)
    storage_options[:table].nil? ? false : true
  end

  # Perform a block action inside of table-altered query:
  def self.table_agnostic_exec(klass)
    begin
      original_table_name = DoesKeyValueIndex.table_name
      if DoesKeyValueIndex.table_storage_for_class?(klass)
        class_storage_options = DoesKeyValue::State.instance.options_for_class(klass)
        if class_storage_options[:table]
          DoesKeyValueIndex.table_name = class_storage_options[:table]
          DoesKeyValue.log("Storage table for index changed to '#{DoesKeyValueIndex.table_name}'")
        end
      end

      exec_result = yield

      if DoesKeyValueIndex.table_storage_for_class?(klass)
        DoesKeyValueIndex.table_name = original_table_name
        DoesKeyValue.log("Storage table for index changed back to original '#{DoesKeyValueIndex.table_name}")
      end

      return exec_result

    rescue ActiveRecord::StatementInvalid => e
      DoesKeyValue.log("Database query statement invalid: #{e.message}")
      if (e.message =~ /doesn't exist/)
        DoesKeyValue.log("It appears the index table `#{DoesKeyValueIndex.table_name}` expected has not been generated.")
        DoesKeyValue.log("To generate the necessary table run: rails generate doeskeyvalue #{DoesKeyValueIndex.table_name}")
      end
      raise e

    ensure
      # Ensure that the table name is always restored
      DoesKeyValueIndex.table_name = original_table_name
      DoesKeyValue.log("After table-agnostic execution, table name restored to '#{DoesKeyValueIndex.table_name}'")
    end
  end



end
