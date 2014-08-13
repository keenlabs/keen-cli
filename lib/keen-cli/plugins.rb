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
    
  end

end