# frozen_string_literal: true

RSpec.describe Kronos::ScheduledTask do
  let(:task_id) { :task_id }
  let(:next_run) { Time.now }

  describe '.new' do
    subject { described_class.new(task_id, next_run) }
    it { expect { subject }.to_not raise_error }

    context 'when task id is invalid' do
      let(:task_id) { Object.new }
      it { expect { subject }.to raise_error(ArgumentError) }
    end

    context 'when next_run is invalid' do
      let(:next_run) { :not_a_valid_time }
      it { expect { subject }.to raise_error(ArgumentError) }
    end
  end
end
