# frozen_string_literal: true

module Kronos
  class Dependencies
    attr_reader :storage, :logger

    def initialize(storage: nil, logger: nil)
      @storage = storage
      @logger = logger
    end
  end
end
