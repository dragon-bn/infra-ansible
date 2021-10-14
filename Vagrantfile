# -*- mode: ruby -*-
# vi: set ft=ruby :
# Use config.yaml for basic VM configuration.

# https://gist.github.com/emgk/44a89c9891ffcdb1f7f89802299e7cde

class String

  def red; colorize(self, "\e[1m\e[31m"); end
  def green; colorize(self, "\e[1m\e[32m"); end
  def dark_green; colorize(self, "\e[32m"); end
  def yellow; colorize(self, "\e[1m\e[33m"); end
  def blue; colorize(self, "\e[1m\e[34m"); end
  def dark_blue; colorize(self, "\e[34m"); end
  def pur; colorize(self, "\e[1m\e[35m"); end
  def colorize(text, color_code)  "#{color_code}#{text}\e[0m" end
end

VAGRANTFILE_API_VERSION = "2"

# lab_name is the name of the lab where all the files will be organized.
lab_group = "Formation"
lab_name = "infra-ansible"

require 'yaml'
dir = File.dirname(File.expand_path(__FILE__))
config_nodes = "#{dir}/artefacts/config/config_multi-nodes.yaml"

if !File.exist?("#{config_nodes}")
  raise 'Configuration file is missing! Please make sure that the configuration exists and try again.'
end
vconfig = YAML::load_file("#{config_nodes}")

BRIDGE_NET = vconfig['vagrant_ip']
DOMAIN = vconfig['vagrant_domain_name']
RAM = vconfig['vagrant_memory']

$script = <<-SCRIPT
echo I am provisioning...
date > /etc/vagrant_provisioned_at
SCRIPT

servers=[
  {
    :hostname => "nfsserver." + "#{DOMAIN}",
    :ip => "#{BRIDGE_NET}" + "150",
    :ram => 1024
  },
  {
    :hostname => "nfsclient." + "#{DOMAIN}",
    :ip => "#{BRIDGE_NET}" + "151",
    :ram => 1024
  },
  {
    :hostname => "docker." + "#{DOMAIN}",
    :ip => "#{BRIDGE_NET}" + "152",
    :ram => 2048
    #:ram => 1024
  },
  {
    :hostname => "jenkins." + "#{DOMAIN}",
    :ip => "#{BRIDGE_NET}" + "153",
    :ram => "#{RAM}" 
  },
  {
    :hostname => "gitlab." + "#{DOMAIN}",
    :ip => "#{BRIDGE_NET}" + "154",
    :ram => "#{RAM}" 
  },
  {
    :hostname => "ansible." + "#{DOMAIN}",
    :ip => "#{BRIDGE_NET}" + "155",
    :ram => "#{RAM}",
	  :install_ansible => "./artefacts/scripts/install_ansible.sh", 
	  :config_ansible => "./artefacts/scripts/config_ansible.sh",
	  :source =>  "./artefacts/.",
	  :destination => "/home/vagrant/"
  }
]

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  #config.vm.synced_folder ".", vconfig['vagrant_directory'], :mount_options => ["dmode=777", "fmode=666"]

  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.manage_guest = true

  servers.each do |machine|

    config.vm.define machine[:hostname] do |node|
		  node.vm.box = vconfig['vagrant_box']
			node.vm.box_version = vconfig['vagrant_box_version']
			node.vm.hostname = machine[:hostname]
      node.vm.network "private_network", ip: machine[:ip] 

      node.vm.provider "virtualbox" do |vb|
        vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        # Set Group for virtual machine
        vb.customize ["modifyvm", :id, "--groups", "/#{lab_group}/#{lab_name}"]
        vb.cpus = vconfig['vagrant_cpu']
        vb.memory = machine[:ram]
        vb.name = machine[:hostname]
      end # end vb

      if (!machine[:install_ansible].nil?)

        if File.exist?(machine[:install_ansible])
          node.vm.provision :shell, path: machine[:install_ansible]
        end

        if File.exist?(machine[:config_ansible])
          node.vm.provision :file, source: machine[:source] , destination: machine[:destination]
      	  node.vm.provision :shell, privileged: false, path: machine[:config_ansible]
        end

       end

      #  puts("Machine - " + machine[:hostname] + " - installée.\n".blue)
      # if (machine[:hostname].include? "ansible")
      #   puts("Machine - " + machine[:hostname] + " - installée.\n".green)
      # end

    end # end node

  end # end machine

  config.trigger.before :provisioner_run, type: :hook do |t|
    t.info = "TRIGGER => Before the provision!"
  end


  config.vm.provision "shell", inline: $script

  config.trigger.before :"Vagrant::Action::Builtin::GracefulHalt", type: :action do |t|
    t.warn = "Vagrant is - gracefull - halting your guest..."
  end

  # Vagrant Triggers
  #
  # If the vagrant-triggers plugin is installed, we can run various scripts on Vagrant
  # state changes like `vagrant up`, `vagrant halt`, `vagrant suspend`, and `vagrant destroy`
  #
  # These scripts are run on the host machine, so we use `vagrant ssh` to tunnel back
  # into the VM and execute things. By default, each of these scripts calls db_backup
  # to create backups of all current databases. This can be overridden with custom
  # scripting. See the individual files in config/homebin/ for details.

  # https://www.vagrantup.com/docs/triggers
  # https://www.vagrantup.com/docs/triggers/configuration
  # https://runebook.dev/en/docs/vagrant/triggers/index


    config.trigger.before :up do |t|
      t.info = "Bringing up your Vagrant guest machine : [:hostname]!"
    end

    config.trigger.before :provision do |trigger|
      trigger.info = "Bringing provision your Vagrant guest machine : [:hostname]!"
    end

    config.trigger.before :reload do |trigger|
      trigger.info = "Bringing reload your Vagrant guest machine : [:hostname]!"
    end

    config.trigger.after :up do |trigger|
      trigger.name = "Finished Message"
      trigger.info = "After UP - Machine is up!"
      # trigger.ruby do
      #   update_ssh_config(main_hostname)
      # end
    end

    config.trigger.after :halt do |trigger|
      trigger.info = "After HALT [:hostname] to ~/.ssh/config"
    end

    config.trigger.after :up do |trigger|
      trigger.info = "More information after up"
      trigger.ruby do |env,machine|
        greetings = "hello there #{machine.id}!"
        puts(greetings .dark_blue)
      end
      trigger.run = {inline: "bash -c 'echo \"hey there bash $(hostname --fqdn)!! - up -\"'" }
    end

    config.trigger.after :provision do |trigger|
      trigger.info = "More information after up"
      trigger.ruby do |env,machine|
        greetings = "hello there #{machine.name}!"
        puts(greetings .blue)
        puts( `VBoxManage showvminfo #{machine.name} --machinereadable | grep ostype` .green)
      end
      trigger.run = {inline: "bash -c 'echo \"hey there bash $(hostname --fqdn)!! - provision -\"'" }
    end

    config.trigger.after :destroy do |trigger|
      trigger.warn = "Destroy command completed"
    end

    config.trigger.before :halt do |trigger|
      trigger.warn = "Vagrant is halting your guest... "
    end

end # end config
