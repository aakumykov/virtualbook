#coding: utf-8
system 'clear'

class Book

	def self.create(&block)
		self.new(&block)
	end

	def initialize(&block)
		instance_eval(&block) if block_given?
	end

	def add_page(page=nil, &block)
		block_data = instance_eval(&block) if block_given?
			puts "#{self}.#{__method__}(), data: '#{block_data}'"
	end
end

class Page
	attr_reader :title, :author

	def to_s
		self.body.to_s
	end

	def to_h
		{
			title: self.title,
			author: self.author,
		}
	end
end

Book.create do |book|
	book.add_page do
		"это - страница"
	end
end

bk = Book.new
bk.add_page do
	{ 
		title: 'Другой заголовок',
		page: 'Другая страница',
	}
end