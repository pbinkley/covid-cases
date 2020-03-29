#!/usr/bin/env ruby

# frozen_string_literal: true

require 'byebug'
require 'csv'
require 'date'

PROVINCES = ['Alberta', 'BC', 'Manitoba', 'New Brunswick', 'NL',
             'Nova Scotia', 'Ontario', 'PEI', 'Quebec', 'Saskatchewan',
             'NWT', 'Nunavut', 'Yukon'].freeze

source_name = Dir.glob('data/recoveries_*.csv').max
timestamp = source_name.split('_')[1]

data = CSV.read(source_name, headers: true)
dates = data.group_by { |row| row['date_recovered'] }
master = []

dates.keys.each do |date|
  proper_date = Date.strptime(date, '%d-%m-%Y').strftime('%Y-%m-%d')
  provinces = dates[date].group_by { |row| row['province'] }
  row = [proper_date]
  PROVINCES.each do |key|
    row << provinces[key].first.field('cumulative_recovered').to_i
  end
  master << row
end

master.sort_by! { |row| row[0] }

previous_output = Dir.glob('data/processed-recoveries_*.csv').max
output_name = "data/processed-recoveries_#{timestamp}"

puts "Previous: #{previous_output}; new: #{output_name}"

# convert cumulative to daily
CSV.open(output_name, 'w') do |csv|
  csv << ['Date'] + PROVINCES
  prev = ['dummy', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  master.each do |row|
    output_row = [row[0]]
    (1..13).each do |field|
      output_row << row[field] - prev[field]
    end
    csv << output_row
    prev = row
  end
end

exec("diff #{previous_output} #{output_name}")
