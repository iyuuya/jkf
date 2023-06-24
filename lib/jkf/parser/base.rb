require 'strscan'

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
        @scanner = StringScanner.new(input.dup)
        @reported_pos = 0
        @max_fail_pos = 0

        @result = parse_root

        if success? && @scanner.eos?
          @result
        else
          record_failure(type: 'end', description: 'end of input') if failed? && @scanner.pos < input.size
          raise ParseError
        end
      end

      protected

      def success?
        @result != :failed
      end

      def failed?; !success?; end

      def match_regexp(reg)
        matched = @scanner.scan(reg)
        unless matched
          record_failure(type: 'class', value: reg.inspect, description: reg.inspect)
          return :failed
        end
        matched
      end

      def match_str(str)
        matched = @scanner.scan(str)
        unless matched
          record_failure(type: 'literal', value: str, description: str.inspect)
          return :failed
        end
        matched
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
        match_regexp(/\d/)
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

      def record_failure(expected)
        return if @scanner.pos < @max_fail_pos

        return unless @scanner.pos > @max_fail_pos

        @max_fail_pos = @scanner.pos
      end
    end
  end
end
