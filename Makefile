# Check for existing installation
ansible := $(shell command -v ansible-playbook 2> /dev/null)

# Install Ansible
install_ansible:
	./modules/bash/ansible/main.sh

# Install Ansible if does not exist
prep:
ifndef ansible
	@echo "Ansible was not found. Installing Ansible ..."
	make install_ansible
else
	@echo "Ansible already installed"
endif

install: prep
			@ansible-playbook ./requirements.yml
