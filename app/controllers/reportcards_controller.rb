class ReportcardsController < ApplicationController

	def index
		@report_card = Reportcard.new

		html = File.open('app/views/reportcards/index.html.erb').read
		template = ERB.new(html)
		puts template.result(binding)
	end

end