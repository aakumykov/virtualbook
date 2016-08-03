#coding: utf-8

class Spider
	def self.get_data
		rand(1000).to_s
	end

	def self.load
		threads = []

		[1,2,3,4,5].each do |i|
			threads << Thread.new do
				Thread.current[:output] = Spider.get_data
			end
		end

		results = []

		threads.each do |thr|
			results += [thr.join[:output]]
		end

		return results
	end
end



puts "#{Spider.load}"