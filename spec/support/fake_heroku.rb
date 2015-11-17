class FakeHeroku
  RECORDER = File.expand_path(File.join('..', '..', 'tmp', 'heroku_commands'), File.dirname(__FILE__))

  def initialize(args)
    @args = args
  end

  def run!
    File.open(RECORDER, 'a') do |file|
      file.puts @args.join(' ')
    end
  end

  def self.clear!
    FileUtils.rm_rf RECORDER
  end

  def self.has_gem_included?(project_path, gem_name)
    gemfile = File.open(File.join(project_path, 'Gemfile'), 'a')

    File.foreach(gemfile).any? do |line|
      line.match(/#{Regexp.quote(gem_name)}/)
    end
  end

  def self.has_created_app_for?(environment, flags = nil)
    app_name = "#{SliningTestHelpers::APP_NAME.dasherize}-#{environment}"

    command = if flags
                "create #{app_name} #{flags} --remote #{environment}\n"
              else
                "create #{app_name} --remote #{environment}\n"
              end

    File.foreach(RECORDER).any? { |line| line == command }
  end

  def self.has_configured_vars?(remote_name, var)
    commands_ran =~ /^config:add #{var}=.+ --remote #{remote_name}\n/
  end

  def self.commands_ran
    @commands_ran ||= File.read(RECORDER)
  end
end
