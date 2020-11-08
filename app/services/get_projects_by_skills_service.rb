# frozen_string_literal: true

class GetProjectsBySkillsService < BaseFreelancehuntApiService
  def initialize(skill_ids, checked_at)
    @skill_ids = skill_ids
    @checked_at = checked_at
  end

  def call
    projects = []

    skill_ids.each do |skill_id|
      projects.concat(fetch_projects(skill_id, checked_at[skill_id]))
    end

    projects
  end

  private

  attr_reader :skill_ids, :checked_at

  def fetch_projects(skill_id, published_at = nil)
    GetProjectsService.call(skill_id, published_at)
  end
end
