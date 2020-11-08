# frozen_string_literal: true

class UserSkillsService < BaseUserSkillsService
  def call
    GetSkillsService.call.select do |el|
      user_skill_ids.include?(el[:id])
    end
  end
end
