# AWEXOME LABS
# DoesKeyValue
#
# Indexes -- ActiveRecord::Base methods for settings and retrieval of values based
#   on key indexes

module DoesKeyValue
  module Indexes
    
    def declare_index(key_value_column, key_name, opts={})
      raise DoesKeyValue::NoColumnNameSpecified unless key_value_column
      raise DoesKeyValue::NoKeyNameSpecified unless key_name
      raise DoesKeyValue::KeyAndIndexOptionsMustBeHash unless opts.is_a?(Hash)
      
      search_key = "#{key_value_column}.#{key_name}"
      ## TODO: raise DoesKeyValue::NoKeyForThatIndex unless self.send("#{key_value_column}_keys").include?(key_name)
      
      class_name = self.name.underscore
      class_table_name = self.table_name
      index_table_name = "key_value_indexes"
      
      # self.send("document_indexes").send("<<", field_name)
      # self.send("#{column_name}_indexes").send("<<", field_name)

      # INDEX TABLE: key_value_indexes
      #  id:int
      #  type:string
      #  key_name:string
      #  value:string
      #  obj_id:int
      
      # Define finders that leverage the custom index table:
      instance_eval <<-EOS
        def find_all_by_#{key_value_column}_#{key_name}(value)
          find(
            :all, 
            :select=>"*",
            :from=>"#{index_table_name}",
            :conditions=>["`#{index_table_name}`.key_name = ? AND `#{index_table_name}`.value = ?", "#{search_key}", value], 
            :joins => "LEFT JOIN `#{class_table_name}` ON `#{class_table_name}`.id = `#{index_table_name}`.obj_id"          
          )
        end
        
        def find_all_by_#{key_name}(value)
          find_all_by_#{key_value_column}_#{key_name}(value)
        end
        
        def find_all_with_#{key_value_column}(opts={})
          conds = Array.new
          opts.each do |k, v|
            conds.add_condition(["`#{index_table_name}`.key_name = ? AND `#{index_table_name}`.value = ?", "#{search_key}", v])
          end
          find(
            :all,
            :select=>"*",
            :from=>"#{index_table_name}",
            :conditions=>conds,
            :joins=>"LEFT JOIN `#{class_table_name}` ON `#{class_table_name}`.id = `#{index_table_name}`.obj_id"
          )
        end
      EOS
      
      # Provide a callback after save which updates the index
      define_method("update_index_#{key_value_column}_#{key_name}_after_save") do
        class_name = self.class.name.underscore
        class_table_name = self.class.table_name
        index_table_name = "key_value_indexes"
        idx_id = ActiveRecord::Base.connection.insert("INSERT INTO `#{index_table_name}` (`obj_id`,`key_name`,`value`) VALUES ("+self.id.to_s+", \""+search_key.to_s+"\", \"#{self.send(key_name).to_s}\")")
      end
      after_save "update_index_#{key_value_column}_#{key_name}_after_save"
      
      # Provide a callback after destroy to likewise update the index
      define_method("update_index_#{column_name}_#{field_name}_after_destroy") do
        class_name = self.class.name.underscore
        class_table_name = self.class.table_name
        index_table_name = "key_value_indexes"
        num_del = ActiveRecord::Base.connection.delete("DELETE FROM `#{index_table_name}` WHERE `obj_id` = #{self.id}")
      end
      after_destroy "update_index_#{column_name}_#{field_name}_after_destroy"
      
    end
    
    
  end # Index
end # DoesKeyValue