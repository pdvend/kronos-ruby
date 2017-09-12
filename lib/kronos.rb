# frozen_string_literal: true

require 'concurrent'
require 'chronic'
require 'ostruct'

require 'kronos/config_agent'
require 'kronos/dependencies'
require 'kronos/exception'
require 'kronos/logger'
require 'kronos/report'
require 'kronos/runner'
require 'kronos/storage'
require 'kronos/task'
require 'kronos/version'

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
