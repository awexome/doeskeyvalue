# AWEXOME LABS
# DoesKeyValue
#
# State -- Singleton state class representing the state of supported objects,
#  known keys, and powered indexes

module DoesKeyValue
  class State

    # There can be only one!
    include Singleton

    # Add support for a single class of objects:
    def add_class(klass, opts={})
    end

    # Add a key for a given class:
    def add_key(klass, key_name, opts={})
    end


  end # State
end # DoesKeyValue



# AWEXOME LABS
# DoesKeyValue
#
# KeyManager -- Holds and maintains key_value configuration for all
#   classes and blob-containers implementing DoesKeyValue

module DoesKeyValue
  class KeyManager
    
    # There can be only one:
    include Singleton
    
    
    # Return the Hash of known columns, organized by declaring class
    def columns
      @columns ||= Hashie::Mash.new
    end
    
    # Declare a key_value columns' existing in a given class
    def declare_column(klass, column_name)
      @columns ||= Hashie::Mash.new
      if @columns[klass].nil?
        @columns[klass] = [column_name]
      else
        @columns[klass] << column_name
      end
      @columns[klass]
    end
    
    # Return the key columns present on a specific class
    def columns_for(klass)
      columns_this_klass = columns[klass]
      columns_lineage = [ columns_this_klass ]
      if ancestor = klass.ancestors[1]
        unless ancestor == ActiveRecord::Base
          columns_lineage << columns_for(ancestor)
        end
      end
      columns_lineage.reject{|i| i.nil? }.flatten
    end
    
    
    # Return the Hash of known keys, organized by the declaring class
    def keys
      @keys ||= Hashie::Mash.new
    end
    
    # Declare a key in a specific column set for a specific class
    def declare_key(klass, column_name, key, opts={})
      # TODO: Store the key options in the manager
      column_name = column_name.to_sym
      @keys ||= Hashie::Mash.new
      if klass_keys = @keys[klass]
        if column_keys = klass_keys[column_name]
          column_keys << key
        else
          klass_keys[column_name] = [key]
        end
      else
        @keys[klass] = {column_name => [key]}
      end
      @keys[klass][column_name]      
    end
    
    # Return the keys present for the given column on a specific class
    def keys_for(klass, column_name)
      keys_this_klass = keys[klass][column_name] rescue []
      keys_lineage = [ keys_this_klass ]
      if ancestor = klass.ancestors[1]
        unless ancestor == ActiveRecord::Base
          keys_lineage << keys_for(ancestor, column_name)
        end
      end
      keys_lineage.flatten.reject{|i| i.nil?}
    end
    
    
    
    # Return the Hash of known Indexes, organized by the declaring class
    def indexes
      @indexes ||= Hashie::Mash.new
    end
    
    # Declare an index in a specific column set for a specific class
    def declare_index(klass, column_name, key, opts={})
      # TODO: Store the index options in the manager
      column_name = column_name.to_sym
      @indexes ||= Hashie::Mash.new
      if klass_indexes = @indexes[klass]
        if column_indexes = klass_indexes[column_name]
          column_indexes << key
        else
          klass_indexes[column_name] = [key]
        end
      else
        @indexes[klass] = {@column_name => [key]}
      end
      @indexes[klass][column_name]
    end
    
    # Return the indexes present for the given column on a specific class
    def indexes_for(klass, column_name)
      indexes_this_klass = indexes[klass][column_name] rescue []
      indexes_lineage = [ indexes_this_klass ]
      if ancestor = klass.ancestors[1]
        unless ancestor == ActiveRecord::Base
          indexes_lineage << indexes_for(ancestor, column_name)
        end
      end
      indexes_lineage.flatten.reject{|i| i.nil? }
    end
        
    
        
  end # KeyManager
end # DoesKeyValue
