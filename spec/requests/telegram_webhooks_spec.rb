# frozen_string_literal: true
require 'rails_helper'
require 'telegram/bot/rspec/integration/rails'
vcr = { cassette_name: 'get_skills' }
vcr_projects_by_skills = { cassette_name: 'new_projects_by_skills_1' }

RSpec.describe TelegramWebhooksController, telegram_bot: :rails do
  let(:skill_id) { 56 }
  let(:chat_id) { 456 }

  def reply
    bot.requests[:sendMessage].last
  end

  shared_examples 'shows keyboard' do
    it 'shows keyboard' do
      should respond_with_message message
      expect(reply[:reply_markup]).to be_present
    end
  end

  describe '#start!' do
    let(:message) do
      "Hi there!\nYou can get list of available commands with /help option.\n"
    end

    subject { -> { dispatch_command :start } }
    it { should respond_with_message message }
  end

  describe '#help!' do
    let(:message) do
      "Available cmds:\n/select_skills - Select your skills from the list to " \
      "receive updates.\n/delete_skills - Delete skills from your list.\n" \
      "/new_projects - Show new progects.\n/keyboard - Reload keyboard.\n" \
      "/help - Show list of commands.\n"
    end

    subject { -> { dispatch_command :help } }
    it { should respond_with_message message }
  end

  describe '#select_skills!', vcr: vcr do
    let(:message) { 'Select your skills:' }

    subject { -> { dispatch_command :select_skills } }
    include_examples 'shows keyboard'
  end

  describe '#delete_skills!', vcr: vcr do
    let(:message) { 'Delete skills:' }

    subject { -> { dispatch_command :delete_skills } }
    include_examples 'shows keyboard'
  end

  describe '#new_projects!' do
    subject { -> { dispatch_command :new_projects } }

    context 'when user didn\'t select skills' do
      let(:message) do
        "Please, select your skills to receive project updates.\n" \
        "You can do it with the following command: /select_skills\n"
      end

      it { should respond_with_message message }
    end

    context 'when user selected skills', vcr: vcr_projects_by_skills do
      let(:user) { create(:user, chat_id: chat_id) }

      context 'when user didn\'t check projects' do
        let!(:user_skill) { create(:user_skill, user: user) }
        let(:message) do
          "\u{1F4A1} Форма загрузки файлов с поддержкой .tiff на WP\n\u{1F4CD}" \
          " #php, #web_programming\n\u{1F680} https://freelancehunt.com/" \
          'project/forma-zagruzki-faylov-podderzhkoy-tiff/812694.html'
        end

        it { should respond_with_message message }
      end

      context 'when user checked projects' do
        let!(:user_skill) { create(:user_skill, user: user, checked_at: Time.now) }
        let(:message) do
          "Unfortunately, there are no new projects for your skills.\n" \
          "You can look up older ones: /all_projects\n"
        end

        it { should respond_with_message message }
      end
    end
  end

  describe '#all_projects!' do
    subject { -> { dispatch_command :all_projects } }

    context 'when user didn\'t select skills' do
      let(:message) do
        "Please, select your skills to receive project updates.\n" \
        "You can do it with the following command: /select_skills\n"
      end

      it { should respond_with_message message }
    end

    context 'when user selected skills', vcr: vcr_projects_by_skills do
      let(:user) { create(:user, chat_id: chat_id) }
      let!(:user_skill) { create(:user_skill, user: user) }

      context 'when user didn\'t check projects' do
        let(:message) do
          "\u{1F4A1} Форма загрузки файлов с поддержкой .tiff на WP\n\u{1F4CD}" \
          " #php, #web_programming\n\u{1F680} https://freelancehunt.com/" \
          'project/forma-zagruzki-faylov-podderzhkoy-tiff/812694.html'
        end

        it { should respond_with_message message }
      end
    end
  end

  describe '#keyboard!' do
    subject { -> { dispatch_command :keyboard } }
    it 'shows keyboard' do
      should respond_with_message 'Select something with keyboard:'
      expect(reply[:reply_markup]).to be_present
    end

    context 'when keyboard button selected' do
      subject { -> { dispatch_message 'Smth' } }
      before { dispatch_command :keyboard }
      it { should respond_with_message "You've selected: Smth" }
    end
  end

  describe '#select_skill_callback_query', :select_skill_callback_query, vcr: vcr do
    let(:data) { { select_skill_callback_query: skill_id }.to_json }

    shared_examples 'one user_skill exists' do
      it 'creates user skill' do
        should edit_current_message(:text, text: 'Select your skills:')
        expect(UserSkill.count).to eq(1)
      end
    end

    context 'when no user_skill exists' do
      include_examples 'one user_skill exists'
    end

    context 'when user_skill exists' do
      let(:user) { create(:user, chat_id: chat_id) }
      let!(:user_skill) { create(:user_skill, user: user, skill_id: skill_id) }

      include_examples 'one user_skill exists'
    end
  end

  describe '#delete_skill_callback_query', :delete_skill_callback_query, vcr: vcr do
    let(:data) { { delete_skill_callback_query: skill_id }.to_json }
    let(:user) { create(:user, chat_id: chat_id) }
    let!(:user_skill) { create(:user_skill, user: user, skill_id: skill_id) }

    it 'deletes user skill' do
      should edit_current_message(:text, text: 'Delete skills:')
      expect(UserSkill.count).to eq(0)
    end
  end
end
