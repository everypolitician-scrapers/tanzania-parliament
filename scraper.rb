#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'date'
require 'open-uri'
require 'date'

require 'colorize'
require 'pry'
require 'csv'
require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

@BASE = 'http://www.parliament.go.tz'

def noko(url)
  url.prepend @BASE unless url.start_with? 'http:'
  warn "Getting #{url}"
  Nokogiri::HTML(open(url).read) 
end

def datefrom(date)
  Date.parse(date)
end

def navigate(url, term)
  page = noko(url)
  rows = page.css('div#tablez').xpath('//table[.//th[contains(.,"Fullname")]]/tr[td[contains(.,"Questions")]]')
  rows.each do |mem|
    tds = mem.css('td')
    data = { 
      id: tds[0].css('img/@src').text.split('/').last[/^(\d+)/, 1],
      photo: tds[0].css('img/@src').text,
      name: tds[1].text.strip,
      party: tds[2].text.strip,
      term: term,
      source: url,
    }
    data[:id]
    puts data
    ScraperWiki.save_sqlite([:id, :term], data)
  end
  
  next_pg = page.css('div#pagination').xpath('//a[text()=">"]/@href').text
  navigate(next_pg, term) unless next_pg.to_s.empty?
end

def scrape(url)
  page = noko(url)
  binding.pry
  box = page.css('div#tablez table')
end


url = '/index.php/members/memberslist/all/all/%i'

(2..4).each do |term|
  puts term
  navigate(@BASE + url % term, term)
end
