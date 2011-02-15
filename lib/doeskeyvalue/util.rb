# AWEXOME LABS
# DoesKeyValue


module DoesKeyValue
  module Util
  
    module CondArray
      def add_condition(cond, conj="AND")
        if cond.is_a?(Array)
          if self.empty?
            (self << cond).flatten!
          else
            self[0] += " #{conj} #{cond.shift}"
            (self << cond).flatten!
          end
        elsif cond.is_a?(String)
          self[0] += " #{conj} #{cond}"
        else
          raise "Condition must be an Array or String"
        end
        self
      end
    end
  
  end
end # DoesKeyValue
