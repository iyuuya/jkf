require "singleton"

module Jkf
  module Model
    module InitialPresetString
      def self.even
        @even ||= Even.instance
      end

      def self.lance
        @lance ||= Lance.instance
      end

      def self.right_lance
        @right_lance ||= RightLance.instance
      end

      def self.bishop
        @bishop ||= Bishop.instance
      end

      def self.rook
        @rook ||= Rook.instance
      end

      def self.rook_and_lance
        @rook_and_lance ||= RookAndLance.instance
      end

      def self.two
        @two ||= Two.instance
      end

      def self.three
        @three ||= Three.instance
      end

      def self.four
        @four ||= Four.instance
      end

      def self.five
        @five ||= Five.instance
      end

      def self.left_five
        @left_five ||= LeftFive.instance
      end

      def self.six
        @six ||= Six.instance
      end

      def self.left_seven
        @left_seven ||= LeftSeven.instance
      end

      def self.right_seven
        @right_seven ||= RightSeven.instance
      end

      def self.eight
        @eight ||= Eight.instance
      end

      def self.ten
        @ten ||= Ten.instance
      end

      def self.other
        @other ||= Other.instance
      end

      include JkfObject

      def self.from_jkf(jkf)
        case jkf
        when "HIRATE" then even
        when "KY" then lance
        when "KY_R" then right_lance
        when "KA" then bishop
        when "HI" then rook
        when "HIKY" then rook_and_lance
        when "2" then two
        when "3" then three
        when "4" then four
        when "5" then five
        when "5_L" then left_five
        when "6" then six
        when "7_L" then left_seven
        when "7_R" then right_seven
        when "8" then eight
        when "10" then ten
        when "OTHER" then other
        end
      end

      class Even
        include Singleton

        include JkfObject

        def to_jkf
          "HIRATE"
        end
      end

      class Lance
        include Singleton

        include JkfObject

        def to_jkf
          "KY"
        end
      end

      class RightLance
        include Singleton

        include JkfObject

        def to_jkf
          "KY_R"
        end
      end

      class Bishop
        include Singleton

        include JkfObject

        def to_jkf
          "KA"
        end
      end

      class Rook
        include Singleton

        include JkfObject

        def to_jkf
          "HI"
        end
      end

      class RookAndLance
        include Singleton

        include JkfObject

        def to_jkf
          "HIKY"
        end
      end

      class Two
        include Singleton

        include JkfObject

        def to_jkf
          "2"
        end
      end

      class Three
        include Singleton

        include JkfObject

        def to_jkf
          "3"
        end
      end

      class Four
        include Singleton

        include JkfObject

        def to_jkf
          "4"
        end
      end

      class Five
        include Singleton

        include JkfObject

        def to_jkf
          "5"
        end
      end

      class LeftFive
        include Singleton

        include JkfObject

        def to_jkf
          "5_L"
        end
      end

      class Six
        include Singleton

        include JkfObject

        def to_jkf
          "6"
        end
      end

      class LeftSeven
        include Singleton

        include JkfObject

        def to_jkf
          "7_L"
        end
      end

      class RightSeven
        include Singleton

        include JkfObject

        def to_jkf
          "7_R"
        end
      end

      class Eight
        include Singleton

        include JkfObject

        def to_jkf
          "8"
        end
      end

      class Ten
        include Singleton

        include JkfObject

        def to_jkf
          "10"
        end
      end

      class Other
        include Singleton

        include JkfObject

        def to_jkf
          "OTHER"
        end
      end
    end
  end
end
