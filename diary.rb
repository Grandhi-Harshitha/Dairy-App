require 'json'
require 'digest'
require 'date'

# === Constants ===
DIARY_FILE = 'diary.json'
CONFIG_FILE = 'config.json'

# === Load or Set Password ===
def setup_password
  if !File.exist?(CONFIG_FILE)
    print "Set your diary password: "
    password = gets.chomp
    hashed = Digest::SHA256.hexdigest(password)
    File.write(CONFIG_FILE, { password: hashed }.to_json)
    puts "Password set successfully!"
  else
    stored = JSON.parse(File.read(CONFIG_FILE))
    print "Enter password: "
    password = gets.chomp
    if Digest::SHA256.hexdigest(password) != stored["password"]
      puts "❌ Incorrect password. Exiting."
      exit
    end
  end
end

# === Load Diary Entries ===
def load_diary
  if File.exist?(DIARY_FILE)
    JSON.parse(File.read(DIARY_FILE))
  else
    {}
  end
end

# === Save Diary Entries ===
def save_diary(diary)
  File.write(DIARY_FILE, JSON.pretty_generate(diary))
end

# === Add New Entry ===
def add_entry(diary)
  today = Date.today.to_s
  print "Entry title: "
  title = gets.chomp
  print "Write your diary entry:\n> "
  content = gets.chomp
  timestamp = Time.now.strftime("%Y-%m-%d %H:%M:%S")

  diary[today] ||= []
  diary[today] << { title: title, entry: content, timestamp: timestamp }

  save_diary(diary)
  puts "✅ Entry added successfully for #{today}."
end

# === View Entries by Date ===
def view_by_date(diary)
  print "Enter date (YYYY-MM-DD): "
  date = gets.chomp
  if diary[date]
    puts "\n📅 Entries for #{date}:"
    diary[date].each_with_index do |entry, index|
      puts "  #{index+1}. #{entry['title']} @ #{entry['timestamp']}"
      puts "     #{entry['entry']}"
    end
  else
    puts "No entries found for that date."
  end
end

# === Search by Keyword ===
def search_entries(diary)
  print "Enter keyword to search: "
  keyword = gets.chomp.downcase
  found = false

  diary.each do |date, entries|
    entries.each do |entry|
      if entry["entry"].downcase.include?(keyword) || entry["title"].downcase.include?(keyword)
        puts "\n🔍 Match on #{date} (#{entry['title']}):"
        puts entry["entry"]
        found = true
      end
    end
  end

  puts "No matches found." unless found
end

# === Menu ===
def menu
  puts "\n📓 Personal Diary"
  puts "1. Add Entry"
  puts "2. View Entries by Date"
  puts "3. Search by Keyword"
  puts "4. Exit"
  print "Choose an option: "
  gets.chomp
end

# === Main Program ===
setup_password
diary = load_diary

loop do
  case menu
  when "1" then add_entry(diary)
  when "2" then view_by_date(diary)
  when "3" then search_entries(diary)
  when "4"
    puts "👋 Goodbye!"
    break
  else
    puts "Invalid option, try again."
  end
end
