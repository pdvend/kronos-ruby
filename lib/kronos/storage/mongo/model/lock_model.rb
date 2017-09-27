# frozen_string_literal: true

require 'mongoid'

module Kronos
  module Storage
    module Mongo
      module Model
        class LockModel
          include Mongoid::Document
          store_in collection: :kronos_locks

          field :task_id, type: Symbol
          field :value, type: String
        end
      end
    end
  end
end
