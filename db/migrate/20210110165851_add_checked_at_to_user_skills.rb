# frozen_string_literal: true

class AddCheckedAtToUserSkills < ActiveRecord::Migration[6.0]
  def change
    add_column :user_skills, :checked_at, :datetime
  end
end
