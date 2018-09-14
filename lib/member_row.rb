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
    name_parts.reject { |p| prefixes.include? p }.join(' ').tidy
  end

  field :honorific_prefix do
    name_parts.select { |p| wanted_prefixes.include? p }.map(&:tidy).join(';')
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

  def wanted_prefixes
    %w[Prof. Eng.]
  end

  def unwanted_prefixes
    %w[Hon.]
  end

  def prefixes
    wanted_prefixes + unwanted_prefixes
  end

  def name_parts
    noko[1].text.tidy.split(' ')
  end

  def link
    noko[1].css('a/@href').text
  end
end
