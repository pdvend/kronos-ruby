# frozen_string_literal: true

RSpec.describe Kronos::Report do
  describe '.success_from' do
    subject { described_class.success_from(task_id, metadata, timestamp) }

    let(:task_id) { :task }
    let(:metadata) { { foo: 'bar' } }
    let(:timestamp) { Time.now }

    it { expect { subject }.to_not raise_error }
    it { is_expected.to be_success }
    it { is_expected.to respond_to(:task_id) }
    it { is_expected.to respond_to(:timestamp) }
    it { is_expected.to respond_to(:metadata) }
    it { is_expected.to_not respond_to(:exception) }

    context 'when task id is invalid' do
      let(:task_id) { Object.new }
      it { expect { subject }.to raise_error(ArgumentError) }
    end

    context 'when metadata is invalid' do
      context 'in type' do
        let(:metadata) { Object.new }
        it { expect { subject }.to raise_error(ArgumentError) }
      end

      context 'in contents' do
        let(:metadata) { { foo: [] } }
        it { expect { subject }.to raise_error(ArgumentError) }
      end
    end

    context 'when timestamp is invalid' do
      let(:timestamp) { 'Jan 01' }
      it { expect { subject }.to raise_error(ArgumentError) }
    end
  end

  describe '.failure_from' do
    subject { described_class.failure_from(task_id, exception, timestamp) }

    let(:task_id) { :task }
    let(:exception) { RuntimeError.new }
    let(:timestamp) { Time.now }

    it { expect { subject }.to_not raise_error }
    it { is_expected.to be_failure }
    it { is_expected.to respond_to(:task_id) }
    it { is_expected.to respond_to(:timestamp) }
    it { is_expected.to respond_to(:exception) }
    it { is_expected.to_not respond_to(:metadata) }

    context 'when task id is invalid' do
      let(:task_id) { Object.new }
      it { expect { subject }.to raise_error(ArgumentError) }
    end

    context 'when exception is a Hash' do
      context 'in valid format' do
        let(:exception) do
          {
            type: 'RuntimeError',
            message: 'fake error',
            stacktrace: ['depth 2', 'depth 1', 'depth 0']
          }
        end
        it { expect { subject }.to_not raise_error }
      end

      context 'in invalid format' do
        let(:exception) { { foo: :bar } }
        it { expect { subject }.to raise_error(ArgumentError) }
      end
    end

    context 'when exception is invalid' do
      let(:exception) { Object.new }
      it { expect { subject }.to raise_error(ArgumentError) }
    end

    context 'when timestamp is invalid' do
      let(:timestamp) { 'Jan 01' }
      it { expect { subject }.to raise_error(ArgumentError) }
    end
  end
end
