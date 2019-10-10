# Multinet Deploy

## Introduction
This repository holds all the deployment code for the Multinet ecosystem.
## Encrypted Files

### Decrypting
As a security precaution, there are several files that are encrypted inside this repository. Our encryption strategy uses [git-crypt](https://github.com/AGWA/git-crypt) to secure certain files that include API keys or other secrets. Please reference the git-crypt repository for installation instructions. Once you have git-crypt installed, you'll need our key to unlock the encrypted files; the key is called `deploy.key` and can be obtained from either Jack or Roni. Please transmit this key securely, using an application like [magic-wormhole](https://github.com/warner/magic-wormhole) or scp. Place the key inside the multinet-deploy folder and then run `git-crypt unlock deploy.key` to decrypt the files in your local repository and make them runnable.

**NOTE**: Please do not rename the key and leave it the multinet-deploy directory as you'd risk pushing it up to github. 

### Encrypting
To encrypt new file on commit you need to edit the .gitattributes file. The syntax for adding a file named "super-secret.txt" to the .gitattribures file is: 
```
super-secret.txt filter=git-crypt diff=git-crypt
```

The file will be encrypted when you commit and you can verify this several ways. The first is by running `git-crypt lock` and trying to open your file. It should complain that the file is a binary. The second way of checking is on github itself. First, go to the github page and click on the file. You should see "View raw" when you get to the page showing that the file is a binary file and cannot be read by github (this strategy doesn't work for files that are already binaries). You can take this one step further by downloading the file and ensuring that the data is definitely encrypted.

## Webhooks
This repo contains code that can run a webhook server on the main Multinet instance. Should you need to modify the code, the server lives outside the docker container ecosystem since it needs to run shell scripts. Currently, the server is running in a tmux session but I'm planning to move it to a system service with a file defined in this folder. If the file exists then the service will also exist. If you need to know where the endpoints are, look inside the nginx/config/nginx.conf file. 

## Docker Containers
The other apps that run as a part of this project run inside of docker containers. The containers each have a Dockerfile in their respective folders and are orchestrated by the docker-compose script the lives at the directory root. In their current form, the containers are restartable without hiccups and without data loss. Here are some commands you might need to administer the containers:

```
# Clear out old builds and images not in use
docker system prune --all -f

# Build from scratch (necessary since docker can't see inside the github repos)
docker-compose build --no-cache

# Start and stop all containers
docker-compose up -d
docker-compose down
```

**NOTE**: The main Multinet instance occassionally runs out of hard drive space if you're building a lot of container images. You can clear out past builds with `docker system prune --all -f` or it might make sense to increase the size of the hard drive.
