#### Environment setting

```
# install
git clone https://github.com/semenovem/environment.git _environment

# add 
source "${HOME}/_environment/profile.sh" [-linux | -maccos] "${HOME}/_environment" 
# to  
~/.bashrc | ~/.zshrc
```  

#### See new commands in terminal

`help`

---------------------------------------------------------

```
# update ssh config

./_self/ssh-config.sh 
    [-workstation | -server]    # machine role
    [-file ~/.ssh/config`]      
    [-yes]                      # to owerwrite file without confirmation
```

```
# update ssh `authorized_keys` file

./_self/ssh-authorized-keys.sh  
    [-all | -server | -workstation]  
    [-replace]                      # delete file contents first
    [-yes]                          # use with -replace. without confirmation
    [-file ~/.ssh/authorized_keys]  
```  

```
# update self repo   

./_self/update-repo.sh  
    [-sync-file]      # file with lastest update date
```  

##### data

| -                        | source                                      |
|--------------------------|---------------------------------------------|
| list of public keys      | `./home/ssh/keys-pub.txt`                   |
| ssh config (server)      | `./home/ssh/server.txt`                     |
| ssh config (workstation) | `./home/ssh/workstation.txt`                |
| shell scripts (common)   | `./home/common`   |
| shell scripts (linux)    | `./home/linux`    |
| shell scripts (macos)    |  `./home/macos`   |

<br />
<br />

##### roadmap

`TODO search`
