module Sensors
  class CPU
    attr_accessor :cpu_stats

    STAT_LABELS = [ :user,
      :nice,
      :system,
      :idle,
      :iowait,
      :irq,
      :soft_irq,
      :steal,
      :guest,
      :niceguest,
      :usage ]

    def initialize(opts = {})
      @first_poll                = true
      @cpu_times                 = {}
      @last_cpu_times            = []
      @poll_time                 = get_current_time
      @last_poll_time            = @poll_time
      @cpu_stats                 = nil
      @cpu_percentage_stats      = nil
      @polling_mode              = opts.delete(:polling_mode) || "single"
    end

    STAT_LABELS.each do |m|
      define_method(m) do |cpu="cpu"|
        if @cpu_stats
          @cpu_stats[cpu][m] || 0 
        else
          0
        end
      end
    end
    
    def polling_mode
      @polling_mode
    end

    def polling_mode=(pm=:single)
      if [:single,:double].include?(pm.to_sym)
        @polling_mode = pm
      else
        raise "Invalid Polling Mode"
      end
    end

    def poll(period=nil)
      send("#{polling_mode.to_s}_shot", period )
    end

    def single_shot(period=nil)
      @last_poll_time  = @poll_time
      @last_cpu_times  =  @cpu_times
      @cpu_times       = Sensors::Utility::Proc.cpu_hash
      @cpu_stats = calculate_stats unless @first_poll
      @first_poll      = false
      @poll_time       = get_current_time
    end

    def double_shot(period=3)
      single_shot
      sleep period
      single_shot
    end

    def calculate_stats
      diffs   = {}
      results = {}
      @cpu_times.each do |cpu, stats|
        diffs[cpu] = {}
        stats.each do |key,value|
          diffs[cpu][key] = value - @last_cpu_times[cpu][key]
        end
        total_ticks = diffs[cpu].inject(0){|s,(k,v)|s+v}

        results[cpu] = {}

        STAT_LABELS.each do |stat|
          results[cpu][stat] = ((diffs[cpu][stat].to_f / total_ticks) * 1000 / 10).round(2) if total_ticks > 0 unless (stat == :usage)
        end
        results[cpu][:usage] = 100.0 - (results[cpu][:idle] || 100.0)
      end if @cpu_times && @last_cpu_times
      results
    end

    def get_current_time
      Time.now
    end
    
  
    def number_of_cpus
      @cpu_times.length - 1
    end 
  end

  module  Utility
    module Proc
      USER        =  1 
      NICE        =  2 
      SYSTEM      =  3 
      IDLE        =  4 
      IOWAIT      =  5 
      IRQ         =  6 
      SOFTIRQ     =  7 
      STEAL       =  8 
      GUEST       =  9 
      NICEGUEST   = 10 

      def self.proc_stat_filename
        # A method to locat stat file that can be stubbed
        "/proc/stat"
      end

      def self.read_proc_stat
        IO.readlines( proc_stat_filename )
      end

      def self.cpu_hash
        read_proc_stat.select{|r| r.match(/cpu/)}.inject({}) do |h,cpu_row|

          cpu_parts = cpu_row.split(" ")

          h[cpu_parts[0]] =  {
            user:       cpu_parts[USER     ].to_i,
            nice:       cpu_parts[NICE     ].to_i,
            system:     cpu_parts[SYSTEM   ].to_i,
            idle:       cpu_parts[IDLE     ].to_i,
            iowait:     cpu_parts[IOWAIT   ].to_i,
            irq:        cpu_parts[IRQ      ].to_i,
            softirq:    cpu_parts[SOFTIRQ  ].to_i,
            steal:      cpu_parts[STEAL    ].to_i,
            guest:      cpu_parts[GUEST    ].to_i,
            niceguest:  cpu_parts[NICEGUEST].to_i
          }

          h
        end
      end
    end
  end
end
