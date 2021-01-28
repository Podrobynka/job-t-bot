# frozen_string_literal: true

require 'rails_helper'
vcr = { cassette_name: 'projects_updates' }

RSpec.describe Tasks::Projects::SendProjectsUpdates, :aggregate_failures, vcr: vcr do
  include ActiveSupport::Testing::TimeHelpers

  let(:time) { '2021-01-31 23:44:55 +0200'.to_time }
  let(:times) { 10 }
  let(:user) { create(:user) }
  let!(:user_skill_1) do
    create(:user_skill, skill_id: 1, user: user, checked_at: Time.now - 2.days)
  end

  let!(:user_skill_2) do
    create(:user_skill, skill_id: 2, user: user, checked_at: Time.now)
  end

  before { travel_to(time) }
  after { travel_back }

  subject { described_class.new.call }

  it 'updates last checked time' do
    expect { subject && user_skill_1.reload && user_skill_2.reload }
      .to change { user_skill_1.checked_at }
      .and(change { user_skill_2.checked_at })
  end

  it 'sends projects updates to chats' do
    expect(Telegram.bot).to receive(:send_message).exactly(times).times.and_call_original
    subject
  end
end
