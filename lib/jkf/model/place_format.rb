module Jkf
  module Model
    PlaceFormat = Struct.new(:file, :rank, keyword_init: true) do
      def to_jkf
        { "x" => file, "y" => rank }
      end

      def self.from_jkf(jkf)
        new(file: jkf["x"], rank: jkf["y"])
      end
    end
  end
end
