#!/usr/bin/env ruby

require 'httparty'
require 'date'
require 'byebug'

timestamp = DateTime.now.strftime('%Y-%m-%dT%H-%d-%S')

url = 'https://health-infobase.canada.ca/src/data/summary_current.csv'
source_name = "data/cases_#{timestamp}.csv"

response = HTTParty.get(url)

File.open(source_name, 'w') do |f|
  f.puts response.to_s.gsub(/\r\n?/, "\n")
end

puts "#{source_name} has been fetched"
