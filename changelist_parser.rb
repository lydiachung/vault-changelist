require 'yaml'
require 'csv'

class ChangelistParser

  def initialize()
  end

  def parse()
    a_changelist = YAML.load_file('changelist.yml')
    h_changelist = {}
    s_prev_path = ""
    CSV.open("filelist.csv", "w") do |o_csv|
      a_changelist.each do |a_change|
      
        s_file_name = "/#{a_change[0]}"
        s_file_path = File.dirname(s_file_name)
        s_file_base = File.basename(s_file_name)
        s_file_ext = File.extname(s_file_name)
        
        o_csv << [s_file_path] unless s_file_path == s_prev_path
        o_csv << [nil,s_file_base] unless s_file_ext.empty?
        
        s_prev_path = s_file_path
      end
    end
    
  end
  
end

ChangelistParser.new.parse