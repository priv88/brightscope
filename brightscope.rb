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

attr_accessor :name, :content, :content_401k, :header, :session, :web_name, :search_bar, :industry
BRIGHTSCOPE_URL = "http://www.brightscope.com"

  def initialize(session)
    @session = session

    # Capybara::Session.new(:selenium)
    # @name = name
  end

  def switch_name(name)

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

  def set_identifiers #basic_form_page
    web_name = @session.all(".cname")[0].text
    
    industry = @session.all('.selected-details tbody tr:nth-child(2) td')[1].text
    address = @session.all('.selected-details tbody tr:nth-child(1) td')[1].text
    
    sanitized_address = sanitize_address(address)
    address_1 = sanitized_address[0]
    state = sanitized_address[1]
    zip_code = sanitized_address[2]

    @content.push(web_name, industry, address_1, state, zip_code) 
  end

  def set_401k_identifiers #form 5500 info
    year = @session.find(:xpath, '//select[@id="select-form-5500-year"]//option[@selected="selected"]').text
    plan_year = @session.find(:xpath, '//table[@class="table-form-5500-section"]//td[contains(text(), "Plan Year")]/following-sibling::td[1]').text
    active_participants = @session.find(:xpath, '//table[@class="table-form-5500-section"]//td[contains(text(), "Active (Eligible) Participants")]/following-sibling::td[1]').text
    total_participants = @session.find(:xpath, '//table[@class="table-form-5500-section"]//td[./text()="Total")]/following-sibling::td[1]').text

    # unless @session.find(:xpath, '//table[@class="table-form-5500-section"]//td[contains(text(), "Total number of participants as of")]/following-sibling::td[1]').nil?
    # LY_participants = @session.find(:xpath, '//table[@class="table-form-5500-section"]//td[contains(text(), "Total number of participants as of")]/following-sibling::td[1]').text
    participants_LY = @session.find(:xpath, '//table[@class="table-form-5500-section"]//td[contains(text(), "Total number of participants as of")]/following-sibling::td[1]').text
    selected_year = @session.find(:xpath, '//select[@id="select-form-5500-year"]//option[@selected="selected"]').text
    @content_401k.push(plan_year, active_participants, total_participants, participants_LY)
    # web_name = @session.find('#company-name-val').text

    # year = @session.find('#select-form-5500-year').textno
    
    # address = @session.find(:xpath, '//table[@class="table-form-5500-section"]//td[./text()="Address")]/following-sibling::td[1]').text
    # sanitized_address = sanitize_address(address)
    # address_1 = sanitized_address[0]
    # state = sanitized_address[1]
    # zip_code = sanitized_address[2]
    
    # naics_code = @session.find(:xpath, '//table[@class="table-form-5500-section"]//td[./text()="Industry Code")]/following-sibling::td[1]').text
    #xpath for active (eligible) participants, total and last year participants line
  end



  def sanitize_address(address)
    regex = /\w{2}\s\d{5}(?:[-\s]\d{4})?$/ #looks for state and zipcode
    address_line = address.split(regex)[0].delte(",").strip #separates address line from state and zipcode
    keys = address.slice(regex).split(" ") #state and zipcode
    keys.unshift(address_line)
    return keys
  end

  def redirect_to_form5500
    form_link = @session.find(".sort li", :text => "Form 5500 Data")
    form_link.click
  end

  def clear_content
    @content.clear
    @content_401k.clear
  end

  private

  def count_years #form 5500
    session.all(:xpath, '//select[@id="select-form-5500-year"]//option').count
  end

  
  def click_through_years
    session.all(:xpath, '//select[@id="select-form-5500-year"]').native.send_keys :arrow_down
  end




end

# @search_bar.native.send_keys :return // :arrow_down

