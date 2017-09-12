# frozen_string_literal: true

module Kronos
  module Runner
    # TODO: Logger instead of puts
    class Synchronous
      # TODO: Let consumer configure it
      METADATA_COLLECTORS = [
        lambda do |block|
          start = Time.now
          result = block.call
          finish = Time.now

          { **result, start: start, finish: finish, duration: finish - start }
        end
      ].freeze

      ID_FUNC = lambda do |block|
        lambda do
          block.call
          {}
        end
      end

      def initialize(tasks, dependencies)
        @tasks = tasks
        @dependencies = dependencies
      end

      def start
        loop do
          run_resolved_tasks
          schedule_current_tasks

          # TODO: Configurable sleep between runs
          sleep(1)
        end
      end

      private

      def schedule_current_tasks
        @tasks.each(&method(:schedule_task))
      end

      def schedule_task(task)
        schedule_next_run(task) unless @dependencies.storage.pending?(task)
      end

      def run_resolved_tasks
        @dependencies.storage.resolved_tasks.each(&method(:process_task))
      end

      def process_task(task_id)
        task = find_task(task_id)
        return remove_task_from_schedule(task_id) unless task
        run_task(task)
        schedule_next_run(task)
      end

      def remove_task_from_schedule(task_id)
        puts "[Kronos] Task `#{task_id}` was removed from definitions. Removing from schedule too."
        @dependencies.storage.remove(task_id)
      end

      # rubocop:disable RescueException
      def run_task(task)
        raw_execute_task(task)
      rescue ::Exception => error
        register_task_failure(task, error)
      end
      # rubocop:enable

      def raw_execute_task(task)
        metadata = collect_metadata { task.block.call }
        puts "[Kronos] Task `#{task.id}` ran successfully."
        @dependencies.storage.register_report(Kronos::Report.success_from(task, metadata))
      end

      def register_task_failure(task, error)
        puts "[Kronos] Task `#{task.id}` failed."
        @dependencies.storage.register_report(Kronos::Report.failure_from(task, error))
      end

      def collect_metadata(&block)
        METADATA_COLLECTORS
          .reverse
          .reduce(ID_FUNC[block]) { |chain, collector| -> () { collector[chain] } }
          .call
      end

      def schedule_next_run(task)
        next_run = task.time
        return if next_run < Time.now
        puts "[Kronos] Scheduling #{task.id} to run #{next_run.iso8601}"
        @dependencies.storage.schedule(task, next_run)
      end

      def find_task(task_id)
        @tasks.find { |task| task.id == task_id }
      end
    end
  end
end
