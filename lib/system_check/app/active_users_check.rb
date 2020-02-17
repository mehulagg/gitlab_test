# frozen_string_literal: true

module SystemCheck
  module App
    class ActiveUsersCheck < SystemCheck::BaseCheck
      set_name 'Active users:'

      def multi_check
        active_users = User.active.count

        if active_users > 0
          $stdout.puts active_users.to_s.color(:green)
          # add metrics: count active users
          # how often is this run?
          # will an average work?
          # e.g. avg(active_users_count)?
          # e.g. sum(active_users_count)/num_of_checks_run
        else
          $stdout.puts active_users.to_s.color(:red)
        end
      end
    end
  end
end
