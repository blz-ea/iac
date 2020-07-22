install:
	@ansible-playbook ./requirements.yml

prep:

init: prep ## Initialize
			@terraform init

plan: init ## Plan changes
			@terraform plan \
								-lock=true

apply: init ## Apply changes
			 @terraform apply \
			 						-auto-approve