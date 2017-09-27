# frozen_string_literal: true

RSpec.describe Kronos::Storage::MongoDb do
  let(:scheduled_task_model) { described_class::SHEDULED_TASK_MODEL }
  let(:report_model) { described_class::REPORT_MODEL }
  let(:lock_model) { described_class::LOCK_MODEL }

  describe '#scheduled_tasks' do
    subject { described_class.new.scheduled_tasks }

    it do
      expect(scheduled_task_model).to receive(:all)
      subject
    end
  end

  describe '#pending?' do
    let(:task) { Kronos::Task.new(id, 'monday', block) }
    let(:id) { :task_id }
    let(:block) { ->(*) {} }
    let(:scheduled_task) { Kronos::ScheduledTask.new(id, next_run) }
    let(:where_response) { [scheduled_task] }
    let(:next_run) { Time.now + 1.second }
    let(:exists) { true }

    subject { described_class.new.pending?(task) }

    before do
      allow(where_response).to receive(:exists?).and_return(exists)
      allow(scheduled_task_model).to receive(:where).with(task_id: id).and_return(where_response)
    end

    context 'when next run is after now' do
      it { is_expected.to be_truthy }
    end

    context 'when next run is now' do
      let(:next_run) { Time.now }
      it { is_expected.to be_falsey }
    end

    context 'when next run is before now' do
      let(:next_run) { Time.now - 1.second }
      it { is_expected.to be_falsey }
    end

    context 'when not exists' do
      let(:exists) { false }
      it { is_expected.to be_falsey }
    end
  end

  describe '#resolved_tasks' do
    let(:scheduled_task) { double('scheduled_task_model', task_id: id) }
    let(:id) { :task_id }
    subject { described_class.new.resolved_tasks }

    before do
      allow(scheduled_task).to receive(:[]).with(:task_id).and_return(id)
      allow(scheduled_task_model).to receive(:where).and_return(where_response)
    end

    context 'when any result' do
      let(:where_response) { [scheduled_task] }
      it { is_expected.to be_a(Array) }
      it { expect(subject).to eq([id]) }
    end

    context 'when empty result' do
      let(:where_response) { [] }
      it { is_expected.to be_a(Array) }
      it { is_expected.to be_empty }
    end
  end

  describe '#remove' do
    let(:task_id) { :some_id }
    let(:where_response) { double(:where_response) }

    subject { described_class.new.remove(task_id) }

    it do
      expect(scheduled_task_model).to receive(:where).with(task_id: task_id).and_return(where_response)
      expect(where_response).to receive(:destroy_all)
      subject
    end
  end

  describe '#schedule' do
    let(:scheduled_task) { Kronos::ScheduledTask.new(task_id, next_run) }
    let(:task_id) { :some_id }
    let(:next_run) { Time.now }
    let(:where_response) { double(:where_response) }

    subject { described_class.new.schedule(scheduled_task) }

    it do
      expect(scheduled_task_model).to receive(:where).with(task_id: task_id).and_return(where_response)
      expect(where_response).to receive(:destroy_all)
      expect(scheduled_task_model).to receive(:create).with(task_id: task_id, next_run: next_run)
      subject
    end
  end

  describe '#reports' do
    subject { described_class.new.reports }

    let(:success_report) do
      double(:report,
             task_id: task_id,
             metadata: metadata,
             status: Kronos::Report::STATUSES[:success],
             timestamp: timestamp)
    end
    let(:failure_report) do
      double(:report,
             task_id: task_id,
             exception: exception,
             status: Kronos::Report::STATUSES[:failure],
             timestamp: timestamp)
    end
    let(:task_id) { :task_id }
    let(:metadata) { {} }
    let(:exception) { { type: 'ArgumentError', message: 'fake message', stacktrace: [] } }
    let(:timestamp) { Time.now }

    before do
      allow(report_model).to receive(:all).and_return([success_report, failure_report])
    end

    it 'get all ReportModel' do
      expect(report_model).to receive(:all)
      subject
    end

    it 'return correct Reports from success' do
      expect(subject.first).to be_a(Kronos::Report)
      expect(subject.first.task_id).to eq(task_id)
      expect(subject.first.metadata).to eq(metadata)
      expect(subject.first.timestamp).to eq(timestamp)
      expect(subject.first).to be_success
    end

    it 'return correct Reports from failure' do
      expect(subject.last).to be_a(Kronos::Report)
      expect(subject.last.task_id).to eq(task_id)
      expect(subject.last.exception).to eq(exception)
      expect(subject.last.timestamp).to eq(timestamp)
      expect(subject.last).to be_failure
    end
  end

  describe '#register_report' do
    let(:report) { Kronos::Report.success_from(task_id, {}) }
    let(:task_id) { :some_id }
    let(:where_response) { double(:where_response) }
    let(:create_params) do
      {
        task_id: report.task_id,
        status: report.status,
        metadata: report.metadata,
        exception: nil,
        timestamp: report.timestamp
      }
    end

    subject { described_class.new.register_report(report) }

    it do
      expect(report_model).to receive(:where).with(task_id: task_id).and_return(where_response)
      expect(where_response).to receive(:destroy_all)
      expect(report_model).to receive(:create).with(create_params)
      subject
    end
  end

  describe '#remove_reports_for' do
    let(:task_id) { :some_id }
    let(:where_response) { double(:where_response) }
    subject { described_class.new.remove_reports_for(task_id) }

    it do
      expect(report_model).to receive(:where).with(task_id: task_id).and_return(where_response)
      expect(where_response).to receive(:destroy_all)
      subject
    end
  end

  describe '#locked_task?' do
    subject { instance.locked_task?(task_id) }
    let(:instance) { described_class.new }
    let(:task_id) { :task }
    let(:where_response) { double(:where_response) }

    before do
      allow(lock_model).to receive(:where).with(task_id: task_id).and_return(where_response)
      allow(where_response).to receive(:exists?).and_return(exists_response)
      allow(lock_model).to receive(:create)
    end

    context 'when the task was locked before' do
      let(:exists_response) { true }
      before { instance.lock_task(task_id) }
      it { is_expected.to be_truthy }
    end

    context 'when the task was not locked before' do
      let(:exists_response) { false }
      it { is_expected.to be_falsey }
    end
  end

  describe '#lock_task' do
    subject { instance.lock_task(task_id) }
    let(:instance) { described_class.new }
    let(:task_id) { :task }

    before { allow(lock_model).to receive(:create) }

    it { is_expected.to be_a(String) }
    it { is_expected.to_not be_empty }
  end

  describe '#check_lock' do
    subject { instance.check_lock(task_id, lock_id) }
    let(:instance) { described_class.new }
    let(:task_id) { :task }
    let(:where_response) { double(:where_response) }

    before do
      allow(lock_model).to receive(:create)
      allow(lock_model).to receive(:where).with(task_id: task_id, value: lock_id).and_return(where_response)
      allow(where_response).to receive(:exists?).and_return(exists_response)
    end

    context 'when the lock is not registered' do
      let(:exists_response) { false }
      let(:lock_id) { SecureRandom.uuid }
      it { is_expected.to be_falsey }
    end

    context 'when the lock has the specified lock value' do
      let(:exists_response) { true }
      let(:lock_id) { instance.lock_task(task_id) }
      it { is_expected.to be_truthy }
    end

    context 'when the lock has not the specified lock value' do
      before { instance.lock_task(task_id) }
      let(:exists_response) { false }
      let(:lock_id) { SecureRandom.uuid }
      it { is_expected.to be_falsey }
    end
  end

  describe '#release_lock' do
    subject { instance.release_lock(task_id) }
    let(:instance) { described_class.new }
    let(:task_id) { :task }
    let(:where_response) { double(:where_response) }

    before do
      allow(lock_model).to receive(:where).with(task_id: task_id).and_return(where_response)
      allow(lock_model).to receive(:create)
    end

    context 'when the lock is registered' do
      before { instance.lock_task(task_id) }

      it 'unregisters the lock' do
        expect(where_response).to receive(:destroy_all)
        subject
      end
    end

    context 'when the lock is not registered' do
      it 'tries to delete all matching locks' do
        expect(where_response).to receive(:destroy_all)
        subject
      end
    end
  end
end
