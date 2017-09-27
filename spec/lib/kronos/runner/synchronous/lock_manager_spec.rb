# frozen_string_literal: true

RSpec.describe Kronos::Runner::Synchronous::LockManager do
  let(:storage) { double('storage') }
  let(:task_id) { :task_1 }

  describe '.new' do
    subject { described_class.new(storage) }
    it { expect { subject }.to_not raise_error }
  end

  describe '#lock_and_execute' do
    let(:instance) { described_class.new(storage) }
    let(:lock_id) { SecureRandom.uuid }

    before do
      allow(storage).to receive(:locked_task?).and_return(false)
      allow(storage).to receive(:lock_task).and_return(SecureRandom.uuid)
      allow(storage).to receive(:check_lock).and_return(true)
      allow(storage).to receive(:release_lock)
    end

    it 'checks if the task is locked' do
      expect(storage).to receive(:locked_task?).with(task_id)
      instance.lock_and_execute(task_id) {}
    end

    it 'locks the task' do
      expect(storage).to receive(:lock_task).with(task_id)
      instance.lock_and_execute(task_id) {}
    end

    it 'checks the lock with same lock_id' do
      allow(storage).to receive(:lock_task).with(task_id).and_return(lock_id)
      expect(storage).to receive(:check_lock).with(task_id, lock_id)
      instance.lock_and_execute(task_id) {}
    end

    it 'executes block' do
      expect { |b| instance.lock_and_execute(task_id, &b) }.to yield_control
    end

    it 'releases the lock' do
      expect(storage).to receive(:release_lock).with(task_id)
      instance.lock_and_execute(task_id) {}
    end

    context 'when task is locked' do
      before { allow(storage).to receive(:locked_task?).and_return(true) }

      it 'will not execute block' do
        expect { |b| instance.lock_and_execute(task_id, &b) }.to_not yield_control
      end
    end

    context 'when task lock is not kept' do
      before do
        allow(storage).to receive(:locked_task?).and_return(false)
        allow(storage).to receive(:lock_task).and_return(SecureRandom.uuid)
        allow(storage).to receive(:check_lock).and_return(false)
      end

      it 'will not execute block' do
        expect { |b| instance.lock_and_execute(task_id, &b) }.to_not yield_control
      end
    end

    context 'when task raises error' do
      before do
        allow(storage).to receive(:locked_task?).and_return(false)
        allow(storage).to receive(:lock_task).and_return(SecureRandom.uuid)
        allow(storage).to receive(:check_lock).and_return(true)
      end

      it 'releases the lock anyway but raises the error' do
        expect(storage).to receive(:release_lock)
        expect { instance.lock_and_execute(task_id) { raise } }.to raise_error
      end
    end
  end
end
