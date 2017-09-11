# frozen_string_literal: true

module Kronos
  class Task
    attr_reader :id, :time, :block, :last_run

    def initialize(id, time, block)
      @id = check_id(id)
      @time = parse_time(time)
      @block = check_block(block)
    end

    private

    def check_id(id)
      id.is_a?(Symbol) ? id : raise_invalid_argument('Task ID', id, Symbol)
    end

    def check_block(block)
      block.is_a?(Proc) ? block : raise_invalid_argument('block', block, Proc)
    end

    def parse_time(timestamp)
      Chronic.parse(timestamp) || raise_unrecognized_time_format
    rescue
      raise_unrecognized_time_format
    end

    def raise_invalid_argument(name, received, expectation)
      raise(ArgumentError, "Invalid #{name} given (#{received.class}). #{expectation} expected.")
    end

    def raise_unrecognized_time_format
      raise(Kronos::Exception::UnrecognizedTimeFormat)
    end
  end
end
