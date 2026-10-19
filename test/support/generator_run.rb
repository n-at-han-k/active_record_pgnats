# frozen_string_literal: true

require "tmpdir"

# Runs a generator into a throwaway destination and hands back the file it wrote.
module GeneratorRun
  def run_generator(generator, args, **options)
    Dir.mktmpdir do |root|
      silently { generator.start(args, destination_root: root, **options) }
      yield root
    end
  end

  def silently
    original = $stdout
    $stdout = StringIO.new
    yield
  ensure
    $stdout = original
  end
end
