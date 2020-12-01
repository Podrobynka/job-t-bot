# frozen_string_literal: true

module Freelancehunt
  class GetSkillsService < Freelancehunt::BaseApiService
    GET_SKILLS = 'https://api.freelancehunt.com/v2/skills'

    def initialize
      @url = GET_SKILLS
    end
  end
end
