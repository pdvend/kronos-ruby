# frozen_string_literals: true

module Kronos
  class Dependencies
    attr_reader :storage

    def initialize(storage: nil)
      @storage = storage
    end
  end
end
