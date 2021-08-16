
subnet = "192.168.50."
server_cpus = 2
server_memory = 1024

Vagrant.configure("2") do |config|
    config.vm.box = "centos/7"
    config.vm.box_check_update=false
    
    config.vm.provider :virtualbox do |vb_config|
        vb_config.memory = server_memory
        vb_config.cpus = server_cpus
        vb_config.gui = false
        vb_config.check_guest_additions=false
    end


    # Install Docker
    config.vm.provision :docker

    # Install Docker Compose
    # First, install required plugin https://github.com/leighmcculloch/vagrant-docker-compose:
    # vagrant plugin install vagrant-docker-compose
    # docker-compose file with Docker Registry and Nexus containers
    config.vm.provision :docker_compose, yml: "/vagrant/docker-compose.yml", rebuild: true, run: "always"

    # config.vm.provision "shell", inline: "/bin/sh /vagrant/docker/start.sh"

    config.vm.define :jenkins do |jenkins_srv|
        jenkins_srv.vm.provider :virtualbox do |vb_config|
            vb_config.name =  "Jenkins"
        end
                    
        jenkins_srv.vm.hostname = "Jenkins"
        jenkins_srv.vm.network :forwarded_port, guest: 8080, host: 8080
        jenkins_srv.vm.network :forwarded_port, guest: 8081, host: 8081
        jenkins_srv.vm.network :forwarded_port, guest: 8082, host: 8082
        # Install Jenkins 
        # jenkins_srv.vm.provision "shell", inline: <<-SHELL
        # yum install java-1.8.0-openjdk java-1.8.0-openjdk-devel wget git -y -q
        # curl --silent --location http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo | sudo tee /etc/yum.repos.d/jenkins.repo
        # rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key
        # yum install jenkins -y -q
        # usermod -aG docker jenkins
        # systemctl start jenkins
        # systemctl enable jenkins
        # sleep 1m
        # JENKINSPWD=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)
        # echo $JENKINSPWD
        # SHELL

        jenkins_srv.vm.network "private_network", ip: subnet+"2"
	end
end
