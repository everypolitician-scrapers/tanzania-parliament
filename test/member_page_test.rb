# frozen_string_literal: true

require_relative './test_helper'
require_relative '../lib/member_page.rb'

describe 'member data' do
  around { |test| VCR.use_cassette(url.split('/').last, &test) }

  subject do
    MemberPage.new(response: Scraped::Request.new(url: url).response)
  end

  describe 'member with complete data' do
    let(:url) { 'http://www.parliament.go.tz/administrations/82' }

    it 'should have the expected data' do
      subject.to_h.must_equal(
        phone:      '+255767605551',
        email:      'a.isack@bunge.go.tz',
        birth_date: '1956-04-30'
      )
    end
  end

  describe 'member with invalid birth date' do
    let(:url) { 'http://www.parliament.go.tz/administrations/256' }

    it 'should have the expected data' do
      subject.to_h.must_equal(
        phone:      '',
        email:      'a.shabiby@bunge.go.tz',
        birth_date: nil
      )
    end
  end
end
