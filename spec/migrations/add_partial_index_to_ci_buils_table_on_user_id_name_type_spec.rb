# frozen_string_literal: true

require 'spec_helper'
require Rails.root.join('db', 'post_migrate', '20200908064229_add_partial_index_to_ci_buils_table_on_user_id_name_type.rb')

RSpec.describe AddPartialIndexToCiBuilsTableOnUserIdNameType do
  let(:migration) { described_class.new }

  describe '#up' do
    it 'creates temporary partial index on type' do
      expect { migration.up }.to change { migration.index_exists?(:ci_builds, [:user_id, :name, :type], name: described_class::INDEX_NAME) }.from(false).to(true)
    end
  end

  describe '#down' do
    it 'removes temporary partial index on type' do
      migration.up

      expect { migration.down }.to change { migration.index_exists?(:ci_builds, [:user_id, :name, :type], name: described_class::INDEX_NAME) }.from(true).to(false)
    end
  end
end
