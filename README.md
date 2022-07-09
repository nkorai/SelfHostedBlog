# README
Self hosted blog powered by docker compose, nginx, ghost.

If you are pushing this with changes to git please run the following so any secrets you add do not get tracked by git:
```bash
git update-index --assume-unchanged bin/secrets/
```