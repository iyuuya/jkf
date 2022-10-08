require 'singleton'

module Jkf
  module Model
    module Color
      class Black
        include Singleton

        def black?
          true
        end

        def white?
          !black?
        end

        def to_jkf
          0
        end
      end

      class White
        include Singleton

        def black?
          !white?
        end

        def white?
          true
        end

        def to_jkf
          1
        end
      end

      def self.black
        Black.instance
      end

      def self.white
        White.instance
      end
    end
  end
end
