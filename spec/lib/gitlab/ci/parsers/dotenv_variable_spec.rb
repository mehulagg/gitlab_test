# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Ci::Parsers::DotenvVariable do
  let_it_be(:project) { create(:project) }
  let_it_be(:pipeline) { create(:ci_pipeline, project: project) }

  describe '#parse!' do
    subject { described_class.new.parse!(blob, build) }

    let_it_be(:build, reload: true) do
      create(:ci_build, pipeline: pipeline, project: project)
    end

    context 'when dotenv file is formatted correctly' do
      let(:blob) do
        <<~EOS
          KEY1=VAR1
          KEY2=VAR2
        EOS
      end

      it 'returns in Ci::Builds::DotenvVariable model' do
        is_expected.to all( be_kind_of(Ci::Builds::DotenvVariable) )
      end

      it 'parses the dotenv data' do
        expect(subject.as_json).to contain_exactly(
          hash_including('key' => 'KEY1', 'value' => 'VAR1'),
          hash_including('key' => 'KEY2', 'value' => 'VAR2'))
      end
    end

    context 'when a white space trails the key' do
      let(:blob) { 'KEY1 =VAR1' }

      it 'trims the trailing space' do
        expect(subject.as_json).to contain_exactly(
          hash_including('key' => 'KEY1', 'value' => 'VAR1'))
      end
    end

    context 'when multiple key/value pairs exist in one line' do
      let(:blob) { 'KEY1=VAR1KEY2=VAR1' }

      it 'raises an error' do
        expect { subject }
          .to raise_error(Gitlab::Ci::Parsers::ParserError, "Key can contain only letters, digits and '_'.")
      end
    end

    context 'when key contains UNICODE' do
      let(:blob) { '🛹=skateboard' }

      it 'raises an error' do
        expect { subject }
          .to raise_error(Gitlab::Ci::Parsers::ParserError, "Key can contain only letters, digits and '_'.")
      end
    end

    context 'when value contains UNICODE' do
      let(:blob) { 'skateboard=🛹' }

      it 'parses the dotenv data' do
        expect(subject.as_json).to contain_exactly(
          hash_including('key' => 'skateboard', 'value' => '🛹'))
      end
    end

    context 'when key contains a space' do
      let(:blob) { 'K E Y 1=VAR1' }

      it 'raises an error' do
        expect { subject }
          .to raise_error(Gitlab::Ci::Parsers::ParserError, "Key can contain only letters, digits and '_'.")
      end
    end

    context 'when value contains a space' do
      let(:blob) { 'KEY1=V A R 1' }

      it 'parses the dotenv data' do
        expect(subject.as_json).to contain_exactly(
          hash_including('key' => 'KEY1', 'value' => 'V A R 1'))
      end
    end

    context 'when key is missing' do
      let(:blob) { '=VAR1' }

      it 'raises an error' do
        expect { subject }
          .to raise_error(Gitlab::Ci::Parsers::ParserError, /Key can't be blank/)
      end
    end

    context 'when value is missing' do
      let(:blob) { 'KEY1=' }

      it 'parses the dotenv data' do
        expect(subject.as_json).to contain_exactly(
          hash_including('key' => 'KEY1', 'value' => ''))
      end
    end

    context 'when it is not dotenv format' do
      let(:blob) { "{ 'KEY1': 'VAR1' }" }

      it 'raises an error' do
        expect { subject }
          .to raise_error(Gitlab::Ci::Parsers::ParserError, 'Invalid Format')
      end
    end

    context 'when more than limitated variables are specified in dotenv' do
      let(:blob) do
        StringIO.new.tap do |s|
          (Ci::Builds::DotenvVariable::MAX_ACCEPTABLE_VARIABLES_COUNT + 1).times do |i|
            s << "KEY#{i}=VAR#{i}\n"
          end
        end.string
      end

      it 'raises an error' do
        expect { subject }
          .to raise_error(Gitlab::Ci::Parsers::ParserError,
            "Variables are not allowed to be stored more than #{Ci::Builds::DotenvVariable::MAX_ACCEPTABLE_VARIABLES_COUNT}")
      end
    end

    context 'when variables are cross-referenced in dotenv' do
      let(:blob) do
        <<~EOS
          KEY1=VAR1
          KEY2=${KEY1}_Test
        EOS
      end

      it 'does not support variable expansion in dotenv parser' do
        expect(subject.as_json).to contain_exactly(
          hash_including('key' => 'KEY1', 'value' => 'VAR1'),
          hash_including('key' => 'KEY2', 'value' => '${KEY1}_Test'))
      end
    end
  end
end
