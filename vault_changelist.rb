require 'yaml'
require 'rexml/document'

include REXML

class VaultChangelist
	
  attr_accessor :vault_config
  attr_accessor :file_names
  attr_accessor :commit_logs
  attr_accessor :changelist
  
  def initialize()
    @vault_config = YAML.load_file('vault_config.yml')
    @file_names = []
    @commit_logs = {}
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
      -rowlimit 3
      "#{@vault_config["vault_folder"]}"
    }
    
    s_cmd_output = %x{#{s_hist_cmd.gsub("\n","")}} # remove newline
    
    o_doc = Document.new(s_cmd_output)
    
    XPath.each(o_doc, "//item") do |o_element| 
      c_version = o_element.attribute("version").value
      @commit_logs[c_version] = o_element.attribute("comment").value
      get_history(c_version)
    end
    
    File.open('files.yml', 'w') do |o_file|
      o_file.write(@file_names.to_yaml)
    end
    
    File.open('commit_logs.yml', 'w') do |o_file|
      o_file.write(@commit_logs.to_yaml)
    end
  end
  
  def get_history(c_version)
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
      @file_names << c_file_name unless @file_names.include?(c_file_name)
    end
    
  end

  def get_
  end
  
end



VaultChangelist.new.get_version_history