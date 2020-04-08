# frozen_string_literal: true

namespace :gitlab do
  desc "GitLab | Set Organization to GitLab for GitLab employees"
  task set_organization_for_gitlab_employees: :gitlab_environment do
    User.where("email LIKE '%@gitlab.com'").where("organization != 'GitLab' OR organization IS NULL").confirmed.find_each do |user|
      previous_organization = user.organization
      if user.update_columns(organization: 'GitLab')
        puts "Updated organization of user #{user.email} from #{previous_organization || 'nil'} to #{user.organization}"
      else
        puts "User #{user.id} with email #{user.email} could not be saved"
      end
    end
  end
end
