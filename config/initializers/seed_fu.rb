if Gitlab.ee?
  SeedFu.fixture_paths += %W[ee/db/fixtures ee/db/fixtures/#{Rails.env}]
end
