require 'spec_helper'
require 'kconv'

describe Jkf::Parser::Kif do
  let(:kif_parser) { Jkf::Parser::Kif.new }
  subject { kif_parser.parse(str) }

  fixtures(:kif).each do |fixture|
    let(:str) { File.read(fixture).toutf8 }
    it "should be parse #{File.basename(fixture)}" do
      is_expected.not_to be_nil
    end
  end
end
