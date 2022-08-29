# frozen_string_literal: true

require 'tty-prompt'
require 'date'
require_relative 'usersstorage'

# Menu class
class Menu
  MENU = [
    { name: 'Открыть контакты', value: :contacts },
    { name: 'Добавить|Изменить|Удалить контакт', value: :add_edit_delete },
    { name: 'Сгруппировать дни рождения', value: :group_birthdays },
    { name: 'Создать приглашение на событие по статусам', value: :group_status },
    { name: 'Статистика', value: :stats },
    { name: 'Завершить работу', value: :close }
  ].freeze

  EDIT_MENU = [
    { name: 'Изменить номер', value: :edit_number },
    { name: 'Изменить статус', value: :edit_status },
    { name: 'Изменить адрес', value: :edit_address },
    { name: 'Назад', value: :back }
  ].freeze

  CONTACT_MENU = [
    { name: 'Добавить контакт', value: :add },
    { name: 'Изменить контакт', value: :edit },
    { name: 'Удалить контакт', value: :delete },
    { name: 'Назад', value: :back }
  ].freeze

  STATS_MENU = [
    { name: 'Общая статистика', value: :full_stats },
    { name: 'Статистика по возрасту', value: :age_stats },
    { name: 'Статистика по полу', value: :sex_stats },
    { name: 'Статистика по статусам', value: :status_stats },
    { name: 'Статистика контактов с указанным домашним номером|адресом', value: :unnecessary_stats },
    { name: 'Назад', value: :back }
  ].freeze

  def initialize
    @contacts = UsersStorage.new
    @contacts.read_from_json(File.expand_path('../data/phone_book.json', __dir__))
    @prompt = TTY::Prompt.new
  end

  #----------Main menu section---------------
  def show
    loop do
      action = @prompt.select('Выберите действие', MENU)
      if action == :close
        @contacts.load_to_json
        break
      end
      @contacts.print_users if action == :contacts
      add_edit_delete_show if action == :add_edit_delete
      @contacts.group_by_birth_month if action == :group_birthdays
      @contacts.group_by_status if action == :group_status
      stats_show if action == :stats
    end
  end

  def add_edit_delete_show
    loop do
      action = @prompt.select('Выберите действие', CONTACT_MENU)

      break if action == :back

      @contacts.add_user if action == :add
      edit_show if action == :edit
      @contacts.delete_user if action == :delete
    end
  end

  #----------Edit menu section---------------

  def edit_action(index, type)
    case type
    when 'number'
      @contacts.edit_users_phone_number(index - 1)
    when 'status'
      @contacts.edit_users_status(index - 1)
    when 'address'
      @contacts.edit_users_address(index - 1)
    end
  end

  def edit_show
    index = @prompt.ask('Введите индекс контакта, которого хотите изменить:', convert: :int)
    loop do
      @contacts.print_user(index)
      action = @prompt.select('Выберите действие', EDIT_MENU)
      break if action == :back

      edit_action(index, 'number') if action == :edit_number
      edit_action(index, 'status') if action == :edit_status
      edit_action(index, 'address') if action == :edit_address
    end
  end

  #----------Stats menu section--------------

  def stats_show
    loop do
      action = @prompt.select('Выберите действие', STATS_MENU)
      break if action == :back

      @contacts.show_number_of_users if action == :full_stats
      @contacts.show_age_stats if action == :age_stats
      @contacts.show_number_of_each_sex  if action == :sex_stats
      @contacts.show_status_stats if action == :status_stats
      @contacts.show_unnecessary_stats  if action == :unnecessary_stats
    end
  end
end
