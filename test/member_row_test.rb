# frozen_string_literal: true
require_relative './test_helper'
require_relative '../lib/members_page.rb'

describe 'MemberRow' do
  around { |test| VCR.use_cassette(url.split('/').last, &test) }

  subject do
    MembersPage.new(response: Scraped::Request.new(url: url).response).member_rows.first.to_h
  end

  let(:url) { 'http://www.parliament.go.tz/mps-list' }

  describe 'member row data' do
    it 'should have the expected data' do
      subject.must_equal(
        id:          '458',
        photo:       'http://parliament.go.tz/polis/uploads/members/0.57945900%201485964592.png',
        name:        'Abbas Ali Mwinyi',
        area:        'Fuoni',
        party:       'CCM',
        member_type: 'Constituent Member',
        source:      'http://www.parliament.go.tz/administrations/458'
      )
    end
  end

  describe 'console output' do
    it 'should not warn of URI.escape obsolescence' do
      proc { subject[:photo] }.must_be_silent
    end
  end
end
