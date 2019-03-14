require 'spec_helper'

describe Gitlab::Ci::Config::Entry::Image do
  include_examples 'CI::Config::Entry::Image validations'
end
