require_relative '../jkf'

module Jkf
  module Model
    DecodeError = Class.new(::Jkf::Error)
    UnknownValueError = Class.new(DecodeError)
  end
end
