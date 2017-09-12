# frozen_string_literal: true

RSpec.describe Kronos do
  describe '.config' do
    subject { described_class.config }

    it { expect { subject }.to_not raise_error }
    it { is_expected.to be_a(Kronos::ConfigAgent) }
  end

  describe '.start' do
    subject { described_class.start }

    let(:runner) { double('runner') }
    let(:runner_instance) { double('runner_instance') }
    let(:storage) { double('storage') }
    let(:storage_instance) { double('storage_instance') }

    before do
      allow(runner).to receive(:new).and_return(runner_instance)
      allow(storage).to receive(:new).and_return(storage_instance)
      allow(runner_instance).to receive(:start)
      described_class.config.runner(runner).storage(storage)
    end

    it { expect { subject }.to_not raise_error }

    it 'should start runner' do
      expect(runner_instance).to receive(:start)
      subject
    end
  end
end
