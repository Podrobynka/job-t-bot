# frozen_string_literal: true

desc 'This task is called by the Heroku scheduler add-on'
task send_projects_updates: :environment do
  puts 'Sending projects updates...'
  Tasks::Projects::SendProjectsUpdates.new.call
  puts 'done.'
end
