# AWEXOME LABS
# DoesKeyValue
#
# State -- Singleton state class representing the state of supported objects,
#  known keys, and powered indexes

require "singleton"

module DoesKeyValue
  class State

    # There can be only one!
    include Singleton

    attr_reader :classes, :keys

    # Add support for a single class of objects:
    def add_class(klass, opts={})
      DoesKeyValue.log("State: Add support for class #{klass.to_s} with opts:#{opts.inspect}")
      @classes ||= Hash.new
      @classes[klass.to_s] = opts
    end

    # Add a key for a given class:
    def add_key(klass, key_name, opts={})
      DoesKeyValue.log("State: Add key #{key_name} to class #{klass.to_s} with opts:#{opts.inspect}")
      @keys ||= Hash.new
      @keys[klass.to_s] ||= Array.new
      @keys[klass.to_s] << {name:key_name, options:opts}
    end

    # Return the configuration for a given klass:
    def options_for_class(klass)
      @classes[klass.to_s] rescue {}
    end

    # Return the list of keys for a given klass:
    def keys_for_class(klass)
      @keys[klass.to_s] rescue []
    end


  end # State
end # DoesKeyValue

