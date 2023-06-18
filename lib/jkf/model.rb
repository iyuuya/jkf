require_relative '../jkf'

module Jkf
  module Model
    DecodeError = Class.new(::Jkf::Error)
    UnknownValueError = Class.new(DecodeError)
    NotImplementedError = Class.new(Error)

    # json-kifu-format object interface.
    # Including this module means the class (or module) is a json-kifu-format object.
    module JkfObject
      def to_jkf(jkf)
        raise NotImplementedError
      end

      def self.included(klass)
        klass.extend(ClassMethods)
      end

      module ClassMethods
        def from_jkf(jkf)
          raise NotImplementedError
        end
      end
    end
  end
end
