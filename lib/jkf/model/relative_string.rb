require "singleton"
require "parslet"

module Jkf
  module Model
    RelativeString = Struct.new(:relative_position, :move_direction, :hit, keyword_init: true) do
      def hit?
        hit
      end

      include JkfObject

      def to_jkf
        (relative_position&.to_jkf || "") + (move_direction&.to_jkf || "") + (hit? ? self::HIT_LITERAL : "")
      end

      def self.from_jkf(jkf)
        RelativePosition::Parser.new.maybe
      end
    end

    RelativeString::HIT_LITERAL = "H"
    
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
        Parser.new(jkf)
      end

      class Parser < Parslet::Parser
        rule(:relative_position) { Left::Parser.new | Center::Parser.new | Right::Parser.new }
        root(:relative_position)
      end

      class Left
        LITERAL = "L"

        include Singleton

        include JkfObject

        def to_jkf
          LITERAL
        end

        def self.from_jkf(jkf)
          Parser.new.parse(jkf)
          instance
        end

        class Parser < Parslet::Parser
          rule(:left) { str(LITERAL) }
          root(:left)
        end
      end

      class Center
        LITERAL = "C"

        include Singleton

        include JkfObject

        def to_jkf
          LITERAL
        end
        
        def self.from_jkf(jkf)
          Parser.new.parse(jkf)
          instance
        end

        class Parser < Parslet::Parser
          rule(:center) { str(LITERAL) }
          root(:center)
        end
      end

      class Right
        LITERAL = "R"
        
        include Singleton
        
        include JkfObject
        
        def to_jkf
          LITERAL
        end
        
        def self.from_jkf(jkf)
          Parser.new.parse(jkf)
          instance
        end

        class Parser < Parslet::Parser
          rule(:right) { str(LITERAL) }
          root(:right)
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
