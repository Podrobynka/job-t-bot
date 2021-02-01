# frozen_string_literal: true

require 'rails_helper'
vcr = { cassette_name: 'get_projects_skills_1_2' }

RSpec.describe Adapters::Projects, :aggregate_failures, vcr: vcr do
  let(:skill_ids) { [1, 2] }
  let(:adaptee) { Freelancehunt::GetProjectsService.call(skill_ids) }
  let(:result) do
    "\u{1F4A1} TRADEBOT Онлаин Steam обмен площадка\n\u{1F4CD} #node_js, #php"
    "\n\u{1F680} https://freelancehunt.com/project/tradebot-onlain-steam-" \
    'obmen-ploschadka/796357.html'
  end

  subject { described_class.call(adaptee) }

  it 'returns modified arrey of skillls' do
    expect(subject).to be_an(Array)
    expect(subject.first).to match(result)
  end
end
