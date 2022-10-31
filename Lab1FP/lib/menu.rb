# frozen_string_literal: true

require 'tty-prompt'

require_relative 'reader_files'
require_relative 'library'

# Class that defines the application menu
class Menu
  def initialize
    library = ReaderFiles.read
    prompt = TTY::Prompt.new
    start(library, prompt)
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

  def add_book(library, prompt)
    library = Marshal.load(Marshal.dump(library))
    book = authorize_book(prompt)
    book[:number_borrowed_books] = 0
    library.books = library.add_book(library.books, book)
    library
  end

  def add_reader(library, prompt)
    library = Marshal.load(Marshal.dump(library))
    reader = authorize_reader(prompt)
    reader[:list_books] = []
    reader[:date_birth] = reader[:date_birth].strftime
    library.readers = library.add_reader(library.readers, reader)
    library
  end

  def delete_reader(library, prompt)
    library = Marshal.load(Marshal.dump(library))
    full_name_reader = prompt.enum_select('Выберите читателя',
                                          library.all_readers(
                                            library.readers
                                          ))

    library.books = library.decrease_borrowed_books(
      library.books,
      library.readers,
      full_name_reader
    )

    library.readers = library.delete_reader(library.readers, full_name_reader)
    library
  end

  def delete_book(library, prompt)
    library = Marshal.load(Marshal.dump(library))
    name_book = prompt.enum_select('Какую книгу удалить?',
                                   library.all_name_books(
                                     library.books
                                   ))

    library.books = library.delete_book(library.books, name_book)

    library.readers = library.delete_books_from_readers(
      library.readers,
      name_book
    )
    library
  end

  def pick_up_books_for_reader(library, prompt)
    library = Marshal.load(Marshal.dump(library))
    full_name_reader = prompt.enum_select('Выберите читателя',
                                          library.all_readers(
                                            library.readers
                                          ))
    choice = prompt.enum_select('Выбор', ['по жанру', 'по автору'])
    date_today = Date.today
    if choice == 'по жанру'
      genre = prompt.enum_select('Выберите жанр',
                                 library.all_genre(library.books))
      library.pick_up_books_by_genre(library.books,
                                     library.readers,
                                     full_name_reader, genre, date_today)
    else
      author = prompt.enum_select('Выберите автора?',
                                  library.all_author(library.books))
      library.pick_up_books_by_author(library.books, library.readers,
                                      full_name_reader, author,
                                      date_today)
    end
  end

  def give_book_reader(library, prompt)
    library = Marshal.load(Marshal.dump(library))
    full_name_reader = prompt.enum_select('Выберите читателя',
                                          library.all_readers(
                                            library.readers
                                          ))

    name_book = prompt.enum_select('Выберите книгу',
                                   library.available_books(
                                     library.books
                                   ))
    date_today = Date.today.strftime
    library.readers = library.add_book_reader(library.readers,
                                              library.books,
                                              full_name_reader,
                                              name_book,
                                              date_today)
    library.books = library.give_out_book(library.books, name_book)
    library
  end

  def return_book(library, prompt)
    library = Marshal.load(Marshal.dump(library))
    full_name_reader = prompt.enum_select('Выберите читателя',
                                          library.all_readers(
                                            library.readers
                                          ))
    borrowed_books = library.borrowed_books_reader(library.readers,
                                                   full_name_reader)
    name_book = prompt.enum_select('Какую книгу хотите вернуть?',
                                   borrowed_books).name

    library.books = library.decrease_borrowed_books(library.books,
                                                    library.readers,
                                                    full_name_reader)

    cost = library.calculate_cost_delay_book(library.readers,
                                             full_name_reader,
                                             name_book, Date.today)

    library.readers = library.return_book(library.books, library.readers,
                                          full_name_reader, name_book)
    {
      library: library,
      cost: cost
    }
  end

  def show_books_by_genre(library, prompt)
    library = Marshal.load(Marshal.dump(library))
    genre = prompt.enum_select('Введите жанр',
                               library.all_genre(library.books))

    library.sorted_books_by_genre(library.books, genre)
  end

  def show_not_returned_books(library, prompt)
    library = Marshal.load(Marshal.dump(library))
    return_date = prompt.ask('Введите дату: ', convert: :date) do |q|
      q.messages[:convert?] = 'Дата некорректная'
    end.strftime
    not_returned_books = library.not_returned_books(library.readers,
                                                    return_date)
    library.all_uniq_books(not_returned_books)
  end

  private

  def start(library, prompt)
    loop do
      choice = prompt.enum_select('Выберите пункт из меню', MENU_ITEM)
      case choice
      when 'Добавить книгу'
        library = add_book(library, prompt)
      when 'Добавить читателя'
        library = add_reader(library, prompt)
      when 'Удалить читателя'
        library = delete_reader(library, prompt)
      when 'Удалить книгу из базы'
        library = delete_book(library, prompt)
      when 'Подобрать книги читателю'
        puts pick_up_books_for_reader(library, prompt)
      when 'Выдать книгу читателю'
        library = give_book_reader(library, prompt)
      when 'Вернуть книгу'
        data = return_book(library, prompt)
        library = data[:library]
        puts "Вы должны оплатить штраф суммой: #{data[:cost]}руб"
      when 'Вывести книги заданного жанра'
        puts show_books_by_genre(library, prompt)
      when 'Вывести все книги'
        puts show_not_returned_books(library, prompt)
      when 'Завершить работу'
        break
      end
    end
  end

  def authorize_reader(prompt)
    prompt.collect do
      key(:name).ask('Ваше имя: ', required: true, modify: :strip) do |q|
        q.messages[:required?] = 'Имя не должно быть пустым'
      end
      key(:surname).ask('Ваша фамилия: ', required: true,
                                          modify: :strip) do |q|
        q.messages[:required?] = 'Фамилия не должна быть пустой'
      end
      key(:patronymic).ask('Ваше отчество: ', required: true,
                                              modify: :strip) do |q|
        q.messages[:required?] = 'Отчество не должно быть пустым'
      end
      key(:date_birth).ask('Дата рождения: ', convert: :date,
                                              required: true) do |q|
        q.messages[:required?] = 'Дата рождения не должна быть пустой'
        q.messages[:convert?] = 'Введите корректный возрастной рейтинг'
      end
    end
  end

  def authorize_book(prompt)
    prompt.collect do
      key(:author).ask('Автор книги: ', required: true, modify: :strip) do |q|
        q.messages[:required?] = 'Имя автора не должно быть пустым'
      end
      key(:name).ask('Название книги: ', required: true, modify: :strip) do |q|
        q.messages[:required?] = 'Название книги не должно быть пустым'
      end
      key(:genre).ask('Жанр книги: ', required: true, modify: :strip) do |q|
        q.messages[:required?] = 'Жанр книги не должн быть пустым'
      end
      key(:age_rating).ask('Возрастной рейтинг: ', convert: :int,
                                                   required: true) do |q|
        q.messages[:required?] = 'Возрастной рейтинг не должен быть пустым'
        q.messages[:convert?] = 'Введите корректный возрастной рейтинг'
      end
      key(:number_books).ask('Количество книг в библиотеке: ',
                             convert: :int,
                             required: true) do |q|
        q.messages[:required?] = 'Кол-во книг не должен быть пустым'
        q.messages[:convert?] = 'Введите корректное кол-во книг'
      end
      key(:inventory_number).ask('Инвентаризационный номер: ',
                                 required: true) do |q|
        q.messages[:required?] =
          'Инвентаризационный номер не должен быть пустым'
      end
    end
  end
end
