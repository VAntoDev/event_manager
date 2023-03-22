require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'time'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]  #to_s makes the nil become "", rjust adjusts strings smaller than 5 with '0', slice makes longer strings only 5 digits
end

def clean_phone_number(phone_number)
  phone_number.gsub!(/[^0-9A-Za-z]/, '')
  if phone_number.length == 10
    phone_number
  elsif phone_number.length == 11
    if phone_number[0] == 1
      phone_number.chr
      phone_number
    else
      "Not Valid Phone Number"
    end
  else
    "Not Valid Phone Number"
  end
end

def time_targeting(full_date) 
  date = create_date_obj(full_date)
  date
end

def create_date_obj(reg_full_date)
  reg_full_date.gsub!(/[^0-9A-Za-z]/, ' ')
  reg_full_date = reg_full_date.split(" ")
  year = 2000 + reg_full_date[0].to_i
  day = reg_full_date[1].to_i
  month = reg_full_date[2].to_i
  hour = reg_full_date[3].to_i
  minutes = reg_full_date[4].to_i

  date = Time.new(year,month,day,hour,minutes)
end

def calculate_hour_peak(arr)
  first = arr.max_by {|i| arr.count(i)}
  arr.delete(first)
  second = arr.max_by {|i| arr.count(i)}
  arr.delete(second)
  third = arr.max_by {|i| arr.count(i)}
  return "#{first}, #{second} and #{third}"
end

def calculate_day_reg_peak(arr)
  week = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
  week[arr.max_by {|i| arr.count(i)}]
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id,form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

puts "Event manager initialized!"

contents = CSV.open(
  'event_attendees.csv',     #filename
  headers: true,             #find headers in the file
  header_converters: :symbol #converts headers to symbols
)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

peak_hours = []
peak_week_days = []

contents.each do |row|
  id = row[0]
  name = row[:first_name]    #picks each name in the header first_name
  zipcode = clean_zipcode(row[:zipcode])
  phone_num = clean_phone_number(row[:homephone])
  reg_date = (row[:regdate])

  peak_hours.push(time_targeting(reg_date).hour)
  peak_week_days.push(time_targeting(reg_date).wday)

  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)

  save_thank_you_letter(id,form_letter)

end

puts "The three most relevant hour peaks are: #{calculate_hour_peak(peak_hours)}"
puts "The day most people registered is: #{calculate_day_reg_peak(peak_week_days)}"
