# Personal Server Applications
This repo is for all applications that will run on my personal server at Digial Ocean (called `dionysus`). It consists of a `docker-compose.yaml` defining the services I want as well as some configuration and some helper scripts.

## Fresh Install
1) Follow the [official Docker documentation](https://docs.docker.com/engine/install/ubuntu/#installation-methods) on installing Docker.
```
# Add Docker's official GPG key:
sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```
2) Clone all required repos onto server.
```
git clone git@github.com:electronsandstuff/Transit-Board.git
git clone git@github.com:electronsandstuff/Personal-Server.git
```
3) Setup `.env` with all variables. Use `.env.example` as example.
4) Create new HTTPS certificates
```
bash init-letsencrypt.sh
```


## Updating Services After Changes
1) Log into the console for `dionysus` through Digital Ocean
2) Navigate to the repo's directory.
```
cd personal-server
```
3) Pull latest changes from github (or switch to the new branch and pull)
```
git pull origin master
```
4) Stop and start the apps.
```
bash stop-app.sh
bash start-app.sh
```

## Secrets
Secrets are stored in a file called `.env` in the root of the repository. It isn't tracked by git for security reasons. This file should really only exist on the server. Environment variables defined there can be accessed through in `docker-compose.yaml` with the syntax `${YOUR_SECRET_HERE}`.