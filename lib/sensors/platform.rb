module Sensors

  class Platform

    def self.platform
      ["linux","darwin"].select{|p| self.architecture.match p}.first
    end

    def self.architecture
      RbConfig::CONFIG["arch"]
    end

  end

end
