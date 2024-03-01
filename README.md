# Personal Server Applications
This repo is for all applications that will rnu on my personal server at Digial Ocean (called `apollo`). It consists of a `docker-compose.yaml` defining the services I want as well as some configuration and some helper scripts.

## Updating Services After Changes
1) Log into the console for `apollo` through Digital Ocean
2) Navigate to the repo's directory.
```
cd Influxdb-Grafana-Docker-Compose
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
