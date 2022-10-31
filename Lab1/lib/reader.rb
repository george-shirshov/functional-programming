# frozen_string_literal: true

require 'date'
require_relative 'book'

# Class describing the reader
class Reader
  attr_reader :age_rating, :date_birth

  def initialize(surname, name, patronymic, date_birth, list_books = [])
    @surname = surname
    @name = name
    @patronymic = patronymic
    @date_birth = date_birth
    @list_books = init_list_books(list_books)
  end

  def full_name
    "#{@surname} #{@name} #{@patronymic} #{@date_birth}"
  end

  def add_book(book)
    date_now = Date.today
    date_now = date_now.strftime('%F')
    list_books[date_now] += [book]
  end

  def age
    (Date.today - Date.parse(@date_birth)).to_i / 365
  end

  private

  def init_list_books(books)
    hash_books = Hash.new([])
    books.each do |book|
      return_date = book['return_date']
      book['books'].each do |obj|
        hash_books[return_date] += [Book.new(obj['author'], obj['name'],
                                             obj['inventory_number'],
                                             obj['genre'], obj['age_rating'],
                                             obj['number_books'],
                                             obj['number_borrowed_books'])]
      end
    end
    hash_books
  end
end
