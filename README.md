# TF

### Infra aws bastion host for instance ec2 and rds

In order to create ssh keys using ssh-keygen:

```
ssh-keygen -t rsa -C "your_email@example.com" -f <name_of_key>
```
To connect to bastion host execute:

```
ssh userx@$(terraform output -raw public_ip) -i <path/name_of_key>
```
