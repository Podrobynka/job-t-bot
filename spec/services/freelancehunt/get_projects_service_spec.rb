# frozen_string_literal: true

require 'rails_helper'
vcr = { cassette_name: 'get_projects' }
vcr_skills = { cassette_name: 'get_projects_skills_1_2' }
vcr_published_at = { cassette_name: 'get_projects_published_at' }
vcr_skills_published_at = { cassette_name: 'get_projects_skills_published_at' }

RSpec.describe Freelancehunt::GetProjectsService, :aggregate_failures, vcr: vcr do
  let(:skill_ids) { [] }
  let(:published_at) { nil }
  subject { described_class.call(skill_ids, published_at) }

  shared_examples 'fetches projects' do
    it 'performs call to external API' do
      expect(RestClient).to receive(:get).exactly(times).times.and_call_original
      subject
    end

    it 'returns arrey with skill ids and names' do
      expect(subject).to be_an(Array)
      expect(subject.first.keys).to contain_exactly(:id, :attributes, :links, :type)
    end
  end

  context 'without skill_ids and published_at' do
    let(:times) { 179 }

    include_examples 'fetches projects'
  end

  context 'with skill_ids', vcr: vcr_skills do
    let(:times) { 16 }

    context 'with skill_ids (array), without published_at' do
      let(:skill_ids) { [1, 2] }

      include_examples 'fetches projects'
    end

    context 'with skill_ids (string), without published_at' do
      let(:skill_ids) { '1,2' }

      include_examples 'fetches projects'
    end
  end

  context 'with published_at', vcr: vcr_published_at do
    let(:published_at) { '2020-12-06 00:48:08 +0200'.to_time }
    let(:times) { 19 }

    include_examples 'fetches projects'
  end

  context 'with skill_ids and published_at', vcr: vcr_skills_published_at do
    let(:skill_ids) { [1, 2] }
    let(:published_at) { '2020-12-06 00:48:08 +0200'.to_time }
    let(:times) { 4 }

    include_examples 'fetches projects'
  end
end
