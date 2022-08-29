# frozen_string_literal: true

require 'json'
require 'tty-prompt'
require_relative 'user'

# UsersStorage class
class UsersStorage
  INVITES_LIB = 'invites/'

  def initialize
    @prompt = TTY::Prompt.new
    @users = []
    @file_path = ''
  end

  def read_from_json(path)
    @file_path = path
    file = JSON.parse(File.read(@file_path))
    file.each do |user|
      new_user = User.new(user['name'],
                          user['surname'],
                          user['patronymic'],
                          user['phone_number'],
                          user['home_number'],
                          user['address'],
                          user['birth_date'],
                          user['sex'],
                          user['status'])
      @users.append(new_user)
    end
  end

  def print_users
    @users.each_index { |i| puts "#{i + 1}. #{@users[i]}" }
  end

  def print_user(index)
    puts @users[index].to_s
  end

  def add_user
    name = @prompt.ask('Введите имя:', required: true)
    surname = @prompt.ask('Введите фамилию:', required: true)
    patronymic = @prompt.ask('Введите отчество (необязательно):')
    phone_number = @prompt.ask('Введите сотовый телефон:', required: true)
    home_number = @prompt.ask('Введите домашний телефон (необязательно):')
    address = @prompt.ask('Введите адрес (необязательно):')
    birth_date = @prompt.ask('Введите дата рождения (в формате ДД/ММ/ГГГГ):', convert: :date, required: true).to_s
    sex = @prompt.ask('Введите пол:', required: true)
    status = @prompt.ask('Введите статус:', required: true)
    user = User.new(name, surname, patronymic, phone_number, home_number, address, birth_date, sex, status)
    @users.append(user)
    puts 'Новый контакт добавлен!'
  end

  def delete_user
    index = @prompt.ask('Введите номер какого контакта, которого хотите удалить:', required: true, convert: :int)
    puts "Контакт \"#{@users[index - 1].name}\" удален"
    @users.delete_at(index - 1)
  end

  def edit_users_phone_number(index)
    return if index > @users.size - 1

    puts "Текущий номер контакта #{@users[index].name}: #{@users[index].phone_number}\nХотите ли вы его изменить?"
    loop do
      ans = @prompt.ask('Введите у/n - да/нет', required: true)
      break if ans == 'y'
      return if ans == 'n'
    end

    number = @prompt.ask('Введите новый номер:')
    @users[index].phone_number = number
    puts 'Номер успешно изменен!'
  end

  def edit_users_status(index)
    return if index > @users.size - 1

    puts "Текущий статус контакта #{@users[index].name}: #{@users[index].status}\nХотите ли вы его изменить?"
    loop do
      ans = @prompt.ask('Введите у/n - да/нет', required: true)
      break if ans == 'y'
      return if ans == 'n'
    end

    status = @prompt.ask('Введите новый статус:')
    @users[index].status = status
    puts 'Статус успешно изменен!'
  end

  def edit_users_address(index)
    return if index > @users.size - 1

    puts "Текущий адрес контакта #{@users[index].name}: #{@users[index].address}\nХотите ли вы его изменить?"
    loop do
      ans = @prompt.ask('Введите у/n - да/нет', required: true)
      break if ans == 'y'
      return if ans == 'n'
    end

    address = @prompt.ask('Введите новый адрес:')
    @users[index].address = address
    puts 'Адрес успешно изменен!'
  end

  def group_by_birth_month
    birth_hash = Hash.new(0)
    @users.each do |user|
      birth_hash[user.birth_date[5...7]] = [] unless birth_hash.key?(user.birth_date[5...7])
      birth_hash[user.birth_date[5...7]].append(user)
    end
    birth_hash.each_key do |month|
      puts "В #{month} месяце родились следующие контакты:"
      birth_hash[month].each { |user| puts user.to_s }
    end
  end

  def invite_text(name, event)
    "Дорогой(ая) #{name}, приглашаю тебя на событие #{event}"
  end

  def make_invites(status_hash)
    chosen_status = @prompt.ask('Введите статус людей, для кого вы хотите оформить приглашения:', required: true)
    name_event = @prompt.ask('Введите название события:', required: true)
    name_file = @prompt.ask('Введите название файла, где будут написаны все приглашенные лица:', required: true)
    dir_name = "#{name_event}_#{name_file}"
    Dir.mkdir(INVITES_LIB + dir_name) unless Dir.exist?(INVITES_LIB + dir_name)
    list_of_invited = File.new("#{INVITES_LIB}#{dir_name}/#{name_file}.txt", 'w')
    list_of_invited.puts("Список приглашенных на событие #{name_event}")
    status_hash[chosen_status].each do |user|
      list_of_invited.puts("#{user.name}:#{user.phone_number}")
      invite = File.new("#{INVITES_LIB}#{dir_name}/#{user.name}#{name_event}.txt", 'w')
      invite.puts(invite_text(user.name, name_event))
      invite.close
    end
    list_of_invited.close
  end

  def group_by_status
    status_hash = Hash.new(0)
    @users.each do |user|
      status_hash[user.status] = [] unless status_hash.key?(user.status)
      status_hash[user.status].append(user)
    end
    puts 'Вот все статусы у ваших контактов:'
    status_hash.each_key { |status| puts status }
    make_invites(status_hash)
  end

  def show_number_of_users
    puts "Общее число контактов: #{@users.size}"
  end

  def show_number_of_each_sex
    male = 0
    female = 0
    @users.each do |user|
      case user.sex.downcase
      when 'мужской'
        male += 1
      when 'женский'
        female += 1
      else
        next
      end
    end
    puts "Количество человек мужского пола: #{male}"
    puts "Количество человек женского пола: #{female}"
  end

  def show_age_stats
    under20 = 0
    above20under30 = 0
    above30under40 = 0
    above40 = 0
    @users.each do |user|
      users_birth = Date.parse(user.birth_date)
      under20 += 1 if get_age(users_birth) < 20
      above20under30 += 1 if (get_age(users_birth) >= 20) && (get_age(users_birth) < 30)
      above30under40 += 1 if (get_age(users_birth) >= 30) && (get_age(users_birth) < 40)
      above40 += 1 if get_age(users_birth) >= 40
    end
    puts "Количество контактов младше 20 лет на данный момент: #{under20}"
    puts "Количество контактов от 20 до 30 лет на данный момент: #{above20under30}"
    puts "Количество контактов от 30 до 40 лет на данный момент: #{above30under40}"
    puts "Количество контактов старше 40 лет на данный момент: #{above40}"
  end

  def get_age(birth)
    now = Time.now.utc.to_date
    now.year - birth.year - (now.month > birth.month || (now.month == birth.month && now.day >= birth.day) ? 0 : 1)
  end

  def show_status_stats
    status_hash = Hash.new(0)
    @users.each do |user|
      if status_hash.key?(user.status)
        status_hash[user.status] += 1
      else
        status_hash[user.status] = 1
      end
    end
    status_hash.each_pair do |status, count|
      puts "Количество людей статус #{status} - #{count}"
    end
  end

  def show_unnecessary_stats
    home_number = 0
    address = 0
    @users.each do |user|
      home_number += 1 unless user.home_number.nil?
      address += 1 unless user.address.nil?
    end
    puts "Количество людей с заполненным полем \"Домашний телефон\" - #{home_number}"
    puts "Количество людей с заполненным полем \"Адрес\" - #{address}"
  end

  def load_to_json
    File.delete(@file_path)
    temp_array_of_users = []
    @users.each { |user| temp_array_of_users.append(user.to_hash) }
    File.open(@file_path, 'w') do |f|
      f.write(JSON.pretty_generate(temp_array_of_users))
    end
  end
end
