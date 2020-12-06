# frozen_string_literal: true

require 'rails_helper'
vcr = { cassette_name: 'get_skills' }

RSpec.describe Freelancehunt::GetSkillsService, :aggregate_failures, vcr: vcr do
  subject { described_class.call }

  it 'performs call to external API' do
    expect(RestClient).to receive(:get).once.and_call_original
    subject
  end

  it 'returns arrey with skill ids and names' do
    expect(subject).to be_an(Array)
    expect(subject.first.keys).to contain_exactly(:id, :name)
  end
end
