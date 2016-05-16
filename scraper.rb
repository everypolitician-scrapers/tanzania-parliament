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
  page.css('table#example tbody tr').each do |mem|
    tds = mem.css('td')
    link = tds[1].css('a/@href').text
    data = { 
      id: link.split('/').last,
      photo: tds[0].css('img/@src').text,
      name: tds[1].text.strip.sub(/^Hon.? /,''), 
      area: tds[2].text.strip,
      party: tds[3].text.strip,
      member_type: tds[4].text.strip,
      term: term,
      source: link,
    }
    %i(photo source).each { |i| data[i] = URI.join(url, URI.encode(data[i])).to_s unless data[i].to_s.empty? }
    data = data.merge(scrape_person(data[:source]))
    ScraperWiki.save_sqlite([:id, :term], data)
  end
  
  next_pg = page.css('div#pagination').xpath('//a[text()=">"]/@href').text
  scrape_term(next_pg, term) unless next_pg.to_s.empty?
end

def scrape_person(url)
  page = noko(url)
  box = page.css('div#divToPrint')
  data = { 
    phone: box.xpath('.//span[@class="item"][contains(.,"Phone")]//following-sibling::text()').text.tidy,
    email: box.xpath('.//span[@class="item"][contains(.,"Email")]//following-sibling::text()').text.tidy,
    birth_date: date_from(box.xpath('.//span[@class="item"][contains(.,"Date of Birth")]//following-sibling::text()').text.tidy),
  }
end


url = 'http://www.parliament.go.tz/mps-list'
scrape_term(url, 5)
