module Jkf::Converter
  class Base
    # @param [String, Hash] jkf
    # @return [String]
    def convert(jkf)
      jkf = jkf.is_a?(Hash) ? jkf : JSON.parse(jkf)
      convert_root(jkf)
    end
  end
end
