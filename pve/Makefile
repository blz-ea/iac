start:
	@ansible-playbook ./requirements.yml

prep:

init: prep ## Initialize
			@terraform init

plan: prep ## Plan changes
			@terraform plan \
								-lock=true

apply: prep ## Apply changes
			 @terraform apply \
			 						-auto-approve