# Self Hosted Blog
This is a self hosted blog solution powered by Linux on Windows, docker, nginx, letencrypt, certbot, ghost and lots more.

### Pre-setup safety
If you are planning your fork of this to git at all I really recommend making the secrets folder untracked to ensure you don't leak any important secrets:
```bash
git update-index --assume-unchanged bin/secrets/
```

## Setup
1. Clone this repository to your local machine
1. Install docker on Windows using WSL2 and ensure you can get Docker Desktop up and running
  - https://docs.docker.com/desktop/windows/install/
1. Port forward ports 80 and 443 to your the private IP address of the computer you want to host the blog on
  - Do this at your own risk
  - This is done to make your blog accessible from the public internet, which is a requirement for the SSL part of the solution.
  - Google how to do this for instructions as it depends on your router.
    - I haven't figured out how to automate this for a HyperV VM which is what I believe WSL2 runs on. I did get it working in just Windows and just Ubuntu but WSL2 is where I hit a roadblock.
1. Enable Dynamic DNS with your domain provider and set a DDNS password.
  - Copy and paste the DDNS password into `bin/secrets/ddns_secret.txt`. If you ran the command to ignore the secrets folder, this shouldn't get checked into git but double check just to be sure
1. Set the following environment variables in `bin/run.sh`. More instructions and reasoning are in comments around the variables
  - DOMAIN_NAME
  - EMAIL_ADDRESS
1. Run `./bin/run.sh` from the root directory to kick off the containers
1. Hopefully everything just works