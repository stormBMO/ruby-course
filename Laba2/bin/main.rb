# frozen_string_literal: true

require_relative '../lib/menu'
require_relative '../lib/usersstorage'

def main
  menu = Menu.new
  menu.show
end

main if __FILE__ == $PROGRAM_NAME
