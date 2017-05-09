#!/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true

require 'pry'
require 'require_all'
require 'scraped'
require 'scraperwiki'

require_rel 'lib'

# require 'open-uri/cached'
# OpenURI::Cache.cache_path = '.cache'
require 'scraped_page_archive/open-uri'

def scrape(h)
  url, klass = h.to_a.first
  klass.new(response: Scraped::Request.new(url: url).response)
end

def scrape_term(url, term)
  page = scrape url => MembersPage
  page.member_rows.each do |mem|
    data = mem.to_h.merge((scrape mem.source => MemberPage).to_h).merge(term: term)
    ScraperWiki.save_sqlite(%i(id term), data)
    # puts data.reject { |k, v| v.to_s.empty? }.sort_by { |k, v| k }.to_h
  end

  next_pg = page.next
  scrape_term(next_pg, term) unless next_pg.to_s.empty?
end

url = 'http://www.parliament.go.tz/mps-list'
ScraperWiki.sqliteexecute('DROP TABLE data') rescue nil
scrape_term(url, 5)
