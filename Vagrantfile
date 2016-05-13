Vagrant.configure("2") do |config|

  config.vm.network :forwarded_port, guest: 8000, host: 8000, auto_correct: true
  config.vm.synced_folder ".", "/vagrant", id: "vagrant-root", disabled: true
  config.vm.synced_folder ".", "/home/vagrant/src", owner: "vagrant", group: "vagrant"
  config.vm.provision :shell, path: "provision.bash"

  config.vm.provider :docker do |docker, override|
    docker.image = ENV.fetch("VAGRANT_DOCKER_IMAGE", "jesselang/debian-vagrant:jessie")
    docker.has_ssh = true
  end

  # For vagrant ssh, forward agent into the VM so that git works
  config.ssh.forward_agent = true

end
