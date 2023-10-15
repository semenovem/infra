#### Environment setting

```
cd && git clone https://github.com/semenovem/infra.git _infra && \
sh _infra/bin/infra install
```  

#### See new commands in terminal

`infra help`

#### Global environment
```
__INFRA_BIN__=${HOME}/_infra/bin
```

# Profile configuration 
${HOME}/_infra/profile_infra
---------------------------------------------------------
 

##### data

| -                        | source                       |
|--------------------------|------------------------------|
| ssh config (server)      | `./configs/ssh/server.txt`      |
| ssh config (workstation) | `./configs/ssh/workstation.txt` |
| ssh config (local)       | `./configs/ssh/local.txt`       |
