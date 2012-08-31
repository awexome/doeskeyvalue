# AWEXOME LABS
# DoesKeyValue
#
# Util -- Utility methods and helpers for use in data access and manipulation

require "singleton"

module DoesKeyValue
  class Util

    # Convert a value to the given type:
    def self.to_type(value, type)
      DoesKeyValue.log("Converting type of value:#{value} to type:#{type}")
      case type.to_sym
        when :string
          value.to_s
        when :integer
          value.to_i
        when :boolean
          converted = true if value == true || value =~ /(true|t|yes|y|1)$/i
          converted = false if value == false || value =~ /(false|f|no|n|0)$/i
          converted
        when :decimal
          value.to_f
        when :datetime
          value.to_datetime
        else
          value
      end
    end

  end # Util
end # DoesKeyValue

