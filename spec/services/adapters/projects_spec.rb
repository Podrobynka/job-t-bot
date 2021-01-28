# frozen_string_literal: true

require 'rails_helper'
vcr = { cassette_name: 'get_projects_skills_1_2' }

RSpec.describe Adapters::Projects, :aggregate_failures, vcr: vcr do
  let(:skill_ids) { [1, 2] }
  let(:adaptee) { Freelancehunt::GetProjectsService.call(skill_ids) }
  let(:result) do
    "TRADEBOT Онлаин Steam обмен площадка\nNode.js, PHP\nhttps://freelancehun" \
    't.com/project/tradebot-onlain-steam-obmen-ploschadka/796357.html'
  end

  subject { described_class.call(adaptee) }

  it 'returns modified arrey of skillls' do
    expect(subject).to be_an(Array)
    expect(subject.first).to match(result)
  end
end
