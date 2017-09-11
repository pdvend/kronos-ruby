# frozen_string_literal: true

require 'kronos/version'
require 'kronos/config_agent'
require 'kronos/exception'
require 'kronos/task'

require 'chronic'

module Kronos
  @tasks = []

  module_function

  def config
    agent = Kronos::ConfigAgent.new(@tasks.map(&:id))
    yield(agent)
    @tasks += agent.tasks
  end

  def tasks
    @tasks
  end

  def clear_tasks
    @tasks.clear
    nil
  end
end
