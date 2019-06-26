require 'spec_helper'

describe Mutations::DesignManagement::Delete do
  Errors = Gitlab::Graphql::Errors

  let(:issue) { create(:issue) }
  let(:user) { issue.author }
  let(:project) { issue.project }
  let(:design_a) { create(:design, issue: issue) }
  let(:design_b) { create(:design, issue: issue) }
  let(:design_c) { create(:design, issue: issue) }
  let(:filenames) { [design_a, design_b, design_c].map(&:filename) }

  let(:mutation) { described_class.new(object: nil, context: { current_user: user }) }

  describe '#resolve' do
    subject(:resolve) do
      mutation.resolve(project_path: project.full_path, iid: issue.iid, filenames: filenames)
    end

    shared_examples "failures" do |error: Errors::ResourceNotAvailable|
      it "raises #{error.name}" do
        expect { resolve }.to raise_error(error)
      end
    end

    shared_examples "resource not available" do
      it_behaves_like "failures"
    end

    context "when the feature is not available" do
      before do
        stub_licensed_features(design_management: false)
      end

      it_behaves_like "resource not available"
    end

    context "when the feature is available" do
      before do
        stub_licensed_features(design_management: true)
      end

      context "when the user is not allowed to delete designs" do
        let(:user) { create(:user) }

        it_behaves_like "resource not available"
      end

      context "when no filenames are specified" do
        let(:filenames) { [] }

        it_behaves_like "failures", error: StandardError
      end

      context "when deleting all the designs" do
        let(:design_a) { create(:design, :with_file, issue: issue) }
        let(:design_b) { create(:design, :with_file, issue: issue) }
        let(:design_c) { create(:design, :with_file, issue: issue) }
        let(:response) { resolve }

        it "does not return any errors, or any designs" do
          expect(response).to include(errors: be_empty, designs: be_empty)
        end

        describe 'the current designs' do
          before do
            resolve
          end
          let(:current_designs) { issue.current_designs }

          it 'is empty' do
            expect(current_designs).to be_empty
          end
        end
      end

      context "when deleting a design" do
        let(:design_a) { create(:design, :with_file, issue: issue) }
        let(:filenames) { [design_a.filename] }
        let(:response) { resolve }

        it "does not return any errors, or any designs" do
          expect(response).to include(errors: be_empty, designs: be_empty)
        end

        describe 'the current designs' do
          before do
            resolve
          end
          let(:current_designs) { issue.current_designs }

          it 'does not contain design-a' do
            expect(current_designs).not_to include(design_a)
          end

          it 'does contain designs b and c' do
            expect(current_designs).to include(design_b, design_c)
          end
        end
      end
    end
  end
end
