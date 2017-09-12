# frozen_string_literal: true

RSpec.describe Kronos::Logger::Stdout do
  describe '.new' do
    subject { described_class.new }
    it { expect { subject }.to_not raise_error }
  end


  describe '#info' do
    subject { described_class.new.info(message) }
    let(:message) { 'foo bar' }
    let(:time) { Time.now.iso8601 }

    it 'invokes system puts' do
      expect_any_instance_of(described_class).to receive(:puts).with("[Kronos][INFO][#{time}] #{message}")
      subject
    end
  end

  describe '#error' do
    subject { described_class.new.error(message) }
    let(:message) { 'foo bar' }
    let(:time) { Time.now.iso8601 }

    it 'invokes system puts' do
      expect_any_instance_of(described_class).to receive(:puts).with("[Kronos][ERROR][#{time}] #{message}")
      subject
    end
  end

  describe '#success' do
    subject { described_class.new.success(message) }
    let(:message) { 'foo bar' }
    let(:time) { Time.now.iso8601 }

    it 'invokes system puts' do
      expect_any_instance_of(described_class).to receive(:puts).with("[Kronos][SUCCESS][#{time}] #{message}")
      subject
    end
  end
end
