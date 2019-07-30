Gitlab::Seeder.quiet do
  flag_0 = Feature.enabled?(:design_management)
  flag_1 = Feature.enabled?(:design_management_flag)

  Feature.enable(:design_management)
  Feature.enable(:design_management_flag)

  issue = Issue.first
  project = issue.project
  user = User.find_by(admin: true)

  Upload = Struct.new(:original_filename, :to_io)

  files = ["dk.png", "rails_sample.jpg"].map do |filename|
    content = File.open("spec/fixtures/#{filename}", 'r') do |f|
      StringIO.new(f.read)
    end

    Upload.new(filename, content)
  end

  service = DesignManagement::SaveDesignsService.new(project, user,
                                                     issue: issue,
                                                     files: files)

  r = service.execute

  if r[:message].present?
    puts r[:message].to_s.red
  else
    r[:designs].each do
      puts '.'
    end
  end

ensure
  short_flag = :design_management
  long_flag = :design_management_flag
  flag_0 ? Feature.enable(short_flag) : Feature.disable(short_flag)
  flag_1 ? Feature.enable(long_flag) : Feature.disable(long_flag)
end
