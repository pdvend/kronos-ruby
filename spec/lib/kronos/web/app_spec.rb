# frozen_string_literal: true

RSpec.describe Kronos::Web::App do
  describe '.call' do
    subject { described_class.call(nil) }

    let(:runner) { double('runner') }
    let(:runner_instance) { double('runner_instance') }
    let(:storage) { double('storage') }
    let(:storage_instance) { double('storage_instance') }
    let(:logger) { double('logger') }
    let(:logger_instance) { double('logger_instance') }

    before do
      allow(runner).to receive(:new).and_return(runner_instance)
      allow(storage).to receive(:new).and_return(storage_instance)
      allow(logger).to receive(:new).and_return(logger_instance)
      allow(runner_instance).to receive(:start)
      allow(storage_instance).to receive(:scheduled_tasks).and_return([])
      allow(storage_instance).to receive(:reports).and_return([])
      Kronos.config.runner(runner).storage(storage).logger(logger)
    end

    it { expect { subject }.to_not raise_error }
    it { is_expected.to be_a(Array) }
    it 'returns success status code' do
      expect(subject[0]).to eq(200)
    end
    it 'returns no headers' do
      expect(subject[1]).to be_a(Hash)
    end
    it 'returns rack-style body' do
      expect(subject[2]).to be_a(Array)
    end
    it 'returns body as string' do
      expect(subject[2]).to all be_a(String)
    end
  end
end
