# frozen_string_literal: true

module Kronos
  class Exception < StandardError
  end
end

require 'kronos/exception/unrecognized_time_format'
require 'kronos/exception/already_registered_id'
