# frozen_string_literal: true

Gitlab::Seeder.quiet do
  Plan::PLAN_NAMES.each do |plan|
    Plan.create!(name: plan, title: plan.titleize)

    print '.'
  end
end
