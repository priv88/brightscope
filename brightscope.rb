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

attr_accessor :name, :content, :content_401k, :header, :session, :web_name, :search_bar, :industry, :skip
BRIGHTSCOPE_URL = "http://www.brightscope.com"

  def initialize(session)
    @session = session
    @content = []
    @content_401k = []
    @skip = false
    # Capybara::Session.new(:selenium)
    # @name = name
  end

  def switch_name(name)

  end

  def start_cache
    @session.visit BRIGHTSCOPE_URL
  end  #visit the website

  def locate_search_bar
    @search_bar = @session.all(:xpath,'//input[@id="company-search"]').empty? ? @session.find_by_id("general-search") : @session.find_by_id("company-search")
  end #identify search bar

  #TODO ISSUE WITH SELECTING DROPDOWN
  def input_and_select 
    @search_bar.set(@name)
    @search_bar.native.send_keys :arrow_down
    sleep 2
    
    unless @session.all(:xpath, '//div[contains(@class, "sitewide-searchbar-dropdown")]').empty?
      @session.first(:xpath, '//div[contains(@class, "sitewide-searchbar-dropdown")]').click
    else
      @skip = true
    end

    # @session.all(".sitewide-searchbar-dropdown div")[0].click
    # @session.execute_script('$(".sitewide-searchbar-dropdown:nth-child(1)").trigger("mouseenter")')
    # @search_bar.native.send_keys :arrow_down
    # puts @session.first(".sitewide-searchbar-dropdown:nth-child(1)").nil?
    # @session.find(".sitewide-searchbar-dropdown:nth-child(1)").click
  end #select the first from the dropdown.


  def set_identifiers #basic_form_page 
    web_name = @session.all(".cname")[0].text
    puts web_name
    industry = @session.all('.selected-details tbody tr:nth-child(2) td')[1].text
    puts industry
    address = @session.all('.selected-details tbody tr:nth-child(1) td')[1].text
    puts address

    sanitized_address = sanitize_address(address)
    puts sanitized_address    
    address_1 = sanitized_address[0]
    state = sanitized_address[1]
    zip_code = sanitized_address[2]

    @content.push(web_name, industry, address_1, state, zip_code) 
  end

  #TODO issues with selecting totals!!!
  def set_401k_identifiers #form 5500 info
    url = @session.current_url
    year = @session.find(:xpath, '//select[@id="select-form-5500-year"]//option[@selected="selected"]').text
    plan_year = @session.find(:xpath, '//table[@class="table-form-5500-section"]//td[contains(text(), "Plan Year")]/following-sibling::td[1]').text
    active_participants = @session.all(:xpath, '//table[@class="table-form-5500-section"]//td[contains(text(), "Active (Eligible) Participants")]/following-sibling::td[1]').empty? ? "N/A" : @session.find(:xpath, '//table[@class="table-form-5500-section"]//td[contains(text(), "Active (Eligible) Participants")]/following-sibling::td[1]').text 
    total_participants = @session.all(:xpath, '//table[@class="table-form-5500-section"]//td[./text()="Total"]/following-sibling::td[1]').empty? ? "N/A" : @session.find(:xpath, '//table[@class="table-form-5500-section"]//td[./text()="Total"]/following-sibling::td[1]').text

    # unless @session.find(:xpath, '//table[@class="table-form-5500-section"]//td[contains(text(), "Total number of participants as of")]/following-sibling::td[1]').nil?
    # LY_participants = @session.find(:xpath, '//table[@class="table-form-5500-section"]//td[contains(text(), "Total number of participants as of")]/following-sibling::td[1]').text
    participants_LY = @session.all(:xpath, '//table[@class="table-form-5500-section"]//td[contains(text(), "Total number of participants as of")]/following-sibling::td[1]').empty? ? "N/A" : @session.find(:xpath, '//table[@class="table-form-5500-section"]//td[contains(text(), "Total number of participants as of")]/following-sibling::td[1]').text
    selected_year = @session.find(:xpath, '//select[@id="select-form-5500-year"]//option[@selected="selected"]').text
    @content_401k.push(year, plan_year, active_participants, total_participants, participants_LY, url)
    # web_name = @session.find('#company-name-val').text

    # year = @session.find('#select-form-5500-year').textno
    
    # address = @session.find(:xpath, '//table[@class="table-form-5500-section"]//td[./text()="Address")]/following-sibling::td[1]').text
    # sanitized_address = sanitize_address(address)
    # address_1 = sanitized_address[0]
    # state = sanitized_address[1]
    # zip_code = sanitized_address[2]
    
    # naics_code = @session.find(:xpath, '//table[@class="table-form-5500-section"]//td[./text()="Industry Code")]/following-sibling::td[1]').text
    #xpath for active (eligible) participants, total and last year participants line
    return @content_401k
  end



  def sanitize_address(address)
    regex = /\w{2}\s\d{5}(?:[-\s]\d{4})?$/ #looks for state and zipcode
    address_line = address.split(regex)[0].delete(",").strip #separates address line from state and zipcode
    keys = address.slice(regex).split(" ") #state and zipcode
    keys.unshift(address_line)
    return keys
  end

  def redirect_to_form5500
    form_link = @session.find(".sort li", :text => "Form 5500 Data")
    form_link.click
  end

  def clear_all_content
    @content.clear
    @content_401k.clear 
  end

  def clear_401k_content
    @content_401k.clear
  end

  def count_years #form 5500
    session.all(:xpath, '//select[@id="select-form-5500-year"]//option').count
  end

  def click_through_years
    session.find(:xpath, '//select[@id="select-form-5500-year"]').native.send_keys :arrow_down
    session.find('body').click
    # year = @session.find(:xpath, '//select[@id="select-form-5500-year"]//option[@selected="selected"]').text
    # plan_year = @session.find(:xpath, '//table[@class="table-form-5500-section"]//td[contains(text(), "Plan Year")]/following-sibling::td[1]').text
    

    # puts plan_year.match(year)

    # if plan_year.match(year).nil?
      # sleep 2
    # end

    # session.find(:xpath, '')native.send_keys :arrow_down
  end







end

# @search_bar.native.send_keys :return // :arrow_down

