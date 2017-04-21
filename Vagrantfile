if File.exist?('env.bash')
  unless Vagrant.has_plugin? 'envbash'
    raise 'Please run: vagrant plugin install envbash'
  end
  EnvBash.load('env.bash')
end

Vagrant.configure("2") do |config|
  config.vm.provider :docker do |docker, override|
    docker.image = ENV.fetch("VAGRANT_DOCKER_IMAGE", "jesselang/debian-vagrant:jessie")
    docker.has_ssh = true
  end
  config.ssh.forward_agent = true  # for github in VM
  config.vm.provision :shell, path: "provision.bash"
end
