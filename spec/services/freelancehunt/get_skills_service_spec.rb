# frozen_string_literal: true

require 'rails_helper'
vcr = { cassette_name: 'get_skills' }

RSpec.describe Freelancehunt::GetSkillsService, :aggregate_failures, vcr: vcr do
  let(:times) { 1 }

  subject { described_class.call }

  shared_examples 'performs call to external API' do
    it 'performs call to external API' do
      expect(RestClient).to receive(:get).exactly(times).times.and_call_original
      subject
    end

    it 'returns arrey with skill ids and names' do
      expect(subject).to be_an(Array)
      expect(subject.first.keys).to contain_exactly(:id, :name)
    end
  end

  context 'without cache' do
    include_examples 'performs call to external API'
  end

  context 'with cache' do
    let(:times) { 0 }

    before { described_class.call }

    include_examples 'performs call to external API'
  end
end
