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
      id.kind_of?(Symbol) ? id : raise(ArgumentError, "Invalid Task ID given (#{id.class}). Symbol expected.")
    end

    def check_block(block)
      block.kind_of?(Proc) ? block : raise(ArgumentError, "Invalid block given (#{id.class}). Proc expected.")
    end

    def parse_time(timestamp)
      Chronic.parse(timestamp) || raise_unrecognized_time_format
    rescue
      raise_unrecognized_time_format
    end

    def raise_unrecognized_time_format
      raise(Kronos::Exception::UnrecognizedTimeFormat)
    end
  end
end
