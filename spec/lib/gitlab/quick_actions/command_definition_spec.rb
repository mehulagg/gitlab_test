# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::QuickActions::CommandDefinition do
  subject { described_class.new(:command) }

  describe "#all_names" do
    context "when the command has aliases" do
      before do
        subject.aliases = [:alias1, :alias2]
      end

      it "returns an array with the name and aliases" do
        expect(subject.all_names).to eq([:command, :alias1, :alias2])
      end
    end

    context "when the command doesn't have aliases" do
      it "returns an array with the name" do
        expect(subject.all_names).to eq([:command])
      end
    end
  end

  describe "#noop?" do
    context "when the command has an action block" do
      before do
        subject.action_block = proc { }
      end

      it "returns false" do
        expect(subject.noop?).to be false
      end
    end

    context "when the command doesn't have an action block" do
      it "returns true" do
        expect(subject.noop?).to be true
      end
    end
  end

  describe "#available?" do
    let(:opts) { OpenStruct.new(go: false) }

    context "when the command has a condition block" do
      before do
        subject.condition_block = proc { go }
      end

      context "when the condition block returns true" do
        before do
          opts[:go] = true
        end

        it "returns true" do
          expect(subject.available?(opts)).to be true
        end
      end

      context "when the condition block returns false" do
        it "returns false" do
          expect(subject.available?(opts)).to be false
        end
      end
    end

    context "when the command doesn't have a condition block" do
      it "returns true" do
        expect(subject.available?(opts)).to be true
      end
    end

    context "when the command has types" do
      before do
        subject.types = [Issue, Commit]
      end

      context "when the command target type is allowed" do
        it "returns true" do
          opts[:quick_action_target] = Issue.new
          expect(subject.available?(opts)).to be true
        end
      end

      context "when the command target type is not allowed" do
        it "returns true" do
          opts[:quick_action_target] = MergeRequest.new
          expect(subject.available?(opts)).to be false
        end
      end
    end

    context "when the command has no types" do
      it "any target type is allowed" do
        opts[:quick_action_target] = Issue.new
        expect(subject.available?(opts)).to be true

        opts[:quick_action_target] = MergeRequest.new
        expect(subject.available?(opts)).to be true
      end
    end
  end

  describe "#execute" do
    let(:context) { double('Context') }

    context "when the command is a noop" do
      it "doesn't execute the command" do
        expect(context).not_to receive(:instance_exec)
        expect(context).not_to receive(:record_command_execution)

        subject.execute(context, nil)
      end
    end

    context "when the command is not a noop" do
      let(:no_arg_action) { -> { run } }

      before do
        subject.action_block = no_arg_action
      end

      context "when the command is not available" do
        before do
          subject.condition_block = proc { false }
        end

        it "doesn't execute the command" do
          expect(context).not_to receive(:record_command_execution)
          expect(context).not_to receive(:run)

          subject.execute(context, nil)
        end
      end

      shared_examples 'an available command' do
        before do
          expect(context).to receive(:record_command_execution)
        end

        context "when the command has no arguments" do
          before do
            subject.action_block = no_arg_action
          end

          context "when the command is provided an argument" do
            it "executes the command" do
              expect(context).to receive(:run)

              subject.execute(context, true)
            end
          end

          context "when the command is not provided an argument" do
            it "executes the command" do
              expect(context).to receive(:run)

              subject.execute(context, nil)
            end
          end
        end

        context "when the command has 1 required argument" do
          before do
            subject.action_block = ->(arg) { run(arg) }
          end

          context "when the command is provided an argument" do
            it "executes the command" do
              expect(context).to receive(:run).with(:the_arg)

              subject.execute(context, :the_arg)
            end
          end

          context "when the command is not provided an argument" do
            it "doesn't execute the command" do
              expect(context).not_to receive(:run)

              subject.execute(context, nil)
            end
          end
        end

        context "when the command has 1 optional argument" do
          before do
            subject.action_block = -> (arg = :default) { run(arg) }
          end

          context "when the command is provided an argument" do
            it "executes the command" do
              expect(context).to receive(:run).with(:provided)

              subject.execute(context, :provided)
            end
          end

          context "when the command is not provided an argument" do
            it "executes the command" do
              expect(context).to receive(:run).with(:default)

              subject.execute(context, nil)
            end
          end
        end

        context 'when the command defines parse_params block' do
          before do
            subject.parse_params_block = ->(raw) { raw.strip }
            subject.action_block = ->(parsed) { run(parsed) }
          end

          it 'executes the command passing the parsed param' do
            expect(context).to receive(:run).with('something')

            subject.execute(context, 'something   ')
          end
        end
      end

      context 'the command is unconditionally available' do
        it_behaves_like 'an available command'
      end

      context 'the command is conditionally available' do
        before do
          subject.condition_block = -> { true }
        end

        it_behaves_like 'an available command'
      end
    end
  end

  describe "#execute_message" do
    context "when the command is a noop" do
      it 'returns nil' do
        expect(subject.execute_message({}, nil)).to be_nil
      end
    end

    context "when the command is not a noop" do
      before do
        subject.action_block = proc { self.run = true }
      end

      context "when the command is not available" do
        before do
          subject.condition_block = proc { false }
        end

        it 'returns nil' do
          expect(subject.execute_message({}, nil)).to be_nil
        end
      end

      context "when the command is available" do
        context 'when the execution_message is a static string' do
          before do
            subject.execution_message = 'Assigned jacopo'
          end

          it 'returns this static string' do
            expect(subject.execute_message({}, nil)).to eq('Assigned jacopo')
          end
        end

        context 'when the explanation is dynamic' do
          before do
            subject.execution_message = proc { |arg| "Assigned #{arg}" }
          end

          it 'invokes the proc' do
            expect(subject.execute_message({}, 'Jacopo')).to eq('Assigned Jacopo')
          end
        end
      end
    end
  end

  describe '#explain' do
    context 'when the command is not available' do
      before do
        subject.condition_block = proc { false }
        subject.explanation = 'Explanation'
      end

      it 'returns nil' do
        result = subject.explain({}, nil)

        expect(result).to be_nil
      end
    end

    context 'when the explanation is a static string' do
      before do
        subject.explanation = 'Explanation'
      end

      it 'returns this static string' do
        result = subject.explain({}, nil)

        expect(result).to eq 'Explanation'
      end
    end

    context 'when warning is set' do
      before do
        subject.explanation = 'Explanation'
        subject.warning = 'dangerous!'
      end

      it 'returns this static string' do
        result = subject.explain({}, nil)

        expect(result).to eq 'Explanation (dangerous!)'
      end
    end

    context 'when the explanation is dynamic' do
      before do
        subject.explanation = proc { |arg| "Dynamic #{arg}" }
      end

      it 'invokes the proc' do
        result = subject.explain({}, 'explanation')

        expect(result).to eq 'Dynamic explanation'
      end
    end
  end
end
