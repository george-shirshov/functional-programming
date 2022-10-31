# frozen_string_literal: true

# Class describing a book
class Book
  attr_reader :genre, :name, :number_books, :author,
              :age_rating
  attr_accessor :number_borrowed_books

  LENGTH_INITIALS = 5

  def initialize(author, name, inventory_number,
                 genre, age_rating, number_books, number_borrowed_books = 0)
    @author = author
    @name = name
    @inventory_number = inventory_number
    @genre = genre
    @age_rating = age_rating
    @number_books = number_books
    @number_borrowed_books = number_borrowed_books
  end

  def surname_author(author)
    author.slice(0...author.size - LENGTH_INITIALS)
  end

  def increase_borrowed_books(borrowed_books)
    borrowed_books + 1
  end

  def decrease_borrowed_books(borrowed_books)
    borrowed_books - 1
  end

  def to_string(name, author, genre, age_rating)
    "Название книги: #{name}\n" \
      "Автор: #{author}\n" \
      "Жанр: #{genre}\n" \
      "Возрастное ограничение: #{age_rating}+\n\n"
  end

  def to_s
    "Название книги: #{@name}\n" \
      "Автор: #{@author}\n" \
      "Жанр: #{@genre}\n" \
      "Возрастное ограничение: #{@age_rating}+\n\n"
  end
end
