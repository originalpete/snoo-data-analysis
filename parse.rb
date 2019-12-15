require 'csv'
require 'active_support/all'

# This script converts Snoo data export (request from support@happiestbaby.com)
# into a data grid suitable for displaying visually.

# To-do: fix offset for DST.

# -------------------------------
# PARAMS

# Dates to visualize
start_date = Date.parse("2 July 2019")
end_date = Date.parse("1 Dec 2019")

# Where should a full "day" of data start? If you use the Snoo at night time only then an hour before bedtime is a good point.
offset = 18.hours

# 5 minutes granularity works well
window = 5.minutes

# Data file locations
infile = "./data/export-from-happiest-baby.csv"
outfile = "./data/grid-#{Time.now.to_s}.csv"

# /PARAMS
# -------------------------------


# Load CSV and convert to eventstream
puts "Reading data from #{infile}"
events = CSV.foreach(
    infile, 
    headers: true, converters: [:numeric, ->(v) { Time.parse(v) rescue v }]
  ).
  to_a.

# If you look at the data you'll see there appears to a be a duplicate
# set of events, with a different format session_id. 

# From Snoo support:
# > The two sets of data are essentially the same data, 
# > but can have minor differences.
# > The long session_id entries are the raw data sent from SNOO as events happen. 
# > Because they are raw data, sometimes some pieces of data can be missing
# > such as a level-up event missing because there was a network glitch. 
# > Whenever a session ends, SNOO would send a summary with all the info 
# > in that sleep session, and these are the data in the short session_id.

# Ergo, we remove the longer "UUID" format session_id data.
  filter!{|e| e["session_id"].to_s.size < 12}

# Create grid structure
dates = (start_date ... end_date).to_a

# Iterate over each window period, and insert 
slots = []
dates.each do |d|
  puts "Processing #{d}"

  (1.day / window).times do |t|
    slot_start = d.to_time + t*window + offset
    slot_end = d.to_time + (t+1)*window + offset
    slots << {
      start: slot_start,
      end: slot_end,

      # find all overlapping levels for this slot
      levels: events.filter{|e| (slot_start..slot_end).overlaps? (e["level_start_time_utc_time"]..e["level_end_time_utc_time"])}.map{|e| e["level"]}.uniq
    }
  end

end

puts "Writing grid to #{outfile}"

CSV.open(outfile, "wb") do |csv|
  csv << ["time"] + dates

  grid = slots.each_slice(1.day / window).to_a.transpose
  grid.each do |row|
    t = row.first[:start].strftime("%H:%M")
    values = row.map{|s|
      case 
        when s[:levels].join.match(/BASELINE/) then 0
        when s[:levels].join.match(/LEVEL1/) then 1
        when s[:levels].join.match(/LEVEL2/) then 2
        when s[:levels].join.match(/LEVEL3/) then 3
        when s[:levels].join.match(/LEVEL4/) then 4
        else nil
      end
    }
    csv << [t] + values
  end
end