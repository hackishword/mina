module Mina
  module Helpers
    module Internal
      extend Configuration::DSL

      def deploy_script
        yield
        erb Mina.root_path(fetch(:deploy_script))
      end

      def erb(file, b = binding)
        require 'erb'
        erb = ERB.new(File.read(file))
        erb.result b
      end

      def echo_cmd(code, ignore_verbose = false)
        if fetch(:verbose) && !ignore_verbose
          "echo #{Shellwords.escape('$ ' + code)} &&\n#{code}"
        else
          code
        end
      end

      def indent(count, str)
        str.gsub(/^/, ' ' * count)
      end

      def report_time
        time_start = Time.now
        output = yield
        puts "Elapsed time: %.2f seconds" % [Time.now - time_start]
        output
      end

      def next_version
        case fetch(:version_scheme)
        when :datetime
          Time.now.utc.strftime("%Y%m%d%H%M%S")
        when :sequence
          "$((`ls -1 #{fetch(:releases_path)} | sort -n | tail -n 1`+1))"
        else
          fail 'Unrecognizes version scheme. Use :datetime or :sequence'
        end
      end
    end
  end
end
extend Mina::Helpers::Internal
