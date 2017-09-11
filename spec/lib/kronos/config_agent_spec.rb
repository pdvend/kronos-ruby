# frozen_string_literal: true

RSpec.describe Kronos::ConfigAgent do
  describe '.new' do
    subject { described_class.new }
    it { expect { subject }.to_not raise_error }
  end

  describe '#register' do
    subject { instance.register(id, timestamp) { |*| } }
    let(:instance) { described_class.new }
    let(:id) { :task2 }
    let(:timestamp) { 'monday' }

    it { expect { subject }.to change { instance.tasks } }
    it { is_expected.to be(instance) }

    context 'when id is registered twice' do
      before { instance.register(id, timestamp) { |*| } }
      it { expect { subject }.to raise_error(Kronos::Exception::AlreadyRegisteredId) }
    end
  end

  describe '#tasks' do
    subject { instance.tasks }
    let!(:instance) { described_class.new }

    it { is_expected.to be_a(Array) }

    context 'when there are not registered tasks' do
      it { is_expected.to be_empty }
    end

    context 'when there are registered tasks' do
      before { instance.register(:task, 'monday') { |*| } }
      it { is_expected.to_not be_empty }
      it { is_expected.to all be_a(Kronos::Task) }
    end
  end

  describe '#runner' do
    subject { instance.runner(runner) }
    let!(:instance) { described_class.new }
    let(:runner) { double('runner') }

    it { expect { subject }.to_not raise_error }
    it { is_expected.to be(instance) }
  end

  describe '#runner_instance' do
    subject { instance.runner_instance }
    let!(:instance) { described_class.new }

    context 'when no runner was previosly registered' do
      it { expect { subject }.to raise_error(Kronos::Exception::NoRunnerRegistered) }
    end

    context 'when a runner was previosly registered' do
      let(:runner) { double('runner') }
      let(:runner_instance) { double('runner_instance') }

      before do
        instance.runner(runner)
        allow(runner).to receive(:new).and_return(runner_instance)
      end

      it { is_expected.to be(runner_instance) }
    end
  end
end
