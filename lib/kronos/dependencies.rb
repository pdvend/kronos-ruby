# frozen_string_literal: true

module Kronos
  class Dependencies
    attr_reader :storage

    def initialize(storage: nil)
      @storage = storage
    end
  end
end
