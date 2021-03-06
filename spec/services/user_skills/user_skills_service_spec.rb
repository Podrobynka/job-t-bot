# frozen_string_literal: true

require 'rails_helper'
vcr = { cassette_name: 'get_skills' }

RSpec.describe UserSkills::UserSkillsService, :aggregate_failures, vcr: vcr do
  let(:user) { create(:user) }
  let(:skill_id) { 1 }
  let!(:user_skill) { create(:user_skill, user: user, skill_id: skill_id) }
  let(:user_skills) { [{ id: skill_id, name: 'PHP' }] }

  subject { described_class.call(user) }

  it 'selects user_skills from list' do
    expect(subject).to eq(user_skills)
  end
end
