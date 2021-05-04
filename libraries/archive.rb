# frozen_string_literal: true

module OpsworksRuby
  class Archive
    MIME_MAGIC_TABLES = [
      ['application/gzip', [[0, "\037\213".b]]],
      ['application/x-7z-compressed', [[0, "7z\274\257'\034".b]]],
      ['application/x-bzip', [[0, 'BZh'.b]]],
      ['application/x-compress', [[0, "\037\235".b]]],
      ['application/x-tar', [[257, "ustar\000".b], [257, "ustar  \000".b]]],
      ['application/x-xz', [[0, "\3757zXZ\000".b]]],
      ['application/zip', [[0, "PK\003\004".b]]]
    ].freeze

    TYPES = {
      'application/x-bzip-compressed-tar' => [
        %w[tar.bz tar.bz2 tb2 tbz tbz2], %w[application/x-bzip], 'Tar archive (bzip-compressed)'
      ],
      'application/x-compressed-tar' => [
        %w[tar.gz tgz], %w[application/gzip], 'Tar archive (gzip-compressed)'
      ],
      'application/x-tarz' => [
        %w[tar.z taz], %w[application/x-compress], 'Tar archive (compressed)'
      ],
      'application/x-xz-compressed-tar' => [
        %w[tar.xz txz], %w[application/x-xz], 'Tar archive (XZ-compressed)'
      ]
    }.freeze

    COMMANDS = {
      'application/gzip' => 'gunzip -c %s > %s',
      'application/x-7z-compressed' => '7z x -t7z %s -o%s',
      'application/x-bzip' => 'bzip2 -ckd %s > %s',
      'application/x-bzip-compressed-tar' => 'tar -xjf %s -C %s',
      'application/x-compress' => 'zcat %s > %s',
      'application/x-compressed-tar' => 'tar -xzf %s -C %s',
      'application/x-tar' => 'tar -xf %s -C %s',
      'application/x-tarz' => 'zcat %s | tar -xf -C %s -',
      'application/x-xz' => 'xz --decompress --stdout %s > %s',
      'application/x-xz-compressed-tar' => 'tar -xJf %s -C %s',
      'application/zip' => 'unzip %s -d %s'
    }.freeze

    def initialize(source_path)
      @source_path = source_path.to_s
    end

    def uncompress(destination)
      cmd = Mixlib::ShellOut.new(extract_command(destination))
      cmd.run_command
    end

    def extract_command(destination)
      format(COMMANDS[file_mime_type], @source_path, destination)
    end

    def file_mime_type
      mime_type = File.open(@source_path) do |io|
        io.binmode
        io.set_encoding(Encoding::BINARY)

        find_mime_matches(io)&.first
      end

      detect_tar_mime_type(mime_type)
    end

    def find_mime_matches(io)
      MIME_MAGIC_TABLES.detect do |item|
        item[1].any? do |bytes|
          io.rewind
          io.read(bytes[0])
          io.read(bytes[1].size) == bytes[1]
        end
      end
    end

    def detect_tar_mime_type(mime_type)
      types_with_matching_extensions = TYPES.select do |_mime_name, types|
        types[1].include?(mime_type)
      end

      types_with_matching_extensions.detect do |types|
        types[1][0].any? { |extension| @source_path.downcase.end_with?(extension) }
      end&.first || mime_type
    end
  end
end
