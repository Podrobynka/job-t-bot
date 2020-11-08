# frozen_string_literal: true

class BaseUserSkillsService < BaseService
  def initialize(user)
    @user = user
  end

  private

  attr_reader :user

  def user_skill_ids
    @user_skill_ids ||= user.user_skills.pluck(:skill_id)
  end
end
