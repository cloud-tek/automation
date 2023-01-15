# CloudTek.Automation.Git

## Prerequisites

> **Warning**
>
> Ensure git CLI is installed
>
> **Debian / Ubuntu**
> 
> ```bash
> sudo apt-get update
> sudo apt-get install git-all
> ```
>
> **MacOS**
> 
> ```bash
> brew install git
> ```

## Cmdlets

### Get-GitRepository

> **Warning**
>
> Mixing PAT && SSH repository address is not permitted

#### With PAT authentication

> **Warning**
>
> Personal access tokens are subject to expiration
> - Azure DevOps:     1Y max
> - GitHub Actions:   1Y max

```pwsh
<# Clone a git repository from https address, with PAT auth, to a $Checkout/$Name location and checkout target branch#>
Get-GitRepository `
  -Repository   "<required>" ` # https GIT repository address
  -Branch       "<required>" ` # branch to checkout
  -Checkout     "<required>" ` # checkout folder location
  -Name         "<required>" ` # name of the folder to clone to
  -Token        $personalAccessToken;
```

#### With SSH authentication (recommended)

> **Warning**
>
> Before SSH authentication is possible, the following SSH setup must be created for each repository. For GitHub repositories, repository deploy keys should be used.
>
> ```bash
> CONFIG=~/.ssh/config
> KEY=~/.ssh/<key-file-name>
> mkdir -p ~/.ssh >/dev/null 2>&1
>
> cat << EOF > $KEY
> <SSH_PRIVATE_KEY>
> EOF
> chmod 600 $KEY
>
> touch $CONFIG
> cat << EOF > ~/.ssh/config
> Host <github_ssh_connection_name>
>   HostName github.com
>   AddKeysToAgent yes
>   PreferredAuthentications publickey
>   IdentityFile <key-file-name>
> EOF
>
> chmod 600 $CONFIG
> ```
>
> Once proper keys are setup, the following git cmd is possible
> 
> ```bash
> git clone git@<github_ssh_connection_name>:user/repo.git your-folder-name
> ```
>
> The above setup is documented [here](https://ralphjsmit.com/git-custom-ssh-key)

**Usage**
```pwsh
<# Clone a git repository from https address, with SSH auth, to a $Checkout/$Name location and checkout target branch#>
Get-GitRepository `
  -Repository   "<required>" ` # SSH GIT repository address including <github_ssh_connection_name>. Example: git@github.com:cloud-tek/automation.git
  -Branch       "<required>" ` # branch to checkout
  -Checkout     "<required>" ` # checkout folder location
  -Name         "<required>";  # name of the folder to clone to

```

### Invoke-GitCommit

```pwsh
<# Executes the script block, performs the equivalent of : git add, git commit and (optionally) git push #>
Invoke-GitCommit `
  -Checkout "<required>" `      # checkout folder location
  -Name "<required>" `          # name of the folder to clone to
  -Branch "<required>" `        # branch to checkout & commit to
  -Message "<required>" `       # git commit message
  -Push `                       # flag to enable 'git push'
  -ScriptBlock {
    "<required>";               # script block used to modify files on disk
  } 
```
