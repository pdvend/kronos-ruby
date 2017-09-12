# frozen_string_literal: true
require 'net/http'
require 'json'

module Kronos
  module Logger
    class Slack
      def initialize(slack_webhook_url)
        @slack_uri = URI.parse(slack_webhook_url)
        @use_ssl = @slack_uri.scheme == 'https'
      end

      def info(msg)
        send_to_slack("[`Kronos`][`INFO`][`#{Time.now.iso8601}`] #{msg}", ':information_source:')
      end

      def error(msg)
        send_to_slack("[`Kronos`][`ERROR`][`#{Time.now.iso8601}`] #{msg}", ':red_circle:')
      end

      def success(msg)
        send_to_slack("[`Kronos`][`SUCCESS`][`#{Time.now.iso8601}`] #{msg}", ':white_check_mark:')
      end

      private

      def send_to_slack(message, emoji)
        request = Net::HTTP::Post.new(@slack_uri)
        request.body = { text: message, icon_emoji: emoji }.to_json
        Net::HTTP.start(@slack_uri.host, @slack_uri.port, use_ssl: @use_ssl) { |http| http.request(request) }
      end
    end
  end
end
