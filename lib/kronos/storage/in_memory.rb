# frozen_string_literal: true

module Kronos
  module Storage
    class InMemory
      def initialize
        @tasks = []
        @reports = []
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
        @tasks.reject! { |(task, _next_run)| task.id == id }
        remove_reports_for(id)
      end

      def register_report(report)
        remove_reports_for(report.task.id)
        @reports << report
      end

      def schedule(task, next_run)
        remove(task.id)
        @tasks.push([task, next_run])
      end

      private

      def remove_reports_for(id)
        @reports.reject! { |report| report.task.id == id }
      end
    end
  end
end
