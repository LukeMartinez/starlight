class PdfMaker

	def initialize
		client = Pdfcrowd::Client.new("lukemartinez", "8ca014eeeb9273f39ceeefe34f5fb445")
	end


	def make_pdf
		File.open('file.pdf', 'wb') {|f| client.convertFile('/views/reportcard/index.html.erb', f)}
	end

	def some_data
		"yooooooo"
	end
end