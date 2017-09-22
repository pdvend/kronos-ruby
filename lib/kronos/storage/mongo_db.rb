# frozen_string_literal: true

require 'kronos/storage/mongo/model/scheduled_task_model'
require 'kronos/storage/mongo/model/report_model'

module Kronos
  module Storage
    # :reek:UtilityFunction:
    class MongoDb
      SHEDULED_TASK_MODEL = Mongo::Model::ScheduledTaskModel
      REPORT_MODEL = Mongo::Model::ReportModel

      def scheduled_tasks
        # Returns all current Kronos::ScheduledTask, resolved or pending
        SHEDULED_TASK_MODEL.all
      end

      def schedule(scheduled_task)
        # Removes any Kronos::ScheduledTask with same task ID and saves the one in parameter
        remove(scheduled_task.task_id)
        SHEDULED_TASK_MODEL.create(scheduled_task_params(scheduled_task))
      end

      def resolved_tasks
        # Returns a list of task ids that where resolved (where scheduled_task.next_run <= Time.now)
        tasks = []
        SHEDULED_TASK_MODEL.where(:next_run.lte => Time.now).each do |scheduled_task_model|
          tasks << Kronos::ScheduledTask.new(scheduled_task_model.id, scheduled_task_model.next_run)
        end
        tasks
      end

      def remove(task_id)
        # Removes scheduled tasks with task_id
        SHEDULED_TASK_MODEL.where(task_id: task_id).destroy_all
      end

      def reports
        # Returns all previous Kronos::Report that were saved using #register_report
        REPORT_MODEL.all
      end

      def register_report(report)
        # Removes any Kronos::Report with same task ID and saves the one in parameter
        remove_reports_for(report.task_id)
        REPORT_MODEL.create(report_params(report))
      end

      def remove_reports_for(task_id)
        # Removes reports with task_id
        REPORT_MODEL.where(task_id: task_id).destroy_all
      end

      def pending?(task)
        # Checks if task has any pending scheduled task (where scheduled_task.next_run > Time.now)
        SHEDULED_TASK_MODEL.where(task_id: task.id).first.next_run > Time.now
      end

      private

      def scheduled_task_params(scheduled_task)
        {
          task_id: scheduled_task.task_id,
          next_run: scheduled_task.next_run
        }
      end

      def report_params(report)
        {
          task_id: report.task_id,
          metadata: report.metadata,
          timestamp: report.timestamp
        }
      end
    end
  end
end
