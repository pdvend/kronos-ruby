# frozen_string_literal: true

RSpec.describe 'Kronos::VERSION' do
  subject { Kronos::VERSION }

  it 'is a string' do
    is_expected.to be_a(String)
  end

  it 'follows semantic versioning format' do
    is_expected.to match(/\d+.\d+.\d+/)
  end
end
