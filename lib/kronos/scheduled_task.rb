# frozen_string_literal: true

module Kronos
  class ScheduledTask
    attr_reader :task_id, :next_run

    def initialize(task_id, next_run)
      @task_id = check_task_id(task_id)
      @next_run = check_next_run(next_run)
    end

    private

    def check_task_id(task_id)
      task_id.is_a?(Symbol) ? task_id : raise_invalid_argument('Task ID', task_id, Symbol)
    end

    def check_next_run(time)
      time.is_a?(Time) ? time : raise_invalid_argument('time', time, Time)
    end

    def raise_invalid_argument(name, received, expectation)
      raise(ArgumentError, "Invalid #{name} given (#{received.class}). #{expectation} expected.")
    end
  end
end
