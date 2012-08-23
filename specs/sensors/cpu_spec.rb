require 'spec_helper'

def stub_read_proc_stat(cpu=1, snapshot=1)
  Sensors::Utility::Proc.send(:define_singleton_method,"proc_stat_filename"){"specs/fixtures/proc_stat_#{cpu}_cpu_snapshot0#{snapshot}"} 
end

def first_hash
  {
    "cpu" => {
                user:        3460,
                nice:        1066,
                system:      2132,
                idle:     7652491,
                iowait:      3546,
                irq:            0,
                softirq:       34,
                steal:       2316,
                guest:          0,
                niceguest:      0
              },
    "cpu0" => {
                user:        3460,
                nice:        1066,
                system:      2132,
                idle:     7652491,
                iowait:      3546,
                irq:            0,
                softirq:       34,
                steal:       2316,
                guest:          0,
                niceguest:      0
              }
  }
end

def second_hash
  {
    "cpu" => {
                user:        3560,
                nice:        1066,
                system:      2182,
                idle:     7652641,
                iowait:      3546,
                irq:            0,
                softirq:       34,
                steal:       2316,
                guest:          0,
                niceguest:      0
              },
    "cpu0" => {
                user:        3560,
                nice:        1066,
                system:      2182,
                idle:     7652641,
                iowait:      3546,
                irq:            0,
                softirq:       34,
                steal:       2316,
                guest:          0,
                niceguest:      0
              }
  }

end

def stats_hash
  {
    "cpu" => {
                user:        33.33,
                nice:        0.0,
                system:      16.67,
                idle:        50.0,
                iowait:      0.0,
                irq:         0.0,
                soft_irq:    0.0,
                steal:       0.0,
                guest:       0.0,
                niceguest:   0.0,
                usage:       50.0
              },
    "cpu0" => {
                user:        33.33,
                nice:        0.0,
                system:      16.67,
                idle:        50.0,
                iowait:      0.0,
                irq:         0.0,
                soft_irq:    0.0,
                steal:       0.0,
                guest:       0.0,
                niceguest:   0.0,
                usage:       50.0
              }
  }

end
describe Sensors::CPU do

  describe "When on linux" do
    describe Sensors::Utility::Proc do

      before do
        stub_read_proc_stat
        @correct_first_hash = first_hash
      end

      it "should return correct hash" do 

        Sensors::Utility::Proc.cpu_hash.must_equal @correct_first_hash
      end
    end

    describe "when polling" do
      before(:each) do
        @correct_first_hash  = first_hash
        @correct_second_hash = second_hash
        @correct_stats_hash  = stats_hash
        @first_snapshot  = IO.readlines( "specs/fixtures/proc_stat_1_cpu_snapshot01" )
        @second_snapshot = IO.readlines( "specs/fixtures/proc_stat_1_cpu_snapshot02" )
        Sensors::CPU.send(:define_method,"get_current_time") { Time.at(0) }
        @cpu_poller = Sensors::CPU.new
      end

      it "reports zero on the first poll" do
        stub_read_proc_stat
        @cpu_poller.poll
        [ :user,
          :nice,
          :system,
          :idle,
          :iowait,
          :irq,
          :soft_irq,
          :steal,
          :guest,
          :niceguest,
          :usage].each do |stat_method|
              @cpu_poller.send(stat_method).must_equal 0
         end
      end

      it "sets up the next poll correctly" do
        stub_read_proc_stat

        @cpu_poller.instance_variable_get("@first_poll").must_equal true 
        @cpu_poller.instance_variable_get("@last_cpu_times").must_be_empty
        @cpu_poller.instance_variable_get("@poll_time").must_equal Time.at(0)
        @cpu_poller.instance_variable_get("@last_poll_time").must_equal Time.at(0)

        @cpu_poller.poll
        @cpu_poller.instance_variable_get("@first_poll").must_equal false
        @cpu_poller.instance_variable_get("@last_cpu_times").must_be_empty
        @cpu_poller.instance_variable_get("@cpu_times").must_equal @correct_first_hash

        @cpu_poller.class.send(:define_method,"get_current_time") { Time.at(5) }
        stub_read_proc_stat(1,2)
        @cpu_poller.poll
        @cpu_poller.instance_variable_get("@first_poll").must_equal false
        @cpu_poller.instance_variable_get("@last_cpu_times").must_equal @correct_first_hash
        @cpu_poller.instance_variable_get("@cpu_times").must_equal @correct_second_hash
        @cpu_poller.instance_variable_get("@last_poll_time").must_equal Time.at(0)
        @cpu_poller.instance_variable_get("@poll_time").must_equal Time.at(5)
      end

      it "does a differential poll" do
        @cpu_clone = @cpu_poller.clone
        stub_read_proc_stat
        poller_thread  = Thread.new { @cpu_poller.polling_mode = :double; @cpu_poller.poll(5) }
        stubber_thread = Thread.new { @cpu_poller.class.send(:define_method,"get_current_time") { Time.now + 5 };
                                     stub_read_proc_stat(1,2)}

        poller_thread.join
        stubber_thread.join
        @cpu_poller.instance_variable_get("@cpu_stats").must_equal @correct_stats_hash
        @cpu_poller = @cpu_clone
      end
    end
    
    def setup_second_poll
      Sensors::CPU.send(:define_method,"get_current_time") { Time.at(3) }
    end

    describe "for various numbers of cpu:" do
      describe  "1 cpus" do 
        before do 
          Sensors::CPU.send(:define_method,"get_current_time") { Time.at(0) }
          @cpu_poller = Sensors::CPU.new
          @cpu_poller.poll
        end

        it "reports 1 cpu" do
          @cpu_poller.number_of_cpus.must_equal 1
        end

        it "can correctly show cpu usage %" do
          stub_read_proc_stat(1,2)
          setup_second_poll
          @cpu_poller.poll
          @cpu_poller.cpu_stats["cpu"][:usage].must_equal 50
          @cpu_poller.usage.must_equal 50
          @cpu_poller.usage("cpu").must_equal 50
          @cpu_poller.usage("cpu0").must_equal 50

          @cpu_poller.cpu_stats["cpu"][:user].must_equal 33.33
          @cpu_poller.user.must_equal 33.33
          @cpu_poller.user("cpu").must_equal 33.33
          @cpu_poller.user("cpu0").must_equal  33.33
          
          @cpu_poller.cpu_stats["cpu"][:idle].must_equal 50
          @cpu_poller.idle.must_equal 50
          @cpu_poller.idle("cpu").must_equal 50
          @cpu_poller.idle("cpu0").must_equal 50

          @cpu_poller.cpu_stats["cpu"][:system].must_equal 16.67
          @cpu_poller.system.must_equal 16.67
          @cpu_poller.system("cpu").must_equal 16.67
          @cpu_poller.system("cpu0").must_equal 16.67

          @cpu_poller.cpu_stats["cpu"][:nice].must_equal 0
          @cpu_poller.nice.must_equal 0
          @cpu_poller.nice("cpu").must_equal 0
          @cpu_poller.nice("cpu0").must_equal 0
        end
      end
    end
  end

  describe "When on darwin" do
  end

end

