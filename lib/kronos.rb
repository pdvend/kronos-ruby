# frozen_string_literal: true

require 'kronos/config_agent'
require 'kronos/exception'
require 'kronos/runner'
require 'kronos/storage'
require 'kronos/task'
require 'kronos/version'

require 'chronic'

module Kronos
  @config_agent = Kronos::ConfigAgent.new

  module_function

  def config
    @config_agent
  end

  def start
    @config_agent.runner_instance.start
  end
end
