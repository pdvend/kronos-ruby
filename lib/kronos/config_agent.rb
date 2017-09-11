# frozen_string_literal: true

module Kronos
  class ConfigAgent
    attr_reader :tasks

    def initialize(registered_ids)
      @tasks = []
      raise(ArgumentError) unless registered_ids.kind_of?(Array)
      @registered_ids = registered_ids
    end

    def register(id, timestamp, options = {}, &block)
      raise(Kronos::Exception::AlreadyRegisteredId) if @registered_ids.include?(id)

      task = Kronos::Task.new(id, timestamp, block)
      tasks.push(task)

      @registered_ids << id
    end
  end
end
