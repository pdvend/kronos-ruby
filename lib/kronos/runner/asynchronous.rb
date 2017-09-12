# frozen_string_literal: true

module Kronos
  module Runner
    class Asynchronous < Synchronous
      include Concurrent::Async
      alias original_start start

      def start
        async.original_start
      end
    end
  end
end
