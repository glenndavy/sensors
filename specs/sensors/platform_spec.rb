require 'spec_helper'

describe Sensors::Platform do
  it "can correctly determine when running on linux" do
    #'def' is my 'stubber'
    class Sensors::Platform
      def self.architecture
        "i686_linux"
      end
    end
    Sensors::Platform.platform.must_equal "linux"
  end


  it "can correctly determine when running on darwin" do
    #'def' is my 'stubber'
    class Sensors::Platform
      def self.architecture
        "x86_64-darwin11.0.4"
      end
    end

    Sensors::Platform.platform.must_equal "darwin"
  end
end
