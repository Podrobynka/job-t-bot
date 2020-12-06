# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserSkills::DeleteService, :aggregate_failures do
  let(:user) { create(:user) }
  let(:skill_id) { '123' }

  subject { described_class.call(user, skill_id) }

  context 'when user_skill exists' do
    let!(:user_skill) { create(:user_skill, user: user, skill_id: skill_id) }

    it 'deletes existed user_skill' do
      expect { subject }.to change { UserSkill.count }.by(-1)
      expect(subject).to eq(user_skill)
    end
  end

  context 'when user_skill doesn\'t exist' do
    it 'returns nil' do
      expect { subject }.to_not(change { UserSkill.count })
      expect(subject).to be_nil
    end
  end
end
