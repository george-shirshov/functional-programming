# frozen_string_literal: true

require 'json'
require_relative 'reader'
require_relative 'book'
require_relative 'library'

# Module that allows you to read data from files
module ReaderFiles
  def self.read
    file_books = File.expand_path('../data/books.json', __dir__)
    file_readers = File.expand_path('../data/readers.json', __dir__)
    library = Library.new
    ruby_objects = JSON.parse(File.read(file_books))
    ruby_objects.each do |obj|
      book = Book.new(obj['author'], obj['name'], obj['inventory_number'],
                      obj['genre'], obj['age_rating'], obj['number_books'],
                      obj['number_borrowed_books'])
      library.add_book(book)
    end
    ruby_objects = JSON.parse(File.read(file_readers))
    ruby_objects.each do |obj|
      reader = Reader.new(obj['surname'], obj['name'], obj['patronymic'],
                          obj['date_birth'], obj['list_books'])
      library.add_reader(reader)
    end
    library
  end
end
