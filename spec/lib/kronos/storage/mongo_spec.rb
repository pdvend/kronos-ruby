# frozen_string_literal: true

RSpec.describe Kronos::Storage::Mongo do
  let(:scheduled_task_model) { described_class::SHEDULED_TASK_MODEL }
  let(:report_model) { described_class::REPORT_MODEL }

  describe '#scheduled_tasks' do
    subject { described_class.scheduled_tasks }

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
    subject { described_class.pending?(task) }

    before do
      allow(scheduled_task_model).to receive(:where).with(task_id: id).and_return(where_response)
    end

    context 'when next run is after now' do
      let(:next_run) { Time.now + 1.second }
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
  end

  describe '#resolved_tasks' do
    let(:scheduled_task) { double('scheduled_task_model', id: id, next_run: next_run) }
    let(:id) { :task_id }
    let(:next_run) { Time.now - 1.second }
    let(:where_response) { [scheduled_task] }
    subject { described_class.resolved_tasks }

    before do
      allow(scheduled_task_model).to receive(:where).and_return(where_response)
    end

    context 'when any result' do
      it { is_expected.to be_a(Array) }
      it { expect(subject.first).to be_a(Kronos::ScheduledTask) }
      it { expect(subject.first.task_id).to eq(id) }
      it { expect(subject.first.next_run).to eq(next_run) }
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

    subject { described_class.remove(task_id) }

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

    subject { described_class.schedule(scheduled_task) }

    it do
      expect(scheduled_task_model).to receive(:where).with(task_id: task_id).and_return(where_response)
      expect(where_response).to receive(:destroy_all)
      expect(scheduled_task_model).to receive(:create).with(task_id: task_id, next_run: next_run)
      subject
    end
  end

  describe '#reports' do
    subject { described_class.reports }

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

    subject { described_class.register_report(report) }

    it do
      expect(scheduled_task_model).to receive(:where).with(task_id: task_id).and_return(where_response)
      expect(where_response).to receive(:destroy_all)
      expect(scheduled_task_model).to receive(:create).with(create_params)
      subject
    end
  end

  describe '#remove_reports_for' do
    let(:task_id) { :some_id }
    let(:where_response) { double(:where_response) }
    subject { described_class.remove_reports_for(task_id) }

    it do
      expect(report_model).to receive(:where).with(task_id: task_id).and_return(where_response)
      expect(where_response).to receive(:destroy_all)
      subject
    end
  end
end
