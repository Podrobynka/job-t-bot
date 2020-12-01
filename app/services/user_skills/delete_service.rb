# frozen_string_literal: true

module UserSkills
  class DeleteService < UserSkills::BaseUserSkillsService
    def initialize(user, skill_id)
      @user = user
      @skill_id = skill_id
    end

    def call
      user.user_skills.find_by(skill_id: skill_id).delete
    end

    private

    attr_reader :user, :skill_id
  end
end
