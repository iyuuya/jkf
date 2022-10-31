require "singleton"
require "parslet"

module Jkf
  module Model
    RelativeString = Struct.new(:relative_position, :move_direction, :hit, keyword_init: true) do
      def hit?
        hit
      end

      def left?
        relative_position == RelativePosition.left
      end

      def center?
        relative_position == RelativePosition.center
      end

      def right?
        relative_position == RelativePosition.right
      end

      def up?
        move_direction == MoveDirection.up
      end

      def middle?
        move_direction == MoveDirection.middle
      end

      def down?
        move_direction == MoveDirection.down
      end

      include JkfObject

      def to_jkf
        (relative_position&.to_jkf || "") + (move_direction&.to_jkf || "") + (hit? ? HIT_LITERAL : "")
      end

      def self.from_jkf(jkf)
        tree = Parser.new.parse(jkf)
        new(relative_position: RelativePosition.from_jkf(tree[:relative_position]),
            move_direction: MoveDirection.from_jkf(tree[:move_direction]), hit: tree[:hit] && true)
      end

      class Parser < Parslet::Parser
        rule(:left) { str(RelativePosition::Left::LITERAL) }
        rule(:center) { str(RelativePosition::Center::LITERAL) }
        rule(:right) { str(RelativePosition::Right::LITERAL) }
        rule(:up) { str(MoveDirection::Up::LITERAL) }
        rule(:middle) { str(MoveDirection::Middle::LITERAL) }
        rule(:down) { str(MoveDirection::Down::LITERAL) }
        rule(:hit) { str(HIT_LITERAL) }
        rule(:relative_position) { (left | center | right).as(:relative_position) }
        rule(:move_direction) { (up | middle | down).as(:move_direction) }
        rule(:root) { relative_position.maybe >> move_direction.maybe >> hit.maybe.as(:hit) }
      end
    end

    HIT_LITERAL = "H".freeze

    module RelativePosition
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
        case jkf
        when "L" then left
        when "C" then center
        when "R" then right
        end
      end

      class Left
        LITERAL = "L".freeze

        include Singleton

        include JkfObject

        def to_jkf
          LITERAL
        end
      end

      class Center
        LITERAL = "C".freeze

        include Singleton

        include JkfObject

        def to_jkf
          LITERAL
        end
      end

      class Right
        LITERAL = "R".freeze

        include Singleton

        include JkfObject

        def to_jkf
          LITERAL
        end
      end
    end

    module MoveDirection
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
        case jkf
        when "U" then up
        when "M" then middle
        when "D" then down
        end
      end

      class Up
        LITERAL = "U".freeze

        include Singleton

        include JkfObject

        def to_jkf
          LITERAL
        end
      end

      class Middle
        LITERAL = "M".freeze

        include Singleton

        include JkfObject

        def to_jkf
          LITERAL
        end
      end

      class Down
        LITERAL = "D".freeze

        include Singleton

        include JkfObject

        def to_jkf
          LITERAL
        end
      end
    end
  end
end
