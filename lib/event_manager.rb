require 'csv'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]  #to_s makes the nil become "", rjust adjusts strings smaller than 5 with '0', slice makes longer strings only 5 digits
end

contents = CSV.open(
  'event_attendees.csv',     #filename
  headers: true,             #find headers in the file
  header_converters: :symbol #converts headers to symbols
)

contents.each do |row|
  name = row[:first_name]    #picks each name in the header first_name
  zipcode = clean_zipcode(row[:zipcode])

  puts "Name -> #{name} - #{zipcode} <- Zipcode"
end


