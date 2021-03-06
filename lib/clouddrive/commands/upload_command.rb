require 'colorize'

module CloudDrive

  class UploadCommand < Command

    parameter "local_path", "Local path to file/folder to upload"
    parameter "[remote_path]", "Remote path to upload the file(s) to"
    option ["-o", "--overwrite"], :flag, "Overwrite the remote node if it exists but has a different checksum"

    def execute
      @offline = false

      init

      source = File.expand_path(local_path)
      unless File.exist?(source)
        error("No file or folder exists at '#{source}'")
      end

      if overwrite?
        overwrite = true
      else
        overwrite = false
      end

      options = { :overwrite => overwrite, :allow_duplicates => @config['upload.duplicates'] }
      if File.directory?(source)
        Node.upload_dir(source, remote_path, method(:display_file_results), options)
      else
        result = Node.upload_file(source, remote_path, options)
        display_file_results(source, remote_path, result)
      end
    end

    def display_file_results(local_path, remote_path, retval)
      if retval[:success]
        info("Successfully uploaded '#{local_path}' to '#{remote_path}'")
      else
        error("Failed to upload '#{local_path}': #{retval[:data]["message"]}")
      end
    end

  end

end
