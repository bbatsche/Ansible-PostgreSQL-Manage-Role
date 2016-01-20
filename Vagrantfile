# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|
  config.vm.define ENV['HOST_NAME'] do |c|
    c.vm.box      = 'ubuntu/trusty64'
    c.vm.hostname = ENV['HOST_NAME']
  end

  config.vm.provision "shell", inline: "sed -i 's/^AcceptEnv.*$/AcceptEnv */g' /etc/ssh/sshd_config"
  config.vm.provision "shell", inline: "service ssh restart"

  if Vagrant.has_plugin? 'vagrant-cachier'
    config.cache.scope = :box

    config.cache.enable :apt
    config.cache.enable :apt_lists
    config.cache.enable :apt_cacher
    config.cache.enable :composer
    config.cache.enable :bower
    config.cache.enable :npm
    config.cache.enable :gem
  end

  if Vagrant.has_plugin? 'vagrant-vbguest'
    config.vbguest.no_install = true
  end
end
