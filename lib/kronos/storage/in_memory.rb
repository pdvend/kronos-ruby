# frozen_string_literal: true

module Kronos
  module Storage
    class InMemory
      attr_reader :reports
      attr_reader :scheduled_tasks

      def initialize
        @scheduled_tasks = []
        @reports = []
        @locks = {}
      end

      def schedule(scheduled_task)
        remove(scheduled_task.task_id)
        @scheduled_tasks.push(scheduled_task)
      end

      def register_report(report)
        remove_reports_for(report.task_id)
        @reports << report
      end

      def pending?(task)
        time = Time.now

        @scheduled_tasks
          .lazy
          .select { |scheduled_task| scheduled_task.next_run > time }
          .map(&:task_id)
          .include?(task.id)
      end

      def resolved_tasks
        time = Time.now

        @scheduled_tasks
          .lazy
          .select { |scheduled_task| scheduled_task.next_run <= time }
          .map(&:task_id)
          .to_a
      end

      def remove(task_id)
        @scheduled_tasks.reject! { |scheduled_task| scheduled_task.task_id == task_id }
      end

      def remove_reports_for(id)
        @reports.reject! { |report| report.task_id == id }
      end

      def locked_task?(task_id)
        @locks.key?(task_id)
      end

      def lock_task(task_id)
        SecureRandom.uuid.tap do |lock_id|
          @locks[task_id] = lock_id
        end
      end

      def check_lock(task_id, lock_id)
        @locks[task_id] == lock_id
      end

      def release_lock(task_id)
        @locks.delete(task_id)
      end
    end
  end
end
