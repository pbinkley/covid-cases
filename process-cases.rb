#!/usr/bin/env ruby

# frozen_string_literal: true

require 'byebug'
require 'csv'
require 'date'

# we will iterate the dates from the beginning of the csv to the end
# note: there are entries for "Repatriated Travellers" and "Repatriated
# travellers", so we will ignore case

unitnames = ['alberta', 'british columbia', 'canada', 'manitoba',
             'new brunswick', 'newfoundland and labrador',
             'northwest territories', 'nova scotia', 'nunavut', 'ontario',
             'prince edward island', 'quebec', 'repatriated travellers',
             'saskatchewan', 'yukon'].freeze

source_name = Dir.glob('data/cases_*.csv').max
timestamp = source_name.split('_')[1]

# read csv and convert to array of hashes
data = CSV.read(source_name, headers: true).map(&:to_hash)

# convert date format and downcase province name
data.map! do |row|
  row['date'] = Date.strptime(row['date'], '%d-%m-%Y').strftime('%Y-%m-%d')
  row['prname'].downcase!
  row
end

dates = data.group_by { |row| row['date'] }
output = []
prev = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

dates.keys.sort.each do |date|
  # dates[date] is an array of rows for provinces on that date
  units = dates[date].group_by { |row| row['prname'] }
  row = []
  unitnames.each do |unitname|
    row << (units[unitname] ? units[unitname].first['numtotal'].to_i : 0)
  end
  # subtract previous value, to get new cases that day
  output_row = row.dup
  (0..14).each { |i| output_row[i] -= prev[i] }
  output << [date] + output_row
  prev = row
end

# add rows of zeros for missing dates (which had no new cases)
first = Date.parse(dates.keys.first)
last = Date.parse(dates.keys.last)

(first..last).each do |date|
  date_string = date.strftime('%Y-%m-%d')
  next if dates[date_string]

  output << [date_string, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
end

# sort the added rows in
output.sort_by! { |row| row[0] }

previous_output = Dir.glob('data/processed-cases_*.csv').max
output_name = "data/processed-cases_#{timestamp}"

puts "Previous: #{previous_output}; new: #{output_name}"

CSV.open(output_name, 'w') do |csv|
  csv << ['date'] + unitnames
  output.each { |row| csv << row }
end

exec("diff #{previous_output} #{output_name}")