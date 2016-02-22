require 'spec_helper'

describe Jkf do
  it 'has a version number' do
    expect(Jkf::VERSION).not_to be nil
  end

  describe '.parse_file(filename, encoding)' do
    subject { Jkf.parse_file(filename) }

    context 'when .kif' do
      let(:filename) { fixtures(:kif).first }

      it { is_expected.to be_a Hash }
    end

    context 'when .ki2' do
      let(:filename) { fixtures(:ki2).first }

      it { is_expected.to be_a Hash }
    end

    context 'when .csa' do
      let(:filename) { fixtures(:csa).first }

      it { is_expected.to be_a Hash }
    end

    context 'when .jkf' do
      let(:filename) { fixtures(:jkf).first }

      it { is_expected.to be_a Hash }
    end
  end
end
