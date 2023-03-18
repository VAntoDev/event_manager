require 'csv'
if File.exists?('event_attendees.csv')
  puts "I exist!"
  puts "------"
end

contents = CSV.open(
  'event_attendees.csv',     #filename
  headers: true,             #find headers in the file
  header_converters: :symbol #converts headers to symbols
)

contents.each do |row|
  name = row[:first_name]    #picks each name in the header first_name
  zipcode = row[:zipcode]
  puts "Name: #{name} - Zipcode: #{zipcode}"
end


