# frozen_string_literal: true

require 'scraped'

class MemberRow < Scraped::HTML
  field :id do
    link.split('/').last
  end

  field :photo do
    noko[0].css('img/@src').text
  end

  field :name do
    noko[1].text.strip.sub(/^Hon.? /, '')
  end

  field :area do
    noko[2].text.strip
  end

  field :party do
    noko[3].text.strip
  end

  field :member_type do
    noko[4].text.strip
  end

  field :source do
    link
  end

  private

  def link
    noko[1].css('a/@href').text
  end
end
