# frozen_string_literal: true

class NotUserSkillsService < BaseUserSkillsService
  def call
    GetSkillsService.call.reject do |el|
      user_skill_ids.include?(el[:id])
    end
  end
end
