require "singleton"

module Jkf
  module Model
    RelativeString = Struct.new(:relative_position, :move_direction, :hit, keyword_init: true) do
      def hit?
        hit
      end
      include JkfObject
      def to_jkf
        (relative_position&.to_jkf || "") + (move_direction&.to_jkf || "") + (hit? ? "H" : "")
      end
      # def self.from_jkf(jkf); end
    end
    
    module RelativeString::RelativePosition
      def self.left
        @left ||= Left.instance
      end

      def self.center
        @center ||= Center.instance
      end

      def self.right
        @right ||= Right.instance
      end

      include JkfObject
      def self.from_jkf(jkf)
        Left.from_jkf(jkf)
      rescue UnknownValueError
        Center.from_jkf(jkf)
      rescue UnknownValueError
        Right.from_jkf(jkf)
      end

      class Left
        include Singleton
        include JkfObject
        def to_jkf
          "L"
        end
        def self.from_jkf(jkf)
          case jkf
          in "L" then instance
          else raise UnknownValueError.new(jkf)
          end
        end
      end

      class Center
        include Singleton
        include JkfObject
        def to_jkf
          "C"
        end
        def self.from_jkf(jkf)
          case jkf
          in "C" then instance
          else raise UnknownValueError.new(jkf)
          end
        end
      end

      class Right
        include Singleton
        include JkfObject
        def to_jkf
          "R"
        end
        def self.from_jkf(jkf)
          case jkf
          in "R" then instance
          else raise UnknownValueError.new(jkf)
          end
        end
      end
    end

    module RelativeString::MoveDirection
      def self.up
        @up ||= Up.instance
      end

      def self.middle
        @middle ||= Middle.instance
      end

      def self.down
        @down ||= Down.instance
      end

      include JkfObject
      def self.from_jkf(jkf)
        Up.from_jkf(jkf)
      rescue UnknownValueError
        Middle.from_jkf(jkf)
      rescue UnknownValueError
        Down.from_jkf(jkf)
      end

      class Up
        include Singleton
        include JkfObject
        def to_jkf
          "U"
        end
        def self.from_jkf(jkf)
          case jkf
          in "U" then instance
          else raise UnknownValueError.new(jkf)
          end
        end
      end

      class Middle
        include Singleton
        include JkfObject
        def to_jkf
          "M"
        end
        def self.from_jkf(jkf)
          case jkf
          in "M" then instance
          else raise UnknownValueError.new(jkf)
          end
        end
      end

      class Down
        include Singleton
        include JkfObject
        def to_jkf
          "D"
        end
        def self.from_jkf(jkf)
          case jkf
          in "D" then instance
          else raise UnknownValueError.new(jkf)
          end
        end
      end
    end
  end
end
