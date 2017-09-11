# frozen_string_literal: true

RSpec.describe Kronos do
  describe '.config' do
    subject { described_class.config }

    it { expect { subject }.to_not raise_error }
    it { is_expected.to be_a(Kronos::ConfigAgent) }
  end
end
