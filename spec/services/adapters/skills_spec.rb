# frozen_string_literal: true

require 'rails_helper'
vcr = { cassette_name: 'get_skills' }

RSpec.describe Adapters::Skills, :aggregate_failures, vcr: vcr do
  let(:adaptee) { Freelancehunt::GetSkillsService.call }
  let(:action_key) { 'select_skill_' }
  let(:result) do
    [
      { text: '1C', callback_data: '{"select_skill_callback_query":56}' },
      { text: '3D modeling', callback_data: '{"select_skill_callback_query":59}' }
    ]
  end

  subject { described_class.call(adaptee, action_key) }

  it 'returns modified arrey of skillls' do
    expect(subject).to be_an(Array)
    expect(subject.first).to match(result)
  end
end
