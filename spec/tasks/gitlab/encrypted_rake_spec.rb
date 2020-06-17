# frozen_string_literal: true

require 'rake_helper'

describe 'gitlab:encrypted rake tasks' do
  let(:encoded_file) { 'tmp/tests/enc/encryptedtest.enc' }

  before do
    Rake.application.rake_require 'tasks/gitlab/encrypted'
    stub_env('EDITOR', 'cat')
    stub_warn_user_is_not_gitlab
    FileUtils.mkdir_p('tmp/tests/enc/')
  end

  after do
    FileUtils.rm_rf('tmp/tests/enc/')
  end

  describe ':show' do
    it 'displays error when file does not exist' do
      expect { run_rake_task('gitlab:encrypted:show', [encoded_file]) }.to output(/File '#{encoded_file}' does not exist. Use `rake gitlab:encrypted:edit\[#{encoded_file}\]` to change that./).to_stdout
    end

    it 'outputs the unencrypted content when present' do
      encrypted = Settings.encrypted(encoded_file, allow_in_safe_mode: true)
      encrypted.write('somevalue')
      expect { run_rake_task('gitlab:encrypted:show', [encoded_file]) }.to output(/somevalue/).to_stdout
    end
  end

  describe ':edit' do
    it 'creates encrypted file' do
      stub_env('EDITOR', 'echo "foo: bar" >')
      expect { run_rake_task('gitlab:encrypted:edit', [encoded_file]) }.to output(/File encrypted and saved./).to_stdout
      expect(File.exist?(encoded_file)).to be true
      value = Settings.encrypted(encoded_file, allow_in_safe_mode: true)
      expect(value.read.present?).to be true
      expect(value.foo).to eq('bar')
    end
  end
end
