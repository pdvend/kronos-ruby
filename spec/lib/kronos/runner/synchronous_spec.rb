# frozen_string_literal: true

RSpec.describe Kronos::Runner::Synchronous do
  let(:tasks) { [] }
  let(:storage) { double('storage') }
  let(:logger) { double('logger') }
  let(:dependencies) { Kronos::Dependencies.new(storage: storage, logger: logger) }

  describe '.new' do
    subject { described_class.new(tasks, storage) }
    it { expect { subject }.to_not raise_error }
  end

  describe '#start' do
    subject { described_class.new(tasks, dependencies).start }

    before do
      allow_any_instance_of(described_class).to receive(:loop).and_yield
      allow_any_instance_of(described_class).to receive(:sleep)
      allow(logger).to receive(:info)
      allow(logger).to receive(:error)
      allow(logger).to receive(:success)
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

        before do
          allow(storage).to receive(:schedule)
        end

        it 'reschedules the task' do
          expect(storage).to receive(:schedule).with(kind_of(Kronos::ScheduledTask))
          subject
        end

        it 'alerts logger with info' do
          expect(logger).to receive(:info)
          subject
        end
      end

      context 'when task time is in the past' do
        let(:timestamp) { '10 seconds ago' }

        before do
          allow(storage).to receive(:remove)
        end

        it 'does not reschedules the task' do
          expect(storage).to_not receive(:schedule)
          subject
        end

        it 'removes task from schedule' do
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
        allow(storage).to receive(:remove)
        allow(storage).to receive(:remove_reports_for)
      end

      it 'removes task from schedule' do
        expect(storage).to receive(:remove).with(:not_registered_id)
        subject
      end

      it 'removes task reports' do
        expect(storage).to receive(:remove_reports_for).with(:not_registered_id)
        subject
      end

      it 'alerts logger' do
        expect(logger).to receive(:info)
        subject
      end
    end

    context 'when there are registered resolved tasks' do
      before do
        allow(storage).to receive(:pending?).and_return(false)
        allow(storage).to receive(:resolved_tasks).and_return(tasks.map(&:id))
        allow(storage).to receive(:register_report)
        allow(storage).to receive(:remove)
      end

      it 'executes the task block' do
        expect(block).to receive(:call)
        subject
      end

      it 'removes task from schedule' do
        expect(storage).to receive(:remove).with(:task1)
        subject
      end

      context 'when task execution succeeds' do
        it 'registers success' do
          expect(storage).to receive(:register_report).with(kind_of(Kronos::Report))
          subject
        end

        it 'alerts logger with success' do
          expect(logger).to receive(:success)
          subject
        end
      end

      context 'when task execution fails' do
        before do
          allow(block).to receive(:call).and_raise(error)
        end

        let(:error) { RuntimeError.new('fake error') }

        it 'registers failure' do
          expect(storage).to receive(:register_report).with(kind_of(Kronos::Report))
          subject
        end

        it 'alerts logger with error' do
          expect(logger).to receive(:error)
          subject
        end
      end
    end
  end
end
