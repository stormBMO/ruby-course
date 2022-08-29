# frozen_string_literal: true

# User class
class User
  attr_reader :name, :birth_date, :sex, :home_number
  attr_accessor :phone_number, :status, :address

  def initialize(name, surname, patronymic, phone_number, home_number, address, birth_date, sex, status)
    @name = name
    @surname = surname
    @patronymic = patronymic
    @phone_number = phone_number
    @home_number = home_number
    @address = address
    @birth_date = birth_date
    @sex = sex
    @status = status
  end

  def to_s
    "Имя: #{@name}
    Фамилия:#{@surname}
    Отчество:#{@patronymic}
    Мобильный телефой:#{@phone_number}
    Домашний телефон:#{@home_number}
    Адрес:#{@address}
    Дата рождения:#{@birth_date}
    Пол:#{@sex}
    Статус:#{@status}"
  end

  def to_hash
    {
      name: @name,
      surname: @surname,
      patronymic: @patronymic,
      phone_number: @phone_number,
      home_number: @home_number,
      address: @address,
      birth_date: @birth_date,
      sex: @sex,
      status: @status
    }
  end
end
