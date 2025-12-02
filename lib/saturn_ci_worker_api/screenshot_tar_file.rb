# frozen_string_literal: true

module SaturnCIWorkerAPI
  class ScreenshotTarFile
    def initialize(source_dir:)
      @source_dir = source_dir
      system("tar -czf #{path} -C #{@source_dir} .")
    end

    def path
      "#{@source_dir}/screenshots.tar.gz"
    end
  end
end
