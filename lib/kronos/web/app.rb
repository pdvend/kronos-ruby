# frozen_string_literal: true

module Kronos
  module Web
    App = Class.new do
      def initialize
        view = File.join(File.dirname(__FILE__), 'view.html.erb')
        template = File.binread(view)
        @erb = ERB.new(template)
      end

      def call(_env)
        [200, {}, [rendered_template]]
      end

      def rendered_template
        @erb.result(binding)
      end
    end.new
  end
end
