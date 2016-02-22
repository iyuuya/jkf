module Jkf::Converter
  class Csa
    def convert(jkf)
      hash = if jkf.is_a?(Hash)
               jkf
             else
               JSON.parse(jkf)
             end
    end
  end
end
