# frozen_string_literal: true

# A class describing a library that contains a list of books
# and a list of readers
class Library
  attr_accessor :books, :readers

  def initialize(readers = [], books = [])
    @readers = readers
    @books = books
  end

  def add_book(books, book_obj)
    books_clone = books.clone
    book = Book.new(book_obj[:author],
                    book_obj[:name], book_obj[:inventory_number],
                    book_obj[:genre],
                    book_obj[:age_rating], book_obj[:number_books],
                    book_obj[:number_borrowed_books])
    books_clone.append(book)
  end

  def add_reader(readers, reader_obj)
    readers_clone = readers.clone
    reader = Reader.new(reader_obj[:surname], reader_obj[:name],
                        reader_obj[:patronymic], reader_obj[:date_birth],
                        reader_obj[:list_books])
    readers_clone.append(reader)
  end

  def decrease_borrowed_books(books, readers, full_name_reader, name_book = '')
    books_clone = books.clone

    borrowed_books = borrowed_books_reader(readers, full_name_reader)
    pp borrowed_books
    books_clone.each do |book|
      borrowed_books.each do |borrowed_book|
        unless book.name == borrowed_book.name && book.name.include?(name_book)
          next
        end

        book.number_borrowed_books =
          book.decrease_borrowed_books(book.number_borrowed_books)
      end
    end
  end

  def borrowed_books_reader(readers, full_name_reader)
    readers.each do |reader|
      if reader.full_name(reader.surname,
                          reader.name,
                          reader.patronymic,
                          reader.date_birth) == full_name_reader
        return reader.list_borrowed_books(reader)
      end
    end
  end

  def delete_reader(readers, full_name_reader)
    readers_clone = readers.clone
    readers_clone.delete_if do |reader|
      reader.full_name(reader.surname,
                       reader.name,
                       reader.patronymic,
                       reader.date_birth) == full_name_reader
    end
  end

  def delete_book(books, name_book)
    books_clone = books.clone
    books_clone.delete_if do |book|
      book.name == name_book
    end
  end

  def delete_books_from_readers(readers, name_book)
    readers_clone = readers.clone
    readers_clone.each do |reader|
      reader.list_books.each do |_date, books|
        books.delete_if { |book| book.name == name_book }
      end
    end
  end

  def pick_up_books_by_genre(books, readers, full_name_reader, genre,
                             date_today)
    age_rating = age_rating_reader(readers, full_name_reader, date_today)

    books = books.select do |book|
      book.genre == genre && book.age_rating <= age_rating
    end

    all_name_books(books)
  end

  def pick_up_books_by_author(books, readers, full_name_reader, author,
                              date_today)
    age_rating = age_rating_reader(readers, full_name_reader, date_today)

    books = books.select do |book|
      book.author == author && book.age_rating <= age_rating
    end

    all_name_books(books)
  end

  def add_book_reader(readers, books, full_name_reader, name_book, date_today)
    book = find_book(books, name_book)
    readers_clone = readers.clone
    readers_clone.each do |reader|
      next unless reader.full_name(reader.surname,
                                   reader.name,
                                   reader.patronymic,
                                   reader.date_birth) == full_name_reader

      reader.list_books = reader.add_book(reader.list_books,
                                          date_today, book)
    end
  end

  def give_out_book(books, name_book)
    books_clone = books.clone
    books_clone.each do |book|
      next unless book.name == name_book

      book.number_borrowed_books =
        book.increase_borrowed_books(book.number_borrowed_books)
    end
  end

  def return_book(_books, readers, full_name_reader, name_book)
    readers_clone = readers.clone
    readers_clone.each do |reader|
      next unless reader.full_name(reader.surname,
                                   reader.name,
                                   reader.patronymic,
                                   reader.date_birth) == full_name_reader

      reader.list_books = reader.delete_book(reader.list_books,
                                             name_book)
    end
  end

  def calculate_cost_delay_book(readers, full_name_reader, name_book,
                                date_today)
    reader = find_reader(readers, full_name_reader)

    reader.list_books.each do |date, books|
      books.each do |book|
        next unless book.name == name_book

        return calculate_cost_delay(date_today, Date.parse(date))
      end
    end
  end

  def sorted_books_by_genre(books, genre)
    books_by_genre = books_by_genre(books, genre)

    sort_books(books_by_genre)
  end

  def books_by_genre(books, genre)
    books.select do |book|
      book.genre == genre
    end
  end

  def sort_books(books)
    books.sort_by do |book|
      [book.surname_author(book.author), book.name]
    end
  end

  def not_returned_books(readers, return_date)
    not_returned_books = []
    readers.each do |reader|
      reader.list_books.each do |date, books|
        not_returned_books += books if date <= return_date
      end
    end

    not_returned_books
  end

  def all_uniq_books(books)
    books.uniq(&:name)
  end

  def available_books(books)
    available_books = books.select do |book|
      book.number_books > book.number_borrowed_books
    end

    all_name_books(available_books)
  end

  def all_name_books(books)
    books.map(&:name)
  end

  def all_readers(readers)
    readers.map do |reader|
      reader.full_name(reader.surname, reader.name,
                       reader.patronymic, reader.date_birth)
    end
  end

  def all_genre(books)
    books.map(&:genre).uniq
  end

  def all_author(books)
    books.map(&:author).uniq
  end

  private

  def age_rating_reader(readers, full_name_reader, date_today)
    readers.each do |reader|
      return reader.age(date_today, reader.date_birth) if reader.full_name(
        reader.surname,
        reader.name,
        reader.patronymic,
        reader.date_birth
      ) == full_name_reader
    end
  end
end

def calculate_cost_delay(date_today, return_date)
  difference_date = (date_today - return_date).to_i
  return 0 if difference_date.negative?

  difference_date
end

def find_reader(readers, full_name_reader)
  readers.each do |reader|
    return reader if reader.full_name(reader.surname,
                                      reader.name,
                                      reader.patronymic,
                                      reader.date_birth) == full_name_reader
  end
end

def find_book(books, name_book)
  books.each do |book|
    return book if book.name == name_book
  end
end
