# frozen_string_literal: true

require 'spec_helper'

describe 'Core extensions' do
  context 'Object' do
    it 'try' do
      expect(nil.try(:lorem)).to be_nil
      expect('123'.try(:to_i)).to eq 123
    end

    it 'blank?' do
      expect(nil.blank?).to be_truthy
      expect({}.blank?).to be_truthy
      expect([].blank?).to be_truthy
      expect(''.blank?).to be_truthy
      expect(false.blank?).to be_truthy
      expect(true.blank?).to be_falsey
      expect('x'.blank?).to be_falsey
      expect([1].blank?).to be_falsey
      expect({ a: 0 }.blank?).to be_falsey
      expect(0.blank?).to be_falsey
    end

    it 'present?' do
      expect(nil.present?).to be_falsey
      expect({}.present?).to be_falsey
      expect([].present?).to be_falsey
      expect(''.present?).to be_falsey
      expect(false.present?).to be_falsey
      expect(true.present?).to be_truthy
      expect('x'.present?).to be_truthy
      expect([1].present?).to be_truthy
      expect({ a: 0 }.present?).to be_truthy
      expect(0.present?).to be_truthy
    end

    it 'presence' do
      expect(nil.presence).to be_nil
      expect({}.presence).to be_nil
      expect([].presence).to be_nil
      expect(''.presence).to be_nil
      expect(false.presence).to be_nil
      expect(true.presence).to eq true
      expect('x'.presence).to eq 'x'
      expect([1].presence).to eq [1]
      expect({ a: 0 }.presence).to eq(a: 0)
      expect(0.presence).to eq 0
    end

    it 'descendants' do
      A = Class.new
      B = Class.new(A)

      expect(A.descendants).to eq [B]

      Object.send(:remove_const, :B)
      Object.send(:remove_const, :A)
    end
  end

  context 'Array' do
    it 'wrap' do
      expect(Array.wrap(nil)).to eq []
      expect(Array.wrap(false)).to eq [false]
      expect(Array.wrap([])).to eq []
      expect(Array.wrap(1..4)).to eq [1..4]
    end
  end

  context 'Hash' do
    it 'stringify_keys' do
      expect({ a: 3, 'b' => 4, 7 => 8 }.stringify_keys).to eq('a' => 3, 'b' => 4, '7' => 8)
    end

    it 'symbolize_keys' do
      expect({ a: 3, 'b' => 4, 7 => 8 }.symbolize_keys).to eq(a: 3, b: 4, 7 => 8)
    end
  end

  context 'String' do
    it 'classify' do
      expect('basic'.classify).to eq 'Basic'
      expect('basic_with_underscore'.classify).to eq 'BasicWithUnderscore'
      expect('Basic'.classify).to eq 'Basic'
      expect('BasicWithCamelCase').to eq 'BasicWithCamelCase'
    end

    it 'constantize' do
      expect('String'.constantize).to eq String
      expect('Drivers::Dsl::Packages'.constantize).to eq Drivers::Dsl::Packages
    end

    it 'underscore' do
      expect('LoremIpsumDolorXSitAmet'.underscore).to eq 'lorem_ipsum_dolor_x_sit_amet'
    end
  end
end
