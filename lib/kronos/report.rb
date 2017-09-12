# frozen_string_literal: true

module Kronos
  class Report < OpenStruct
    STATUSES = { success: 0, failure: 1 }.freeze

    class << self
      def success_from(task, metadata, timestamp = Time.now)
        new(
          task: check_task(task),
          status: Kronos::Report::STATUSES[:success],
          timestamp: check_timestamp(timestamp),
          metadata: check_metadata(metadata)
        )
      end

      def failure_from(task, exception, timestamp = Time.now)
        new(
          task: check_task(task),
          status: Kronos::Report::STATUSES[:failure],
          timestamp: check_timestamp(timestamp),
          exception: check_exception(exception)
        )
      end

      private :new

      private

      def check_timestamp(timestamp)
        timestamp.is_a?(Time) ? timestamp : raise_invalid_argument('timestamp', timestamp, Time)
      end

      def check_task(task)
        task.is_a?(Kronos::Task) ? task : raise_invalid_argument('task', task, Kronos::Task)
      end

      def check_metadata(metadata)
        raise_invalid_argument('metadata', metadata, Hash) unless metadata.is_a?(Hash)
        return metadata if metadata.values.all? { |value| value.is_a?(String) }
        raise(ArgumentError, 'Expected all values in metadata to be strings')
      end

      def check_exception(exception)
        if exception.is_a?(Hash)
          return exception if valid_exception_format(exception)
          raise(ArgumentError, 'Invalid exception format')
        elsif exception.is_a?(::Exception)
          exception_hash_from(exception)
        else
          raise_invalid_argument('exception', exception, Hash)
        end
      end

      def exception_hash_from(exception)
        {
          type: exception.class.name,
          message: exception.message,
          stacktrace: exception.backtrace
        }
      end

      def valid_exception_format(exception)
        type = exception[:type]
        message = exception[:message]
        stacktrace = exception[:stacktrace]

        type.is_a?(String) &&
          !type.empty? &&
          message.is_a?(String) &&
          !message.empty? &&
          stacktrace.is_a?(Array) &&
          stacktrace.all? { |line| line.is_a?(String) }
      end

      def raise_invalid_argument(name, received, expectation)
        raise(ArgumentError, "Invalid #{name} given (#{received.class}). #{expectation} expected.")
      end
    end

    def success?
      status == Kronos::Report::STATUSES[:success]
    end

    def failure?
      status == Kronos::Report::STATUSES[:failure]
    end
  end
end
