# Self Hosted Blog
This is a self hosted blog solution powered by Linux on Windows, docker, nginx, letencrypt, certbot, ghost and lots more.

### Pre-setup safety
If you are planning on pushing your fork of this to git or just in general I really recommend making git ignore changes to the the secrets folder to ensure you don't accidentally leak any important secrets:
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
1. Monitor Docker dashboard and ensure containers did not exit unexpectedly

### General troubleshooting
- Try running the clean script `./bin/clean.sh` to blow away the `build` folder, followed by re-running the `./bin/run.sh` script.
- If you're running all the scripts from inside VSCode, try exiting/restarting the terminal and if that doesn't work try exiting/restarting VSCode
- Try STOPPING and NOT DELETING your docker containers in Docker Desktop. NOTE: if you delete a container (like ghost) you will lose all data and it will be tough/impossible to get it back.
- If your issue persists please create an issue, I'll do my best to help.

### How do I use a different domain name provider?
My setup uses namecheap, but you can use another service as long as it is supported by https://github.com/qdm12/ddns-updater and grab the key e.g.  of your domain name provider.
Once you confirm it is supported by the DDNS updater project, you will need to enable DDNS with your provider and the modify the `bin/ddns/config.json` file to match your providers format, e.g. [FreeDNS](https://github.com/qdm12/ddns-updater/blob/master/docs/freedns.md) uses "token" rather than "password". In that case all you need to do is update the "password" property, leave in the `DDNS_PASSWORD` variable and add the token to `./bin/secrets/ddns_secret.txt`

### You've checked in SSL certs into bin/ssl and they are now compromised
They are dummy certs that were never used and are only there to ensure the nginx container comes up correctly, and are replaced by certbot with the letsencrypt real ones.
