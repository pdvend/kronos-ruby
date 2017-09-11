# frozen_string_literal: true

RSpec.describe Kronos::ConfigAgent do
  describe '.new' do
    subject { described_class.new(registered_ids) }

    context 'when registered_ids is invalid' do
      let(:registered_ids) { Object.new }
      it { expect { subject }.to raise_error(ArgumentError) }
    end

    context 'when registered_ids is valid' do
      let(:registered_ids) { [] }
      it { expect { subject }.to_not raise_error }
    end
  end

  describe '#register' do
    subject { instance.register(id, timestamp) { |*| } }
    let(:instance) { described_class.new(registered_ids) }
    let(:registered_ids) { [:task1] }
    let(:id) { :task2 }
    let(:timestamp) { 'monday' }
    let(:options) { {} }

    context 'when id is invalid' do
      let(:id) { 'task1' }
      it { expect { subject }.to raise_error(ArgumentError) }
    end

    context 'when id is registered after class initialization and then repeated' do
      before { instance.register(id, timestamp, options) { |*| } }
      it { expect { subject }.to raise_error(Kronos::Exception::AlreadyRegisteredId) }
    end

    context 'when id is already registered' do
      let(:id) { :task1 }
      it { expect { subject }.to raise_error(Kronos::Exception::AlreadyRegisteredId) }
    end
  end
end
