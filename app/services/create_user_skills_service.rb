# frozen_string_literal: true

class CreateUserSkillsService < BaseService
  def initialize(user, skill_id)
    @user = user
    @skill_id = skill_id
  end

  def call
    user.user_skills.find_or_create_by(skill_id: skill_id)
  end

  private

  attr_reader :user, :skill_id
end
