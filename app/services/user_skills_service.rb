# frozen_string_literal: true

class UserSkillsService < BaseService
  def initialize(user)
    @user = user
  end

  def call
    GetSkillsService.call.select do |el|
      user.user_skills.pluck(:skill_id).include?(el[:id])
    end
  end

  private

  attr_reader :user
end
