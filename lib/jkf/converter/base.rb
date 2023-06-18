module Jkf
  module Converter
    # Base of Converter
    class Base
      # start convert
      # 
      # @param [String, Hash] jkf
      # @return [String] kif or ki2 or csa text
      def convert(jkf)
        jkf = jkf.is_a?(Hash) ? jkf : JSON.parse(jkf)
        convert_root(jkf)
      end
    end
  end
end
