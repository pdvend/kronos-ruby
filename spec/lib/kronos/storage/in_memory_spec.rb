# frozen_string_literal: true

RSpec.describe Kronos::Storage::InMemory do
  describe '.new' do
    subject { described_class.new }
    it { expect { subject }.to_not raise_error }
  end

  describe '#schedule' do
    subject { instance.schedule(task, next_run) }
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
        instance.schedule(task, Time.now - 1)
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
    let(:report) { Kronos::Report.success_from(task, foo: 'bar') }

    context 'when task has no registered report' do
      it { expect { subject }.to_not raise_error }
      it 'add report to the list' do
        expect { subject }.to change { instance.reports }.from([]).to([report])
      end
    end

    context 'when task already has a registered report' do
      let(:old_report) { Kronos::Report.success_from(task, foo: 'bar') }

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
      before { instance.schedule(task, next_run) }

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
      it { is_expected.to be_a(Enumerator) }
      it { expect(subject.to_a).to be_empty }
    end

    context 'when there are registered tasks' do
      before do
        instance.schedule(task1, Time.now - 86_400)
        instance.schedule(task2, Time.now + 86_400)
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
      before { instance.schedule(task, Time.now) }

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
end
