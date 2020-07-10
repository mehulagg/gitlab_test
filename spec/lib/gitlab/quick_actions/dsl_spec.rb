# frozen_string_literal: true

require 'fast_spec_helper'

RSpec.describe Gitlab::QuickActions::Dsl do
  let(:ctx) { double(:Context, record_command_execution: nil) }

  before :all do
    DummyClass = Struct.new(:project) do
      include Gitlab::QuickActions::Dsl

      command :no_args, :none do
        desc 'A command with no args'
        action do
          "Hello World!"
        end
      end

      command :explanation_with_aliases, :once, :first do
        params 'The first argument'
        explanation 'Static explanation'
        warning 'Possible problem!'
        action do |arg|
          arg
        end
      end

      command :dynamic_description do
        desc do
          "A dynamic description for #{noteable.upcase}"
        end
        execution_message do |arg|
          "A dynamic execution message for #{noteable.upcase} passing #{arg}"
        end
        params 'The first argument', 'The second argument'
        action do |args|
          args.split
        end
      end

      command :cc do
        noop
      end

      command :cond_action do
        explanation do |arg|
          "Action does something with #{arg}"
        end
        execution_message 'Command applied correctly'
        condition do
          project == 'foo'
        end
        action do |arg|
          arg
        end
      end

      command :with_params_parsing do
        parse_params do |raw_arg|
          [raw_arg, raw_arg]
        end
        action do |parsed|
          parsed
        end
      end

      command :with_params_parsing_and_alias do
        parse_params(as: :parsed) do |raw_arg|
          raw_arg.strip
        end
        action do
          parsed
        end
      end

      substitution :something do
        params '<Comment>'
        action do |text|
          "#{text} Some complicated thing you want in here"
        end
      end

      command :has_types do
        desc 'A command with types'
        types Issue, Commit
        action do
          "Has Issue and Commit types"
        end
      end

      helper_one = Module.new do
        def do_something
          :did_something
        end
      end

      command :with_modules do
        desc 'A command with helpers'
        action { [do_something, some_method] }
        helpers helper_one
        helpers do
          def some_method
            :called_some_method
          end
        end
      end

      command :strips_param do
        noop
        strips_param
      end

      command :with_named_argument do
        argument :foo
        action do
          [foo, foo, foo]
        end
      end
    end
  end

  context 'a block calls context methods' do
    def build_module
      Module.new do
        include Gitlab::QuickActions::Dsl

        command :a do
          action do
            [context_method, *twice(useful_method)]
          end
        end

        command :b do
          action do
            missing_method
          end
        end

        helpers(Module.new do
          def twice(arg)
            [arg, arg]
          end
        end)

        helpers do
          def useful_method
            :x
          end
        end
      end
    end

    it 'defines commands with access to the context, and to helpers', :aggregate_failures do
      command_a, command_b = build_module.command_definitions

      expect(ctx).to receive(:context_method).and_return(:from_ctx)

      expect(command_a.execute(ctx, nil)).to eq([:from_ctx, :x, :x])
      expect { command_b.execute(ctx, nil) }.to raise_error(NameError)
    end
  end

  context 'a module has common properties' do
    def build_module
      Module.new do
        include Gitlab::QuickActions::Dsl

        types Integer

        command :a do
          noop
        end

        command :b do
          noop
        end

        helpers Module.new

        helpers do
          def useful_method
            :x
          end
        end
      end
    end

    it 'sets the common properties' do
      command_a, command_b = build_module.command_definitions

      expect(command_a.types).to eq([Integer])
      expect(command_b.types).to eq([Integer])
      expect(command_a.helpers).to contain_exactly(Module, Module)
      expect(command_a.helpers).to contain_exactly(Module, Module)
      expect(command_a.helpers.to_a).to match_array(command_b.helpers.to_a)
    end
  end

  context 'a command declares a property twice' do
    def build_module
      Module.new do
        include Gitlab::QuickActions::Dsl

        command :two_descs do
          noop
          desc 'so good'
          desc 'they described it twice'
        end
      end
    end

    it 'raises an error' do
      expect { build_module }.to raise_error(described_class::Builder::DuplicateAttribute)
    end
  end

  context 'a command does not specify an action' do
    def build_module
      Module.new do
        include Gitlab::QuickActions::Dsl

        command :no_action do
          desc 'all talk, and no action'
        end
      end
    end

    it 'raises an error' do
      expect { build_module }.to raise_error(described_class::Builder::NoActionError)
    end
  end

  context 'there is a name collision in primary names' do
    def build_module
      Module.new do
        include Gitlab::QuickActions::Dsl

        command :one do
          noop
        end

        command :one do
          noop
        end
      end
    end

    it 'raises an error' do
      expect { build_module }.to raise_error(described_class::DuplicateCommand)
    end
  end

  context 'there is a name collision in aliases' do
    def build_module
      Module.new do
        include Gitlab::QuickActions::Dsl

        command :ein, :one do
          noop
        end

        command :uno, :one do
          noop
        end
      end
    end

    it 'raises an error' do
      expect { build_module }.to raise_error(described_class::DuplicateCommand)
    end
  end

  context 'there is a name collision in aliases and primary names' do
    def build_module
      Module.new do
        include Gitlab::QuickActions::Dsl

        command :one do
          noop
        end

        command :uno, :one do
          noop
        end
      end
    end

    it 'raises an error' do
      expect { build_module }.to raise_error(described_class::DuplicateCommand)
    end
  end

  describe '.command_definitions' do
    it 'returns an array with commands definitions', :aggregate_failures do
      no_args_def, explanation_with_aliases_def, dynamic_description_def,
      cc_def, cond_action_def, with_params_parsing_def, with_params_parsing_and_alias,
      substitution_def, has_types, with_modules, strips_param, with_named_argument =
        DummyClass.command_definitions

      expect(no_args_def.name).to eq(:no_args)
      expect(no_args_def.aliases).to eq([:none])
      expect(no_args_def.description).to eq('A command with no args')
      expect(no_args_def.explanation).to eq('')
      expect(no_args_def.execution_message).to eq('')
      expect(no_args_def.params).to eq([])
      expect(no_args_def.condition_block).to be_nil
      expect(no_args_def.types).to eq([])
      expect(no_args_def.action_block).to be_a_kind_of(Proc)
      expect(no_args_def.parse_params_block).to be_nil
      expect(no_args_def.warning).to eq('')

      expect(explanation_with_aliases_def.name).to eq(:explanation_with_aliases)
      expect(explanation_with_aliases_def.aliases).to eq([:once, :first])
      expect(explanation_with_aliases_def.description).to eq('')
      expect(explanation_with_aliases_def.explanation).to eq('Static explanation')
      expect(explanation_with_aliases_def.execution_message).to eq('')
      expect(no_args_def.params).to eq([])
      expect(explanation_with_aliases_def.params).to eq(['The first argument'])
      expect(explanation_with_aliases_def.condition_block).to be_nil
      expect(explanation_with_aliases_def.types).to eq([])
      expect(explanation_with_aliases_def.action_block).to be_a_kind_of(Proc)
      expect(explanation_with_aliases_def.parse_params_block).to be_nil
      expect(explanation_with_aliases_def.warning).to eq('Possible problem!')

      expect(dynamic_description_def.name).to eq(:dynamic_description)
      expect(dynamic_description_def.aliases).to eq([])
      expect(dynamic_description_def.to_h(OpenStruct.new(noteable: 'issue'))[:description]).to eq('A dynamic description for ISSUE')
      expect(dynamic_description_def.execute_message(OpenStruct.new(noteable: 'issue'), 'arg')).to eq('A dynamic execution message for ISSUE passing arg')
      expect(dynamic_description_def.params).to eq(['The first argument', 'The second argument'])
      expect(dynamic_description_def.condition_block).to be_nil
      expect(dynamic_description_def.types).to eq([])
      expect(dynamic_description_def.action_block).to be_a_kind_of(Proc)
      expect(dynamic_description_def.parse_params_block).to be_nil
      expect(dynamic_description_def.warning).to eq('')

      expect(cc_def.name).to eq(:cc)
      expect(cc_def.aliases).to eq([])
      expect(cc_def.description).to eq('')
      expect(cc_def.explanation).to eq('')
      expect(cc_def.execution_message).to eq('')
      expect(cc_def.params).to eq([])
      expect(cc_def.condition_block).to be_nil
      expect(cc_def.types).to eq([])
      expect(cc_def.action_block).to be_nil
      expect(cc_def.parse_params_block).to be_nil
      expect(cc_def.warning).to eq('')

      expect(cond_action_def.name).to eq(:cond_action)
      expect(cond_action_def.aliases).to eq([])
      expect(cond_action_def.description).to eq('')
      expect(cond_action_def.explanation).to be_a_kind_of(Proc)
      expect(cond_action_def.execution_message).to eq('Command applied correctly')
      expect(cond_action_def.params).to eq([])
      expect(cond_action_def.condition_block).to be_a_kind_of(Proc)
      expect(cond_action_def.types).to eq([])
      expect(cond_action_def.action_block).to be_a_kind_of(Proc)
      expect(cond_action_def.parse_params_block).to be_nil
      expect(cond_action_def.warning).to eq('')

      expect(with_params_parsing_def.name).to eq(:with_params_parsing)
      expect(with_params_parsing_def.aliases).to eq([])
      expect(with_params_parsing_def.description).to eq('')
      expect(with_params_parsing_def.explanation).to eq('')
      expect(with_params_parsing_def.execution_message).to eq('')
      expect(with_params_parsing_def.params).to eq([])
      expect(with_params_parsing_def.condition_block).to be_nil
      expect(with_params_parsing_def.types).to eq([])
      expect(with_params_parsing_def.action_block).to be_a_kind_of(Proc)
      expect(with_params_parsing_def.parse_params_block).to be_a_kind_of(Proc)
      expect(with_params_parsing_def.warning).to eq('')
      expect(with_params_parsing_def.parse_params_block.call(:x)).to eq([:x, :x])

      expect(with_params_parsing_and_alias.name).to eq(:with_params_parsing_and_alias)
      expect(with_params_parsing_and_alias.aliases).to eq([])
      expect(with_params_parsing_and_alias.description).to eq('')
      expect(with_params_parsing_and_alias.explanation).to eq('')
      expect(with_params_parsing_and_alias.execution_message).to eq('')
      expect(with_params_parsing_and_alias.params).to eq([])
      expect(with_params_parsing_and_alias.condition_block).to be_nil
      expect(with_params_parsing_and_alias.types).to eq([])
      expect(with_params_parsing_and_alias.action_block).to be_a_kind_of(Proc)
      expect(with_params_parsing_and_alias.parse_params_block).to be_a_kind_of(Proc)
      expect(with_params_parsing_and_alias.warning).to eq('')
      expect(with_params_parsing_and_alias.argument_alias).to eq(:parsed)

      expect(substitution_def.name).to eq(:something)
      expect(substitution_def.aliases).to eq([])
      expect(substitution_def.description).to eq('')
      expect(substitution_def.explanation).to eq('')
      expect(substitution_def.execution_message).to eq('')
      expect(substitution_def.params).to eq(['<Comment>'])
      expect(substitution_def.condition_block).to be_nil
      expect(substitution_def.types).to eq([])
      expect(substitution_def.action_block.call('text')).to eq('text Some complicated thing you want in here')
      expect(substitution_def.parse_params_block).to be_nil
      expect(substitution_def.warning).to eq('')

      expect(has_types.name).to eq(:has_types)
      expect(has_types.aliases).to eq([])
      expect(has_types.description).to eq('A command with types')
      expect(has_types.explanation).to eq('')
      expect(has_types.execution_message).to eq('')
      expect(has_types.params).to eq([])
      expect(has_types.condition_block).to be_nil
      expect(has_types.types).to eq([Issue, Commit])
      expect(has_types.action_block).to be_a_kind_of(Proc)
      expect(has_types.parse_params_block).to be_nil
      expect(has_types.warning).to eq('')

      expect(with_modules.name).to eq(:with_modules)
      expect(with_modules.aliases).to be_empty
      expect(with_modules.description).to eq('A command with helpers')
      expect(with_modules.explanation).to eq('')
      expect(with_modules.execution_message).to eq('')
      expect(with_modules.params).to be_empty
      expect(with_modules.condition_block).to be_nil
      expect(with_modules.types).to be_empty
      expect(with_modules).not_to be_noop
      expect(with_modules.parse_params_block).to be_nil
      expect(with_modules.warning).to eq('')
      expect(with_modules.helpers.to_a).to contain_exactly(Module, Module)
      expect(with_modules.execute(ctx, nil)).to contain_exactly(:did_something, :called_some_method)

      expect(strips_param.name).to eq(:strips_param)
      expect(strips_param.aliases).to be_empty
      expect(strips_param.description).to eq('')
      expect(strips_param.explanation).to eq('')
      expect(strips_param.execution_message).to eq('')
      expect(strips_param.params).to be_empty
      expect(strips_param.condition_block).to be_nil
      expect(strips_param.types).to be_empty
      expect(strips_param).to be_noop
      expect(strips_param.warning).to eq('')
      expect(strips_param.helpers).to be_empty
      expect(strips_param.parse_params_block.call(' ooo iii ')).to eq('ooo iii')

      expect(with_named_argument.name).to eq(:with_named_argument)
      expect(with_named_argument.aliases).to be_empty
      expect(with_named_argument.description).to eq('')
      expect(with_named_argument.explanation).to eq('')
      expect(with_named_argument.execution_message).to eq('')
      expect(with_named_argument.params).to be_empty
      expect(with_named_argument.condition_block).to be_nil
      expect(with_named_argument.types).to be_empty
      expect(with_named_argument.warning).to eq('')
      expect(with_named_argument.helpers).to be_empty
      expect(with_named_argument.parse_params_block).to be_nil
      expect(with_named_argument).not_to be_noop
      expect(with_named_argument.execute(ctx, 'x')).to contain_exactly('x', 'x', 'x')
    end
  end
end
