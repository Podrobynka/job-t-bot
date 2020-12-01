# frozen_string_literal: true

module UserSkills
  class NotUserSkillsService < UserSkills::BaseUserSkillsService
    def call
      Freelancehunt::GetSkillsService.call.reject do |el|
        user_skill_ids.include?(el[:id])
      end
    end
  end
end
