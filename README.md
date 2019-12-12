# Snoo Data Analysis

The Snoo basinet from [The Happiest Baby](https://happiestbaby.com) is a life-changing device for new parents.

The Snoo companion app is great for viewing your baby's sleep progression from one day to another, but it doesn't tell you much about long-term changes or patterns.

As a data geek, I wanted to know more! So I contacted support and asked them for a full data download ... which they happily obliged. Thanks guys, great service!

Once I'd formatted the data into a grid I loaded into Google Sheets to visualize:

![alt text](https://user-images.githubusercontent.com/42993/70681394-34ba7480-1c69-11ea-8609-a618d3f883cf.png
 "Google Sheets screenshot")

The viz clearly shows the key sleep milestones, including dropping several night-time feeds, as well as the infamous 4 month sleep regression (ugh!).

## How to use

* Download the script
* Ensure you have Ruby 2.6 (or thereabouts) installed
* Request your data export from support@happiestbaby.com (maybe one day they'll provide this data via your user account, hint hint!)
* Set your preferred variables in the first lines of the script
* Run it! `$ ruby parse.rb`