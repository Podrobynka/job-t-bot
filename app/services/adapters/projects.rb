# frozen_string_literal: true

module Adapters
  class Projects < BaseAdapter
    def call
      adaptee.map { |pr| project(pr) }
    end

    private

    def project(item)
      [item.dig(:attributes, :name), "\n",
       item.dig(:attributes, :skills).pluck(:name).join(', '), "\n",
       item.dig(:links, :self, :web)].join
    end
  end
end
