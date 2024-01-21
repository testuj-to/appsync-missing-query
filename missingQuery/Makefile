
.PHONY: default deploy destroy

default:

deploy:
	terraform init
	terraform apply -auto-approve -input=false

destroy:
	terraform destroy -auto-approve -input=false
