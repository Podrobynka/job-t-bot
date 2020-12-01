# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserSkill, type: :model do
  describe 'relations' do
    it { should belong_to(:user) }
  end
end
