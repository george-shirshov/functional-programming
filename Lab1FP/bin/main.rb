# frozen_string_literal: true

# require 'tty-prompt'

require_relative '..\lib\menu'

def main
  Menu.new
end

main if __FILE__ == $PROGRAM_NAME
