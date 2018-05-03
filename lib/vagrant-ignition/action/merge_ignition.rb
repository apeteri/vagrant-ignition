require 'json'

def ignition_template()
  {ignition: {version: "2.0.0", config: {}}, storage: {}, networkd: {}, passwd: {}}
end

def hostname_entry(hostname)
  {filesystem: "root", path: "/etc/hostname", contents: {source: "data:,%s" % hostname, verification: {}}, mode: 0644, user: {id: 0}, group: {id: 0}}
end

def ip_entry(ip, internal_adapter)
  {name: "00-%s.network" % internal_adapter, contents: "[Match]\nName=%s\n\n[Network]\nAddress=%s" % [ internal_adapter, ip ]}
end

# Vagrant insecure key
VAGRANT_INSECURE_KEY = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key"

def ssh_entry()
  {name: "core", sshAuthorizedKeys: [VAGRANT_INSECURE_KEY]}
end

HOSTNAME_REGEX = /^(?=.{1,255}$)[0-9A-Za-z](?:(?:[0-9A-Za-z]|-){0,61}[0-9A-Za-z])?(?:\.[0-9A-Za-z](?:(?:[0-9A-Za-z]|-){0,61}[0-9A-Za-z])?)*\.?$/

def merge_ignition(ignition_path, hostname, ip, internal_adapter, env)
  if !ignition_path.nil?
    ign_file = File.new(ignition_path, "rb")
    config = JSON.parse(File.read(ign_file), :symbolize_names => true)
  else
    config = ignition_template()
  end

  # Handle hostname
  if !hostname.nil?
    if !(hostname =~ (HOSTNAME_REGEX)).nil?
      config[:storage] ||= {:files => []}
      config[:storage][:files] ||= []
      config[:storage][:files] += [hostname_entry(hostname)]
    else
      env[:machine].ui.info "WARNING: Invalid hostname specified in config.ignition.hostname; ignoring hostname for Ignition Config Drive"
    end
  end

  # Handle internal network NIC
  if !ip.nil?
    config[:networkd] ||= {:units => []}
    config[:networkd][:units] ||= []
    config[:networkd][:units] += [ip_entry(ip, internal_adapter)]
  end

  # Handle ssh key
  config[:passwd] ||= {:users => []}
  config[:passwd][:users] ||= []
  if config[:passwd][:users].select {|user| user[:name] == "core"} != []
    config[:passwd][:users].select{|user| user[:name] == "core"}[0][:sshAuthorizedKeys] ||= []
    config[:passwd][:users].select{|user| user[:name] == "core"}[0][:sshAuthorizedKeys] += [VAGRANT_INSECURE_KEY]
  else
    config[:passwd][:users] += [ssh_entry()]
  end

  File.open("config.ign.merged","wb") do |f|
    f.write(config.to_json)
  end
end
