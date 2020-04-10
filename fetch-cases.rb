#!/usr/bin/env ruby

require 'httparty'
require 'date'
require 'byebug'

# url = 'https://health-infobase.canada.ca/src/data/summary_current.csv'
# new url, noticed 2020-03-31; last version of previous url data was 2020-03-28
url = 'https://health-infobase.canada.ca/src/data/covidLive/covid19.csv'

response = HTTParty.get(url)

# last-modified format: "Tue, 31 Mar 2020 19:40:58 GMT"
timestamp = DateTime.strptime(
  response.headers['last-modified'], '%a, %e %b %Y %H:%M:%S %Z'
)

source_name = "data/cases_#{timestamp.strftime('%Y-%m-%dT%H-%M-%S')}.csv"

if File.file?(source_name)
  puts "No new version since #{source_name}"
else
  # remove today's and yesterday's entries, since the data may not be complete
  today = Date.today.strftime('%d-%m-%Y')
  yesterday = Date.today.prev_day.strftime('%d-%m-%Y')
  content = response.to_s.gsub(/\r\n?/, "\n")
                    .gsub(/^.+#{today}.+$/, '')
                    .gsub(/^.+#{yesterday}.+$/, '')
                    .sub(/\n*\Z/, '')

  File.open(source_name, 'w') do |f|
    f.puts content
  end
  puts "#{source_name} has been fetched"
end
