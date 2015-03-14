require "rest-client"
require "nokogiri"
userInfo = File.open('loginInfo.txt')
loginInfo = []
puts "Reading loginInfo.txt"
userInfo.each_line do |w|
  w.split('\s').each {|x| loginInfo <<x.strip}
end
request_url = "https://wsuol2.wright.edu/patroninfo/"

form_data = "name=#{loginInfo[0]}&code=#{loginInfo[1]}&pat_submit=xxx"

page = RestClient.post(request_url,form_data) { |response, request, result, &block|
  puts response.code
  if [301, 302, 307].include? response.code
    puts response.headers
    response_hsh = response.headers
    request_url ="https://wsuol2.wright.edu/"
    request_url<<response_hsh[:location].slice(1..response_hsh[:location].length)
    response.follow_redirection(request, result, &block)
  else
    response.return!(request, result, &block)
  end
}

File.open("myAccount.html", 'w'){|f| f.write page.body}

npage = Nokogiri::HTML(page)
rows = npage.css('table tr')
puts "#{rows.length} rows"

rows.each do |row|
  puts row.css('td').map{|td| td.text}.join(', ')
end
