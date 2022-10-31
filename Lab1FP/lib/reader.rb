# frozen_string_literal: true

require 'date'
require_relative 'book'

# Class describing the reader
class Reader
  attr_reader :age_rating, :date_birth, :name, :surname, :patronymic

  attr_accessor :list_books

  def initialize(surname, name, patronymic, date_birth, list_books = [])
    @surname = surname
    @name = name
    @patronymic = patronymic
    @date_birth = date_birth
    @list_books = init_list_books(list_books)
  end

  def list_borrowed_books(reader)
    reader.list_books.values.flatten
  end

  def full_name(surname, name, patronymic, date_birth)
    "#{surname} #{name} #{patronymic} #{date_birth}"
  end

  def add_book(list_books, date_today, book)
    list_books_clone = list_books.clone
    list_books_clone[date_today] += [book]
    list_books_clone
  end

  def delete_book(list_books, name_book)
    list_books_clone = list_books.clone
    list_books_clone.each do |_date, books|
      books.delete_if { |book| book.name == name_book }
    end
  end

  def age(date_today, date_birth)
    (date_today - Date.parse(date_birth)).to_i / 365
  end

  private

  def init_list_books(books)
    hash_books = Hash.new([])
    books.each do |book|
      return_date = book['return_date']
      book['books'].each do |obj|
        hash_books[return_date] += [create_book(obj)]
      end
    end
    hash_books
  end

  def create_book(obj_book)
    Book.new(obj_book['author'],
             obj_book['name'],
             obj_book['inventory_number'],
             obj_book['genre'],
             obj_book['age_rating'],
             obj_book['number_books'],
             obj_book['number_borrowed_books'])
  end
end
