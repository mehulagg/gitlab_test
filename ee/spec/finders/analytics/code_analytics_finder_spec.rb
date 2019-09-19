# frozen_string_literal: true

require 'spec_helper'

describe Analytics::CodeAnalyticsFinder do
  describe "#execute" do
    set(:project) { create(:project) }
    set(:file) { create(:analytics_repository_file, project: project, file_path: 'app/db/migrate/file.rb')}

    set(:repo_file_edits) { create(:analytics_repository_file_edits, project: project, analytics_repository_file: file, committed_date: Date.today) }

    subject { described_class.new(project, 10.days.ago, Time.now).execute }

    context "with one file in given timerange" do
      it "returns a hash with one file and its edits" do
        expect(subject).to include(file[:file_path] => repo_file_edits[:num_edits])
      end
    end
  end
end
