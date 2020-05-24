# frozen_string_literal: true

class GetSkillsService < BaseService
  GET_SKILLS = 'https://api.freelancehunt.com/v2/skills'

  def call
    response =
      RestClient.get(GET_SKILLS, Authorization: "Bearer #{FREELANCEHUNT_TOKEN}")

    JSON.parse(response, symbolize_names: true)[:data]
  end
end
