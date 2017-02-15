# frozen_string_literal: true
require_relative './test_helper'
require_relative '../lib/members_page.rb'

describe 'member data' do
  url = 'http://www.parliament.go.tz/mps-list'
  around { |test| VCR.use_cassette(url.split('/').last, &test) }

  subject do
    MembersPage.new(response: Scraped::Request.new(url: url).response)
               .member_rows
               .find { |row| row.id == id }
  end

  describe 'Member with Prof prefix' do
    let(:id) { '568' }
    it 'should return the expected data' do
      subject.to_h.must_equal(
        id:               '568',
        photo:            'http://www.parliament.go.tz/site/images/img.jpg',
        name:             'Palamagamba John Aidan Mwaluko Kabudi',
        honorific_prefix: 'Prof.',
        area:             'Nominated',
        party:            'CCM',
        member_type:      'Nominated',
        source:           'http://www.parliament.go.tz/administrations/568'
      )
    end
  end

  describe 'Member with Dr prefix' do
    let(:id) { '401' }
    # Note: Current live data includes names with Dr prefix attached
    it 'should return the expected data' do
      subject.to_h.must_equal(
        id:               '401',
        photo:            'http://parliament.go.tz/polis/uploads/members/0.76488000%201486015693.png',
        name:             'Dr. Tulia Ackson',
        honorific_prefix: '',
        area:             'Nominated',
        party:            'CCM',
        member_type:      'Nominated',
        source:           'http://www.parliament.go.tz/administrations/401'
      )
    end
  end

  describe 'Member without honorific prefix' do
    let(:id) { '458' }
    it 'should return the expected data' do
      subject.to_h.must_equal(
        id:               '458',
        photo:            'http://parliament.go.tz/polis/uploads/members/0.57945900%201485964592.png',
        name:             'Abbas Ali Mwinyi',
        honorific_prefix: '',
        area:             'Fuoni',
        party:            'CCM',
        member_type:      'Constituent Member',
        source:           'http://www.parliament.go.tz/administrations/458'
      )
    end
  end
end
