module Spree
  class ZinreloConfiguration
    attr_reader :account

    def initialize
      @account= load_account
    end

    def self.account
      zinrelo_yml=File.join(Rails.root,'config/zinrelo.yml')
      if File.exist? zinrelo_yml
        zinrelo_yml=File.join(Rails.root,'config/zinrelo.yml')
        YAML.load(File.read(zinrelo_yml))
      end
    end

    private
    def load_account
      zinrelo_yml=File.join(Rails.root,'config/zinrelo.yml')
      if File.exist? zinrelo_yml
        zinrelo_yml=File.join(Rails.root,'config/zinrelo.yml')
        YAML.load(File.read(zinrelo_yml))
      end
    end
  end
end