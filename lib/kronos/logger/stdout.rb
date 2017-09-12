# frozen_string_literal: true

module Kronos
  module Logger
    class Stdout
      def info(msg)
        puts "[Kronos][INFO][#{Time.now.iso8601}] #{msg}"
      end

      def error(msg)
        puts "[Kronos][ERROR][#{Time.now.iso8601}] #{msg}"
      end

      def success(msg)
        puts "[Kronos][SUCCESS][#{Time.now.iso8601}] #{msg}"
      end
    end
  end
end
