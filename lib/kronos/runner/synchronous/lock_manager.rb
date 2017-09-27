# frozen_string_literal: true

module Kronos
  module Runner
    class Synchronous
      class LockManager
        extend Forwardable

        def initialize(storage)
          @storage = storage
        end

        def lock_and_execute(task_id)
          return if locked_task?(task_id)
          lock_id = lock_task(task_id)
          return unless check_lock(task_id, lock_id)
          yield
        ensure
          release_lock(task_id)
        end

        def_delegator :@storage, :locked_task?, :locked_task?
        def_delegator :@storage, :lock_task,    :lock_task
        def_delegator :@storage, :check_lock,   :check_lock
        def_delegator :@storage, :release_lock, :release_lock
      end
    end
  end
end
