# frozen_string_literal: true

require 'scraped'

class MemberPage < Scraped::HTML
  field :phone do
    box.xpath('.//span[@class="item"][contains(.,"Phone")]//following-sibling::text()')
       .text
       .tidy
  end

  field :email do
    box.xpath('.//span[@class="item"][contains(.,"Email")]//following-sibling::text()')
       .text
       .tidy
  end

  field :birth_date do
    # At least one member has an invalid birth date of 00-00-00.
    date_str = box.xpath('.//span[@class="item"][contains(.,"Date of Birth")]//following-sibling::text()').text.tidy
    if Date.valid_date?(*date_str.split('-').map(&:to_i))
      Date.parse(date_str).to_s
    end
  end

  private

  def box
    noko.css('div#divToPrint')
  end
end
