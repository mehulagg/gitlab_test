# frozen_string_literal: true
require 'rails_helper'

describe DesignManagement::Version do
  describe 'relations' do
    it { is_expected.to have_many(:design_versions) }
    it { is_expected.to have_many(:designs).through(:design_versions) }

    it 'constrains the designs relation correctly' do
      design = create(:design)
      version = create(:design_version)

      version.designs << design

      expect { version.designs << design }.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it 'allows adding multiple versions to a single design' do
      design = create(:design)
      versions = create_list(:design_version, 2)

      expect { versions.each { |v| design.versions << v } }
        .not_to raise_error
    end
  end

  describe 'validations' do
    subject(:design_version) { build(:design_version) }

    it { is_expected.to be_valid }
    it { is_expected.to validate_presence_of(:sha) }
    it { is_expected.to validate_uniqueness_of(:sha).case_insensitive }
  end

  describe "scopes" do
    describe ".for_designs" do
      it "only returns versions related to the specified designs" do
        version_1 = create(:design_version)
        version_2 = create(:design_version)
        _other_version = create(:design_version)
        designs = [create(:design, versions: [version_1]),
                   create(:design, versions: [version_2])]

        expect(described_class.for_designs(designs))
          .to contain_exactly(version_1, version_2)
      end
    end

    describe '.as_of' do
      let(:t_zero) { Time.local(2010) }

      let!(:version_a) { Timecop.freeze(t_zero) { create(:design_version) } }
      let!(:version_b) { Timecop.freeze(t_zero + 10.days) { create(:design_version) } }
      let!(:version_c) { Timecop.freeze(t_zero + 20.days) { create(:design_version) } }
      let!(:version_d) { Timecop.freeze(t_zero + 30.days) { create(:design_version) } }

      subject { described_class.as_of(cut_off) }

      context 'the as-of date is after the last creation' do
        let(:cut_off) { t_zero + 30.days }

        it { is_expected.to include(version_a, version_b, version_c, version_d) }
      end

      context 'the as-of date is before the first creation' do
        let(:cut_off) { t_zero - 1.day }

        it { is_expected.to be_empty }
      end

      context 'the as-of date is in between two moments' do
        let(:cut_off) { t_zero + 15.days }

        it { is_expected.to include(version_a, version_b) }

        it { is_expected.not_to include(version_c, version_d) }
      end
    end
  end

  describe ".bulk_create" do
    it "creates a version and links it to multiple designs" do
      designs = create_list(:design, 2)

      version = described_class.create_for_designs(designs, "abc")

      expect(version.designs).to contain_exactly(*designs)
    end
  end

  describe "#issue" do
    it "gets the issue for the linked design" do
      version = create(:design_version)
      design = create(:design, versions: [version])

      expect(version.issue).to eq(design.issue)
    end
  end
end
