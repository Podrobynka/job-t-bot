# frozen_string_literal: true

module Adapters
  class BaseAdapter < BaseService
    def initialize(adaptee)
      @adaptee = adaptee
    end

    def call; end

    private

    attr_reader :adaptee
  end
end
