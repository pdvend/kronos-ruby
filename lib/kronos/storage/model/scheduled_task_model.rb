# frozen_string_literal: true

require 'mongoid'

module Kronos
  module Storage
    module Model
      class ScheduledTaskModel
        include Mongoid::Document
        store_in collection: :kronos_scheduled_tasks

        field :task_id, type: Symbol
        field :next_run, type: Time
      end
    end
  end
end
