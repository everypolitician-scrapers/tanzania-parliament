# frozen_string_literal: true

require_relative './test_helper'
require_relative '../lib/members_page.rb'

describe MembersPage do
  around { |test| VCR.use_cassette(url.split('/').last, &test) }

  let(:yaml_data) { YAML.load_file(subject) }
  let(:url) { 'http://www.parliament.go.tz/mps-list' }
  let(:response) { MembersPage.new(response: Scraped::Request.new(url: url).response) }

  describe 'member rows' do
    let(:subject) { 'test/custom_test_data/member_row.yml' }

    it 'contains the expected data' do
      response.member_rows.first.to_h.must_equal yaml_data[:to_h]
    end
  end
end
