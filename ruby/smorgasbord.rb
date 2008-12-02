require 'xgen/mongo'

# A convenience method that escapes text for HTML.
def h(o)
  o.to_s.gsub(/&/, '&amp;').gsub(/</, '&lt;').gsub(/>/, '&gt;').gsub(/'/, '&apos;').gsub(/"/, '&quot;')
end

class Object
  def method_missing sym, args
    msg = "method missing: #{sym}; class of self = #{self.class.name}"
    puts "<p style='color:red;'>#{msg}</p>"
    $stderr.puts "**** #{msg}"
  end
end

def header(level, title)
 puts "<h#{level}>#{title}</h#{level}>"
end
(1..6).each {|i| eval "def h#{i}(title); header(#{i}, title); end" }

def pre
  puts "<pre>"
  yield
  puts "</pre>"
end

def track_table(text=nil)
  puts "<table border='1' cellpadding='4px'>"
  puts "<caption>#{h(text)}</caption>" if text
  puts "<tr style='color:white;background:#333'><th>Id</th><th>Artist</th><th>Album</th><th>Song</th><th>Track</th></tr>"
  yield
  puts "</table>"
end

def br; puts "<br/>"; end

# ****************************************************************

h1 "Ruby Implementation Test"

print "<p><a href=\"/admin/doc?f=/ruby/#{File.basename(__FILE__)}\">[code]</a></p>"

h2 "Create Ruby object from JS class def"
pre {
  f = MyJSClass.new("bar")
  puts "Object.constants.include?('MyJSClass') = #{Object.constants.include?('MyJSClass')}"
  puts "f is of class #{f.class.name}"
  puts "f.inspect = #{f.inspect}"
  puts "f['moo'].getNumParameters = #{f['moo'].getNumParameters}"
  puts "can access f['foo'], but not f.foo because keySet has no foo. f['foo'] = #{f['foo'] }"
  puts "f.moo should be 'rab', it is '#{f.moo()}'"
}

h3 "Create subclass of JS class in Ruby"
pre {
   class SubclassOfMyJSClass < MyJSClass
     def initialize(arg)
       super(arg)
     end
     def method2
       "method2: " + moo
     end
   end

  puts "SubclassOfMyJSClass.new('bar').method2 = #{SubclassOfMyJSClass.new('bar').method2}"
}

# # FIXME
h3 "New class loaded from local file"
pre {
  load 'local/ruby/newclass'
  f = NewClass3.new("bar")
  puts "Object.constants.include?('NewClass3') = #{Object.constants.include?('NewClass3')}"
  puts "f is of class #{f.class.name}"
  puts "f.inspect = #{f.inspect}"
  puts "f['moo'].getNumParameters = #{f['moo'].getNumParameters}"
  puts "can access f['foo'], but not f.foo because keySet has no foo. f['foo'] = #{f['foo'] }"
  puts "f.moo should be 'rab', it is '#{f.moo()}'"
}

h3 "tojson JS func called with Ruby object"
pre {
  puts tojson(Struct.new(:name, :age).new('Jim', 4324))
}

h2 "Scope print"
pre {
  $scope.print("Hello, World!")
}

h3 "Scope print reassignment"
pre {
  puts "We should see stars around the output."
  $scope.print = Proc.new { |str| puts "*** #{str} ***" }
  $scope.print("Hello, World!")
  $scope.print = Proc.new { |str| print str }
}

h2 "Basic Stuff"
pre {
  x = 42
  puts "x = #{x}"

  puts "$data.count = #{$data.count}"
  puts "$data.plus_seven(35) = #{$data.plus_seven(35)}"
  puts "$data.plus_seven(35, 'abc') = #{$data.plus_seven(35, 'abc')}"
}

h2 "Top-Level Funcs Everywhere"
pre {
  puts "should see three hashes, all the same"
  puts tojson({'a' => 1, 'b' => 2})
  def json_inside
    puts tojson({'a' => 1, 'b' => 2})
  end
  json_inside
  class Foo
    def foo
      puts tojson({'a' => 1, 'b' => 2})
    end
  end
  Foo.new.foo()
}

h2 "GridFS"
require 'xgen/gridfile'
pre {
  GridFile.open('myfile', 'w') { |f|
    f.write "Hello, GridFS!"
    f['my-attribute'] = 42
  }
  GridFile.open('myfile', 'r') { |f|
    puts f.read
    puts "my-attribute = #{f['my-attribute']}"
  }
}

h2 "Database"

song_id = nil
pre {
  puts "Creating data..."
  $db.test.remove({})
  $db.test.save({:artist => 'Thomas Dolby', :album => 'Aliens Ate My Buick', :song => 'The Ability to Swing'})
  $db.test.save({:artist => 'Thomas Dolby', :album => 'Aliens Ate My Buick', :song => 'Budapest by Blimp'})
  $db.test.save({:artist => 'Thomas Dolby', :album => 'The Golden Age of Wireless', :song => 'Europa and the Pirate Twins'})
  $db.test.save({:artist => 'XTC', :album => 'Oranges & Lemons', :song => 'Garden Of Earthly Delights', :track => 1})
  track_jsobj = $db.test.save({:artist => 'XTC', :album => 'Oranges & Lemons', :song => 'The Mayor Of Simpleton', :track => 2})
  $db.test.save({:artist => 'XTC', :album => 'Oranges & Lemons', :song => 'King For A Day', :track => 3})
  song_id = track_jsobj._id.to_s
  puts "Data created. song_id = #{song_id}. There are #{$db.test.find(:all).length} records in the test collection."
}

h3 "Find One"

pre {
  # Find a single record with a particular id
  puts "The id I'm looking for is #{song_id}; I expect to see The Mayor Of Simpleton:"
  x = $db.test.findOne(song_id)

  puts "x.class.name = #{x.class.name}"
  puts "x = #{h(tojson(x))}"
  puts "x._id = #{x._id}"
  puts "x.name = # => #{x.song}"

  puts "tojson(x) = #{h(tojson(x))}"
}

h3 "Find"

h4 "all records"
pre {
  $db.test.find.each { |row| puts h(tojson(row)) }
}

h4 "search for \"Aliens Ate My Buick\""
pre {
  $db.test.find({:album => "Aliens Ate My Buick"}).each { |row| puts h(tojson(row)) }
}

h2 "XGen::Mongo::Base"

class Track < XGen::Mongo::Base
  collection_name :test
  fields :artist, :album, :song, :track

  def to_s
    "artist: #{artist}, album: #{album}, song: #{song}, track: #{track ? track.to_i : nil}"
  end

  def to_tr
    str = "<tr>"
    %w(_id artist album song track).each { |s|
      val = instance_variable_get("@#{s}")
      val = val.to_i if s == 'track' && val
      str << "<td>#{val ? h(val) : '&nbsp;'}</td>"
    }
    str << "</tr>"
    str
  end
end

h3 "Testing tojson(pure Ruby object)"
pre {
  t = Track.new({:song => 'New Song', :artist => 'New Artist', :album => 'New Album'})
  puts "tojson(Track.find(song_id)) = #{tojson(Track.find(song_id))}"
}

h3 "Various uses of find"

track_table("Track.collection.findOne(song_id)") {
  puts Track.new(Track.collection.findOne(song_id)).to_tr
}

br
track_table("Track.find(song_id)") {
  puts Track.find(song_id).to_tr
}

br
track_table("Track.find(song_id, :select => :album) -- only album field is returned") {
  puts Track.find(song_id, :select => :album).to_tr
}

h3 "Track.find_by_*"
track_table("find_by__id") {
  puts Track.find_by__id(song_id).to_tr
}

br
track_table("find by song 'Budapest by Blimp':") {
  puts Track.find_by_song("Budapest by Blimp").to_tr
}

h3 "Update"

x = Track.find_by_track(2)
track_table("track 2") { puts x.to_tr }

br
x.track = 99
track_table("after setting track to 99") { puts x.to_tr }
x.save
puts "<em>saved</em>"

br
track_table("find_by_track(99)") {
  puts Track.find_by_track(99).to_tr
}

br
track_table("find_by_song 'The Mayor Of Simpleton'") {
  puts Track.find_by_song('The Mayor Of Simpleton').to_tr
}

h3 "Track.find(:all)"
track_table {
  Track.find(:all).each { |t| puts t.to_tr }
}

h3 "Track.find(:all, :conditions => {:song => /to/})"
track_table {
  Track.find(:all, :conditions => {:song => /to/}).each { |row| puts row.to_tr }
}

h3 "Track.find(:all, :limit => 2)"
track_table {
  Track.find(:all, :limit => 2).each { |t| puts t.to_tr }
}

h3 "Track.find(:all, :conditions => {:album => 'Aliens Ate My Buick'})"
track_table {
  Track.find(:all, :conditions => {:album => 'Aliens Ate My Buick'}).each { |t| puts t.to_tr }
}

h3 "Track.find(:first)"

track_table("find first, no search params") { puts Track.find(:first).to_tr }

br
track_table("find first, track 3") { puts Track.find(:first, :conditions => {:track => 3}).to_tr }

h3 "Track.find_all_by_album"

track_table("find_all_by_album('Oranges & Lemons')") {
  Track.find_all_by_album('Oranges & Lemons').each { |t| puts t.to_tr }
}

h3 "Sorting"

track_table("Track.find(:all, :order => 'album desc')") {
  Track.find(:all, :order => 'album desc').each { |t| puts t.to_tr }
}

h3 "Track.new"
track_table {
  puts Track.new.to_tr
}

h3 "t = Track.new(hash); t.save"
t = Track.new(:artist => 'Level 42', :album => 'Standing In The Light', :song => 'Micro-Kid', :track => 1)
track_table {
  puts t.to_tr
}
puts "save returned #{t.save}"

h3 "Track.find_or_create_by_song"

s, a = 'The Ability to Swing', 'ignored because song found'
track_table("find_or_create_by_song(#{s}, :artist => #{a}") {
  puts Track.find_or_create_by_song(s, :artist => a).to_tr
}

br
s, ar, al = 'New Song', 'New Artist', 'New Album'
track_table("find_or_create_by_song(#{s}, :artist => #{ar}, :album => #{al})") {
  puts Track.find_or_create_by_song(s, :artist => ar, :album => al).to_tr
}

h3 "Track.find(:first, :conditions => {:song => 'King For A Day'}).delete"
t = Track.find(:first, :conditions => {:song => 'King For A Day'}).delete
track_table("Track.find(:first, {:song => 'King For A Day'}).remove") {
  Track.find(:all).each { |t| puts t.to_tr }
}

h3 "Track.find('bogus_id')"
pre {
  puts "I should see an exception here:"
  begin
    Track.find('bogus_id')
  rescue => ex
    puts ex.to_s
  end
}

h2 "new database features"

h3 "Track.find(:all, :conditions => {:song => 'King For A Day'}).explain()"
pre {
  puts tojson(Track.find(:all, :conditions => {:song => 'King For A Day'}).explain())
}

h2 "require"

# Test require
require 'pp'
pre {
  puts "required 'pp', here is a new track presented using pretty_inspect:"
  puts h(Track.new(:artist => 'Level 42', :album => 'Standing In The Light', :song => 'Micro-Kid', :track => 1).pretty_inspect)
}
