# frozen_string_literal: true

module Kronos
  class Task
    attr_reader :id, :block

    def initialize(id, timestamp, block)
      @id = check_id(id)
      @timestamp = timestamp
      time # check timestamp parseability
      @block = check_block(block)
    end

    def time
      Chronic.parse(@timestamp) || raise_unrecognized_time_format
    rescue
      raise_unrecognized_time_format
    end

    private

    def check_id(id)
      id.is_a?(Symbol) ? id : raise_invalid_argument('Task ID', id, Symbol)
    end

    def check_block(block)
      block.is_a?(Proc) ? block : raise_invalid_argument('block', block, Proc)
    end

    def raise_invalid_argument(name, received, expectation)
      raise(ArgumentError, "Invalid #{name} given (#{received.class}). #{expectation} expected.")
    end

    def raise_unrecognized_time_format
      raise(Kronos::Exception::UnrecognizedTimeFormat)
    end
  end
end
