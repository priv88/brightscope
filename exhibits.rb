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

url = CSV.read('Brightscope Test Exhibits v2.csv')

session = Capybara::Session.new(:selenium)
main_window = Brightscope.new(session)
url.each do |name|
  begin
  # binding.pry
  main_window.start_cache_screenshots(name[3])
  # binding.pry
  main_window.session.save_screenshot "#{name[0]}" + ".png"
  puts name[0]
  sleep rand(4..8)

  rescue
    next
  end
end