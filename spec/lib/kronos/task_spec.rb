# frozen_string_literal: true

RSpec.describe Kronos::Task do
  let(:id) { :task_id }
  let(:timestamp) { 'monday' }
  let(:block) { ->(*) {} }

  describe '.new' do
    subject { described_class.new(id, timestamp, block) }
    it { expect { subject }.to_not raise_error }

    context 'when id is invalid' do
      let(:id) { Object.new }
      it { expect { subject }.to raise_error(ArgumentError) }
    end

    context 'when timestamp is unparseable' do
      let(:timestamp) { 'foobar' }
      it { expect { subject }.to raise_error(Kronos::Exception::UnrecognizedTimeFormat) }
    end

    context 'when block is invalid' do
      let(:block) { :not_a_valid_block }
      it { expect { subject }.to raise_error(ArgumentError) }
    end
  end

  describe '#id' do
    subject { described_class.new(id, timestamp, block).id }
    it { is_expected.to be(id) }
  end

  describe '#time' do
    subject { described_class.new(id, timestamp, block).time }
    let(:timestamp) { '1979-05-27 05:00:00' }
    it { is_expected.to be_a(Time) }
    it { expect(subject.year).to be(1979) }
    it { expect(subject.month).to be(5) }
    it { expect(subject.day).to be(27) }
    it { expect(subject.hour).to be(5) }
    it { expect(subject.min).to be(0) }
    it { expect(subject.sec).to be(0) }
  end

  describe '#block' do
    subject { described_class.new(id, timestamp, block).block }
    it 'should equal proc passed to constructor' do
      is_expected.to be(block)
    end
  end
end
