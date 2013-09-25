require 'yaml'
require 'rexml/document'

include REXML

class VaultChangelist
	
  attr_accessor :vault_config
  attr_accessor :commit_logs
  attr_accessor :changelist
  
  def initialize()
    @vault_config = YAML.load_file('vault_config.yml')
    @changelist = {} # key = file name, value = array of commits
  end
  
  def get_version_history()
    # retrive all commits since the begin date
    s_hist_cmd = %{"#{@vault_config["vault_exe"]}" versionhistory 
      -host #{@vault_config["vault_host"]} 
      -user #{@vault_config["vault_user"]} 
      -password "#{@vault_config["vault_password"]}" 
      -repository #{@vault_config["vault_repo"]} 
      -beginversion "#{@vault_config["vault_begin_version"]}"
      "#{@vault_config["vault_folder"]}"
    }
    
    s_cmd_output = %x{#{s_hist_cmd.gsub("\n","")}} # remove newline
    
    o_doc = Document.new(s_cmd_output)
    
    XPath.each(o_doc, "//item") do |o_element| 
      c_version = o_element.attribute("version").value
      o_comment = o_element.attribute("comment")
      c_comment = o_comment.value unless o_comment.nil?
      get_history(c_version, c_comment)
    end
    
    File.open('changelist.yml', 'w') do |o_file|
      o_file.write(@changelist.sort.to_yaml)
    end
  end
  
  def get_history(c_version, c_comment)
    # retrieve file changelist by each commit 
    
    puts "getting file list for commit #{c_version}"
    
    s_hist_cmd = %{"#{@vault_config["vault_exe"]}" history 
      -host #{@vault_config["vault_host"]} 
      -user #{@vault_config["vault_user"]} 
      -password "#{@vault_config["vault_password"]}" 
      -repository #{@vault_config["vault_repo"]} 
      -beginversion #{c_version}
      -endversion #{c_version}
      "#{@vault_config["vault_folder"]}"
    }
    
    s_cmd_output = %x{#{s_hist_cmd.gsub("\n","")}} # remove newline
    
    o_doc = Document.new(s_cmd_output)

    XPath.each(o_doc, "//item") do |o_element|
      c_file_name = o_element.attribute("name").value.downcase
      
      if @changelist.include?(c_file_name)
        a_comments = @changelist[c_file_name]
      else
        a_comments = []
        @changelist[c_file_name] = a_comments
      end
      
      a_comments << c_comment
      
    end
    
  end

end

VaultChangelist.new.get_version_history