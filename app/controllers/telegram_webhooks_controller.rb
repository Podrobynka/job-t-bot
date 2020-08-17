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
    # binding.pry
    respond_with :message, text: t('.prompt'), reply_markup: {
      inline_keyboard: skills_list(all_skills)
    }
  end

  def delete_skills!(*)
    # binding.pry
    respond_with :message, text: t('.prompt'), reply_markup: {
      inline_keyboard: skills_list(user_skills)
    }
  end

  def memo!(*args)
    if args.any?
      session[:memo] = args.join(' ')
      respond_with :message, text: t('.notice')
    else
      respond_with :message, text: t('.prompt')
      save_context :memo!
    end
  end

  def remind_me!(*)
    to_remind = session.delete(:memo)
    reply = to_remind || t('.nothing')
    respond_with :message, text: reply
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

  def inline_keyboard!(*)
    respond_with :message, text: t('.prompt'), reply_markup: {
      inline_keyboard: [
        [
          { text: t('.alert'), callback_data: 'alert' },
          { text: t('.no_alert'), callback_data: 'no_alert' }
        ],
        [{ text: t('.repo'), url: 'https://github.com/telegram-bot-rb/telegram-bot' }]
      ]
    }
  end

  def callback_query(data)
    send(*JSON.parse(data, symbolize_names: true).to_a.first)
  end

  def select_skill_callback_query(skill_id)
    create_user_skills(skill_id)
    answer_callback_query("#{show_skill(skill_id)[:name]} added to list",
                          show_alert: true)
  end

  def delete_skill_callback_query(skill_id)
    delete_user_skills(skill_id)
    answer_callback_query("#{show_skill(skill_id)[:name]} deleted from list",
                          show_alert: true)
  end

  def message(message)
    respond_with :message, text: t('.content', text: message['text'])
  end

  def inline_query(query, _offset)
    query = query.first(10) # it's just an example, don't use large queries.
    t_description = t('.description')
    t_content = t('.content')
    results = Array.new(5) do |i|
      {
        type: :article,
        title: "#{query}-#{i}",
        id: "#{query}-#{i}",
        description: "#{t_description} #{i}",
        input_message_content: {
          message_text: "#{t_content} #{i}"
        }
      }
    end
    answer_inline_query results
  end

  # As there is no chat id in such requests, we can not respond instantly.
  # So we just save the result_id, and it's available then with `/last_chosen_inline_result`.
  def chosen_inline_result(result_id, _query)
    session[:last_chosen_inline_result] = result_id
  end

  def last_chosen_inline_result!(*)
    result_id = session[:last_chosen_inline_result]
    if result_id
      respond_with :message, text: t('.selected', result_id: result_id)
    else
      respond_with :message, text: t('.prompt')
    end
  end

  def action_missing(action, *_args)
    if action_type == :command
      respond_with :message,
                   text: t('telegram_webhooks.action_missing.command', command: action_options[:command])
    else
      respond_with :message, text: t('telegram_webhooks.action_missing.feature', action: action)
    end
  end

  private

  def user
    @user ||= User.find_or_create_by(chat_id: chat['id'])
  end

  def skills_list(skills)
    skills_list = []
    skills.map do |skill|
      skills_list << {
        text: skill[:name],
        callback_data: { select_skill_callback_query: skill[:id] }.to_json
      }
    end

    skills_list.each_slice(2).to_a
  end

  def all_skills
    @all_skills ||= GetSkillsService.call
  end

  def user_skills
    binding.pry
    all_skills.select { |el| user.user_skills.pluck(:skill_id).include?(el[:id]) }
  end

  def show_skill(id)
    all_skills.select { |skill| all_skills[:id] == id }.first
  end

  def create_user_skills(skill_id)
    user.user_skills.find_or_create_by(skill_id: skill_id)
  end

  def delete_user_skills(skill_id)
    user.user_skills.find(skill_id: skill_id).delete
  end
end
