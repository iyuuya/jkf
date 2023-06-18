module Jkf
  module Parser
    # Base of Parser
    class Base
      # start parse
      #
      # @param [String] input
      #
      # @return [Hash] JKF
      def parse(input)
        @input = input.clone

        @current_pos = 0
        @reported_pos = 0
        @cached_pos = 0
        @cached_pos_details = { line: 1, column: 1, seenCR: false }
        @max_fail_pos = 0
        @max_fail_expected = []
        @silent_fails = 0

        @result = parse_root

        if success? && @current_pos == @input.size
          @result
        else
          fail(type: 'end', description: 'end of input') if failed? && @current_pos < input.size
          raise ParseError
        end
      end

      protected

      def success?
        @result != :failed
      end

      def failed?; !success?; end

      # match regexp
      def match_regexp(reg)
        ret = nil
        if (matched = reg.match(@input[@current_pos]))
          ret = matched.to_s
          @current_pos += ret.size
        else
          ret = :failed
          fail(type: 'class', value: reg.inspect, description: reg.inspect) if @silent_fails == 0
        end
        ret
      end

      # match string
      def match_str(str)
        ret = nil
        if @input[@current_pos, str.size] == str
          ret = str
          @current_pos += str.size
        else
          ret = :failed
          fail(type: 'literal', value: str, description: "\"#{str}\"") if @slient_fails == 0
        end
        ret
      end

      # match space
      def match_space
        match_str(' ')
      end

      # match space one or more
      def match_spaces
        stack = []
        matched = match_space
        while matched != :failed
          stack << matched
          matched = match_space
        end
        stack
      end

      # match digit
      def match_digit
        match_regexp(/^\d/)
      end

      # match digits
      def match_digits
        stack = []
        matched = match_digit
        while matched != :failed
          stack << matched
          matched = match_digit
        end
        stack
      end

      # match digit one ore more
      def match_digits!
        matched = match_digits
        if matched.empty?
          :failed
        else
          matched
        end
      end

      # record failure
      def fail(expected)
        return if @current_pos < @max_fail_pos

        if @current_pos > @max_fail_pos
          @max_fail_pos = @current_pos
          @max_fail_expected = []
        end

        @max_fail_expected << expected
      end
    end
  end
end
