# frozen_string_literal: true

require 'mongoid'

module Kronos
  module Storage
    module Model
      class ReportModel
        include Mongoid::Document
        store_in collection: :kronos_reports

        field :task_id, type: Symbol
        field :metadata, type: Hash
        field :timestamp, type: Time
      end
    end
  end
end
