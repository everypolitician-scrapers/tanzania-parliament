#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'date'
require 'date'
require 'colorize'
require 'pry'
require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

@BASE = 'http://www.parliament.go.tz'

class String
  def tidy
    self.gsub(/[[:space:]]+/, ' ').strip
  end
end

def noko(url)
  # url.prepend @BASE unle# ss url.start_with? 'http:'
  # warn "Getting #{url}"
  Nokogiri::HTML(open(url).read) 
end

def date_from(date)
  return if date.to_s.empty?
  Date.parse(date).to_s rescue nil
end

def scrape_term(url, term)
  page = noko(url)
  rows = page.css('div#tablez').xpath('//table[.//th[contains(.,"Fullname")]]/tr[td[contains(.,"Questions")]]')
  rows.each do |mem|
    tds = mem.css('td')
    link = tds[1].css('a/@href').text
    data = { 
      id: tds[0].css('img/@src').text.split('/').last[/^(\d+)/, 1],
      photo: tds[0].css('img/@src').text,
      name: tds[1].text.strip, # but overwritten if we have parts on their MP page
      sort_name: tds[1].text.strip,
      party: tds[2].text.strip,
      term: term,
      source: link,
    }
    %i(photo source).each { |i| data[i] = URI.join(url, URI.encode(data[i])).to_s unless data[i].to_s.empty? }
    data = data.merge(scrape_person(data[:source]))
    # puts data
    ScraperWiki.save_sqlite([:id, :term], data)
  end
  
  next_pg = page.css('div#pagination').xpath('//a[text()=">"]/@href').text
  scrape_term(next_pg, term) unless next_pg.to_s.empty?
end

def scrape_person(url)
  page = noko(url)
  box = page.xpath('//div[@id="tablez"]//table[.//th[contains(.,"GENERAL")]]')
  data = { 
    salutation: box.xpath('.//td[.//strong[contains(.,"Salutation")]]/following-sibling::td[1]').text.tidy,
    given_name: box.xpath('.//td[.//strong[contains(.,"First Name")]]/following-sibling::td[1]').text.tidy,
    middle_name: box.xpath('.//td[.//strong[contains(.,"Middle Name")]]/following-sibling::td[1]').text.tidy,
    family_name: box.xpath('.//td[.//strong[contains(.,"Last Name")]]/following-sibling::td[1]').text.tidy,
    member_type: box.xpath('.//td[.//strong[contains(.,"Member Type")]]/following-sibling::td[1]').text.tidy,
    area: box.xpath('.//td[.//strong[contains(.,"Constituent")]]/following-sibling::td[1]').text.tidy,
    email: box.xpath('.//td[.//strong[contains(.,"E-mail")]]/following-sibling::td[1]').text.tidy,
    birth_date: date_from(box.xpath('.//td[.//strong[contains(.,"Date of Birth")]]/following-sibling::td[1]').text.tidy),
  }
  data[:name] = %i(given_name middle_name family_name).map { |i| data[i] }.join " "
  return data[:name].tidy.empty? ? {} : data
end


url = 'http://www.parliament.go.tz/index.php/members/memberslist/all/all/%i'

(2..4).reverse_each do |term|
  puts term
  scrape_term(url % term, term)
end
