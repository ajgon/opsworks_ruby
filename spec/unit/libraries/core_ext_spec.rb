require 'spec_helper'

describe 'Core extensions' do
  context 'classify' do
    it 'basic' do
      expect('basic'.classify).to eq 'Basic'
    end

    it 'basic_with_underscore' do
      expect('basic_with_underscore'.classify).to eq 'BasicWithUnderscore'
    end

    it 'Basic' do
      expect('Basic'.classify).to eq 'Basic'
    end

    it 'BasicWithCamelCase' do
      expect('BasicWithCamelCase').to eq 'BasicWithCamelCase'
    end
  end

  context 'constantize' do
    it 'String' do
      expect('String'.constantize).to eq String
    end

    it 'Drivers::Dsl::Basic' do
      expect('Drivers::Dsl::Basic'.constantize).to eq Drivers::Dsl::Basic
    end
  end

  context 'underscore' do
    it 'LoremIpsumDolorXSitAmet' do
      expect('LoremIpsumDolorXSitAmet'.underscore).to eq 'lorem_ipsum_dolor_x_sit_amet'
    end
  end
end
