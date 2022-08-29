# frozen_string_literal: true

require 'tty-prompt'
require_relative 'data_reader'
require_relative 'train_list'
require_relative 'train'
require_relative 'stop'

# DOC
class Menu
  def initialize
    @prompt = TTY::Prompt.new
    @train_list = DataReader.read_trains
  end
  MAIN_MENU_CHOICES = [
    { name: 'вывести расписание движения поездов', value: :rasp },
    { name: 'вывести список поездов, отсортировав по количнству остановок', value: :stops },
    { name: 'завершить работу приложения', value: :exit }
  ].freeze

  def show_menu
    loop do
      action = @prompt.select('выберите действие', MAIN_MENU_CHOICES)
      break if action == :exit

      show_rasp if action == :rasp
      show_stops if action == :stops
    end
  end

  def show_rasp
    train = @prompt.select('Выберите поезд') do |menu|
      @train_list.each_train do |train_choice|
        menu.choice(train_choice, train_choice)
      end
    end

    train.each_stop.with_index do |stop, index|
        puts "#{index}: #{stop}"    
    end
  end

  def show_stops
    @train_list.each_train_by_length do |train|
      puts "Остановки: #{train.stop_count} Маршрут: #{train} "
    end
  end
end
