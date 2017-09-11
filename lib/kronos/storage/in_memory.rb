# frozen_string_literals: true

module Kronos
  module Storage
    class InMemory
      def initialize
        @tasks = []
      end

      def pending?(task)
        time = Time.now

        @tasks
          .lazy
          .select { |(_task, next_run)| next_run > time }
          .map(&:first)
          .map(&:id)
          .include?(task.id)
      end

      def resolved_tasks
        time = Time.now

        @tasks
          .lazy
          .select { |(_task, next_run)| next_run <= time }
          .map(&:first)
          .map(&:id)
      end

      def remove(id)
        @tasks.reject!{|(task, _next_run)| task.id == id }
      end

      def register_task_success(_task, _metadata)
        # TODO
      end

      def register_task_failure(_task, _error)
        # TODO
      end

      def schedule(task, next_run)
        remove(task.id)
        @tasks.push([task, next_run])
      end
    end
  end
end
