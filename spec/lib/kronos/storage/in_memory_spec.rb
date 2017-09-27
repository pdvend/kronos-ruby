# frozen_string_literal: true

RSpec.describe Kronos::Storage::InMemory do
  describe '.new' do
    subject { described_class.new }
    it { expect { subject }.to_not raise_error }
  end

  describe '#schedule' do
    subject { instance.schedule(scheduled_task) }
    let(:scheduled_task) { Kronos::ScheduledTask.new(task.id, next_run) }
    let(:instance) { described_class.new }
    let(:task) { Kronos::Task.new(:task, '1 day from now', ->() {}) }
    let(:next_run) { Time.now + 86_400 }

    context 'when task is not scheduled' do
      it { expect { subject }.to_not raise_error }

      it 'will not remove task resolval' do
        expect { subject }.to_not(change { instance.resolved_tasks.to_a })
      end

      it 'change task state to pending' do
        expect { subject }.to change { instance.pending?(task) }.from(false).to(true)
      end
    end

    context 'when task is scheduled' do
      before do
        instance.schedule(Kronos::ScheduledTask.new(task.id, Time.now - 1))
      end

      it { expect { subject }.to_not raise_error }

      it 'remove task resolval' do
        expect { subject }.to change { instance.resolved_tasks.to_a }.from([:task]).to([])
      end

      it 'change task state to pending' do
        expect { subject }.to change { instance.pending?(task) }.from(false).to(true)
      end
    end
  end

  describe '#register_report' do
    subject { instance.register_report(report) }
    let(:instance) { described_class.new }
    let(:task) { Kronos::Task.new(:task, '1 day from now', ->() {}) }
    let(:report) { Kronos::Report.success_from(task.id, foo: 'bar') }

    context 'when task has no registered report' do
      it { expect { subject }.to_not raise_error }
      it 'add report to the list' do
        expect { subject }.to change { instance.reports }.from([]).to([report])
      end
    end

    context 'when task already has a registered report' do
      let(:old_report) { Kronos::Report.success_from(task.id, foo: 'bar') }

      before do
        instance.register_report(old_report)
      end

      it { expect { subject }.to_not raise_error }
      it 'replaces old report' do
        expect { subject }.to change { instance.reports }.from([old_report]).to([report])
      end
    end
  end

  describe '#pending?' do
    subject { instance.pending?(task) }
    let(:instance) { described_class.new }
    let(:task) { Kronos::Task.new(:task, '1 day from now', ->() {}) }

    context 'when task is not registered' do
      it { is_expected.to be_falsey }
    end

    context 'when task is registered' do
      before { instance.schedule(Kronos::ScheduledTask.new(task.id, next_run)) }

      context 'when task is resolved' do
        let(:next_run) { Time.now - 86_400 }
        it { is_expected.to be_falsey }
      end

      context 'when task is pending' do
        let(:next_run) { Time.now + 86_400 }
        it { is_expected.to be_truthy }
      end
    end
  end

  describe '#resolved_tasks' do
    subject { instance.resolved_tasks }

    let(:instance) { described_class.new }
    let(:task1) { Kronos::Task.new(:task1, '1 day from now', ->() {}) }
    let(:task2) { Kronos::Task.new(:task2, '1 day from now', ->() {}) }

    context 'when there is no task registered' do
      it { is_expected.to be_a(Enumerable) }
      it { expect(subject.to_a).to be_empty }
    end

    context 'when there are registered tasks' do
      before do
        instance.schedule(Kronos::ScheduledTask.new(task1.id, Time.now - 86_400))
        instance.schedule(Kronos::ScheduledTask.new(task2.id, Time.now + 86_400))
      end

      it 'returns only resolved task ids' do
        expect(subject.to_a).to eq([:task1])
      end
    end
  end

  describe '#remove' do
    subject { instance.remove(task_id) }
    let(:instance) { described_class.new }
    let(:task_id) { :task }
    let(:task) { Kronos::Task.new(task_id, '1 day from now', ->() {}) }

    it { expect { subject }.to_not raise_error }

    context 'when task is registered' do
      before { instance.schedule(Kronos::ScheduledTask.new(task.id, Time.now)) }

      it 'removes from both resolved and pending tasks' do
        subject
        expect(instance.resolved_tasks).to_not include(task_id)
        expect(instance.pending?(task)).to be_falsey
      end

      it 'removes task from reports' do
        subject
        expect(instance.reports.map(&:task).map(&:id)).to_not include(task_id)
      end
    end
  end

  describe '#locked_task?' do
    subject { instance.locked_task?(task_id) }
    let(:instance) { described_class.new }
    let(:task_id) { :task }

    context 'when the task was locked before' do
      before { instance.lock_task(task_id) }
      it { is_expected.to be_truthy }
    end

    context 'when the task was not locked before' do
      it { is_expected.to be_falsey }
    end
  end

  describe '#lock_task' do
    subject { instance.lock_task(task_id) }
    let(:instance) { described_class.new }
    let(:task_id) { :task }

    it { is_expected.to be_a(String) }
    it { is_expected.to_not be_empty }
  end

  describe '#check_lock' do
    subject { instance.check_lock(task_id, lock_id) }
    let(:instance) { described_class.new }
    let(:task_id) { :task }

    context 'when the lock is not registered' do
      let(:lock_id) { SecureRandom.uuid }
      it { is_expected.to be_falsey }
    end

    context 'when the lock has the specified lock value' do
      let(:lock_id) { instance.lock_task(task_id) }
      it { is_expected.to be_truthy }
    end

    context 'when the lock has not the specified lock value' do
      before { instance.lock_task(task_id) }
      let(:lock_id) { SecureRandom.uuid }
      it { is_expected.to be_falsey }
    end
  end

  describe '#release_lock' do
    subject { instance.release_lock(task_id) }
    let(:instance) { described_class.new }
    let(:task_id) { :task }

    context 'when the lock is registered' do
      before { instance.lock_task(task_id) }

      it 'unregisters the lock' do
        expect { subject }.to change { instance.locked_task?(task_id) }.from(true).to(false)
      end
    end

    context 'when the lock is not registered' do
      it 'does nothing' do
        expect { subject }.to_not(change { instance.locked_task?(task_id) })
      end
    end
  end
end
