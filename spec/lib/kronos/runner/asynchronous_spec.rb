# frozen_string_literal: true

RSpec.describe Kronos::Runner::Asynchronous do
  let(:tasks) { [] }
  let(:dependencies) { double('dependencies') }

  before { allow(dependencies).to receive(:storage) }

  describe '.new' do
    subject { described_class.new(tasks, dependencies) }
    it { expect { subject }.to_not raise_error }
  end

  describe '#start' do
    subject { described_class.new(tasks, dependencies).start }
    let(:async_executor) { double('async_executor') }

    before do
      allow_any_instance_of(described_class).to receive(:async).and_return(async_executor)
    end

    it 'calls original_start on async executor' do
      expect(async_executor).to receive(:original_start)
      subject
    end
  end
end
