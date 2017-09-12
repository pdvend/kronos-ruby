# frozen_string_literal: true

RSpec.describe Kronos::Runner::Synchronous do
  let(:tasks) { [] }
  let(:storage) { double('storage') }
  let(:dependencies) { Kronos::Dependencies.new(storage: storage) }

  describe '.new' do
    subject { described_class.new(tasks, storage) }
    it { expect { subject }.to_not raise_error }
  end

  describe '#start' do
    subject { described_class.new(tasks, dependencies).start }

    before do
      allow_any_instance_of(described_class).to receive(:loop).and_yield
      allow_any_instance_of(described_class).to receive(:sleep)
      allow_any_instance_of(described_class).to receive(:puts)
    end

    let(:tasks) { [Kronos::Task.new(:task1, timestamp, block)] }
    let(:timestamp) { 'now' }
    let(:block) { ->() {} }

    context 'when registered tasks are not pending' do
      before do
        allow(storage).to receive(:pending?).and_return(false)
        allow(storage).to receive(:resolved_tasks).and_return([])
      end

      context 'when task time is in the future' do
        let(:timestamp) { '10 seconds from now' }

        it 'reschedules the task' do
          expect(storage).to receive(:schedule).with(tasks.first, kind_of(Time))
          subject
        end
      end

      context 'when task time is in the past' do
        let(:timestamp) { '10 seconds ago' }

        it 'does not reschedules the task' do
          expect(storage).to_not receive(:schedule)
          subject
        end
      end
    end

    context 'when registered tasks are pending' do
      before do
        allow(storage).to receive(:pending?).and_return(true)
        allow(storage).to receive(:resolved_tasks).and_return([])
      end

      it 'does not reschedules the task' do
        expect(storage).to_not receive(:schedule)
        subject
      end
    end

    context 'when there are unregistered resolved tasks' do
      before do
        allow(storage).to receive(:pending?).and_return(true)
        allow(storage).to receive(:resolved_tasks).and_return([:not_registered_id])
      end

      it 'removes task from schedule' do
        expect(storage).to receive(:remove).with(:not_registered_id)
        subject
      end
    end

    context 'when there are registered resolved tasks' do
      before do
        allow(storage).to receive(:pending?).and_return(false)
        allow(storage).to receive(:resolved_tasks).and_return(tasks.map(&:id))
        allow(storage).to receive(:register_task_success)
      end

      it 'executes the task block' do
        expect(block).to receive(:call)
        subject
      end

      context 'when task execution succeeds' do
        it 'registers success' do
          expect(storage).to receive(:register_task_success).with(tasks.first, kind_of(Hash))
          subject
        end
      end

      context 'when task execution fails' do
        before do
          allow(block).to receive(:call).and_raise(error)
        end

        let(:error) { RuntimeError.new('fake error') }

        it 'registers failure' do
          expect(storage).to receive(:register_task_failure).with(tasks.first, error)
          subject
        end
      end
    end
  end
end
