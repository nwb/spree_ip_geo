module Spree
  class MaxmindConfiguration

    def self.account
      bronto_yml=File.join(Rails.root,'config/maxmind.yml')
      if File.exist? bronto_yml
        bronto_yml=File.join(Rails.root,'config/maxmind.yml')
        YAML.load(File.read(bronto_yml))
      end
    end
  end
end