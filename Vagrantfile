Vagrant.configure("2") do |config|
  k8s_version='v1.29'

  config.vm.box = "ubuntu/focal64"  

  config.vm.provision :shell, path: "bootstrap-common.sh"
  

  number_of_nodes = 3

  
  config.vm.define "master" do |master|
    ip_addr = "192.168.1.1"

    master.vm.provider :virtualbox do |vb|
      vb.cpus = 2
      vb.memory = 2048
    end

    master.vm.network "public_network", bridge: "eth0"
    master.vm.network "private_network", ip: "#{ip_addr}", virtualbox__intnet: true
    master.vm.hostname = "master"

  
    master.vm.provision :shell, path: "bootstrap-master.sh", env: {"IP_ADDR" => "#{ip_addr}", "KUBE_VERSION" => "#{k8s_version}"}
    
  end

  
  (1..number_of_nodes).each do |n|
    config.vm.define "node-#{n}" do |node|
      ip_addr = "192.168.1.1#{n}"
      
      node.vm.provider :virtualbox do |vb|
        vb.cpus = 2
        vb.memory = 4096
      end
  
      node.vm.network "private_network", ip: "#{ip_addr}", virtualbox__intnet: true
      node.vm.hostname = "node#{n}"      
  
      node.vm.provision :shell, path: "bootstrap-node.sh", env: {"IP_ADDR" => "#{ip_addr}", "KUBE_VERSION" => "#{k8s_version}"}
  
    end
  end
  
  

end