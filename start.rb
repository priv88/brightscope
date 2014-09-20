require "rubygems"
require "nokogiri"
require "open-uri"
require "capybara"
# require "capybara-webkit"
require "httparty"
require "pp"
require 'pry-byebug'
require "timeout"
require "writeexcel"
require "csv"
require_relative 'brightscope.rb'

url = CSV.read('BrightscopeTest.csv')

# url.each do |link|
#   main_link = Brightscope.new(link[0])
#   binding.pry
#   main_link.sanitize_name
#   main_link.start_cache
#   main_link.locate_search_bar
#   binding.pry
#   main_link.input_and_select
#   # main_link.
# end


def sanitize_name(name)
  regex = /,|GmbH|S.p.A|Ltd|Inc.|Inc|Limited|Co.|Corp|LLC|L.L.C.|L.L.C|SA|S.A.$/
  name.sub!(regex,"")
  name.strip
end

def create_row(array_1, array_2, row)
  array_1.each {|item| row << item}
  array_2.each {|item| row << item}
end

session = Capybara::Session.new(:selenium)
main_window = Brightscope.new(session)
main_window.start_cache
wb_name = "Brightscope" + ".xls"
workbook = WriteExcel.new(wb_name)
header_row = ["File Name", "Web Name", "Industry", "Address", "State", "Zip Code", "Plan Year", "Active Participants", "Total Partipants", "LY Participants"]
  binding.pry

url.each do |url|

  main_window.clear_content
  file_name = url[0]
    binding.pry
  main_window.name = sanitize_name(file_name)
  main_window.locate_search_bar
  binding.pry
  main_window.input_and_select
      binding.pry
  main_window.set_identifiers
  #Form 5500
  main_window.redirect_to_form5500
  main_window.set_401k_identifiers

  #switch to years
  click_down = main_window.count_years - 1
  click_down.times do 
    main_link.click_through_years
    main_link.set_401k_identifiers
  end
  row = [file_name]
  create_row(main_link.content, main_link.content_401k, row)

  workbook.write_row(index,0,row)


end

workbook.close
