# frozen_string_literal: true

module UserSkills
  class UserSkillsService < UserSkills::BaseUserSkillsService
    def call
      Freelancehunt::GetSkillsService.call.select do |el|
        user_skill_ids.include?(el[:id])
      end
    end
  end
end
