# frozen_string_literal: true

class GetSkillsService < BaseFreelancehuntApiService
  GET_SKILLS = 'https://api.freelancehunt.com/v2/skills'

  def initialize
    @url = GET_SKILLS
  end
end
