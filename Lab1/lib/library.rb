# frozen_string_literal: true

# A class describing a library that contains a list of books
# and a list of readers
class Library
  attr_reader :books, :readers

  def initialize(readers = [], books = [])
    @readers = readers
    @books = books
  end

  def add_book(book)
    @books.append(book)
  end

  def add_reader(reader)
    @readers.append(reader)
  end

  def add_new_book(author, name, inventory_number,
                   genre, age_rating, number_books)
    book = Book.new(author, name, inventory_number,
                    genre, age_rating, number_books)
    add_book(book)
  end

  def add_new_reader(surname, name, patronymic, date_birth)
    reader = Reader.new(surname, name, patronymic, date_birth)
    add_reader(reader)
  end

  def delete_reader(full_name_reader)
    borrowed_books = []
    @readers.each do |reader|
      if reader.full_name == full_name_reader
        reader.list_books.each do |_date, books|
          borrowed_books += books
        end
        break
      end  
    end

    @readers.delete_if { |reader| reader.full_name == full_name_reader }

    borrowed_books.each do |borrowed_book|
      decrease_borrowed_books(borrowed_book)
    end
  end

  def delete_book(name_book)
    @books.delete_if do |book|
      book.name == name_book
    end

    @readers.each do |reader|
      reader.list_books.each do |_date, books|
        books.delete_if { |book| book.name == name_book }
      end
    end
  end

  def books_by_genre(surname, name, patronymic, date_birth, genre)
    age_rating = age_rating_reader(surname, name, patronymic, date_birth)
    books = @books.select do |book|
      book.genre == genre && book.age_rating <= age_rating
    end

    map_books_naming(books)
  end

  def books_by_author(surname, name, patronymic, date_birth, author)
    age_rating = age_rating_reader(surname, name, patronymic, date_birth)

    books = @books.select do |book|
      book.author == author && book.age_rating <= age_rating
    end

    map_books_naming(books)
  end

  def add_book_reader(surname, name, patronymic, date_birth, name_book)
    book = find_book(name_book)
    full_name = "#{surname} #{name} #{patronymic} #{date_birth}"

    @readers.each do |reader|
      if reader.full_name == full_name
        reader.add_book(book)
        break
      end
    end

    give_out_book(name_book)
  end

  def return_book(surname, name, patronymic, date_birth, name_book)
    full_name = "#{surname} #{name} #{patronymic} #{date_birth}"
    @readers.each do |reader|
      next unless reader.full_name == full_name

      reader.list_books.each do |date, books|
        books.each do |book|
          next unless book.name == name_book

          decrease_borrowed_books(book)
          remove_book_from_reader(full_name, name_book)
          return calculate_cost_delay(date)
        end
      end
    end
  end

  def show_books_by_genre(genre)
    books_by_genre = @books.select do |book|
      book.genre == genre
    end

    books_by_genre.sort_by do |book|
      [book.surname_author, book.name]
    end
  end

  def show_not_returned_books(return_date)
    return_date = return_date.strftime('%F')
    not_returned_books = []

    @readers.each do |reader|
      reader.list_books.each do |date, books|
        not_returned_books += books if date <= return_date
      end
    end

    not_returned_books.uniq(&:name)
  end

  def available_books
    books = @books.select do |book|
      book.number_books > book.number_borrowed_books
    end

    map_books_naming(books)
  end

  def all_name_books
    @books.map(&:name)
  end

  def all_readers
    @readers.map(&:full_name)
  end

  def all_genre
    @books.map(&:genre).uniq
  end

  def all_author
    @books.map(&:author).uniq
  end

  def reader?(surname, name, patronymic, date_birth)
    full_name = "#{surname} #{name} #{patronymic} #{date_birth.strftime('%F')}"
    @readers.each do |reader|
      return true if reader.full_name == full_name
    end
    false
  end

  def books_reader(surname, name, patronymic, date_birth)
    full_name = "#{surname} #{name} #{patronymic} #{date_birth}"
    borrowed_books = []
    @readers.each do |reader|
      next unless reader.full_name == full_name

      reader.list_books.each do |_date, books|
        borrowed_books += books
      end
    end
    map_books_naming(borrowed_books)
  end

  private

  def map_books_naming(books)
    books.map(&:name)
  end

  def age_rating_reader(surname, name, patronymic, date_birth)
    full_name = "#{surname} #{name} #{patronymic} #{date_birth}"
    @readers.each do |reader|
      return reader.age if reader.full_name == full_name
    end
  end
end

def find_book(name_book)
  @books.each do |book|
    return book if book.name == name_book
  end
end

def give_out_book(name_book)
  @books.each do |book|
    if book.name == name_book
      book.increase_borrowed_books
      break
    end
  end
end

def calculate_cost_delay(return_date)
  return_date = Date.parse(return_date)
  date_now = Date.today
  difference_date = (date_now - return_date).to_i
  if difference_date.negative?
    0
  else
    difference_date
  end
end

def decrease_borrowed_books(remote_book)
  @books.each do |book|
    if book.name == remote_book.name
      book.decrease_borrowed_books
      break
    end
  end
end

def remove_book_from_reader(full_name, name_book)
  @readers.each do |reader|
    next unless reader.full_name == full_name

    reader.list_books.each do |_date, books|
      books.delete_if { |book| book.name == name_book }
    end

    reader.delete_if { |books| books.size.zero? }
  end
end
