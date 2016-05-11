Vagrant.configure("2") do |config|

  config.vm.network :forwarded_port, guest: 4000, host: 4000
  config.vm.synced_folder ".", "/vagrant", id: "vagrant-root", disabled: true
  config.vm.provision :shell, path: "provision.bash"
  config.ssh.forward_agent = true

  config.vm.provider :lxc do |lxc, override|
    lxc.customize 'network.link', 'virbr0'
    override.vm.box = "fgrehm/trusty64-lxc"
    override.vm.synced_folder ".", "/home/vagrant/src", owner: "vagrant", group: "vagrant"
  end

end
