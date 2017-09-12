# frozen_string_literal: true

module Kronos
  class ConfigAgent
    attr_reader :tasks

    def initialize
      @tasks = []
      @instance = {}
    end

    def register(id, timestamp, &block)
      raise(Kronos::Exception::AlreadyRegisteredId) if @tasks.lazy.map(&:id).include?(id)

      task = Kronos::Task.new(id, timestamp, block)
      tasks.push(task)

      self
    end

    def storage(storage, *config)
      @instance[:storage] = storage.new(*config)
      self
    end

    def logger(logger, *config)
      @instance[:logger] = logger.new(*config)
      self
    end

    def runner(runner)
      @_runner = runner
      @instance[:runner] = nil
      self
    end

    def runner_instance
      @instance[:runner] ||= begin
        raise(Kronos::Exception::NoRunnerRegistered) unless _runner

        dependencies = Kronos::Dependencies.new(
          storage: storage_instance,
          logger: logger_instance
        )

        _runner.new(tasks, dependencies)
      end
    end

    def storage_instance
      @instance[:storage] || raise(Kronos::Exception::NoStorageRegistered)
    end

    def logger_instance
      @instance[:logger] || raise(Kronos::Exception::NoLoggerRegistered)
    end

    private

    attr_accessor :_runner, :_storage
  end
end
