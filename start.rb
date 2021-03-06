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

url = CSV.read('BrightscopeTestv4.csv')

def sanitize_name(name)
  regex = /GmbH$|S\.p\.A$|S\.p\.A\.$|Ltd$|Inc\.$|Incorporated|Inc$|Limited$|Co\.$|Corp$|Corp\.$|LLC$|L\.L\.C\.$|L\.L\.C$|\,|SA$|S\.A\.$|A\/S$|LP$|L\.P\.|L\.P|/
  mod_name = name.gsub(regex,"")
  mod_name.strip
end

def create_row(array_1, array_2, row)
  array_1.each {|item| row << item}
  array_2.each {|item| row << item}
end

session = Capybara::Session.new(:selenium)
main_window = Brightscope.new(session)
main_window.start_cache
wb_name = "Brightscope v4 " + "#{Time.now.strftime("%m%d%Y")}" + ".xls"
workbook = WriteExcel.new(wb_name)
worksheet = workbook.add_worksheet
header_row = ["File Name", "Web Name", "Industry", "Address Line 1", "Address Line 2", "City", "State", "Zip Code", "Year", "Plan Year", "Active Participants", "Total Partipants", "LY Participants", "URL"]
worksheet.write_row(0,0,header_row)
index_url = 0
index = 1
row = []  

url.each do |url|
  begin
  main_window.clear_all_content
  file_name = url[index_url]
  puts file_name
  # main_window.name = sanitize_name(file_name)
  main_window.name = file_name
  puts main_window.name

  main_window.locate_search_bar

  main_window.input_and_select
  unless main_window.skip
    main_window.set_identifiers #basic form
    main_window.redirect_to_form5500 #Form 5500
    click_down = main_window.count_years #switch years
    click_down.times do 
      main_window.set_401k_identifiers
      row = [file_name]
      create_row(main_window.content, main_window.content_401k, row)
      main_window.clear_401k_content
      main_window.click_through_years
      worksheet.write_row(index,0,row)
      index += 1
      sleep rand(4..8)
    end
  else
    puts file_name + "Not found in Brightscope"
    worksheet.write_row(index,0,[file_name,"Not found in Brightscope"])
    index += 1
    row.clear  
    main_window.skip = false
  end
  worksheet.write_row(index,0,[" "])
  index += 1
  sleep rand(3..12)
  rescue
    retry
  end
end

workbook.close
