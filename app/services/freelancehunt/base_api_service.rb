# frozen_string_literal: true

module Freelancehunt
  class BaseApiService < BaseService
    def call
      request(url)[:data]
    end

    private

    attr_reader :url

    def request(url)
      RestClient.get(
        url, Authorization: "Bearer #{FREELANCEHUNT_TOKEN}", 'Accept-Language' => 'en'
      ).then { |response| JSON.parse(response, symbolize_names: true) }
    end
  end
end
