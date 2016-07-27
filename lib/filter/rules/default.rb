#coding: utf-8

class DefaultSite

	def initialize
		puts "создаётся объект #{self.class}"
		index_rules
	end

	def process(*arg)
		puts "#{self.class}.#{__method__}(#{arg})"

		case arg.size
		when 1
			process_link(arg.first)
		when 2
			process_page(arg.first,arg.last)
		else
			# не опасно ли выводить здесь arg?
			raise ArgumentError "ожидается 'uri, page', получено '#{arg}'"
		end
	end

	private

	def index_rules
		puts " внутренний метод #{self.class}.#{__method__}"
		self.class.constants.each do |const_name|
			Object.get_const(const_name.new
		end
	end


	def process_link(uri)
		puts "#{self.class}.#{__method__}(#{uri})"
	end

	def process_page(uri,page)
		puts "#{self.class}.#{__method__}(#{uri},#{page.class})"
	end

	# фильтры
	def RemoveScript_Filter(page)
	end

	def RemoveNoscript_Filter(page)
	end
end
