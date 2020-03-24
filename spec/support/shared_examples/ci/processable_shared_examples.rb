# frozen_string_literal: true

RSpec.shared_examples 'has build dependencies' do |processable_type|
  describe '#invalid_dependencies' do
    let(:pipeline) { create(:ci_pipeline) }
    let!(:job_1) { create(:ci_build, :manual, pipeline: pipeline, name: 'job_1', stage_idx: 0) }
    let!(:job_2_invalid) { create(:ci_build, :success, :expired, pipeline: pipeline, name: 'job_2', stage_idx: 1) }
    let!(:processable) { create(processable_type, pipeline: pipeline, stage_idx: 2) }

    it 'returns invalid dependencies' do
      expect(processable.invalid_dependencies).to eq([job_2_invalid])
    end
  end

  describe '#has_valid_build_dependencies?' do
    let(:options) { {} }
    let!(:processable) { create(processable_type, pipeline: pipeline, stage_idx: 1, options: options) }

    # TODO: validate dependencies based on stages only

    context 'when validation of dependencies is enabled' do
      before do
        stub_feature_flags(ci_disable_validates_dependencies: false)
      end

      let!(:pre_stage_job) { create(:ci_build, :success, pipeline: pipeline, name: 'test', stage_idx: 0) }

      context 'when "dependencies" keyword is not defined' do
        let(:options) { {} }

        it { expect(processable).to have_valid_build_dependencies }
      end

      context 'when "dependencies" keyword is empty' do
        let(:options) { { dependencies: [] } }

        it { expect(processable).to have_valid_build_dependencies }
      end

      context 'when "dependencies" keyword is specified' do
        let(:options) { { dependencies: ['test'] } }

        context 'when depended job has not been completed yet' do
          let!(:pre_stage_job) { create(:ci_build, :manual, pipeline: pipeline, name: 'test', stage_idx: 0) }

          it { expect(processable).to have_valid_build_dependencies }
        end

        context 'when artifacts of depended job has been expired' do
          let!(:pre_stage_job) { create(:ci_build, :success, :expired, pipeline: pipeline, name: 'test', stage_idx: 0) }

          it { expect(processable).not_to have_valid_build_dependencies }
        end

        context 'when artifacts of depended job has been erased' do
          let!(:pre_stage_job) { create(:ci_build, :success, pipeline: pipeline, name: 'test', stage_idx: 0, erased_at: 1.minute.ago) }

          before do
            pre_stage_job.erase
          end

          it { expect(processable).not_to have_valid_build_dependencies }
        end
      end

      context 'when processable has invalid jobs in previous stages' do
        let!(:pre_stage_invalid_job) { create(:ci_build, :success, :expired, pipeline: pipeline, name: 'test', stage_idx: 0) }

        it { expect(processable).not_to have_valid_build_dependencies }
      end
    end

    context 'when validates for dependencies is disabled' do
      let(:options) { { dependencies: ['test'] } }

      before do
        stub_feature_flags(ci_disable_validates_dependencies: true)
      end

      context 'when depended job has not been completed yet' do
        let!(:pre_stage_job) { create(:ci_build, :manual, pipeline: pipeline, name: 'test', stage_idx: 0) }

        it { expect(processable).to have_valid_build_dependencies }
      end

      context 'when artifacts of depended job has been expired' do
        let!(:pre_stage_job) { create(:ci_build, :success, :expired, pipeline: pipeline, name: 'test', stage_idx: 0) }

        it { expect(processable).to have_valid_build_dependencies }
      end

      context 'when artifacts of depended job has been erased' do
        let!(:pre_stage_job) { create(:ci_build, :success, pipeline: pipeline, name: 'test', stage_idx: 0, erased_at: 1.minute.ago) }

        before do
          pre_stage_job.erase
        end

        it { expect(processable).to have_valid_build_dependencies }
      end

      context 'when processable has invalid jobs in previous stages' do
        let!(:pre_stage_invalid_job) { create(:ci_build, :success, :expired, pipeline: pipeline, name: 'test', stage_idx: 0) }

        it { expect(processable).to have_valid_build_dependencies }
      end
    end
  end
end
