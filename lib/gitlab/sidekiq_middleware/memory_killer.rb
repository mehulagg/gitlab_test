# frozen_string_literal: true

module Gitlab
  module SidekiqMiddleware
    class MemoryKiller
      # Default the RSS limit to 0, meaning the MemoryKiller is disabled
      MAX_RSS = (ENV['SIDEKIQ_MEMORY_KILLER_MAX_RSS'] || 0).to_s.to_i
      # Give Sidekiq 15 minutes of grace time after exceeding the RSS limit
      GRACE_TIME = (ENV['SIDEKIQ_MEMORY_KILLER_GRACE_TIME'] || 15 * 60).to_s.to_i
      # Wait 30 seconds for running jobs to finish during graceful shutdown
      SHUTDOWN_WAIT = (ENV['SIDEKIQ_MEMORY_KILLER_SHUTDOWN_WAIT'] || 30).to_s.to_i
      # Check Sidekiq Worker alive every CHECK_INTERVAL_SECONDS, minimum 2 seconds
      CHECK_INTERVAL_SECONDS = [ENV.fetch('SIDEKIQ_MEMORY_KILLER_CHECK_INTERVAL', 3).to_i, 2].max

      # Create a mutex used to ensure there will be only one thread waiting to
      # shut Sidekiq down
      MUTEX = Mutex.new

      attr_reader :worker

      def call(worker, job, queue)
        yield

        @worker = worker
        current_rss = get_rss

        return unless MAX_RSS > 0 && current_rss > MAX_RSS

        Thread.new do
          # Return if another thread is already waiting to shut Sidekiq down
          next unless MUTEX.try_lock

          sidekiq_pid = Process.pid
          sidekiq_pgrp = Process.getpgrp

          # If Sidekiq Worker process hang, child thread is not able to signal.
          # Fork a new process to handle signal safely.
          # Refer to issue: https://gitlab.com/gitlab-org/gitlab/issues/36638
          forked_pid = Process.fork do
            kill_sidekiq_worker_process(sidekiq_pid, sidekiq_pgrp, current_rss, worker, job)
          end
          Process.wait(forked_pid)
        end
      end

      private

      def kill_sidekiq_worker_process(sidekiq_pid, sidekiq_pgrp, sidekiq_current_rss, worker, job)
        warn("Sidekiq worker PID-#{sidekiq_pid} current RSS #{sidekiq_current_rss}"\
             " exceeds maximum RSS #{MAX_RSS} after finishing job #{worker.class} JID-#{job['jid']}", sidekiq_pid: sidekiq_pid)

        warn("Sidekiq worker PID-#{sidekiq_pid} will stop fetching new jobs"\
             " in #{GRACE_TIME} seconds, and will be shut down #{SHUTDOWN_WAIT} seconds later", sidekiq_pid: sidekiq_pid)

        # Wait `GRACE_TIME` to give the memory intensive job time to finish.
        # Then, tell Sidekiq to stop fetching new jobs.
        wait_and_signal(sidekiq_pid, GRACE_TIME, 'SIGTSTP', 'stop fetching new jobs')

        # Wait `SHUTDOWN_WAIT` to give already fetched jobs time to finish.
        # Then, tell Sidekiq to gracefully shut down by giving jobs a few more
        # moments to finish, killing and requeuing them if they didn't, and
        # then terminating itself. Sidekiq will replicate the TERM to all its
        # children if it can.
        wait_and_signal(sidekiq_pid, SHUTDOWN_WAIT, 'SIGTERM', 'gracefully shut down')

        # Wait for Sidekiq to shutdown gracefully, and kill it if it didn't.
        # Kill the whole pgroup, so we can be sure no children are left behind
        wait_and_signal_pgroup(sidekiq_pid, sidekiq_pgrp, Sidekiq.options[:timeout] + 200, 'SIGKILL', 'die')
      end

      def get_rss
        output, status = Gitlab::Popen.popen(%W(ps -o rss= -p #{pid}), Rails.root.to_s)
        return 0 unless status.zero?

        output.to_i
      end

      def process_alive?(process_id)
        Process.getpgid(process_id)
        true
      rescue Errno::ESRCH
        false
      end

      def parent_process?(process_id)
        Process.ppid == process_id
      end

      def parent_process_alive?(process_id)
        process_alive?(process_id) && parent_process?(process_id)
      end

      # If this sidekiq process is pgroup leader, signal to the whole pgroup
      def wait_and_signal_pgroup(sidekiq_pid, sidekiq_pgrp, time, signal, explanation)
        wait_and_signal(sidekiq_pid, time, signal, explanation, signal_pgroup: sidekiq_pgrp == sidekiq_pid)
      end

      def wait_and_signal(sidekiq_pid, time, signal, explanation, signal_pgroup: false)
        if signal_pgroup
          pid_or_pgrp_str = 'PGRP'
          pid_to_signal = 0
        else
          pid_or_pgrp_str = 'PID'
          pid_to_signal = sidekiq_pid
        end

        warn("waiting #{time} seconds before sending Sidekiq worker #{pid_or_pgrp_str}-#{sidekiq_pid} #{signal} (#{explanation})", sidekiq_pid: sidekiq_pid, signal: signal)

        deadline = Gitlab::Metrics::System.monotonic_time + time
        sleep(CHECK_INTERVAL_SECONDS) while parent_process_alive?(sidekiq_pid) && Gitlab::Metrics::System.monotonic_time < deadline

        if parent_process_alive?(sidekiq_pid)
          warn("sending Sidekiq worker #{pid_or_pgrp_str}-#{sidekiq_pid} #{signal} (#{explanation})", sidekiq_pid: sidekiq_pid, signal: signal)
          Process.kill(signal, pid_to_signal)
        else
          warn("parent Sidekiq worker has already terminated, skip sending Sidekiq worker #{pid_or_pgrp_str}-#{sidekiq_pid} #{signal} (#{explanation})", sidekiq_pid: sidekiq_pid, signal: signal)
        end
      end

      def pid
        Process.pid
      end

      def warn(message, sidekiq_pid: nil, signal: nil)
        Sidekiq.logger.warn(class: worker.class.name, sidekiq_pid: sidekiq_pid, pid: pid, signal: signal, message: message)
      end
    end
  end
end
