# frozen_string_literal: true

module Freelancehunt
  class GetProjectsService < Freelancehunt::BaseApiService
    GET_PROJECTS = 'https://api.freelancehunt.com/v2/projects?filter[skill_id]' \
                  '=%<skill_ids>s'

    def initialize(skill_ids, published_at = nil)
      @skill_ids = skill_ids.is_a?(Array) ? skill_ids.join(',') : skill_ids
      @published_at = published_at
    end

    def call
      response = { links: { next: format(GET_PROJECTS, skill_ids: skill_ids) } }
      projects = []

      fetch_projects(response, projects)
    end

    private

    attr_reader :skill_ids, :published_at

    def fetch_projects(response, projects)
      loop do
        break unless response[:links][:next]

        response = request(response[:links][:next])
        f_projects = fresh_projects(response[:data])
        break if f_projects.empty?

        projects.concat(f_projects)
      end

      projects
    end

    def fresh_projects(data)
      return data unless published_at

      data.select { |h| h[:attributes][:published_at].to_time >= published_at }
    end
  end
end
