module KeenCli

  class CLI < Thor

    desc 'plugins:install', 'Install a plugin'
    map 'plugins:install' => :plugins_install

    def plugins_install(name)
      begin
        puts "Installing keen-cli-#{name} plugin"
        gem "keen-cli-#{name}"
        true
      rescue LoadError
        %x("gem install keen-cli-#{name}")
        unless $? == 0
          false
        else
          true
        end
      end
    end
    
    desc 'plugins:remove', 'Remove a plugin'
    map 'plugins:remove' => :plugins_remove

    def plugins_remove(name)
      begin
        puts "Removing keen-cli-#{name} plugin"
        gem "keen-cli-#{name}"
        true
      rescue LoadError
        %x("gem uninstall keen-cli-#{name}")
        unless $? == 0
          false
        else
          true
        end
      end
    end
    
    # browse for installed plugins
	  begin
	    name = nil  # plugin name
	    plugins = Gem::Specification.select{ |g| g.name.downcase.include? "keen-cli-"} # keen-cli- prefix is used for plugins
	    plugins.each {|plugin|
	      name = plugin.name.gsub(/keen-cli-/,'')
	      
	      # load the plugin gem
	      require "keen-cli-#{name}"
	      command = Object.const_get("KeenCli::" << name.capitalize)
	      
	      # attach subcommand
  	    desc name, "Manage the #{name} plugin"
  	    subcommand name, command
	    }
    rescue LoadError	    
      # gem isn't installed
      puts "Could not find plugin \"#{name}\""
	  end
    
  end

end