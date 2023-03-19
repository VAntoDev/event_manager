require 'csv'

def clean_zipcode(zipcode)
  if zipcode.nil?
    zipcode = '00000'
  elsif zipcode.length < 5
    zipcode = zipcode.rjust(5, '0')
  elsif zipcode.length > 5
    zipcode = zipcode[0..4]
  else
    zipcode
  end
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


