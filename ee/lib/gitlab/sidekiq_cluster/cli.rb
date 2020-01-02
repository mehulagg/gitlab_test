# frozen_string_literal: true

require 'optparse'
require 'logger'
require 'time'

module Gitlab
  module SidekiqCluster
    class CLI
      CommandError = Class.new(StandardError)

      def initialize(log_output = STDERR)
        # As recommended by https://github.com/mperham/sidekiq/wiki/Advanced-Options#concurrency
        @max_concurrency = 50
        @environment = ENV['RAILS_ENV'] || 'development'
        @pidfile = nil
        @interval = 5
        @alive = true
        @num_workers = nil
        @processes = []
        @logger = Logger.new(log_output)
        @rails_path = Dir.pwd
        @dryrun = false

        # Use a log format similar to Sidekiq to make parsing/grepping easier.
        @logger.formatter = proc do |level, date, program, message|
          "#{date.utc.iso8601(3)} #{Process.pid} TID-#{Thread.current.object_id.to_s(36)} #{level}: #{message}\n"
        end
      end

      def run(argv = ARGV)
        if argv.empty?
          raise CommandError,
            'Usage: ' + option_parser.help
        end

        option_parser.parse!(argv)

        all_queues = SidekiqConfig.worker_queues(@rails_path)
        parsed_queues = SidekiqCluster.parse_queues(argv)
        assert_valid_options(parsed_queues)

        queue_groups = build_queue_groups(all_queues, parsed_queues)

        @logger.info("Starting cluster with #{queue_groups.length} processes")

        @processes = SidekiqCluster.start(queue_groups, env: @environment, directory: @rails_path,
          max_concurrency: @max_concurrency, dryrun: @dryrun)

        return if @dryrun

        write_pid
        trap_signals
        start_loop
      end

      # some options cannot be combined; these are rejected here
      def assert_valid_options(parsed_queues)
        if @num_workers && @negate_queues
          raise CommandError.new "Cannot combine the -w and -n switches"
        end

        if @num_workers && parsed_queues.any?
          raise CommandError.new "The -w switch does not support queue grouping"
        end
      end

      def build_queue_groups(all_queues, parsed_queues)
        if @num_workers
          # with the -w switch, each worker process will operate on all queues
          Array.new(@num_workers) { all_queues }
        else
          # otherwise, parse queue groups from CLI and dynamically determine process count
          queue_groups = parsed_queues.map do |queues|
            SidekiqConfig.expand_queues(queues, all_queues)
          end

          if @negate_queues
            queue_groups.map { |queues| all_queues - queues }
          else
            queue_groups
          end
        end
      end

      def write_pid
        SidekiqCluster.write_pid(@pidfile) if @pidfile
      end

      def trap_signals
        SidekiqCluster.trap_terminate do |signal|
          @alive = false
          SidekiqCluster.signal_processes(@processes, signal)
        end

        SidekiqCluster.trap_forward do |signal|
          SidekiqCluster.signal_processes(@processes, signal)
        end
      end

      def start_loop
        while @alive
          sleep(@interval)

          unless SidekiqCluster.all_alive?(@processes)
            # If a child process died we'll just terminate the whole cluster. It's up to
            # runit and such to then restart the cluster.
            @logger.info('A worker terminated, shutting down the cluster')

            SidekiqCluster.signal_processes(@processes, :TERM)
            break
          end
        end
      end

      def option_parser
        OptionParser.new do |opt|
          opt.banner = "#{File.basename(__FILE__)} [QUEUE,QUEUE] [QUEUE] ... [OPTIONS]"

          opt.separator "\nOptions:\n"

          opt.on('-h', '--help', 'Shows this help message') do
            abort opt.to_s
          end

          opt.on('-m', '--max-concurrency INT', 'Maximum threads to use with Sidekiq (default: 50, 0 to disable)') do |int|
            @max_concurrency = int.to_i
          end

          opt.on('-e', '--environment ENV', 'The application environment') do |env|
            @environment = env
          end

          opt.on('-w', '--workers INT', 'Number of worker processes to start. If set, [QUEUE]s will be ignored and all workers will operate on all queues.') do |int|
            @num_workers = int.to_i
          end

          opt.on('-P', '--pidfile PATH', 'Path to the PID file') do |pidfile|
            @pidfile = pidfile
          end

          opt.on('-r', '--require PATH', 'Location of the Rails application') do |path|
            @rails_path = path
          end

          opt.on('-n', '--negate', 'Run workers for all queues in sidekiq_queues.yml except the given ones. Has no effect when -w is passed.') do
            @negate_queues = true
          end

          opt.on('-i', '--interval INT', 'The number of seconds to wait between worker checks') do |int|
            @interval = int.to_i
          end

          opt.on('-d', '--dryrun', 'Print commands that would be run without this flag, and quit') do |int|
            @dryrun = true
          end
        end
      end
    end
  end
end
