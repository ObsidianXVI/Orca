# Orca

Orchestrate the deployment, installation, maintenance and runtimes of locally-hosted Flutter web apps.

## Install

1. Download this Git repo
2. Unzip and move the directory to wherever you like
3. Copy the path to the directory
4. Follow the succeeding platform-specific instructions to finish setup

### For Mac

If you don't have a `.bash_profile` located in your HOME directory execute this first;
```
touch ~/.bash_profile (if does not exist)
```
Then, finish with this step:
```
echo "export ORCA_PATH=\"copiedPathToOrca\"" >> ~/.bash_profile
source ~/.bash_profile
```