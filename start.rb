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

url.each do |link|
  main_link = Brightscope.new(link[0])
  binding.pry
  main_link.sanitize_name
  main_link.start_cache
  main_link.locate_search_bar
  binding.pry
  main_link.input_and_select
  # main_link.
end