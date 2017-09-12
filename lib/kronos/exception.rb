# frozen_string_literal: true

module Kronos
  class Exception < StandardError
  end
end

require 'kronos/exception/already_registered_id'
require 'kronos/exception/no_logger_registered'
require 'kronos/exception/no_runner_registered'
require 'kronos/exception/no_storage_registered'
require 'kronos/exception/unrecognized_time_format'
