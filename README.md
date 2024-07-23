# terraform-service-now
I have been tasked to create a terraform pipeline that builds our entire environment in a sequential order. The goal is to make this process as automated as possible without sacrificing security. This repo is my POC to test custom GitHub environments approvals using service now or a service now self service pipeline workflow.

## Webhook setup:
1. Create GitHub app with webhook url pointed to your local machine http://<urIP>:9000/hooks/deployment-approval
- Add repo read and write permissions for deployment and subscribe to the deployment protection rule event
- install the GitHub app on your repo you want to call this webhook
2. Create an environment in the repo you instead the GitHub app
- edit environment
- add environment secrets
- add custom approval app you just installed as a deployment protection rule
3. Install webhook on your workstation
```
wget https://github.com/adnanh/webhook/releases/download/2.8.1/webhook-linux-amd64.tar.gz
md5sum webhook-linux-amd64.tar.gz (verify checksum)
tar -xvf webhook-linux-amd64.tar.gz
sudo mv webhook-linux-amd64/webhook /usr/local/bin/
webhook --version
webhook -verbose
```
4. Configure webhook on your workstation
- create folder in the repo called webhooks
- Create a hooks.yaml
- Add hook matching your URL name
5. Start webhook server
```
webhook -hooks hooks.yaml -hotreload -verbose -http-methods post
```