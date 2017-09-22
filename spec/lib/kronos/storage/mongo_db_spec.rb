# frozen_string_literal: true

RSpec.describe Kronos::Storage::MongoDb do
  let(:scheduled_task_model) { described_class::SHEDULED_TASK_MODEL }
  let(:report_model) { described_class::REPORT_MODEL }

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

    it do
      expect(report_model).to receive(:all)
      subject
    end
  end

  describe '#register_report' do
    let(:report) { Kronos::Report.success_from(task_id, {}) }
    let(:task_id) { :some_id }
    let(:where_response) { double(:where_response) }
    let(:create_params) do
      {
        task_id: report.task_id,
        metadata: report.metadata,
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
end
