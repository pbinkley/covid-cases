#!/usr/bin/env ruby

require 'httparty'
require 'csv'
require 'byebug'

timestamp = DateTime.now.strftime('%Y-%m-%dT%H-%d-%S')

url = 'https://docs.google.com/spreadsheets/u/2/d/1D6okqtBS3S2NRC7GFVHzaZ67DuTw7LX49-fqSLwJyeo/export?format=csv&id=1D6okqtBS3S2NRC7GFVHzaZ67DuTw7LX49-fqSLwJyeo&gid=2036294689'
source_name = "data/recoveries-#{timestamp}.csv"

response = HTTParty.get(url)
text = response.to_s
# drop first three lines
lines = text.split(/\n+/).drop(3)

input = CSV.parse(lines.join("\n"), headers: true)

CSV.open(source_name, 'w') do |csv|
  csv << %w[date_recovered province cumulative_recovered]
  input.each do |row|
    csv << [row['date_recovered'], row['province'], row['cumulative_recovered']]
  end
end

puts "#{source_name} has been fetched"
