# frozen_string_literal: true

namespace :gitlab do
  desc "GitLab | Set Organization to GitLab for GitLab employees"
  task set_organization_for_gitlab_employees: :gitlab_environment do
    User.where("email LIKE '%@gitlab.com'").where("organization != 'GitLab' OR organization IS NULL").confirmed.find_each do |user|
      if user.update(organization: 'GitLab')
        puts "Updated organization of user #{user.email} to #{user.organization}"
      else
        puts "User #{user.id} with email #{user.email} could not be saved, beacause of: #{user.errors.full_messages.join(', ')}"
      end
    end
  end
end
