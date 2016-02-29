class Configuration
  FILE = Rails.root.join('config', 'config.yml')

  def initialize
    config
  end

  def all
    config
  end

  def update
    File.write(FILE, config.to_yaml) ? true : false
  end

  def method_missing(name, *attrs)
    if name =~ /^([a-z_0-9]+)$/
      config[$1.to_sym]
    elsif name =~ /^([a-z_0-9]+)=$/
      config[$1.to_sym] = attrs.first
    elsif name =~ /^([a-z_0-9]+)\?$/
      config[$1.to_sym].present?
    else
      super
    end
  end

  private
    def config
      @config ||= YAML.load_file(FILE)
    end
end
