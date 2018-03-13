# frozen_string_literal: true

require 'spec_helper'

archives_path = fixture_path('archives')

describe OpsworksRuby::Archive do
  TEST_MIME_TYPES = {
    'test.gz' => 'application/gzip',
    'test.7z' => 'application/x-7z-compressed',
    'test.bz2' => 'application/x-bzip',
    'test.tar.bz2' => 'application/x-bzip-compressed-tar',
    'test.Z' => 'application/x-compress',
    'test.tar.gz' => 'application/x-compressed-tar',
    'test.tar' => 'application/x-tar',
    'test.tar.Z' => 'application/x-tarz',
    'test.xz' => 'application/x-xz',
    'test.tar.xz' => 'application/x-xz-compressed-tar',
    'test.zip' => 'application/zip'
  }.freeze

  TEST_COMMANDS = {
    'test.gz' => "gunzip -c #{archives_path}/test.gz > %s",
    'test.7z' => "7z x -t7z #{archives_path}/test.7z -o%s",
    'test.bz2' => "bzip2 -ckd #{archives_path}/test.bz2 > %s",
    'test.tar.bz2' => "tar -xjf #{archives_path}/test.tar.bz2 -C %s",
    'test.Z' => "zcat #{archives_path}/test.Z > %s",
    'test.tar.gz' => "tar -xzf #{archives_path}/test.tar.gz -C %s",
    'test.tar' => "tar -xf #{archives_path}/test.tar -C %s",
    'test.tar.Z' => "zcat #{archives_path}/test.tar.Z | tar -xf -C %s -",
    'test.xz' => "xz --decompress --stdout #{archives_path}/test.xz > %s",
    'test.tar.xz' => "tar -xJf #{archives_path}/test.tar.xz -C %s",
    'test.zip' => "unzip #{archives_path}/test.zip -d %s"
  }.freeze

  context '#file_mime_type' do
    TEST_MIME_TYPES.each do |file, expected_mime_type|
      example file do
        expect(described_class.new(fixture_path('archives', file)).file_mime_type).to eq expected_mime_type
      end
    end
  end

  context '#extract_command' do
    let(:destination) { Dir.mktmpdir(SecureRandom.uuid) }

    TEST_COMMANDS.each do |file, expected_command|
      example file do
        expect(described_class.new(archives_path.join(file)).extract_command(destination))
          .to eq format(expected_command, destination)
      end
    end
  end
end
