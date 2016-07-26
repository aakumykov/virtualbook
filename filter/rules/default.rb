#coding: utf-8

class DefaultSite

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

class DefaultPage
end