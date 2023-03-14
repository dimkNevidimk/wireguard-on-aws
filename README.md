# Overview
Unix tools to setup a `t2.micro` instance with Wireguard VPN in AWS cloud

# Prerequisites
1. Create an account in AWS
    * Important: please check [AWS pricing](https://aws.amazon.com/pricing) before proceed, this is not a *free-vpn* setup, you'll be charged according to AWS policies.

2. Create API credentials and write them to `~/.aws/config` file. Note that depending on the region your server would be located in different places
```
cat ~/.aws/config
[default]
region=eu-west-2
aws_access_key_id=xxx
aws_secret_access_key=yyy
```

3. Install [terraform](https://developer.hashicorp.com/terraform) on your system
4. Setup SSH-keys if not already:
```
ssh-keygen -t ed25519 -C "your@email.smth"
```

# Usage
First start a EC2 instance in a region you setup in `~/.aws/config`.
```
terraform apply
# or if you use different ssh-key than `~/.ssh/id_ed25519`
terraform apply -var private_key_file="path-to-your-private-key"
```
Next create a new Wireguard client configuration on a server
```
./add_client $USER # add a new VPN configuration
# QR-code will be printed to your console #
```
scan resulting QR-code from Wireguard APP on your device and connect to your own VPN server

# Important note
If you don't need a server anymore, don't forget to terminate it in order to avoid unnecessary costs.
```
terraform destroy
```
