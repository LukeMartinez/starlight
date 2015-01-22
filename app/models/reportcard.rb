require 'frontend'


class Reportcard 

	attr_reader :client

	def initialize
		# @client = Pdfcrowd::Client.new("lukemartinez", "8ca014eeeb9273f39ceeefe34f5fb445")
	end

	def make_pdf(html)
		File.open('file.pdf', 'wb') {|f| client.convertHtml(html, f) }
	end

	def content
		File.open('app/views/reportcards/index.html.erb').read
	end

	def template
		ERB.new(content).result
	end


	def raw_front_end_data_hash
		Frontend.new.grab(902016)
	end

	# def parse_individual_days_from_raw_data
	# 	raw_front_end_data_hash.each do |one_day_of_data|

	# 	end
	# end



end

