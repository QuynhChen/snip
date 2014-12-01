## Stypi session: https://code.stypi.com/jgerminario/snip

class FileReader
attr_reader :file_to_open

  def initialize(file_to_open)
    @@file_to_open = file_to_open
    @array_of_lines = Array.new
  end

  def convert_to_array_of_lines
    File.open(@@file_to_open, "r").each do |line|
      @array_of_lines << line
    end
    @array_of_lines
  end
end

# => -----------------------------------------------------

#("\n" and whitespace are necessary to keep to preserve formatting):
#["#<snip>\n", "  def age!\n", "    @oranges += Array.new(rand(1..10)) { Orange.new } if @age > 5\n", "  end\n", "#</snip>\n", "\n", "#<snip>\n", "  def any_oranges?\n", "    !@oranges.empty?\n", "  end\n", "#</snip>\n", "\n"]

class Snippet
  @@snippet_array = []
  attr_reader :code_array

  def initialize(code_array)
    @code_array = code_array
    @@snippet_array << self
  end

  def self.snippet_array
    @@snippet_array
  end
end

class CodeScanner
  @file_array = []
  class << self; attr_reader :file_array end
  def self.run(file_array)
    @file_array = file_array
    while @file_array.include?("#<snip>\n")
     Snippet.new(array_range)
    end
  end

  def self.find_begin_range
    @file_array.each_with_index do |line, index|
      if line.include?("<snip>")
        strip_snip_tag(index)
        return @begin_scan = index
      end
    end
    return false
  end

  def self.find_end_range
    @file_array.each_with_index do |line, index|
      if line.include?("</snip>")
        strip_snip_tag(index)
        return @end_scan = index
      end
    end
    return false
  end

   def self.array_range
    find_begin_range
    find_end_range
    @file_array[@begin_scan+1..@end_scan-1]
  end

  def self.strip_snip_tag(index)
    @file_array[index] = ""
  end
end

# => -----------------------------------------------------


# Input ex:
#[#<Snippet:0x007fc98c9cbd20 @code_array=["  def age!\n", "    @oranges += Array.new(rand(1..10)) { Orange.new } if @age > 5\n", "  end\n"]>, #<Snippet:0x007fc98c9ca678 @code_array=["  def any_oranges?\n", "    !@oranges.empty?\n", "  end\n"]>]


require_relative 'viewformatter'

module FileWriter

  extend self

  def run(snippet_array)
    # @new_file_name = @@file_to_open.delete(".rb") + "_snipped.rb"
    @new_file_name = "my_snips.rb"
    file_exists?
    create_new_file
    write_file(snippet_array)
  end

  def file_exists?
    dir = Dir.new(".")
    dir.entries.include?(@new_file_name)
  end

  def create_new_file
    unless file_exists?
      File.new(@new_file_name, 'w')
    end
  end

  def write_file(snippet_array)
    File.open(@new_file_name, "w") do |file|
      snippet_array.each_with_index do |snip_object, index|
        file << ViewFormatter.snippet_indexer(index)
        snip_object.code_array.each do |line|
          file << line
        end
        file << "\n"
      end
    end
  end

  def full_file_directory
    File.absolute_path(@new_file_name)
  end

end
## debugger: gem install debugger from command line

require 'debugger'

require_relative 'filereader'
require_relative 'codescanner'
require_relative 'filewriter'

module CommandLineController

  extend self

  def run
    file_read = FileReader.new(ARGV.first)
    to_run = file_read.convert_to_array_of_lines
    CodeScanner.run(to_run)
    FileWriter.run(Snippet.snippet_array)
    puts ViewFormatter.success_message(FileWriter.full_file_directory)
  end
end

CommandLineController.run

#Tests:
# p file_write.file_exists?
# p file_write.create_new_file
# p file_write.write_file
# p Snippet.snippet_array
