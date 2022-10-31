# frozen_string_literal: true

require 'tty-prompt'

require_relative '..\lib\menu'

def main
  prompt = TTY::Prompt.new
  menu = Menu.new
  loop do
    choice = prompt.enum_select('Выберите пункт из меню', Menu::MENU_ITEM)
    case choice
    when 'Добавить книгу'
      menu.add_book
    when 'Добавить читателя'
      menu.add_reader
    when 'Удалить читателя'
      menu.remove_reader
    when 'Удалить книгу из базы'
      menu.remove_book_from_library
    when 'Подобрать книги читателю'
      menu.pick_up_books_for_reader
    when 'Выдать книгу читателю'
      menu.give_book_reader
    when 'Вернуть книгу'
      menu.return_book
    when 'Вывести книги заданного жанра'
      menu.show_books_by_genre
    when 'Вывести все книги'
      menu.show_not_returned_books
    when 'Завершить работу'
      break
    end
  end
end

main if __FILE__ == $PROGRAM_NAME
