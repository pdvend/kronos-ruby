# frozen_string_literal: true

RSpec.describe Kronos::Logger::Slack do
  let(:webhook_url) { 'https://fake.slack.url' }

  before do
    Timecop.freeze
  end

  after do
    Timecop.return
  end

  describe '.new' do
    subject { described_class.new(webhook_url) }

    context 'with a valid webhook url' do
      it { expect { subject }.to_not raise_error }
    end

    context 'with an invalid webhook url' do
      let(:webhook_url) { 'foo bar' }
      it { expect { subject }.to raise_error(URI::InvalidURIError) }
    end
  end

  describe '#info' do
    subject { described_class.new(webhook_url).info(message) }
    let(:message) { 'foo bar' }
    let(:time) { Time.now.iso8601 }
    let(:expected_body) { { text: "[`Kronos`][`INFO`][`#{time}`] #{message}", icon_emoji: ':information_source:' } }

    before do
      stub_request(:post, webhook_url)
    end

    it 'invokes slack webhook' do
      subject
      expect(WebMock)
        .to have_requested(:post, webhook_url)
        .with(body: expected_body.to_json)
    end
  end

  describe '#error' do
    subject { described_class.new(webhook_url).error(message) }
    let(:message) { 'foo bar' }
    let(:time) { Time.now.iso8601 }
    let(:expected_body) { { text: "[`Kronos`][`ERROR`][`#{time}`] #{message}", icon_emoji: ':red_circle:' } }

    before do
      stub_request(:post, webhook_url)
    end

    it 'invokes slack webhook' do
      subject
      expect(WebMock)
        .to have_requested(:post, webhook_url)
        .with(body: expected_body.to_json)
    end
  end

  describe '#success' do
    subject { described_class.new(webhook_url).success(message) }
    let(:message) { 'foo bar' }
    let(:time) { Time.now.iso8601 }
    let(:expected_body) { { text: "[`Kronos`][`SUCCESS`][`#{time}`] #{message}", icon_emoji: ':white_check_mark:' } }

    before do
      stub_request(:post, webhook_url)
    end

    it 'invokes slack webhook' do
      subject
      expect(WebMock)
        .to have_requested(:post, webhook_url)
        .with(body: expected_body.to_json)
    end
  end
end
