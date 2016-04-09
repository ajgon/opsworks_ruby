require 'spec_helper'

describe Drivers::Dsl::Packages do
  include described_class

  context 'parameters' do
    it 'returns the default action' do
      expect(packages_default_action).to eq 'install'
    end

    it 'sets the default action' do
      packages_default_action 'update'

      expect(packages_default_action).to eq 'update'

      packages_default_action 'install'
    end

    it 'returns default packages' do
      expect(packages).to eq []
    end

    it 'sets packages' do
      packages 'ruby'

      expect(packages).to eq ['ruby']

      packages []
    end
  end

  context '#handle_packages' do
    it 'install' do
      packages 'wget', 'curl'

      handle_packages
    end
  end
end
