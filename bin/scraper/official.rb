#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class MemberList
  # details for an individual member
  class Member < Scraped::HTML
    field :state do
      noko.css('.state').text.tidy
    end

    field :name do
      # this version has names without the 'Gov.' prefix
      noko.css('img/@alt').text.tidy
    end
  end

  # The page listing all the members
  class Members < Scraped::HTML
    field :members do
      member_container.map { |member| fragment(member => Member).to_h }
    end

    private

    def member_container
      noko.css('.current-governors__item')
    end
  end
end

file = Pathname.new 'html/official.html'
puts EveryPoliticianScraper::FileData.new(file).csv
