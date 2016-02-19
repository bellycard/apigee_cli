require 'apigee_cli/cli/thor_cli'

class Resource < ThorCli
  namespace 'resource'
  default_task :list

  desc 'list', 'List resource files'
  option :name, type: :string
  def list
    name = options[:name]

    resource = ApigeeCli::ResourceFile.new(environment)

    if name
      response = resource.read(name, ApigeeCli::ResourceFile::DEFAULT_RESOURCE_TYPE)
      say response
    else
      pull_list(resource)
    end
  end

  desc 'upload', 'Upload resource files'
  option :folder, type: :string, required: true
  option :name, type: :string
  def upload
    folder = options[:folder]
    name = options[:name]

    if name
      files = Dir.entries(folder).select{ |f| f =~ /#{name}$/ }
    else
      files = Dir.entries(folder).select{ |f| f =~ /.js$/ }
    end

    resource = ApigeeCli::ResourceFile.new(environment)

    files.each do |file|
      result = resource.upload file, ApigeeCli::ResourceFile::DEFAULT_RESOURCE_TYPE, "#{folder}/#{file}"
      if result == :overwritten
        say "Overwriting current resource for #{file}", :green
      elsif result == :new_file
        say "Creating resource for #{file}", :green
      end
    end
  end

  desc 'delete', 'Delete resource file'
  option :name, type: :string, required: true
  def delete
    name = options[:name]

    resource = ApigeeCli::ResourceFile.new(environment)

    confirm = yes? "Are you sure you want to delete #{name} from #{org}? [y/n]"

    if confirm
      begin
        say "Deleting current resource for #{name}", :red
        resource.remove(name, ApigeeCli::ResourceFile::DEFAULT_RESOURCE_TYPE)
      rescue RuntimeError => e
        render_error(e)
        exit
      end
    else
      exit
    end
  end

  private

    def pull_list(resource)
      response = Hashie::Mash.new(resource.all)
      render_list(response[ApigeeCli::ResourceFile::RESOURCE_FILE_KEY])
    end

    def render_list(resource_files)
      say "Resource files for #{org}", :blue
      resource_files.each do |resource_file|
        name = resource_file['name']
        type = resource_file['type']

        say "  #{type} file - #{name}", :green
      end
    end

    def render_error(error)
      say error.to_s, :red
    end
end
