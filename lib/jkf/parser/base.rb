module Jkf::Parser
  class Base
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
        return @result
      else
        fail(type: "end", description: "end of input") if failed? && @current_pos < input.size
        raise ParseError
      end
    end

    protected

    def success?
      @result != :failed
    end

    def failed?; !success?; end

    def match_regexp(reg)
      ret = nil
      if matched = reg.match(@input[@current_pos])
        ret = matched.to_s
        @current_pos += ret.size
      else
        ret = :failed
        fail(type: "class", value: reg.inspect, description: reg.inspect) if @silent_fails == 0
      end
      ret
    end

    def match_str(str)
      ret = nil
      if @input[@current_pos, str.size] == str
        ret = str
        @current_pos += str.size
      else
        ret = :failed
        fail(type: "literal", value: str, description: "\"#{str}\"") if @slient_fails == 0
      end
      ret
    end

    def match_space
      match_str(" ")
    end

    def match_spaces
      stack = []
      matched = match_space
      while matched != :failed
        stack << matched
        matched = match_space
      end
      stack
    end

    def match_digit
      match_regexp(/^\d/)
    end

    def match_digits
      stack = []
      matched = match_digit
      while matched != :failed
        stack << matched
        matched = match_digit
      end
      stack
    end

    def match_digits!
      matched = match_digits
      if matched.empty?
        :failed
      else
        matched
      end
    end

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
