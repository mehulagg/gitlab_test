# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::ImportExport::JSON::NdjsonWriter do
  include ImportExport::CommonUtil

  let(:path) { "#{Dir.tmpdir}/legacy_writer_spec/tree" }
  let(:root) { :project }

  subject { described_class.new(path, root) }

  after do
    FileUtils.rm_rf(path)
  end

  describe "#set" do
    it "writes correct json to root" do
      expected_hash = { "key" => "value_1", "key_1" => "value_2" }
      subject.set(expected_hash)
      subject.close

      expect(ndjson_relations(path, root)).to eq([expected_hash])
    end
  end

  describe "#append" do
    let (:values) { [{ "key" => "value_1", "key_1" => "value_1" }, { "key" => "value_2", "key_1" => "value_2" }] }

    context "when multiple values are appended to same relation" do
      it "appends json in correct file " do
        relation = "relation"
        values.each do |value|
          subject.append(relation, value)
        end
        subject.close

        expect(ndjson_relations(path, relation)).to eq(values)
      end
    end

    context "when multiple values are appended to different relation" do
      it "writes json in correct files" do
        relations = %w(relation1 relation2)
        relations.each do |relation|
          values.each do |value|
            subject.append(relation, value)
          end
        end
        subject.close

        relations.each do |relation|
          expect(ndjson_relations(path, relation)).to eq(values)
        end
      end
    end
  end
end
