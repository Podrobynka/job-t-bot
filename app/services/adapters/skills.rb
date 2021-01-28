# frozen_string_literal: true

module Adapters
  class Skills < BaseAdapter
    def initialize(adaptee, action_key)
      super(adaptee)
      @action_key = action_key
    end

    def call
      skills_list = []
      adaptee.map do |skill|
        skills_list << {
          text: skill[:name],
          callback_data: { "#{action_key}callback_query": skill[:id] }.to_json
        }
      end

      skills_list.each_slice(2).to_a
    end

    private

    attr_reader :action_key
  end
end
