require "rubygems"
require "nokogiri"
require "open-uri"
require "capybara"
# require "capybara-webkit"
require "httparty"
require "pp"
require 'pry-byebug'
require 'timeout'
require "writeexcel"
require "csv"


class Brightscope

attr_accessor :name, :content, :header, :session, :web_name, :search_bar, :industry
BRIGHTSCOPE_URL = "http://www.brightscope.com"

  def initialize(name)
    @session = Capybara::Session.new(:selenium)
    @name = name
  end

  def start_cache
    @session.visit BRIGHTSCOPE_URL
  end  #visit the website

  def locate_search_bar
    @search_bar = @session.find_by_id("company-search")
    @search_bar = @session.find_by_id("general-search") if @session.find_by_id("company-search").nil?
  end #identify search bar

  def input_and_select
    @search_bar.set(@name)
    entry = @session.first(".sitewide-searchbar-dropdown")
    entry.click
  end #select the first from the dropdown.

  def set_identifiers
    @web_name = @session.all(".cname")[0].text
    @address = @session.all('.selected-details tbody tr:nth-child(1) td')[1].text
    @industry = @session.all('.selected-details tbody tr:nth-child(2) td')[1].text
  end

  def redirect_to_form5500
    form_link = @session.find(".sort li", :text => "Form 5500 Data")
    form_link.click
  end

  def sanitize_name
    regex = /,|GmbH|S.p.A|Ltd|Inc.|Inc|Limited|Co.|Corp|LLC|L.L.C.|L.L.C|SA|S.A.$/
    @name.sub!(regex,"")
    @name.squeeze!
  end

end

# @search_bar.native.send_keys :return // :arrow_down

