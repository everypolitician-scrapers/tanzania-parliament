# frozen_string_literal: true

require 'scraped'
require_relative 'member_row'

class MembersPage < Scraped::HTML
  decorator Scraped::Response::Decorator::CleanUrls

  field :member_rows do
    noko.css('table#example tbody tr').map do |mem|
      fragment mem.css('td') => MemberRow
    end
  end

  field :next do
    noko.css('div#pagination').xpath('//a[text()=">"]/@href').text
  end
end
