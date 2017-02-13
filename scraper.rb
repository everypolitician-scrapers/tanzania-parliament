#!/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true

require 'date'
require 'pry'
require 'scraped'
require 'scraperwiki'
require 'require_all'

require_rel 'lib'

# require 'open-uri/cached'
# OpenURI::Cache.cache_path = '.cache'
require 'scraped_page_archive/open-uri'

@BASE = 'http://www.parliament.go.tz'

def noko(url)
  Nokogiri::HTML(open(url).read)
end

def date_from(date)
  return if date.to_s.empty?
  Date.parse(date).to_s rescue nil
end

def scrape(h)
  url, klass = h.to_a.first
  klass.new(response: Scraped::Request.new(url: url).response)
end

def scrape_term(url, term)
  page = noko(url)
  page.css('table#example tbody tr').each do |mem|
    tds = mem.css('td')
    link = tds[1].css('a/@href').text
    data = {
      id:          link.split('/').last,
      photo:       tds[0].css('img/@src').text,
      name:        tds[1].text.strip.sub(/^Hon.? /, ''),
      area:        tds[2].text.strip,
      party:       tds[3].text.strip,
      member_type: tds[4].text.strip,
      term:        term,
      source:      link,
    }
    %i(photo source).each { |i| data[i] = URI.join(url, URI.encode(data[i])).to_s unless data[i].to_s.empty? }
    data = data.merge((scrape data[:source] => MemberPage).to_h)
    ScraperWiki.save_sqlite(%i(id term), data)
    # puts data.reject { |k, v| v.to_s.empty? }.sort_by { |k, v| k }.to_h
  end

  next_pg = page.css('div#pagination').xpath('//a[text()=">"]/@href').text
  scrape_term(next_pg, term) unless next_pg.to_s.empty?
end

url = 'http://www.parliament.go.tz/mps-list'
ScraperWiki.sqliteexecute('DELETE FROM data') rescue nil
scrape_term(url, 5)
