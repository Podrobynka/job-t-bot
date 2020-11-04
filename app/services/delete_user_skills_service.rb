# frozen_string_literal: true

class DeleteUserSkillsService < BaseService
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
