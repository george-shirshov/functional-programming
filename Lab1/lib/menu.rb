# frozen_string_literal: true

require 'tty-prompt'

require_relative 'reader_files'
require_relative 'library'

# Class that defines the application menu
class Menu
  def initialize
    @library = ReaderFiles.read
    @prompt = TTY::Prompt.new
  end

  MENU_ITEM = ['Добавить книгу',
               'Добавить читателя',
               'Удалить читателя',
               'Удалить книгу из базы',
               'Подобрать книги читателю',
               'Выдать книгу читателю',
               'Вернуть книгу',
               'Вывести книги заданного жанра',
               'Вывести все книги',
               'Завершить работу'].freeze

  
  def add_book
    book = authorize_book
    @library.add_new_book(book[:author], book[:name], book[:inventory_number],
                          book[:genre], book[:age_rating], book[:number_books])
  end

  def add_reader
    reader = authorize_reader
    @library.add_new_reader(reader[:surname], reader[:name],
                            reader[:patronymic], reader[:date_birth])
  end

  def remove_reader
    full_name_reader = @prompt.enum_select('Выберите читателя',
                                           @library.all_readers)
    @library.delete_reader(full_name_reader)
  end

  def remove_book_from_library
    name_book = @prompt.enum_select('Какую книгу удалить?',
                                    @library.all_name_books)
    @library.delete_book(name_book)
  end

  def pick_up_books_for_reader
    reader = authorize_reader
    if @library.reader?(reader[:surname], reader[:name], reader[:patronymic],
                        reader[:date_birth])
      choice = @prompt.enum_select('Выбор', ['по жанру', 'по автору'])
      if choice == 'по жанру'
        genre = @prompt.enum_select('Выберите жанр', @library.all_genre)
        puts '---------'
        puts @library.books_by_genre(reader[:surname], reader[:name],
                                     reader[:patronymic], reader[:date_birth],
                                     genre)
      else
        author = @prompt.enum_select('Выберите автора?', @library.all_author)
        puts '---------'
        puts @library.books_by_author(reader[:surname], reader[:name],
                                      reader[:patronymic], reader[:date_birth],
                                      author)
      end
      puts '---------'
    else
      puts 'Данного читателя не существует'
    end
  end

  def give_book_reader
    reader = authorize_reader
    if @library.reader?(reader[:surname], reader[:name], reader[:patronymic],
                        reader[:date_birth])
      name_book = @prompt.enum_select('Выберите книгу',
                                      @library.available_books)
      @library.add_book_reader(reader[:surname], reader[:name],
                               reader[:patronymic], reader[:date_birth],
                               name_book)
    else
      puts 'Данного читателя не существует'
    end
  end

  def return_book
    reader = authorize_reader
    if @library.reader?(reader[:surname], reader[:name], reader[:patronymic],
                        reader[:date_birth])
      borrowed_books = @library.books_reader(reader[:surname], reader[:name],
                                             reader[:patronymic],
                                             reader[:date_birth])
      name_book = @prompt.enum_select('Какую книгу хотите вернуть?',
                                      borrowed_books)
      puts "Вы должны оплатить штраф суммой: #{@library.return_book(
        reader[:surname], reader[:name], reader[:patronymic],
        reader[:date_birth], name_book
      )}руб"
    else
      puts 'Данного читателя не существует'
    end
  end

  def show_books_by_genre
    genre = @prompt.enum_select('Введите жанр', @library.all_genre)
    puts @library.show_books_by_genre(genre)
  end

  def show_not_returned_books
    return_date = @prompt.ask('Введите дату: ', convert: :date) do |q|
      q.validate(CheckValue::REG_DATE)
    end
    puts @library.show_not_returned_books(return_date)
  end

  private

  def authorize_reader
    @prompt.collect do
      key(:name).ask('Ваше имя: ', required: true, modify: :strip) do |q|
        q.messages[:required?] = "Имя не должно быть пустым"
      end
      key(:surname).ask('Ваша фамилия: ', required: true, modify: :strip) do |q|
        q.messages[:required?] = "Фамилия не должна быть пустой"
      end
      key(:patronymic).ask('Ваше отчество: ', required: true, modify: :strip) do |q|
        q.messages[:required?] = "Отчество не должно быть пустым"
      end
      key(:date_birth).ask('Дата рождения: ', convert: :date, required: true) do |q|
        q.messages[:required?] = "Дата рождения не должна быть пустой"
        q.messages[:convert?] = "Введите корректный возрастной рейтинг"     
      end
  end

  def authorize_book
    @prompt.collect do
      key(:author).ask('Автор книги: ', required: true, modify: :strip) do |q|
        q.messages[:required?] = "Имя автора не должно быть пустым"
      end
      key(:name).ask('Название книги: ', required: true, modify: :strip) do |q|
        q.messages[:required?] = "Название книги не должно быть пустым"
      end
      key(:genre).ask('Жанр книги: ', required: true, modify: :strip) do |q|
        q.messages[:required?] = "Жанр книги не должн быть пустым"
      end
      key(:age_rating).ask('Возрастной рейтинг: ', convert: :int, required: true) do |q|
        q.messages[:required?] = "Возрастной рейтинг не должен быть пустым"
        q.messages[:convert?] = "Введите корректный возрастной рейтинг"     
      end
      key(:number_books).ask('Количество книг в библиотеке: ', convert: :int, required: true) do |q|
        q.messages[:required?] = "Кол-во книг не должен быть пустым"
        q.messages[:convert?] = "Введите корректное кол-во книг"     
      end
      key(:inventory_number).ask('Инвентаризационный номер: ', required: true) do |q|
        q.messages[:required?] = "Инвентаризационный номер не должен быть пустым"  
      end
    end
  end
end
