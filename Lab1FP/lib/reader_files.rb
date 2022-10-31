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
    books_obj = JSON.parse(File.read(file_books))
    books_obj.each do |book_obj|
      book_obj.transform_keys!(&:to_sym)
      library.books = library.add_book(library.books, book_obj)
    end
    readers_obj = JSON.parse(File.read(file_readers))
    readers_obj.each do |reader_obj|
      reader_obj.transform_keys!(&:to_sym)
      library.readers = library.add_reader(library.readers, reader_obj)
    end
    library
  end
end
