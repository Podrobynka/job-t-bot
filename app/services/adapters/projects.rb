# frozen_string_literal: true

module Adapters
  class Projects < BaseAdapter
    def call
      adaptee.map { |pr| project(pr) }
    end

    private

    def project(item)
      ["\u{1F4A1} ", item.dig(:attributes, :name), "\n", "\u{1F4CD} ",
       item.dig(:attributes, :skills).pluck(:name)
           .map { |s| '#' + s.parameterize.underscore }.join(', '), "\n",
       "\u{1F680} ", item.dig(:links, :self, :web)].join
    end
  end
end
