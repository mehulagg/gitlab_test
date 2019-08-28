# frozen_string_literal: true

class SeedDesigns
  SETTINGS = %i[
    n_issues
    max_designs_per_issue
    max_versions_per_issue
    max_designs_per_version
  ].freeze

  attr_reader(*SETTINGS)

  def initialize(settings)
    SETTINGS.each do |k|
      instance_variable_set("@#{k}".to_sym, settings.fetch(k))
    end
  end

  def uploads
    @uploads ||= ["dk.png", "rails_sample.jpg"]
      .map { |fn| upload(fn) }
      .cycle(max_designs_per_issue)
      .map { |upload| upload.rename(random_file_name) }
  end

  def random_file_name
    "#{FFaker::Product.product_name}-#{FFaker::Product.unique.model}"
  end

  Upload = Struct.new(:original_filename, :to_io) do
    def rename(name)
      Upload.new("#{name}.#{File.extname(original_filename)}", to_io)
    end
  end

  def upload(filename)
    content = File.open("spec/fixtures/#{filename}", 'r') do |f|
      StringIO.new(f.read)
    end

    Upload.new(filename, content)
  end

  def as_action(design)
    next_action = case design.status
                  when :deleted, :new
                    :create
                  when :current
                    [:update, :delete].sample
                  end

    DesignManagement::DesignAction.new(
      design,
      next_action,
      next_action == :delete ? nil : uploads.sample.to_io
    )
  end

  def create_version(repo, devs, to_change, version_number)
    warn(to_change.inspect)
    user = devs.sample
    actions = to_change.map { |design| as_action(design) }
    sha = repo.multi_action(user, branch_name: 'master',
                                 message: "version #{version_number}",
                                 actions: actions.map(&:gitaly_action))
    version = DesignManagement::Version.create_for_designs(actions, sha)

    if version.valid?
      print('.' * to_change.size)
    else
      print('F' * to_change.size)
      version.errors.each { |e| warn(e) }
    end
  end

  def create_designs(project, issue, repo, devs)
    files = uploads.sample(Random.rand(2..max_designs_per_issue))

    files.in_groups_of(10).map(&:compact).select(&:present?).flat_map do |fs|
      user = devs.sample
      next [] unless user.present?

      service = DesignManagement::SaveDesignsService.new(project, user,
                                                         issue: issue,
                                                         files: fs)

      message, designs = service.execute.values_at(:message, :designs)

      if message
        print('F' * fs.size)
        warn(message)
      elsif designs.present?
        print('.' * designs.size)
      else
        warn('No designs?')
      end

      designs.presence || []
    end
  end

  def run
    puts(<<~NOTICE)
    NB: This seed requires the rails-web component to be running!

        This fixture will certainly fail if rails-web is not running
        since it requires access to some API calls. If you want your designs
        to be seeded, then please re-run this with rails-web running in
        the background with:

          rake db:seed_fu FILTER=designs

        Failure to load designs here is a known issue.
    NOTICE

    Issue.all.sample(n_issues).each do |issue|
      project = issue.project
      repo = project.design_repository
      devs = project.team.developers.all

      repo.create_if_not_exists

      # All designs get created at least once
      designs = create_designs(project, issue, repo, devs)
      next unless designs.present?

      Random.rand(max_versions_per_issue).times do |i|
        to_change = designs.sample(Random.rand(1..max_designs_per_version))
        puts("Designs: #{designs.inspect}")
        puts("To Change: #{to_change.inspect}")

        create_version(repo, devs, to_change, i)
      end
    end
  end

  def warn(msg)
    Rails.logger.warn(msg) # rubocop: disable Gitlab/RailsLogger
  end
end

Gitlab::Seeder.quiet do
  clear                   = ENV.fetch('DESIGN_MANAGEMENT_SEED_CLEAR', false)
  n_issues                = ENV.fetch('DESIGN_MANAGEMENT_SEED_N_ISSUES', 3).to_i
  max_designs_per_issue   = ENV.fetch('DESIGN_MANAGEMENT_SEED_DESIGNS_PER_ISSUE', 5).to_i
  max_versions_per_issue  = ENV.fetch('DESIGN_MANAGEMENT_SEED_VERSIONS_PER_ISSUE', 5).to_i
  max_designs_per_version = ENV.fetch('DESIGN_MANAGEMENT_SEED_DESIGNS_PER_VERSION', 5).to_i
  max_designs_per_issue   = [2, max_designs_per_issue].max

  flags = %i[design_management design_management_flag].map do |flag|
    old = Feature.enabled?(flag)
    Feature.enable(flag)
    [flag, old]
  end.to_h

  DesignManagement::Design.delete_all if clear

  seed = SeedDesigns.new(n_issues: n_issues,
                         max_designs_per_issue: max_designs_per_issue,
                         max_versions_per_issue: max_versions_per_issue,
                         max_designs_per_version: max_designs_per_version)

  seed.run
ensure
  flags.each do |(flag, old_value)|
    old_value ? Feature.enable(flag) : Feature.disable(flag)
  end
end
