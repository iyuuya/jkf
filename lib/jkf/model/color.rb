require 'singleton'
require_relative '../model'

module Jkf
  module Model
    module Color
      def self.black
        Black.instance
      end

      def self.white
        White.instance
      end

      include JkfObject

      def self.from_jkf(jkf)
        Black.from_jkf(jkf)
      rescue UnknownValueError
        White.from_jkf(jkf)
      end

      class Black
        include Singleton

        def black?
          true
        end

        def white?
          !black?
        end

        include JkfObject

        def to_jkf
          0
        end

        def self.from_jkf(jkf)
          case jkf
          in 0 then instance
          else raise UnknownValueError, jkf
          end
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

        include JkfObject

        def to_jkf
          1
        end

        def self.from_jkf(jkf)
          case jkf
          in 1 then instance
          else raise UnknownValueError, jkf
          end
        end
      end
    end
  end
end
