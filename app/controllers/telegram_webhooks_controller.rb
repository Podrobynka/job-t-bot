# frozen_string_literal: true

class TelegramWebhooksController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  include Telegram::Bot::UpdatesController::CallbackQueryContext

  def start!(*)
    user
    respond_with :message, text: t('.content')
  end

  def help!(*)
    respond_with :message, text: t('.content')
  end

  def select_skills!(*)
    respond_with :message, text: t('.prompt'), reply_markup: {
      inline_keyboard: skills_list(UserSkills::NotUserSkillsService.call(user), 'select_skill_')
    }
  end

  def delete_skills!(*)
    respond_with :message, text: t('.prompt'), reply_markup: {
      inline_keyboard: skills_list(UserSkills::UserSkillsService.call(user), 'delete_skill_')
    }
  end

  def new_projects!(*)
    last_time = session.delete(:projects_check_time)
    session[:projects_check_time] =
      user_skills_ids.each_with_object({}) { |s_id, h| h[s_id] = Time.now }

    show_projects('new_projects', last_time)
  end

  def all_projects!(*)
    show_projects('all_projects')
  end

  def keyboard!(value = nil, *)
    if value
      respond_with :message, text: t('.selected', value: value)
    else
      save_context :keyboard!
      respond_with :message, text: t('.prompt'), reply_markup: {
        keyboard: [t('.buttons')],
        resize_keyboard: true,
        one_time_keyboard: true,
        selective: true
      }
    end
  end

  def callback_query(data)
    send(*JSON.parse(data, symbolize_names: true).to_a.first)
  end

  def select_skill_callback_query(skill_id)
    UserSkills::CreateService.call(user, skill_id)

    bot.edit_message_text(
      chat_id: chat['id'],
      message_id: payload.dig('message', 'message_id'),
      text: t('.select_skills.prompt'),
      reply_markup: {
        inline_keyboard: skills_list(UserSkills::NotUserSkillsService.call(user), 'select_skill_')
      }
    )
  end

  def delete_skill_callback_query(skill_id)
    UserSkills::DeleteService.call(user, skill_id)

    bot.edit_message_text(
      chat_id: chat['id'],
      message_id: payload.dig('message', 'message_id'),
      text: t('.delete_skills.prompt'),
      reply_markup: {
        inline_keyboard: skills_list(UserSkills::UserSkillsService.call(user), 'delete_skill_')
      }
    )
  end

  private

  def user
    @user ||= User.find_or_create_by(chat_id: chat['id'])
  end

  def skills_list(skills, action_key = nil)
    skills_list = []
    skills.map do |skill|
      skills_list << {
        text: skill[:name],
        callback_data: { "#{action_key}callback_query": skill[:id] }.to_json
      }
    end

    skills_list.each_slice(2).to_a
  end

  def show_skill(id)
    GetSkillsService.call.select { |skill| skill[:id] == id }.first
  end

  def user_skills_ids
    user.user_skills.pluck(:skill_id)
  end

  def projects(date = nil)
    if date.is_a?(Hash)
      Freelancehunt::GetProjectsBySkillsService.call(user_skills_ids, date)
    else
      Freelancehunt::GetProjectsService.call(user_skills_ids, date)
    end
  end

  def project(item)
    [item.dig(:attributes, :name), "\n",
     item.dig(:attributes, :skills).pluck(:name).join(', '), "\n",
     item.dig(:links, :self, :web)].join
  end

  def show_projects(action_key, date = nil)
    if user_skills_ids.empty?
      respond_with :message, text: t(".#{action_key}.no_skills_selected")
    elsif projects(date).empty?
      respond_with :message, text: t(".#{action_key}.no_projects")
    else
      projects(date).each do |pr|
        respond_with :message, text: project(pr)
      end
    end
  end
end
