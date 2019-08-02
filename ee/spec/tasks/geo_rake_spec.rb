require 'rake_helper'

describe 'geo rake tasks', :geo do
  include ::EE::GeoHelpers

  let(:schema_file) { Rails.root.join('tmp', 'tests', 'geo_schema.rb').to_s }

  before do
    Rake.application.rake_require 'tasks/geo'
    stub_licensed_features(geo: true)
    stub_env('SCHEMA', schema_file)
  end

  describe 'db_drop task' do
    it 'drops the current database' do
      expect(Gitlab::Geo::DatabaseTasks).to receive(:drop_current)
      expect { run_rake_task('geo:db:drop') }.not_to raise_error
    end
  end

  describe 'db_create task' do
    it 'creates a Geo tracking database' do
      expect(Gitlab::Geo::DatabaseTasks).to receive(:create_current)
      run_rake_task('geo:db:create')
    end
  end

  describe 'db_setup task' do
    it 'sets up a Geo tracking database' do
      allow(Rake::Task['geo:db:schema:load']).to receive(:invoke).and_return(TRUE)
      allow(Rake::Task['geo:db:seed']).to receive(:invoke).and_return(TRUE)
      allow(Gitlab::Geo::DatabaseTasks).to receive(:abort_if_no_geo_config!).and_return(FALSE)

      expect(Rake::Task['geo:db:schema:load']).to receive(:invoke)
      expect(Rake::Task['geo:db:seed']).to receive(:invoke)
      run_rake_task('geo:db:setup')
    end
  end

  describe 'db_migrate task' do
    it 'migrates a Geo tracking database' do
      allow(Rake::Task['geo:db:_dump']).to receive(:invoke).and_return(TRUE)

      expect(Gitlab::Geo::DatabaseTasks).to receive(:migrate)
      expect(Rake::Task['geo:db:_dump']).to receive(:invoke)
      expect { run_rake_task('geo:db:migrate') }.not_to raise_error
    end
  end

  describe 'db_rollback task' do
    it 'rolls back a Geo tracking database' do
      allow(Gitlab::Geo::DatabaseTasks).to receive(:dump_schema_after_migration?).and_return(FALSE)

      expect(Gitlab::Geo::DatabaseTasks).to receive(:rollback)
      expect(Rake::Task['geo:db:_dump']).to receive(:invoke)
      run_rake_task('geo:db:rollback')
    end
  end

  describe 'db_version task' do
    it 'retrieves current schema version number' do
      allow(Gitlab::Geo::DatabaseTasks).to receive(:dump_schema_after_migration?).and_return(FALSE)
      expect(Gitlab::Geo::DatabaseTasks).to receive(:version)

      run_rake_task('geo:db:version')
    end
  end

  describe 'db_reset task' do
    it 'drops, recreates, loads schema for, and seeds database' do
      run_rake_task('geo:db:reset')
    end
  end

  describe 'db_seed task' do
    it 'loads seed data' do
      allow(Rake::Task['geo:db:abort_if_pending_migrations']).to receive(:invoke).and_return(FALSE)
      
      expect(Rake::Task['geo:db:abort_if_pending_migrations']).to receive(:invoke)
      expect(Gitlab::Geo::DatabaseTasks).to receive(:load_seed)
      run_rake_task('geo:db:seed')
    end
  end

  describe 'db_refresh_foreign_tables task' do
    it 'refreshes foreign tables definition on secondary node' do
      allow(Gitlab::Geo::GeoTasks).to receive(:foreign_server_configured?).and_return(TRUE)
      expect(Gitlab::Geo::GeoTasks).to receive(:refresh_foreign_tables!)
      run_rake_task('geo:db:refresh_foreign_tables')
    end
  end

  describe 'db__dump task' do
    it 'dumps the schema' do
      allow(Gitlab::Geo::DatabaseTasks).to receive(:dump_schema_after_migration?).and_return(TRUE)
      allow(Rake::Task['geo:db:schema:dump']).to receive(:invoke).and_return(TRUE)
      allow(Rake::Task['geo:db:_dump']).to receive(:reenable).and_return(TRUE)

      expect(Rake::Task['geo:db:schema:dump']).to receive(:invoke)
      run_rake_task('geo:db:_dump')
    end
  end

  describe 'db_abort_if_pending_migrations task' do
    it 'raises an error if there are pending migrations' do
      #create stubbed pending migration, return it from method call
      allow(Gitlab::Geo::DatabaseTasks).to receive(:pending_migrations).and_return([1])
      run_rake_task('geo:db:abort_if_pending_migrations')
    end
  end

  describe 'db_schema_load task' do
    it 'loads schema file into database' do
      allow(Rake::Task['geo:db:_dump']).to receive(:invoke).and_return(TRUE)

      exepct(GitLab::Geo::DatabaseTasks).to receive(:load_schema_current)
      run_rake_task('geo:db:schema:load')
    end
  end

  describe 'db_schema_dump task' do
    it 'creates schema.rb file' do
      allow(Rake::Task['geo:db:_dump']).to receive(:invoke).and_return(TRUE)

      expect(Gitlab::Geo::DatabaseTasks::Schema).to receive(:dump)
      expect(Rake::Task['geo:db:_dump']).to receive(:invoke)
      run_rake_task('geo:db:schema:dump')
    end
  end

  describe 'db_migrate_up task' do
    it 'runs up method for given migration' do
      allow(Rake::Task['geo:db:_dump']).to receive(:invoke).and_return(TRUE)

      expect(Gitlab::Geo::DatabaseTasks::Migrate).to receive(:up)
      expect(Rake::Task['geo:db:_dump']).to receive(:invoke)
      run_rake_task('geo:db:migrate:up')
    end
  end

  describe 'db_migrate_down task' do
    it 'runs down method for given migration' do
      allow(Rake::Task['geo:db:_dump']).to receive(:invoke).and_return(TRUE)

      expect(Gitlab::Geo::DatabaseTasks::Migrate).to receive(:down)
      expect(Rake::Task['geo:db:_dump']).to receive(:invoke)
      run_rake_task('geo:db:migrate:down')
    end
  end

  describe 'db_migrate_redo task' do
    it 'rolls back database by one migration, then re-migrates it up' do
      run_rake_task('geo:db:migrate:redo')
    end
  end
  
  describe 'db_migrate_status task' do
    it 'displays migration status' do
      expect(Gitlab::Geo::DatabaseTasks::Migrate).to receive(:status)
      run_rake_task('geo:db:migrate:status')
    end
  end

  describe 'db_test_prepare task' do
    it 'check for pending migrations and load schema in test environment' do
      allow(Rake::Task['geo:db:test:load']).to receive(:invoke).and_return(TRUE)

      expect(Rake::Task['geo:db:test:load']).to receive(:invoke)
      run_rake_task('geo:db:test:prepare')
    end
  end

  describe 'db_test_load task' do
    it 'recreates database in test environment' do
      allow(Gitlab::Geo::DatabaseTasks::Test).to receive(:purge).and_return(TRUE)
      allow(Rake::Task['geo:db:test:purge']).to receive(:invoke).and_return(TRUE)

      expect(Gitlab::Geo::DatabaseTasks::Test).to receive(:load)
      run_rake_task('geo:db:test:load')
    end
  end

  describe 'db_test_purge task' do
    it 'empties database in test environment' do
      expect(Gitlab::Geo::DatabaseTasks::Test).to receive(:purge)
      run_rake_task('geo:db:test:purge')
    end
  end

  describe 'db_test_refresh_foreign_tables task' do
    it 'refreshes foreign tables definitions in test environment' do
      expect()
      run_rake_task('geo:db:test:refresh_foreign_tables')
    end
  end

  describe 'set_primary_node task' do
    before do
      stub_config_setting(url: 'https://example.com:1234/relative_part')
      stub_geo_setting(node_name: 'Region 1 node')
    end

    it 'creates a GeoNode' do
      expect(GeoNode.count).to eq(0)

      run_rake_task('geo:set_primary_node')

      expect(GeoNode.count).to eq(1)

      node = GeoNode.first

      expect(node.name).to eq('Region 1 node')
      expect(node.uri.scheme).to eq('https')
      expect(node.url).to eq('https://example.com:1234/relative_part/')
      expect(node.primary).to be_truthy
    end
  end

  describe 'set_secondary_as_primary task' do
    let!(:current_node) { create(:geo_node) }
    let!(:primary_node) { create(:geo_node, :primary) }

    before do
      stub_current_geo_node(current_node)
    end

    it 'removes primary and sets secondary as primary' do
      run_rake_task('geo:set_secondary_as_primary')

      expect(current_node.primary?).to be_truthy
      expect(GeoNode.count).to eq(1)
    end
  end

  describe 'update_primary_node_url task' do
    let(:primary_node) { create(:geo_node, :primary, url: 'https://secondary.geo.example.com') }

    before do
      allow(GeoNode).to receive(:current_node_url).and_return('https://primary.geo.example.com')
      stub_current_geo_node(primary_node)
    end

    it 'updates Geo primary node URL' do
      run_rake_task('geo:update_primary_node_url')

      expect(primary_node.reload.url).to eq 'https://primary.geo.example.com/'
    end
  end

  describe 'status task', :geo_fdw do
    context 'without a valid license' do
      before do
        stub_licensed_features(geo: false)
      end

      it 'runs with an error' do
        expect { run_rake_task('geo:status') }.to raise_error("GitLab Geo is not supported with this license. Please contact the sales team: https://about.gitlab.com/sales.")
      end
    end

    context 'with a valid license' do
      let!(:current_node) { create(:geo_node) }
      let!(:primary_node) { create(:geo_node, :primary) }
      let!(:geo_event_log) { create(:geo_event_log) }
      let!(:geo_node_status) { build(:geo_node_status, :healthy, geo_node: current_node) }

      before do
        stub_licensed_features(geo: true)
        stub_current_geo_node(current_node)

        allow(GeoNodeStatus).to receive(:current_node_status).once.and_return(geo_node_status)
      end

      it 'runs with no error' do
        expect { run_rake_task('geo:status') }.not_to raise_error
      end

      context 'with a healthy node' do
        before do
          geo_node_status.status_message = nil
        end

        it 'shows status as healthy' do
          expect { run_rake_task('geo:status') }.to output(/Health Status: Healthy/).to_stdout
        end

        it 'does not show health status summary' do
          expect { run_rake_task('geo:status') }.not_to output(/Health Status Summary/).to_stdout
        end
      end

      context 'with an unhealthy node' do
        before do
          geo_node_status.status_message = 'Something went wrong'
        end

        it 'shows status as unhealthy' do
          expect { run_rake_task('geo:status') }.to output(/Health Status: Unhealthy/).to_stdout
        end

        it 'shows health status summary' do
          expect { run_rake_task('geo:status') }.to output(/Health Status Summary: Something went wrong/).to_stdout
        end
      end
    end
  end
end
