# frozen_string_literal: true

require 'spec_helper'

describe Analytics::CodeAnalyticsFinder do
  describe '#execute' do
    set(:project) { create(:project) }
    set(:file) { create(:analytics_repository_file, project: project, file_path: 'app/db/migrate/file.rb')}

    subject { described_class.new(project: project, from: 10.days.ago, to: Time.now).execute }

    context 'with no commits in the given timerange' do
      it 'returns an empty hash' do
        Timecop.freeze(10.minutes.from_now) do
          expect(subject).to be_empty
        end
      end
    end

    context 'with one file in given timerange' do
      set(:repo_file_edits) { create(:analytics_repository_file_edits, project: project, analytics_repository_file: file, committed_date: Date.today) }

      it 'returns a hash with one file and its edits' do
        Timecop.freeze(10.minutes.from_now) do
          expect(subject).to include(file[:file_path] =>
            repo_file_edits[:num_edits])
        end
      end
    end
  end
end
