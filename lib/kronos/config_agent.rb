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

    def runner(runner)
      @runner = runner
      self
    end

    def runner_instance
      raise(Kronos::Exception::NoRunnerRegistered) if @runner.nil?
      @runner.new
    end
  end
end
