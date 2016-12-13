require 'spec_helper'

describe KeenCli::CLI do

  def start(str=nil)
    KeenCli::CLI.start(str ? str.split(" ") : [])
  end
  
  describe 'install' do
    it 'fails if no plugin is specified' do
      _, options = start "plugins:install"
      expect(_).to be_nil
    end
    
    it 'fails if plugin doesn\'t exist' do
      _, options = start "plugins:install undefined"
      expect(_).to be false
    end
  end
  
  describe 'remove' do
    it 'fails if no plugin is specified' do
      _, options = start "plugins:remove"
      expect(_).to be_nil
    end
    
    it 'fails if plugin doesn\'t exist' do
      _, options = start "plugins:remove undefined"
      expect(_).to be false
    end
  end
  
end