# frozen_string_literal: true

require 'kronos/version'
require 'kronos/config_agent'
require 'kronos/exception'
require 'kronos/task'

require 'chronic'

module Kronos
  @config_agent = Kronos::ConfigAgent.new

  module_function

  def config
    @config_agent
  end
end
