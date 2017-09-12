# frozen_string_literal: true

module Kronos
  class ConfigAgent
    attr_reader :tasks

    def initialize
      @tasks = []
      @runner_class = nil
    end

    def register(id, timestamp, &block)
      raise(Kronos::Exception::AlreadyRegisteredId) if @tasks.lazy.map(&:id).include?(id)

      task = Kronos::Task.new(id, timestamp, block)
      tasks.push(task)

      self
    end

    def storage(storage, *config)
      @_storage = storage
      @storage_instance = nil
      @storage_config = config
      self
    end

    def runner(runner)
      @_runner = runner
      @runner_instance = nil
      self
    end

    def runner_instance
      @runner_instance ||= begin
        raise(Kronos::Exception::NoRunnerRegistered) unless _runner

        dependencies = Kronos::Dependencies.new(
          storage: storage_instance
        )

        _runner.new(tasks, dependencies)
      end
    end

    def storage_instance
      @storage_instance ||= begin
        raise(Kronos::Exception::NoStorageRegistered) unless _storage
        _storage.new(*@storage_config)
      end
    end

    private

    attr_accessor :_runner, :_storage
  end
end
