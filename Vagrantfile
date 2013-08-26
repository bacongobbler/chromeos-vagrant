# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "precise64-cloudimg"
  config.vm.box_url = "http://cloud-images.ubuntu.com/precise/current/precise-server-cloudimg-vagrant-amd64-disk1.box"

  config.vm.provider :virtualbox do |vb|
    vb.gui = true
    # linking the browser for ChromeOS takes 4GB
    vb.customize ["modifyvm", :id, "--memory", "4096"]
  end

  config.vm.provision :shell, :path => "provision.sh"
end
