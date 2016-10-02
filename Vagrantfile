# Load .env.bash -- backticks actually run /bin/sh so run bash inside.
if File.exist?('vagrant-env.bash')
  ENV.replace(eval `bash -ac "source vagrant-env.bash >/dev/null; ruby -e 'p ENV'"`)
end

Vagrant.configure("2") do |config|
  config.vm.provider :docker do |docker, override|
    docker.image = ENV.fetch("VAGRANT_DOCKER_IMAGE", "jesselang/debian-vagrant:jessie")
    docker.has_ssh = true
  end
  config.ssh.forward_agent = true  # for github in VM
  config.vm.provision :shell, path: "provision.bash"
end
