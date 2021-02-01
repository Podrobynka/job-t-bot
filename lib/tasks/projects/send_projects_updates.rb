# frozen_string_literal: true

module Tasks
  module Projects
    class SendProjectsUpdates
      def initialize
        @last_check = Time.now - 1.day
      end

      def call
        projects.each do |p|
          skill_ids = p.dig(:attributes, :skills)&.pluck(:id)
          created_at = p.dig(:attributes, :published_at)

          send_updates(p, chat_ids(skill_ids, created_at))
        end

        UserSkill.update_all(checked_at: Time.now)
      end

      private

      attr_reader :last_check

      def projects
        @projects ||=
          Freelancehunt::GetProjectsService.call(skill_ids, last_check)
      end

      def skill_ids
        UserSkill.all.distinct.pluck(:skill_id)
      end

      def chat_ids(skill_ids, created_at)
        User.joins(:user_skills)
            .where(user_skills: { skill_id: skill_ids })
            .where('checked_at <= ?', created_at.to_time)
            .pluck(:chat_id)
      end

      def send_updates(project, chats)
        chats.each do |chat|
          Telegram.bot.send_message(chat_id: chat,
                                    text: Adapters::Projects.call([project])[0])
        end
      end
    end
  end
end
