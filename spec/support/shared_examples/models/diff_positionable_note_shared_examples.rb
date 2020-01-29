# frozen_string_literal: true

RSpec.shared_examples 'a valid diff positionable note' do |factory, factory_on_commit = factory|
  let(:project) { create(:project, :repository) }
  let(:repository) { project.repository }
  let(:position) { build(:text_diff_position, file: 'files/ruby/popen.rb', diff_refs: diff_refs) }

  context 'for commit' do
    next unless factory_on_commit

    let(:commit) { project.commit(sample_commit.id) }
    let(:commit_id) { commit.id }
    let(:diff_refs) { commit.diff_refs }

    subject { build(factory_on_commit, project: project, commit_id: commit_id, position: position) }

    context 'position diff refs matches commit diff refs' do
      it 'is valid' do
        expect(subject).to be_valid
        expect(subject.errors).not_to have_key(:commit_id)
      end
    end

    context 'position diff refs does not match commit diff refs' do
      let(:diff_refs) do
        Gitlab::Diff::DiffRefs.new(
          base_sha: "not_existing_sha",
          head_sha: "existing_sha"
        )
      end

      it 'is invalid' do
        expect(subject).to be_invalid
        expect(subject.errors).to have_key(:commit_id)
      end
    end

    context 'commit does not exist' do
      let(:commit_id) { 'non-existing' }

      it 'is invalid' do
        expect(subject).to be_invalid
        expect(subject.errors).to have_key(:commit_id)
      end
    end

    %i(original_position position change_position).each do |method|
      describe "#{method}=" do
        it "doesn't accept non-hash JSON passed as a string" do
          subject.send(:"#{method}=", "true")
          expect(subject.attributes_before_type_cast[method.to_s]).to be(nil)
        end

        it "does accept a position hash as a string" do
          subject.send(:"#{method}=", position.to_json)
          expect(subject.position).to eq(position)
        end

        it "doesn't accept an array" do
          subject.send(:"#{method}=", ["test"])
          expect(subject.attributes_before_type_cast[method.to_s]).to be(nil)
        end

        it "does accept a hash" do
          subject.send(:"#{method}=", position.to_h)
          expect(subject.position).to eq(position)
        end
      end
    end
  end

  context 'for other noteables' do
    subject { build(factory, project: project, position: position) }

    let(:base_sha) { repository.commit('HEAD^').sha }
    let(:head_sha) { repository.commit('HEAD').sha }
    let(:diff_refs) { Gitlab::Diff::DiffRefs.new(base_sha: base_sha, head_sha: head_sha) }

    def expect_commits_by
      expect(subject.repository).to receive(:commits_by).and_call_original
    end

    context 'commits exist in the repository' do
      it 'is valid' do
        expect_commits_by.with(oids: containing_exactly(base_sha, head_sha))
        expect(subject).to be_valid
      end

      context 'the same SHAs are repeated in different positions' do
        subject { build(factory, project: project, position: position, change_position: change_position) }

        let(:change_position) do
          attrs = position.to_h.merge(
            diff_refs: Gitlab::Diff::DiffRefs.new(base_sha: position.base_sha, start_sha: 'new-sha1', head_sha: 'new-sha2')
          )

          position.class.new(attrs)
        end

        it 'only loads each SHA once' do
          expect_commits_by.with(oids: containing_exactly(base_sha, head_sha, 'new-sha1', 'new-sha2'))

          expect(subject).to be_invalid
          expect(subject.errors.messages).to include(base: ["invalid SHA \"new-sha1\", \"new-sha2\""])
        end

        it 'does not revalidate already persisted SHAs' do
          allow(subject).to receive(:changed_attributes)
            .and_return(change_position: change_position)

          expect_commits_by.with(oids: containing_exactly('new-sha1', 'new-sha2'))

          expect(subject).to be_invalid
          expect(subject.errors.messages).to include(base: ["invalid SHA \"new-sha1\", \"new-sha2\""])
        end
      end
    end

    context 'commits do not exist in the repository' do
      # Invalid SHAs can be on several attributes on any of the position fields.
      # We don't want to test all permutations, but cycle through them to verify
      # they're covered.
      sha_attributes = %i[base_sha start_sha head_sha].cycle
      invalid_shas = %w[foo 1234567].cycle

      DiffPositionableNote::POSITION_ATTRIBUTES.each do |position_attribute|
        it 'is invalid' do
          sha_attribute = sha_attributes.next
          invalid_sha = invalid_shas.next

          # Mock the invalid SHA value
          # allow(subject).to receive(:changed_attributes).and_return(position_attribute => position)
          allow(subject[position_attribute]).to receive(sha_attribute).and_return(invalid_sha)
          allow(subject[position_attribute]).to receive(:complete?).and_return(true) # work around set_original_position
          subject.public_send("#{position_attribute}_will_change!")

          expect_commits_by.with(oids: including(invalid_sha))

          expect(subject).to be_invalid, "expected validation error for '#{invalid_sha}' on #{position_attribute}.#{sha_attribute}"
          expect(subject.errors.messages).to include(base: ["invalid SHA \"#{invalid_sha}\""])
        end
      end

      context 'feature flags' do
        before do
          allow(subject).to receive(:changed_attributes).and_return(position: position)
          allow(subject.position).to receive(:base_sha).and_return('foo')
        end

        context 'when the :validate_note_diff_refs feature is disabled' do
          before do
            stub_feature_flags(validate_note_diff_refs: false)
          end

          it 'does not validate diff refs' do
            expect_commits_by.never

            subject.valid?

            expect(subject.errors).not_to include(:base)
          end
        end

        context 'when the :validate_note_diff_refs feature is enabled for the project' do
          before do
            stub_feature_flags(validate_note_diff_refs: project)
          end

          it 'validates diff refs' do
            expect_commits_by.once

            expect(subject).to be_invalid
            expect(subject.errors.messages).to include(base: ['invalid SHA "foo"'])
          end
        end
      end
    end
  end
end
