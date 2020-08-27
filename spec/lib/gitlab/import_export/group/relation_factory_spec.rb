# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::ImportExport::Group::RelationFactory do
  let(:admin) { create(:admin) }
  let(:importer_user) { admin }
  let(:group) { create(:group) }
  let(:members_mapper) { double('members_mapper').as_null_object }
  let(:excluded_keys) { [] }
  let(:created_object) do
    described_class.create(
      relation_sym: relation_sym,
      relation_hash: relation_hash,
      members_mapper: members_mapper,
      object_builder: Gitlab::ImportExport::Group::ObjectBuilder,
      user: importer_user,
      importable: group,
      excluded_keys: excluded_keys
    )
  end

  context 'label object' do
    let(:relation_sym) { :group_label }
    let(:id) { random_id }
    let(:original_group_id) { random_id }

    let(:relation_hash) do
      {
        'id' => 123456,
        'title' => 'Bruffefunc',
        'color' => '#1d2da4',
        'project_id' => nil,
        'created_at' => '2019-11-20T17:02:20.546Z',
        'updated_at' => '2019-11-20T17:02:20.546Z',
        'template' => false,
        'description' => 'Description',
        'group_id' => original_group_id,
        'type' => 'GroupLabel',
        'priorities' => [],
        'textColor' => '#FFFFFF'
      }
    end

    it 'does not have the original ID' do
      expect(created_object.id).not_to eq(id)
    end

    it 'does not have the original group_id' do
      expect(created_object.group_id).not_to eq(original_group_id)
    end

    it 'has the new group_id' do
      expect(created_object.group_id).to eq(group.id)
    end

    context 'excluded attributes' do
      let(:excluded_keys) { %w[description] }

      it 'are removed from the imported object' do
        expect(created_object.description).to be_nil
      end
    end
  end

  context 'Notes user references' do
    let(:relation_sym) { :notes }
    let(:mapped_user) { create(:user) }
    let(:exported_member) do
      {
        'id' => 111,
        'access_level' => 30,
        'source_id' => 1,
        'source_type' => 'Namespace',
        'user_id' => 3,
        'notification_level' => 3,
        'created_at' => '2016-11-18T09:29:42.634Z',
        'updated_at' => '2016-11-18T09:29:42.634Z',
        'user' => {
          'id' => 999,
          'email' => mapped_user.email,
          'username' => mapped_user.username
        }
      }
    end

    let(:relation_hash) do
      {
        'id' => 4947,
        'note' => 'note',
        'noteable_type' => 'Epic',
        'author_id' => 999,
        'created_at' => '2016-11-18T09:29:42.634Z',
        'updated_at' => '2016-11-18T09:29:42.634Z',
        'project_id' => 1,
        'attachment' => {
          'url' => nil
        },
        'noteable_id' => 377,
        'system' => true,
        'author' => {
          'name' => 'Administrator'
        },
        'events' => []
      }
    end

    let(:members_mapper) do
      Gitlab::ImportExport::MembersMapper.new(
        exported_members: [exported_member].compact,
        user: importer_user,
        importable: group
      )
    end

    context 'when the importer is admin' do
      let(:importer_user) { admin }

      context 'and the note author is not mapped' do
        let(:exported_member) { nil }

        it 'maps the right author to the imported note' do
          expect(created_object.author).to eq(importer_user)
        end

        it 'does not add original autor note' do
          expect(created_object.note).to include('*By Administrator')
        end
      end

      context 'and the note author is the importer user' do
        let(:mapped_user) { importer_user }

        it 'maps the right author to the imported note' do
          expect(created_object.author).to eq(mapped_user)
        end

        it 'does not add original autor note' do
          expect(created_object.note).not_to include('*By Administrator')
        end
      end

      context 'and the note author is a mapped admin' do
        let(:mapped_user) { admin }

        it 'maps the right author to the imported note' do
          expect(created_object.author).to eq(mapped_user)
        end

        it 'does not add original autor note' do
          expect(created_object.note).not_to include('*By Administrator')
        end
      end

      context 'and the note author is a mapped user' do
        let(:mapped_user) { create(:user) }

        it 'maps the right author to the imported note' do
          expect(created_object.author).to eq(mapped_user)
        end

        it 'does not add original autor note' do
          expect(created_object.note).not_to include('*By Administrator')
        end
      end
    end

    context 'when the importer is not admin' do
      let(:importer_user) { create(:user) }

      context 'and the note author is not mapped' do
        let(:exported_member) { nil }

        it 'maps the right author to the imported note' do
          expect(created_object.author).to eq(importer_user)
        end

        it 'does not add original autor note' do
          expect(created_object.note).to include('*By Administrator')
        end
      end

      context 'and the note author is the importer user' do
        let(:mapped_user) { importer_user }

        it 'maps the right author to the imported note' do
          expect(created_object.author).to eq(mapped_user)
        end

        it 'does not add original autor note' do
          expect(created_object.note).not_to include('*By Administrator')
        end
      end

      context 'and the note author is a mapped admin user' do
        let(:mapped_user) { admin }

        it 'maps the right author to the imported note' do
          expect(created_object.author).to eq(mapped_user)
        end

        it 'does not add original autor note' do
          expect(created_object.note).not_to include('*By Administrator')
        end
      end

      context 'and the note author is a mapped user' do
        let(:mapped_user) { create(:user) }

        it 'maps the right author to the imported note' do
          expect(created_object.author).to eq(mapped_user)
        end

        it 'does not add original autor note' do
          expect(created_object.note).not_to include('*By Administrator')
        end
      end
    end
  end

  def random_id
    rand(1000..10000)
  end
end
