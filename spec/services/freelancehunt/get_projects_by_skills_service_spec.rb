# frozen_string_literal: true

require 'rails_helper'
vcr = { cassette_name: 'get_projects_by_skills_1_2' }
vcr_checked_at = { cassette_name: 'get_projects_by_skills_checked_at' }

RSpec.describe Freelancehunt::GetProjectsBySkillsService, :aggregate_failures do
  let(:skill_ids) { [] }
  let(:checked_at) { nil }
  subject { described_class.call(skill_ids, checked_at) }

  shared_examples 'fetches projects' do
    it 'performs call to external API' do
      expect(RestClient).to receive(:get).exactly(times).times.and_call_original
      subject
      expect(subject).to be_an(Array)
    end
  end

  shared_examples 'fetches projects data' do
    it 'returns arrey with skill ids and names' do
      expect(subject.first.keys).to contain_exactly(:id, :attributes, :links, :type)
    end
  end

  context 'without skill_ids and published_at' do
    let(:times) { 0 }

    include_examples 'fetches projects'
  end

  context 'with skill_ids', vcr: vcr do
    let(:times) { 10 }
    let(:skill_ids) { [1, 2] }

    include_examples 'fetches projects'
    include_examples 'fetches projects data'

    context 'with cached request' do
      let(:times) { 0 }

      before { described_class.call(skill_ids, checked_at) }

      include_examples 'fetches projects'
      include_examples 'fetches projects data'
    end
  end

  context 'with published_at' do
    let(:checked_at) { { 1 => '2021-01-01 00:48:08 +0200'.to_time } }
    let(:times) { 0 }

    include_examples 'fetches projects'
  end

  context 'with skill_ids and published_at', vcr: vcr_checked_at do
    let(:skill_ids) { [1, 2] }
    let(:checked_at) { { 1 => '2020-12-30 00:48:08 +0200'.to_time } }
    let(:times) { 7 }

    include_examples 'fetches projects'
    include_examples 'fetches projects data'
  end
end
