#
# Copyright 2011 Boy van Amstel, http://boyvanamstel.nl, @boyvanamstel
#

$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'rubygems'
require 'fssm'

# Setup default path
$chat_file = "chat.txt"

puts "Nickname:"
user = gets.strip
$user = user == "" ? "Guest#{Time.now.hour + Time.now.min + Time.now.sec}" : user

# Get text
def talk
  s = gets
  file = File.open(File.join('.', $chat_file),"a+")
  file.write "#{$user}: #{s}"
  file.close
  talk
end

# Do something with a change
def act(base, relative)
  if relative == $chat_file
    puts `tail -n 1 #{File.join('.', $chat_file)}`
  end
end

# Setup FSSM to watch the file
a = Thread.new do
  FSSM.monitor do
    path '.' do
      update { |b,r| act(b,r) } 
      delete { |b,r| act(b,r) }
      create { |b,r| act(b,r) }
    end
    puts "Hi #{$user}! Start talking :)"
  end
end

b = Thread.new do
  file = File.open(File.join('.', $chat_file),"a+")
  file.write "-- #{$user} entered\n"
  file.close
  talk
end

a.join
b.join
