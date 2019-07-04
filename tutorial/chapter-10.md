# 磁盘配额(Quota)
因为 Linux 是一个多用户多任务的工作环境, 比如磁盘空间总共500G, 共有10个用户, 那么每个用户平均下来可以使用 10G 的磁盘空间, 但是偏偏有个用户他存放了很多的电影文件, 大概200G, 那么其他用户平均使用的空间就没有10G了. 这对其他用户来说会很不方便(空间太小), 所以这个时候就需要使用到 quota 来限制每个人可以使用的磁盘空间.
```bash
## 使用的限制
仅能针对文件系统进行限制, 不能针对某个目录
内核必须支持 quota 功能


## 限制的对象
用户限制　　　　　　: 限制某一个用户的最大磁盘配额           (usrquota)
用户组限制　　　　　: 限制某一个用户组所能使用的最大磁盘配额  (grpquota)
用户组+用户限制　　 : 即限制一个用户, 也限制一个用户组所能使用的磁盘配额


## 限制的方式
限制 inode 数量 : 可以新建的文件数量
限制 block 数量 : 可以使用的磁盘容量


## 限制值 (通常 hard 值大于 soft 值)
软限制(soft)：当达到软限制时会提示用户，但仍允许用户在限定的额度内继续使用。
硬限制(hard)：当达到硬限制时会提示用户，且强制终止用户的操作。


宽限时间(grace time) 
当磁盘使用量超过 soft 的限制而没有超过 hard 限制时, 系统会给与一个宽限时间并发出警告信息.
如果用户在宽限时间内将使用的磁盘容量降到 soft 以下, 则宽限时间将会停止.
如果用户在宽限时间之后还没有进行任何操作, 那么系统会使用 soft 的值来代替 hard 值来作为 quota 的限制.
比如 bsoft=300M, bhard=400M, 你已经使用了 350M, 查过了 bsoft, 宽限时间为 7 天
7天后如果你没有进行任何的操作, 那么你的 bhard 会变为 400M.
```

## 实验要求
```bash
1. 创建五个用户 myquota[1-5] 同属于一个用户组 myquotagrp, 密码为 password
2. 每个用户的磁盘配额为 300M(hard), 超过 250M(soft) 则警告用户, 不限制文件数量
3. myquotagrp 这个用户组最多只能使用 1G 的磁盘空间, 超过 900M 则警告
```

## 实验步骤
### 创建用户以及用户组
```bash
[root@localhost ~]# vim add_quota_user.sh
#!/bin/bash
groupadd myquotagrp
for user_num in $(seq 1 5); do
    useradd -g myquotagrp "myquota${user_num}"
    echo 'password' | passwd --stdin "myquota${user_num}"
done

[root@localhost ~]# bash add_quota_user.sh 
Changing password for user myquota1.
passwd: all authentication tokens updated successfully.
Changing password for user myquota2.
passwd: all authentication tokens updated successfully.
Changing password for user myquota3.
passwd: all authentication tokens updated successfully.
Changing password for user myquota4.
passwd: all authentication tokens updated successfully.
Changing password for user myquota5.
passwd: all authentication tokens updated successfully.

[root@localhost ~]# tail -n 5 /etc/passwd /etc/group
==> /etc/passwd <==
myquota1:x:500:500::/home/myquota1:/bin/bash
myquota2:x:501:500::/home/myquota2:/bin/bash
myquota3:x:502:500::/home/myquota3:/bin/bash
myquota4:x:503:500::/home/myquota4:/bin/bash
myquota5:x:504:500::/home/myquota5:/bin/bash

==> /etc/group <==
stapusr:x:156:
stapsys:x:157:
stapdev:x:158:
tcpdump:x:72:
myquotagrp:x:500:
```

### 开启文件系统支持quota
```bash
## 因为开启 quota 必须要内核和文件系统支持才可以.
[root@localhost ~]# df -h /home
Filesystem                 Size  Used Avail Use% Mounted on
/dev/mapper/server-myhome  4.7G   10M  4.5G   1% /home
[root@localhost ~]# mount | grep /home
/dev/mapper/server-myhome on /home type ext4 (rw)


## 修改 /etc/fstab 文件中 /home 目录 如下所示  
[root@localhost ~]# vim /etc/fstab 
/dev/mapper/server-myhome  /home  ext4  defaults                    1  2 <== 之前数据
/dev/mapper/server-myhome  /home  ext4  defaults,usrquota,grpquota  1  2 <== 修改为此行数据

## 然后可以选择重启或者使用如下命令
[root@localhost ~]# mount -o remount /home
[root@localhost ~]# mount | grep /home
/dev/mapper/server-myhome on /home type ext4 (rw,usrquota,grpquota)  <== 重新挂载的选项可以看出来
```

### quotacheck命令 : 扫描文件系统并生成配额文件
quota 是分析整个文件系统中每个 用户/用户组 拥有的文件总数和总容量, 然后把数据记录在该文件系统的最顶层目录, 然后在该配置文件中在使用每个 账号/用户组 的限制值去规定磁盘使用量的. 所以这个 quota 配置文件非常重要.
> quotacheck [ options ] [ /mount_point ]

| 选项 | 作用 |
| :---: | ----- |
| -a | 扫描所有在 /etc/mtab 文件内, 包含 quota 支持的文件系统, mount_point 可以不写, 表示扫描所有文件系统 |
| -u | (针对用户) 扫描文件与目录的使用情况, 新建 aquota.user |
| -g | (针对用户组) 扫描文件于目录的使用情况, 新建 aquota.group |
| -v | 显示扫描过程的信息 |
| -f | 强制扫描文件系统, 并写入新的 quota 配置文件(不要轻易使用) |
| -M | 强制以读写的方式扫描文件系统(特殊情况使用) |

```bash
## 开始检查并生成配置文件
[root@localhost ~]# quotacheck -avug
quotacheck: Scanning /dev/mapper/server-myhome [/home] done
quotacheck: Cannot stat old user quota file /home/aquota.user: No such file or directory. Usage will not be substracted.
quotacheck: Cannot stat old group quota file /home/aquota.group: No such file or directory. Usage will not be substracted.
quotacheck: Cannot stat old user quota file /home/aquota.user: No such file or directory. Usage will not be substracted.
quotacheck: Cannot stat old group quota file /home/aquota.group: No such file or directory. Usage will not be substracted.
quotacheck: Checked 27 directories and 15 files
quotacheck: Old file not found.
quotacheck: Old file not found.

## 可以发现配置文件已经生成了
[root@localhost ~]# ll /home/aquo*
-rw-------. 1 root root 7168 Apr 26 10:01 /home/aquota.group
-rw-------. 1 root root 7168 Apr 26 10:01 /home/aquota.user
```

###  quotaon命令 :  启动 quota 服务
**这个命令只要在第一次启动 quota 的时候执行一次, 以后即使重启也不需要再次执行, 因为系统会帮你自动执行.**
> quotaon [ -avug ]
> 
> quotaon {-vug}  mount_point

| 选项 | 作用 |
| :----: | ----- |
| -u | 针对用户启动 quota ( aquota.user ) |
| -g | 针对用户组启动 quota ( aquota.group ) |
| -v | 显示启动进程的相关信息 |
| -a | 根据 /etc/mtab 内的文件系统启动有关的 quota |

```bash
## 比如我们启动所有的文件系统的 quota
## 这里说的所有表示文件系统既要支持 quota, 并且还有 usrquota 或 grpquota
[root@localhost ~]# quotaon -avug
/dev/mapper/server-myhome [/home]: group quotas turned on
/dev/mapper/server-myhome [/home]: user quotas turned on

## 如果我们仅仅只是启动 /home 目录下的 usrquota, 则可以使用下列命令, 针对需要 灵活运用
[root@localhost ~]# quotaon -uv /home


## 系统的 /etc/rc.d/rc.sysinit 会自动执行这个命令
[root@localhost ~]# cat /etc/rc.d/rc.sysinit  | grep 'quota'
if [ -f /forcequotacheck ] || strstr "$cmdline" forcequotacheck ; then
# Update quotas if necessary
if [ X"$_RUN_QUOTACHECK" = X1 -a -x /sbin/quotacheck ]; then
	action $"Checking local filesystem quotas: " /sbin/quotacheck -anug
if [ -x /sbin/quotaon ]; then
    action $"Enabling local filesystem quotas: " /sbin/quotaon -aug     <== 系统自动帮助你启动它
rm -f /fastboot /fsckoptions /forcefsck /.autofsck /forcequotacheck /halt \
```

### edquota命令 :  编辑 用户/用户组 的磁盘配额
> edquota [ -u User_Name ] [ -g Group_Name ]
> 
> edquota -p User_Name1 -u User_Name2

| 选项 | 作用 |
| :----: | ----- |
| -u User_Name | 进入 quota 的编辑界面去设置 User_Name 的配额值 |
| -g Group_Name | 进入 quota 的编辑界面去设置 Group_Name 的配额值 | 
| -p User_Name1 -u User_Name2 | 参考 User_Name 1 来设置 User_Name2 |

```bash
## 尝试编辑一下 myquota1 用户, 修改为如下所示, 然后保存退出, (把 1024 当做 1000 来比较好计算)
[root@localhost ~]# edquota -u myquota1
Disk quotas for user myquota1 (uid 500):  <== 对 myquota1 用户使用磁盘配额, uid 为 500
  文件系统或分区                磁盘容量(KB)  软限制(KB)  硬限制(KB)   文件数量(个数) 软限制  硬限制 
  Filesystem                   blocks       soft       hard        inodes        soft     hard
  /dev/mapper/server-myhome        32     250000     300000            8           0        0

## 然后设置剩下的其他四个用户
[root@localhost ~]# edquota -p myquota1 -u myquota2
[root@localhost ~]# edquota -p myquota1 -u myquota3
[root@localhost ~]# edquota -p myquota1 -u myquota4
[root@localhost ~]# edquota -p myquota1 -u myquota5
[root@localhost ~]# edquota -u myquota5
Disk quotas for user myquota5 (uid 504):
  Filesystem                   blocks       soft       hard     inodes     soft     hard
  /dev/mapper/server-myhome         32     250000     300000          8        0        0

## 然后来设置用户组的磁盘配额
[root@localhost ~]# edquota -g myquotagrp
Disk quotas for group myquotagrp (gid 500):
  Filesystem                   blocks       soft       hard     inodes     soft     hard
  /dev/mapper/server-myhome       160     900000    1000000         40        0        0
```

### quota 磁盘配额的查看
我们针对了某个文件系统来做磁盘配额, 那么我又应该如何来查看针对特定用户以及查看整个文件系统的磁盘配额呢, 所有就存在了以下两种形式 :
#### quota命令 : 特定 用户/用户组 的 quota 报表
> quota [ options ]

| 选项 | 作用 |
| :---: | ---- |
| -u User_Name1 ... | 查看 User_Name 等用户的磁盘配额 |
| -g Group_Name | 查看 Group_Name 组的磁盘配额 |
| -v | 显示每个 用户/用户组 在文件系统中的 quota |
| -s | 使用 1024 为倍数, 来显示单位, 如 M  G 等 |

```bash
## 查看用户的磁盘配额, 使用 1024 作单位, 我们之前是 1000 所以肯定有误差
[root@localhost ~]# quota -uvs myquota1 myquota2
Disk quotas for user myquota1 (uid 500): 
     Filesystem            blocks   quota   limit   grace   files   quota   limit   grace
/dev/mapper/server-myhome      32    245M    293M               8       0       0        
Disk quotas for user myquota2 (uid 501): 
     Filesystem            blocks   quota   limit   grace   files   quota   limit   grace
/dev/mapper/server-myhome      32    245M    293M               8       0       0        

## 查看用户组的磁盘配额
[root@localhost ~]# quota -gvs myquotagrp
Disk quotas for group myquotagrp (gid 500): 
     Filesystem            blocks   quota   limit   grace   files   quota   limit   grace
/dev/mapper/server-myhome     160    879M    977M              40       0       0  
```

#### repquota命令 : 显示针对文件系统的限额
> requota -a [ options ]

| 选项 | 作用 |
| :---: | ---- |
| -a | 查新 /etc/mtab 中具有 quota 标志的文件系统, 并显示 quota 的结果 |
| -v | 显示系统相关的详细信息 |
| -u | 显示出用户的 quota (默认值) |
| -g | 显示出用户组的 quota |
| -s | 使用 M G 等单位 |

```bash
## 用户
[root@localhost ~]# repquota  -auvs
*** Report for user quotas on device /dev/mapper/server-myhome
Block grace time: 7days; Inode grace time: 7days
                        Block limits                File limits
User            used    soft    hard  grace    used  soft  hard  grace
----------------------------------------------------------------------
root      --      20       0       0              2     0     0       
myquota1  --      32    245M    293M              8     0     0       
myquota2  --      32    245M    293M              8     0     0       
myquota3  --      32    245M    293M              8     0     0       
myquota4  --      32    245M    293M              8     0     0       
myquota5  --      32    245M    293M              8     0     0       

Statistics:           <== 这些就是所谓的系统相关信息, -v 显示的结果
Total blocks: 7
Data blocks: 1
Entries: 6
Used average: 6.000000

## 用户组
[root@localhost ~]# repquota  -agvs
*** Report for group quotas on device /dev/mapper/server-myhome
Block grace time: 7days; Inode grace time: 7days
                        Block limits                File limits
Group           used    soft    hard  grace    used  soft  hard  grace
----------------------------------------------------------------------
root      --      20       0       0              2     0     0       
myquotagrp --     160    879M    977M             40     0     0       

Statistics:
Total blocks: 7
Data blocks: 1
Entries: 2
Used average: 2.000000
```

### 实践出真知
我们启动了 quota, 也设置好了用户以及用户组的磁盘配额并查看了配额, 那么我们做的到底有没有效果呢, 我们现在来实际测试一下. (**请注意查看是使用 哪个用户 登录了系统并且使用了 哪个用户 来操作命令**)

```bash
## myquota1 用户登录并创建一个 270M 的文件
[myquota1@localhost ~]$ dd if=/dev/zero of=big_file bs=1M count=270
dm-0: warning, user block quota exceeded.    <== 给出了警告信息, 但是可以正常创建
270+0 records in
270+0 records out
283115520 bytes (283 MB) copied, 1.2924 s, 219 MB/s
[myquota1@localhost ~]$ ll -h 
total 270M
-rw-r--r--. 1 myquota1 myquotagrp 270M Apr 27 05:18 big_file


## root 用户操作
[root@localhost ~]# quota -uvs myquota1
Disk quotas for user myquota1 (uid 500): 
                            使用的block的大小         宽限时间已经开始倒计时, 倒计时完成会变为 none
     Filesystem             blocks   quota   limit   grace   files   quota   limit   grace
/dev/mapper/server-myhome    271M*    245M    293M   6days       9       0       0  


## myquota1 在创建一个 40M 的文件
[myquota1@localhost ~]$ dd if=/dev/zero of=small_file bs=1M count=40
dm-0: write failed, user block limit reached.
dd: writing `small_file': Disk quota exceeded
23+0 records in   <== 只能记录 23 条 也就是 23M
22+0 records out
24051712 bytes (24 MB) copied, 0.0603297 s, 399 MB/s
[myquota1@localhost ~]$ ll -h
total 293M
-rw-r--r--. 1 myquota1 myquotagrp 270M Apr 27 05:26 big_file
-rw-r--r--. 1 myquota1 myquotagrp  23M Apr 27 05:27 small_file  <== 发现只有 23M 符合我们的 293M hard
[myquota1@localhost ~]$ du -sh
293M	.


## 我们来测试 用户和用户组限制同时生效的情况
[myquota1@localhost ~]$ su - myquota2
Password: 
[myquota2@localhost ~]$ ll
total 0
[myquota2@localhost ~]$ dd if=/dev/zero of=big_file bs=1M count=300
dm-0: warning, user block quota exceeded.
dm-0: write failed, user block limit reached.
dd: writing `big_file': Disk quota exceeded
293+0 records in
292+0 records out
307167232 bytes (307 MB) copied, 1.77363 s, 173 MB/s
-rw-r--r--. 1 myquota2 myquotagrp 293M Apr 27 05:31 big_file
[myquota2@localhost ~]$ du -sh
293M	.
[myquota2@localhost ~]$ exit
logout

[myquota1@localhost ~]$ su - myquota3
Password: 
[myquota3@localhost ~]$ dd if=/dev/zero of=big_file bs=1M count=300
dm-0: warning, user block quota exceeded.
dm-0: warning, group block quota exceeded.     <== 也到了组的 soft
dm-0: write failed, user block limit reached.
dd: writing `big_file': Disk quota exceeded
293+0 records in
292+0 records out
307167232 bytes (307 MB) copied, 0.641958 s, 478 MB/s
[myquota3@localhost ~]$ du -sh
293M	.
[myquota3@localhost ~]$ exit
logout

## 查看报表
[root@localhost ~]# repquota -augvs
*** Report for user quotas on device /dev/mapper/server-myhome
Block grace time: 7days; Inode grace time: 7days
                        Block limits                File limits
User            used    soft    hard  grace    used  soft  hard  grace
----------------------------------------------------------------------
root      --      20       0       0              2     0     0       
myquota1  +-    293M    245M    293M  6days      10     0     0       
myquota2  +-    293M    245M    293M  6days      10     0     0       
myquota3  +-    293M    245M    293M  6days      10     0     0       
myquota4  --      32    245M    293M              8     0     0       
myquota5  --      32    245M    293M              8     0     0       

Statistics:
Total blocks: 7
Data blocks: 1
Entries: 6
Used average: 6.000000

*** Report for group quotas on device /dev/mapper/server-myhome
Block grace time: 7days; Inode grace time: 7days
                        Block limits                File limits
Group           used    soft    hard  grace    used  soft  hard  grace
----------------------------------------------------------------------
root      --      20       0       0              2     0     0       
myquotagrp +-    879M    879M    977M  6days      46     0     0       
                                       组也出现了 grace time
Statistics:
Total blocks: 7
Data blocks: 1
Entries: 2
Used average: 2.000000

## 继续测试
[myquota1@localhost ~]$ su - myquota4
Password: 
[myquota4@localhost ~]$ dd if=/dev/zero of=big_file bs=1M count=300
dm-0: write failed, group block limit reached.
dd: writing `big_file': Disk quota exceeded
98+0 records in
97+0 records out
102334464 bytes (102 MB) copied, 0.104191 s, 982 MB/s
[myquota4@localhost ~]$ du -sh
98M	.    <== 因为组只有 98M 的大小可以使用了, 虽然用户的磁盘额外没有使用完.


[root@localhost ~]# repquota -augvs
*** Report for user quotas on device /dev/mapper/server-myhome
Block grace time: 7days; Inode grace time: 7days
                        Block limits                File limits
User            used    soft    hard  grace    used  soft  hard  grace
----------------------------------------------------------------------
root      --      20       0       0              2     0     0       
myquota1  +-    293M    245M    293M  6days      10     0     0       
myquota2  +-    293M    245M    293M  6days      10     0     0       
myquota3  +-    293M    245M    293M  6days      10     0     0       
myquota4  --   99968    245M    293M              9     0     0   <== 没有达到 soft 所以没有 grace time     
myquota5  --      32    245M    293M              8     0     0       

Statistics:
Total blocks: 7
Data blocks: 1
Entries: 6
Used average: 6.000000

*** Report for group quotas on device /dev/mapper/server-myhome
Block grace time: 7days; Inode grace time: 7days
                        Block limits                File limits
Group           used    soft    hard  grace    used  soft  hard  grace
----------------------------------------------------------------------
root      --      20       0       0              2     0     0       
myquotagrp +-    977M    879M    977M  6days      47     0     0   <== 组 hard 已满, 无法使用

Statistics:
Total blocks: 7
Data blocks: 1
Entries: 2
Used average: 2.000000
```
我们以上的实例证明了, 我们既可以对 ` 用户组 ` 也可以对` 用户 `, 还可以使用 ` 用户组+用户 ` 的方式来设置磁盘配额, 我们可以根据自己的需要来灵活的调整.

### warnquota命令 : 对超过限额者发送警告信
warnquota 可以根据 /etc/warnquota.conf 的设置, **找出目前系统上 quota 超过 soft(存在 grace time) 的用户并发送 mail信息**. 但是这个命令不会手动执行, 所以只能我们自己去主动的执行这个命令.
```bash
[root@localhost ~]# warnquota


[myquota1@localhost ~]$ mail
Heirloom Mail version 12.4 7/29/08.  Type ? for help.
"/var/spool/mail/myquota1": 1 message 1 new
>N  1 root@example.com  Sat Apr 27 05:46  26/970 "NOTE: You are exceeding your allocated disk space limits"
& 1
Message  1:
From root@localhost.localdomain  Sat Apr 27 05:46:53 2019
Return-Path: <root@localhost.localdomain>
X-Original-To: myquota1
Delivered-To: myquota1@localhost.localdomain
From: root@example.com
Reply-To: root@example.com
Subject: NOTE: You are exceeding your allocated disk space limits
To: myquota1@localhost.localdomain
Cc: root@example.com
Date: Sat, 27 Apr 2019 05:46:53 +0800 (CST)
Status: R

Your disk usage has exceeded the agreed limits on this server
Please delete any unnecessary files on following filesystems:

/dev/mapper/server-myhome

                        Block limits               File limits
Filesystem           used    soft    hard  grace    used  soft  hard  grace
/dev/mapper/server-myhome
               +-  300000  250000  300000  6days      10     0     0       

root@example.com

& quit
Held 1 message in /var/spool/mail/myquota1


## 具体发信的内容, 也可以修改 /etc/warnquota.conf 来自己定制
## 如果想每天系统自动检测超过 soft 的并发送信息, 我们可以把他写为一个脚本并放到定时任务中去执行
[root@localhost ~]# vim /etc/cron.daily/warnquota
/usr/sbin/warnquota
[root@localhost ~]# chmod 755 /etc/cron.daily/warnquota 
```

### setquota命令 : 直接在命令中设置 quota 配额
> setquota [-u | -g] User_Name/Group_Name bsoft bhard isoft ihard File_System

我们基本上给用户设置磁盘配额都会使用脚本来设置方便快捷, 这个时候我们就有两种解决方式 :
```bash
1. 新建一个设置好 quota 的账号, 然后使用 edquota -p Old_User -u New_User 来设置.
2. 使用 setquota 命令来设置.

[root@localhost ~]# quota -uv myquota5
Disk quotas for user myquota5 (uid 504): 
     Filesystem            blocks   quota   limit   grace   files   quota   limit   grace
/dev/mapper/server-myhome      32  250000  300000               8       0       0 
[root@localhost ~]# setquota -u myquota5 100000 200000 0 0 /home
[root@localhost ~]# quota -uv myquota5
Disk quotas for user myquota5 (uid 504): 
     Filesystem            blocks   quota   limit   grace   files   quota   limit   grace
/dev/mapper/server-myhome      32  100000  200000               8       0       0 
``` 

### quotaoff命令 : 关闭 quota 服务
> quotaoff -a
>
> quotaoff [ -ug ] mount_point

| 选项 | 作用 |
| :---: | ---- |
| -a | 关闭所有文件系统的 quota ( /etc/mtab ) |
| -u | 只关闭 mount_point 的 user quota |
| -g | 只关闭 mount_point 的 group quota |

```bash
## 临时关闭 quotaoff
[root@localhost ~]# quotaoff /home
[root@localhost ~]# su - myquota5
[myquota5@localhost ~]$ dd if=/dev/zero of=bigfile bs=1M count=300
300+0 records in
300+0 records out
314572800 bytes (315 MB) copied, 0.989361 s, 318 MB/s
[myquota5@localhost ~]$ du -sh
301M	.
[myquota5@localhost ~]$ exit
logout

## 重启后发现关闭已经失效, 所以如果需要彻底停用 quota, 需要修改 /etc/fstab 并且重新挂载即可.
```

# RAID磁盘冗余阵列
RAID（Redundant Array of Independent Disks，独立冗余磁盘阵列）技术通过把多个硬盘设备组合成一个容量更大、安全性更好的磁盘阵列，并把数据切割成多个区段后分别存放在各个不同的物理硬盘设备上，然后利用分散读写技术来提升磁盘阵列整体的性能，同时把多个重要数据的副本同步到不同的物理硬盘设备上，从而起到了非常好的数据冗余备份效果。RAID技术确实具有非常好的数据冗余备份功能，但是它也相应地提高了成本支出。出于成本和技术方面的考虑，需要针对不同的需求在数据可靠性及读写性能上作出权衡，制定出满足各自需求的不同方案。

## RAID级别
### RAID 0 (等量模式 striping)
RAID 0技术能够有效地提升硬盘数据的吞吐速度，但是不具备数据备份和错误修复能力. 先把要存入的文件依据块的大小切割好, 然后在依序放到各个磁盘中, 数据会被等量的放置在各个磁盘中, 因此每个磁盘所负责的数据量降低了, 但是只要有一块磁盘损坏, 那么RAID上面的所有数据就会丢失而无法读取.

![linux_raid_0](https://github.com/gkdaxue/linux/raw/master/image/chapter_A10_0001.jpg)

```bash
1. 读写性能提升(多盘读入/写入)
2. 可用空间 : 磁盘数 * min(disk space), 比如 10G 20G 30G, 那么可用为 10 + 10 + 10 = 30G
3. 无容错能力(任意一块硬盘损坏, 将导致整个系统的数据都受到破坏)
4. 最小磁盘数 : 2 块
```

### RAID 1 (镜像模式 mirroring)
它是把两块以上的硬盘设备进行绑定，在写入数据时，是将数据同时写入到多块硬盘设备上（可以将其视为数据的镜像或备份）。当其中某一块硬盘发生故障后，一般会立即自动以热交换的方式来恢复数据的正常使用。

![linux_raid_1](https://github.com/gkdaxue/linux/raw/master/image/chapter_A10_0002.jpg)

```bash
1. 读性能提升, 写性能略微下降
2. 可用空间 : 1 * min(disk space)
3. 有容错能力
4. 最小磁盘数 : 2 块
```

### RAID 5 
RAID5技术是把硬盘设备的数据奇偶校验信息保存到其他硬盘设备中。RAID 5磁盘阵列组中数据的奇偶校验信息并不是单独保存到某一块硬盘设备中，而是存储到除自身以外的其他每一块硬盘设备上，这样的好处是其中任何一设备损坏后不至于出现致命缺陷, 当硬盘设备出现问题后通过奇偶校验信息来尝试重建损坏的数据。RAID这样的技术特性“妥协”地兼顾了硬盘设备的读写速度、数据安全性与存储成本问题. 
RAID 5 **默认**仅能支持一块硬盘损坏的情况, 如果损坏的适量大于等于2 快, 那么整个 RAID 5 的数据就损坏了.

![linux_raid_5](https://github.com/gkdaxue/linux/raw/master/image/chapter_A10_0003.jpg)

```bash
1. 读写性能提升
2. 可用空间 : (磁盘总数-1) * min(disk space)
3. 有容错能力 : 1 块磁盘
4. 最小磁盘数 : 3 块
```

### RAID 10 或 RAID 01
这是一个组合的 RAID 1 + 0 或者 RAID 0 + 1的形式, RAID 0 不具备容错的能力 但是性能好, 而 RAID 1 的性能不佳, 具备容错能力. 所以就诞生了这两种组合.
> RAID 0 + 1 : 先组合成 RAID 0 在组合成 RAID 1
> 
> RAID 1 + 0 : 先组合成 RAID 1 在组合成 RAID 0

![linux_raid_10](https://github.com/gkdaxue/linux/raw/master/image/chapter_A10_0004.jpg)

```bash
1. 读写性能提升
2. 可用空间 : 磁盘数 * min(S1, S2, ...) / 2
3. 有容错能力 : 每组镜像最多只能坏一块
4. 最少磁盘数 : 4
```

### Space Disk : 热备盘
当磁盘阵列的磁盘损坏后, 磁盘阵列就会自动重建(rebuild)坏掉磁盘的数据到热备盘上, 这样磁盘阵列上面的数据就复原了. 然后我们就可以把坏的磁盘替换为可以使用的磁盘并作为热备盘 下次使用. **平时是不会使用热备盘.** 

## 分类
主要分为 Software RAID 和 Hardware RAID,  Hardware RAID 主要是一个是靠磁盘阵列卡来完成, 磁盘阵列卡自带一块芯片, 所以性能较好并且支持热插拔, 但是价格比较昂贵. 所以一般都是利用软件来实现仿真磁盘阵列的功能, 称为 Software RAID. 也就需要用到 mdadm 这个软件了.

## mdadm命令 : 软件磁盘阵列的设置
mdadm 可以以 **分区或者磁盘 作为单位**, 所以我们只要保证有足够的 分区/磁盘 就可以了, 因为我们现在是在实验阶段, 所以我们会使用分区来制作 RAID.
> mdadm [mode] <raiddevice> [options] <component-devices>

| 选项 | 作用 |
| :------: | ----- |
| -C | 创建 RAID |
| -n | 指定设备数量 |
| -a {yes\|no}| 是否自动为其创建设备文件 |
| -x | 指定备用盘数量 |
| -l | 指定 RAID 级别 |
| -v | 显示创建过程 |
| -D | 查看详细信息 |
| -S | 停止 RAID 磁盘阵列 |
| --add 设备 | 添加设备到 RAID 中 |
| --remove 设备 | 从 RAID 中移除设备 |
| {-f \| -\-fail} 设备 | 将 RAID 中 此设备设置为出错状态 |
| {-s \| \-\-scan} | 扫描配置文件信息 |

## 实践出真知
### 环境准备
```bash
## 1. 创建 5 个分区, 每个分区大小为 3 G
## 2. 使用 RAID 5 级别加上一块热备盘
## 3. 格式化为 ext3 格式并挂载到 /mnt/raid


## 自己先增加一块 20G 硬盘, 比如我的识别为 /dev/sdb 
[root@localhost ~]# fdisk -l /dev/sdb

Disk /dev/sdb: 21.5 GB, 21474836480 bytes
255 heads, 63 sectors/track, 2610 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x00000000

## 然后分为 3个主分区 1个扩展分区 2个逻辑分区 , 每个分区的大小为 3 G
[root@localhost ~]# fdisk /dev/sdb
........
Command (m for help): n
Command action
   e   extended
   p   primary partition (1-4)
p
Partition number (1-4): 1
First cylinder (1-2610, default 1): 
Using default value 1
Last cylinder, +cylinders or +size{K,M,G} (1-2610, default 2610): +3G

Command (m for help): n
Command action
   e   extended
   p   primary partition (1-4)
p
Partition number (1-4): 2
First cylinder (394-2610, default 394): 
Using default value 394
Last cylinder, +cylinders or +size{K,M,G} (394-2610, default 2610): +3G

Command (m for help): n
Command action
   e   extended
   p   primary partition (1-4)
p
Partition number (1-4): 3
First cylinder (787-2610, default 787): 
Using default value 787
Last cylinder, +cylinders or +size{K,M,G} (787-2610, default 2610): +3G

Command (m for help): n
Command action
   e   extended
   p   primary partition (1-4)
e                     <== 想一下为什么要创建扩展分区
Selected partition 4
First cylinder (1180-2610, default 1180): 
Using default value 1180
Last cylinder, +cylinders or +size{K,M,G} (1180-2610, default 2610):   <== 分区全部空间, 敲回车即可
Using default value 2610

Command (m for help): n
First cylinder (1180-2610, default 1180): 
Using default value 1180
Last cylinder, +cylinders or +size{K,M,G} (1180-2610, default 2610): +3G

Command (m for help): n
First cylinder (1573-2610, default 1573): 
Using default value 1573
Last cylinder, +cylinders or +size{K,M,G} (1573-2610, default 2610): +3G

Command (m for help): p

Disk /dev/sdb: 21.5 GB, 21474836480 bytes
255 heads, 63 sectors/track, 2610 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x702f158d

   Device Boot      Start         End      Blocks   Id  System
/dev/sdb1               1         393     3156741   83  Linux
/dev/sdb2             394         786     3156772+  83  Linux
/dev/sdb3             787        1179     3156772+  83  Linux
/dev/sdb4            1180        2610    11494507+   5  Extended
/dev/sdb5            1180        1572     3156741   83  Linux
/dev/sdb6            1573        1965     3156741   83  Linux

Command (m for help): w
The partition table has been altered!

Calling ioctl() to re-read partition table.
Syncing disks.

## 查看一下磁盘分区是否已经被内核识别, 如果没有请使用 partprobe 命令
[root@localhost ~]# ll /dev/sdb*
brw-rw----. 1 root disk 8, 16 Apr 26 04:55 /dev/sdb
brw-rw----. 1 root disk 8, 17 Apr 26 04:55 /dev/sdb1
brw-rw----. 1 root disk 8, 18 Apr 26 04:55 /dev/sdb2
brw-rw----. 1 root disk 8, 19 Apr 26 04:55 /dev/sdb3
brw-rw----. 1 root disk 8, 20 Apr 26 04:55 /dev/sdb4
brw-rw----. 1 root disk 8, 21 Apr 26 04:55 /dev/sdb5
brw-rw----. 1 root disk 8, 22 Apr 26 04:55 /dev/sdb6
```

### 创建 RAID 5
```bash
## 利用 sdb1 sdb2 sdb3 sdb5 组成 RAID 5 sdb6 用来做热备盘(spare disk)
## 设备数一定要等于 n 的个数(4) + x 的个数(1) = /dev/sdb{1,2,3,5,6} (5)
[root@localhost ~]# mdadm -Cv /dev/md0 -l 5 -n 4 -x 1 /dev/sdb{1,2,3,5,6}
mdadm: layout defaults to left-symmetric
mdadm: layout defaults to left-symmetric
mdadm: chunk size defaults to 512K
mdadm: size set to 3154432K
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md0 started.

## 查看详细信息
[root@localhost ~]# mdadm -D /dev/md0
/dev/md0:
        Version : 1.2
  Creation Time : Fri Apr 26 03:57:32 2019
     Raid Level : raid5
     Array Size : 9463296 (9.02 GiB 9.69 GB)
  Used Dev Size : 3154432 (3.01 GiB 3.23 GB)
   Raid Devices : 4
  Total Devices : 5
    Persistence : Superblock is persistent

    Update Time : Fri Apr 26 03:58:24 2019
          State : clean 
 Active Devices : 4
Working Devices : 5
 Failed Devices : 0
  Spare Devices : 1

         Layout : left-symmetric
     Chunk Size : 512K

 Rebuild Status : 18% complete    <== 因为构建 RAID 需要时间, 所以会显示此行信息, 完成后此行自动消失

           Name : localhost.localdomain:0  (local to host localhost.localdomain)
           UUID : b3480a3a:9c89f632:c6f0236e:3fb66b7f
         Events : 18
                             磁盘顺序
    Number   Major   Minor   RaidDevice State
       0       8       17        0      active sync   /dev/sdb1
       1       8       18        1      active sync   /dev/sdb2
       2       8       19        2      active sync   /dev/sdb3
       5       8       21        3      spare rebuilding   /dev/sdb5  <== 表示正在 rebuild

       4       8       22        -      spare         /dev/sdb6  <== 备用盘          


## 也可以听过 /proc/mdstat 文件来查看
[root@localhost ~]# cat /proc/mdstat 
Personalities : [raid6] [raid5] [raid4] 
md0 : active raid5 sdb5[5] sdb6[4](S) sdb3[2] sdb2[1] sdb1[0]
      9463296 blocks super 1.2 level 5, 512k chunk, algorithm 2 [4/4] [UUUU]
      
unused devices: <none>

从上面我们可以得出如下信息 :
md0 为 RAID 5 , 并且使用了 sdb1 sdb2 sdb3 sdb5 sdb6, 每个后边有一个数字表示在 RAID 中的顺序 S 表示 spare
共拥有 9463296 个块, chunk 为 512k, 使用了 algorithm 2 算法
[4/4] [UUUU] : 表示需要 4个 设备且这 4个 设备正常运行, U 表示正常运行, _ 表示不正常
```

### 挂载并使用
```bash
[root@localhost ~]# mkfs.ext3 /dev/md0
mke2fs 1.41.12 (17-May-2010)
Filesystem label=
OS type: Linux
Block size=4096 (log=2)
Fragment size=4096 (log=2)
Stride=128 blocks, Stripe width=384 blocks
592176 inodes, 2365824 blocks
118291 blocks (5.00%) reserved for the super user
First data block=0
Maximum filesystem blocks=2424307712
73 block groups
32768 blocks per group, 32768 fragments per group
8112 inodes per group
Superblock backups stored on blocks: 
	32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632

Writing inode tables: done                            
Creating journal (32768 blocks): done
Writing superblocks and filesystem accounting information: done

This filesystem will be automatically checked every 28 mounts or
180 days, whichever comes first.  Use tune2fs -c or -i to override.

[root@localhost ~]# mkdir -p /mnt/raid
[root@localhost ~]# mount /dev/md0 /mnt/raid/
[root@localhost ~]# df -h /dev/md0
Filesystem      Size  Used Avail Use% Mounted on
/dev/md0        8.9G  149M  8.3G   2% /mnt/raid
```

### 热备盘的使用
```bash
## 先把 RAID 中的一个设备设置为出错状态 比如 /dev/sdb1
[root@localhost ~]# mdadm /dev/md0 --fail /dev/sdb1
mdadm: set /dev/sdb1 faulty in /dev/md0

## 然后迅速查看 /dev/md0 的状态
[root@localhost ~]# mdadm -D /dev/md0
/dev/md0:
        Version : 1.2
  Creation Time : Fri Apr 26 03:57:32 2019
     Raid Level : raid5
     Array Size : 9463296 (9.02 GiB 9.69 GB)
  Used Dev Size : 3154432 (3.01 GiB 3.23 GB)
   Raid Devices : 4
  Total Devices : 5
    Persistence : Superblock is persistent

    Update Time : Fri Apr 26 06:13:12 2019
          State : clean, degraded, recovering 
 Active Devices : 3
Working Devices : 4
 Failed Devices : 1       <== 出错的一个磁盘
  Spare Devices : 1

         Layout : left-symmetric
     Chunk Size : 512K

 Rebuild Status : 16% complete   <== Rebuild 的进度

           Name : localhost.localdomain:0  (local to host localhost.localdomain)
           UUID : b3480a3a:9c89f632:c6f0236e:3fb66b7f
         Events : 22

    Number   Major   Minor   RaidDevice State
       4       8       22        0      spare rebuilding   /dev/sdb6
       1       8       18        1      active sync   /dev/sdb2
       2       8       19        2      active sync   /dev/sdb3
       5       8       21        3      active sync   /dev/sdb5

       0       8       17        -      faulty   /dev/sdb1   <== 状态为 faulty


## 完成之后的状态 
[root@localhost ~]# mdadm -D /dev/md0
/dev/md0:
        Version : 1.2
  Creation Time : Fri Apr 26 03:57:32 2019
     Raid Level : raid5
     Array Size : 9463296 (9.02 GiB 9.69 GB)
  Used Dev Size : 3154432 (3.01 GiB 3.23 GB)
   Raid Devices : 4
  Total Devices : 5
    Persistence : Superblock is persistent

    Update Time : Fri Apr 26 06:13:57 2019
          State : clean 
 Active Devices : 4
Working Devices : 4
 Failed Devices : 1    <== 出错的盘 1个
  Spare Devices : 0    <== 热备已经没有了

         Layout : left-symmetric
     Chunk Size : 512K

           Name : localhost.localdomain:0  (local to host localhost.localdomain)
           UUID : b3480a3a:9c89f632:c6f0236e:3fb66b7f
         Events : 37

    Number   Major   Minor   RaidDevice State
       4       8       22        0      active sync   /dev/sdb6
       1       8       18        1      active sync   /dev/sdb2
       2       8       19        2      active sync   /dev/sdb3
       5       8       21        3      active sync   /dev/sdb5

       0       8       17        -      faulty   /dev/sdb1
```

### 更换新的磁盘
```bash
## 我们把出错的磁盘移除掉
[root@localhost ~]# mdadm /dev/md0 --remove /dev/sdb1
mdadm: hot removed /dev/sdb1 from /dev/md0
[root@localhost ~]# mdadm -D /dev/md0
/dev/md0:
        Version : 1.2
  Creation Time : Fri Apr 26 03:57:32 2019
     Raid Level : raid5
     Array Size : 9463296 (9.02 GiB 9.69 GB)
  Used Dev Size : 3154432 (3.01 GiB 3.23 GB)
   Raid Devices : 4
  Total Devices : 4
    Persistence : Superblock is persistent

    Update Time : Fri Apr 26 06:17:44 2019
          State : clean 
 Active Devices : 4
Working Devices : 4
 Failed Devices : 0
  Spare Devices : 0

         Layout : left-symmetric
     Chunk Size : 512K

           Name : localhost.localdomain:0  (local to host localhost.localdomain)
           UUID : b3480a3a:9c89f632:c6f0236e:3fb66b7f
         Events : 38

    Number   Major   Minor   RaidDevice State
       4       8       22        0      active sync   /dev/sdb6
       1       8       18        1      active sync   /dev/sdb2
       2       8       19        2      active sync   /dev/sdb3
       5       8       21        3      active sync   /dev/sdb5

## 然后在添加新的磁盘
[root@localhost ~]# mdadm /dev/md0 --add /dev/sdb1
mdadm: added /dev/sdb1
[root@localhost ~]# mdadm -D /dev/md0
/dev/md0:
        Version : 1.2
  Creation Time : Fri Apr 26 03:57:32 2019
     Raid Level : raid5
     Array Size : 9463296 (9.02 GiB 9.69 GB)
  Used Dev Size : 3154432 (3.01 GiB 3.23 GB)
   Raid Devices : 4
  Total Devices : 5
    Persistence : Superblock is persistent

    Update Time : Fri Apr 26 06:18:49 2019
          State : clean 
 Active Devices : 4
Working Devices : 5
 Failed Devices : 0
  Spare Devices : 1

         Layout : left-symmetric
     Chunk Size : 512K

           Name : localhost.localdomain:0  (local to host localhost.localdomain)
           UUID : b3480a3a:9c89f632:c6f0236e:3fb66b7f
         Events : 39

    Number   Major   Minor   RaidDevice State
       4       8       22        0      active sync   /dev/sdb6
       1       8       18        1      active sync   /dev/sdb2
       2       8       19        2      active sync   /dev/sdb3
       5       8       21        3      active sync   /dev/sdb5

       6       8       17        -      spare   /dev/sdb1

## 这样就可以在一定程度上保证我们数据的安全性. 如果同时坏 2 块盘就比较麻烦了. 并且我们都是在没有关机状态下操作的.
```

### 开机自挂载RAID
```bash
## 如果我们想要开机的时候自动挂载, 那么我们就需要以下操作了.

## 先获取 /dev/md0 的 UUID, 然后编辑下面这个文件
[root@localhost ~]# mdadm -D /dev/md0 | grep UUID:
           UUID : b3480a3a:9c89f632:c6f0236e:3fb66b7f
[root@localhost ~]# vim /etc/mdadm.conf
ARRAY /dev/md0 UUID=b3480a3a:9c89f632:c6f0236e:3fb66b7f

## 然后在 /etc/fstab 文件中新增一行
[root@localhost ~]# vim /etc/fstab
/dev/md0  /mnt/raid  ext3 defaults 0 0

## 测试一下 是否写的有问题
[root@localhost ~]# umount /dev/md0; mount -a
[root@localhost ~]# df /mnt/raid/
Filesystem     1K-blocks   Used Available Use% Mounted on
/dev/md0         9314596 152000   8689432   2% /mnt/raid
```

### 先关在开 RAID
```bash
## 先把 RAID 关闭, 在查看 /proc/mdstat 文件
[root@localhost ~]# mdadm -S /dev/md0
mdadm: stopped /dev/md0
[root@localhost ~]# cat /proc/mdstat
Personalities : [raid6] [raid5] [raid4] 
unused devices: <none>

## 那么我们如何在重新打开这个 RAID 呢 ?
[root@localhost ~]# mdadm -A -s /dev/md0
mdadm: /dev/md0 not identified in config file.

## 有些同学会遇到上面的错误, 错误的原因是没有 /etc/mdadm.conf 配置文件
## 这个时候我们就可以使用下面这个命令来解决, 是不是发现和我们自己手动写入的很像
[root@localhost ~]# mdadm -Ds
ARRAY /dev/md0 metadata=1.2 spares=1 name=localhost.localdomain:0 UUID=b3480a3a:9c89f632:c6f0236e:3fb66b7f

## 然后我们就可以使用 > 或 >> 来把这些导入到配置文件中去(具体使用 > >> 看自己需要)
## 这样我们的配置文件就存在了, 然后就继续我们的启动 RAID 的操作
[root@localhost ~]# mdadm -Ds > /etc/mdadm.conf
[root@localhost ~]# mdadm -A -s /dev/md0
mdadm: /dev/md0 has been started with 4 drives and 1 spare.

## 查看 /proc/mdstat 
[root@localhost ~]# cat /proc/mdstat 
Personalities : [raid6] [raid5] [raid4] 
md0 : active raid5 sdb5[5] sdb6[4](S) sdb3[2] sdb2[1] sdb1[0]
      9463296 blocks super 1.2 level 5, 512k chunk, algorithm 2 [4/4] [UUUU]

unused devices: <none>
```

### 关闭 RAID
```bash
## 卸载并删除 /etc/fatab 中配置文件
[root@localhost ~]# umount /dev/md0

## 关闭 /dev/md0 并查看 发现确实没有
[root@localhost ~]# mdadm -S /dev/md0
mdadm: stopped /dev/md0
[root@localhost ~]# cat /proc/mdstat
Personalities : [raid6] [raid5] [raid4] 
unused devices: <none>

## 擦除 分区/磁盘 中的super block 信息
[root@localhost ~]# mdadm --misc --zero-superblock /dev/sdb1
[root@localhost ~]# mdadm --misc --zero-superblock /dev/sdb2
[root@localhost ~]# mdadm --misc --zero-superblock /dev/sdb3
[root@localhost ~]# mdadm --misc --zero-superblock /dev/sdb5
[root@localhost ~]# mdadm --misc --zero-superblock /dev/sdb6

## 删除配置信息
[root@localhost ~]# vim /etc/mdadm.conf
ARRAY /dev/md0 UUID=b3480a3a:9c89f632:c6f0236e:3fb66b7f   <== 删除此行
[root@localhost ~]# vim /etc/fstab
/dev/md0  /mnt/raid  ext3 defaults 0 0    <== 删除此行
```

# 逻辑卷管理器(Logical Volume Manager)
逻辑卷管理器是Linux系统用于对硬盘分区进行管理的一种机制，是为了解决硬盘设备在创建分区后不易修改分区大小的缺陷。对硬盘分区进行强制扩容或缩容从理论上来讲是可行的，但是却可能造成数据的丢失。而LVM技术是在硬盘分区和文件系统之间添加了一个逻辑层，它提供了一个抽象的卷组，可以把多块硬盘进行卷组合并。这样一来，用户不必关心物理硬盘设备的底层架构和布局，就可以实现对硬盘分区的动态调整。
LVM的做法类似 先将几个物理的分区(或磁盘 PV)通过软件来组合成一个看起来是独立的大磁盘(VG), 然后在这块磁盘上在划分出可用的分区(LV), 然后格式化, 最终就可以挂载使用了. 
```bash
PV : Physical Volume (物理卷) 可以是某个分区或磁盘
VG : Volume Group (卷组) 将多个 PV 组合成一个 VG 大磁盘.
PE : Physical Extend (物理扩展块) VG 的基本单位, VG 默认使用 4MB 的PE, 类似于文件系统中的 block .
LV : Logical Volume (逻辑卷) PE 是整个 LVM 的最小存储单位, 所以 LV 的大小和 PE 的数量大小有关系.
	 缩容/扩大磁盘 LV 大小 就是操作 PE 的数量来实现扩容/缩容的操作. 
	 LV 设备文件名通常为 /dev/VG_NAME/LV_NAME
```

| 功能/命令 | 物理卷管理	 | 卷组管理	 |  逻辑卷管理 |
| :-----:  |   :-----: |  :-----: |  :-----: |
| 扫描      |	pvscan |	vgscan |	lvscan |
| 建立	   | pvcreate |	vgcreate  |	lvcreate |
| 显示	  | pvdisplay	 | vgdisplay |	lvdisplay |
| 删除   |	pvremove |	vgremove |	lvremove |
| 扩展    |	<br> |	vgextend |	lvextend |
| 缩小   | <br> | 	vgreduce |	lvreduce |

## 实验出真知
### 实验要求
```bash
1. /dev/sdb1 /dev/sdb2 /dev/sdb3 /dev/sdb5 组成一个 VG , VG 名称为 vg_gkdaxue
2. PE 的大小为 16MB, 划分出来一个 7G 的 LV, 名称为 lv_gkdaxue
3. 格式化为 ext3 文件格式并挂载到 /mnt/lvm 下, 开机自启动

我们来理一下思路
分区/磁盘 -> PV -> VG -> LV -> 格式化 -> 开机挂载 -> 挂载并使用, 所以我们就使用这个步骤开始操作. 
```

### 实验环境
```bash
还用我们之前的那块磁盘 /dev/sdb, 分区如下显示, 每个分区大小为 3 G
[root@localhost ~]# fdisk -l /dev/sdb

Disk /dev/sdb: 21.5 GB, 21474836480 bytes
255 heads, 63 sectors/track, 2610 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0xd140095f

   Device Boot      Start         End      Blocks   Id  System
/dev/sdb1               1         393     3156741   83  Linux
/dev/sdb2             394         786     3156772+  83  Linux
/dev/sdb3             787        1179     3156772+  83  Linux
/dev/sdb4            1180        2610    11494507+   5  Extended
/dev/sdb5            1180        1572     3156741   83  Linux
/dev/sdb6            1573        1965     3156741   83  Linux
```

## PV的管理
> PV 的名称就是 分区/磁盘 的设备文件名

### pvcreate命令 : 将 分区/磁盘 新建为 PV
> pvcreate PhysicalVolume1 [ PhysicalVolume2.......]

```bash
[root@localhost ~]# pvcreate /dev/sdb{1,2,3,5,6}
  Physical volume "/dev/sdb1" successfully created
  Physical volume "/dev/sdb2" successfully created
  Physical volume "/dev/sdb3" successfully created
  Physical volume "/dev/sdb5" successfully created
  Physical volume "/dev/sdb6" successfully created
```

### pvscan命令 : 扫描所有磁盘以查找物理卷并显示汇总信息
```bash
[root@localhost ~]# pvscan
  PV /dev/sda2   VG server          lvm2 [4.88 GiB / 0    free]
  PV /dev/sdb1                      lvm2 [3.01 GiB]
  PV /dev/sdb2                      lvm2 [3.01 GiB]
  PV /dev/sdb3                      lvm2 [3.01 GiB]
  PV /dev/sdb5                      lvm2 [3.01 GiB]
  PV /dev/sdb6                      lvm2 [3.01 GiB]
  Total: 6 [19.93 GiB] / in use: 1 [4.88 GiB] / in no VG: 5 [15.05 GiB]
  整体 PV 数量以及容量 / 已经使用的 PV 数量以及容量 / 剩余的 PV 数量以及容量
```

### pvdisplay命令 : 显示 全部/部分 设备的 PV 属性
> pvdisplay [PhysicalVolumePath1 PhysicalVolumePath2.....]

```bash
## 查看指定的 pv 信息, 如果不指定, 默认显示全部
[root@localhost ~]# pvdisplay /dev/sdb1 /dev/sda2
  --- Physical volume ---
  PV Name               /dev/sda2                       <== 分区设备名称
  VG Name               server                          <== 属于哪个 VG
  PV Size               4.88 GiB / not usable 4.00 MiB  <== PV 的大小 / 不可用的为 4MB
  Allocatable           yes (but full)                  <== 已分配
  PE Size               4.00 MiB                        <== PE 大小 4MB
  Total PE              1249                            <== 共有 1249 PE
  Free PE               0                               <== 空闲的 PE
  Allocated PE          1249                            <== 已经分配的 PE
  PV UUID               QiqoY2-Wmng-l4uw-EnNi-QcrR-hiCk-Us7Atn
   
  "/dev/sdb1" is a new physical volume of "3.01 GiB"
  --- NEW Physical volume ---
  PV Name               /dev/sdb1
  VG Name               
  PV Size               3.01 GiB
  Allocatable           NO
  PE Size               0   
  Total PE              0
  Free PE               0
  Allocated PE          0
  PV UUID               Sgoeon-wcjB-nnE8-78yw-UzUM-b0zd-DKvWd1


PE 只有新建 VG 是才给与的参数, 所以这里关于 PE 的都是 0

```

###  pvremove命令 : 移除一个 PV
> pvremove PhysicalVolume

```bash
[root@localhost ~]# pvremove /dev/sdb6
  Labels on physical volume "/dev/sdb6" successfully wiped
[root@localhost ~]# pvdisplay /dev/sdb6
  Failed to find physical volume "/dev/sdb6"

## 再加上去, 稍后会用到
[root@localhost ~]# pvcreate /dev/sdb6
  Physical volume "/dev/sdb6" successfully created
[root@localhost ~]# pvdisplay /dev/sdb6
  "/dev/sdb6" is a new physical volume of "3.01 GiB"
  --- NEW Physical volume ---
  PV Name               /dev/sdb6
  VG Name               
  PV Size               3.01 GiB
  Allocatable           NO
  PE Size               0   
  Total PE              0
  Free PE               0
  Allocated PE          0
  PV UUID               RHnCxK-MI5R-AYQj-Sw4o-KV8U-Ni8S-Qy0asv
```

## VG管理
> VG 的名称可以自定义

### vgcreate命令
用来新建 VG
> vgcreate [ -s Num[MGT]] VolumeGroupName PhysicalDevicePath1 [PhysicalDevicePath2.....]

```bash
## 之前我们说过 PE 的大小默认为 4MB, 所以我们可以使用 -s 来设置 PE 的大小
## 也可以使用多个 PV 来组成一个 VG

## 使用 /dev/sdb{1,2,3,5} 组成一个 PE 为 8M 的 VG 名称为 vg_gkdaxue
[root@localhost ~]# vgcreate -s 8M vg_gkdaxue /dev/sdb{1,2,3,5}
  Volume group "vg_gkdaxue" successfully created

## 查看一下之前的 PV /dev/sdb1
[root@localhost ~]# pvdisplay  /dev/sdb1
  --- Physical volume ---
  PV Name               /dev/sdb1
  VG Name               vg_gkdaxue    <== 属于哪个卷组
  PV Size               3.01 GiB / not usable 2.75 MiB
  Allocatable           yes           <== 已经分配了
  PE Size               8.00 MiB      <== PE 的大小
  Total PE              385           <== PE 的总数
  Free PE               385           <== 可用的 PE
  Allocated PE          0             <== 已经分配的PE
  PV UUID               Sgoeon-wcjB-nnE8-78yw-UzUM-b0zd-DKvWd1

[root@localhost ~]# pvscan 
  PV /dev/sdb1   VG vg_gkdaxue      lvm2 [3.01 GiB / 3.01 GiB free]  <== 已经和之前显示的不同了
  PV /dev/sdb2   VG vg_gkdaxue      lvm2 [3.01 GiB / 3.01 GiB free]
  PV /dev/sdb3   VG vg_gkdaxue      lvm2 [3.01 GiB / 3.01 GiB free]
  PV /dev/sdb5   VG vg_gkdaxue      lvm2 [3.01 GiB / 3.01 GiB free]
  PV /dev/sda2   VG server          lvm2 [4.88 GiB / 0    free]
  PV /dev/sdb6                      lvm2 [3.01 GiB]
  Total: 6 [19.92 GiB] / in use: 5 [16.91 GiB] / in no VG: 1 [3.01 GiB]
```

### vgscan命令 : 扫描所有磁盘以查找卷组并重建缓存
```bash
[root@localhost ~]# vgscan 
  Reading all physical volumes.  This may take a while...
  Found volume group "vg_gkdaxue" using metadata type lvm2  <== 可以发现我们刚才创建的已经存在了
  Found volume group "server" using metadata type lvm2 
```

### vgdisplay命令 : 显示卷组的属性
> vgdisplay [VolumeGroupName1 [VolumeGroupName2....]]

```bash
[root@localhost ~]# vgdisplay vg_gkdaxue
  --- Volume group ---
  VG Name               vg_gkdaxue
  System ID             
  Format                lvm2
  Metadata Areas        4
  Metadata Sequence No  1
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                0
  Open LV               0
  Max PV                0
  Cur PV                4
  Act PV                4
  VG Size               12.03 GiB         <== VG 的容量
  PE Size               8.00 MiB          <== PE 的大小
  Total PE              1540              <== 总共的 PE 数量 (385 * 4 = 1540)
  Alloc PE / Size       0 / 0             <== 已经分配的 PE 数量
  Free  PE / Size       1540 / 12.03 GiB  <== 空闲的 PE 数量以及容量 
  VG UUID               78sXrm-wwY1-qSjs-5rIy-zaEp-AEMs-y6ajNj
```

### vgextend命令 : 扩大卷组容量(增加一个 PV 到 VG 中)
> vgextend VolumeGroupName PhysicalDevicePath

```bash
## 我们总共有 sdb1 sdb2 sdb3 sdb5 sdb6 我们只使用了 sdb1 sdb2 sdb3 sdb5 没有使用 sdb6
## 所以我们现在把 sdb6 也加进来
[root@localhost ~]# pvscan 
  PV /dev/sdb1   VG vg_gkdaxue      lvm2 [3.01 GiB / 3.01 GiB free]
  PV /dev/sdb2   VG vg_gkdaxue      lvm2 [3.01 GiB / 3.01 GiB free]
  PV /dev/sdb3   VG vg_gkdaxue      lvm2 [3.01 GiB / 3.01 GiB free]
  PV /dev/sdb5   VG vg_gkdaxue      lvm2 [3.01 GiB / 3.01 GiB free]
  PV /dev/sda2   VG server          lvm2 [4.88 GiB / 0    free]
  PV /dev/sdb6                      lvm2 [3.01 GiB]                      <== 没有被使用     
  Total: 6 [19.92 GiB] / in use: 5 [16.91 GiB] / in no VG: 1 [3.01 GiB]

## 把 /dev/sdb6 加入到 vg_gkdaxue 卷组中去
[root@localhost ~]# vgextend vg_gkdaxue /dev/sdb6
  Volume group "vg_gkdaxue" successfully extended
[root@localhost ~]# pvscan 
  PV /dev/sdb1   VG vg_gkdaxue      lvm2 [3.01 GiB / 3.01 GiB free]
  PV /dev/sdb2   VG vg_gkdaxue      lvm2 [3.01 GiB / 3.01 GiB free]
  PV /dev/sdb3   VG vg_gkdaxue      lvm2 [3.01 GiB / 3.01 GiB free]
  PV /dev/sdb5   VG vg_gkdaxue      lvm2 [3.01 GiB / 3.01 GiB free]
  PV /dev/sdb6   VG vg_gkdaxue      lvm2 [3.01 GiB / 3.01 GiB free]      <== 已经加入到卷组中
  PV /dev/sda2   VG server          lvm2 [4.88 GiB / 0    free]
  Total: 6 [19.92 GiB] / in use: 6 [19.92 GiB] / in no VG: 0 [0   ]

[root@localhost ~]# pvdisplay  /dev/sdb6
  --- Physical volume ---
  PV Name               /dev/sdb6
  VG Name               vg_gkdaxue
  PV Size               3.01 GiB / not usable 2.75 MiB
  Allocatable           yes 
  PE Size               8.00 MiB
  Total PE              385
  Free PE               385
  Allocated PE          0
  PV UUID               RHnCxK-MI5R-AYQj-Sw4o-KV8U-Ni8S-Qy0asv

[root@localhost ~]# vgdisplay vg_gkdaxue
  --- Volume group ---
  VG Name               vg_gkdaxue
  System ID             
  Format                lvm2
  Metadata Areas        5
  Metadata Sequence No  2
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                0
  Open LV               0
  Max PV                0
  Cur PV                5
  Act PV                5
  VG Size               15.04 GiB
  PE Size               8.00 MiB
  Total PE              1925
  Alloc PE / Size       0 / 0   
  Free  PE / Size       1925 / 15.04 GiB                        <== PE 数量和容量都增大了
  VG UUID               78sXrm-wwY1-qSjs-5rIy-zaEp-AEMs-y6ajNj
```

### vgreduce命令 : 缩小卷组容量
>  vgreduce  VolumeGroupName  PhysicalVolumePath...

```bash
[root@localhost ~]# vgreduce vg_gkdaxue /dev/sdb6
  Removed "/dev/sdb6" from volume group "vg_gkdaxue"

[root@localhost ~]# pvscan 
  PV /dev/sdb1   VG vg_gkdaxue      lvm2 [3.01 GiB / 3.01 GiB free]
  PV /dev/sdb2   VG vg_gkdaxue      lvm2 [3.01 GiB / 3.01 GiB free]
  PV /dev/sdb3   VG vg_gkdaxue      lvm2 [3.01 GiB / 3.01 GiB free]
  PV /dev/sdb5   VG vg_gkdaxue      lvm2 [3.01 GiB / 3.01 GiB free]
  PV /dev/sda2   VG server          lvm2 [4.88 GiB / 0    free]
  PV /dev/sdb6                      lvm2 [3.01 GiB]
  Total: 6 [19.92 GiB] / in use: 5 [16.91 GiB] / in no VG: 1 [3.01 GiB]

[root@localhost ~]# vgdisplay vg_gkdaxue
  --- Volume group ---
  VG Name               vg_gkdaxue
  System ID             
  Format                lvm2
  Metadata Areas        4
  Metadata Sequence No  3
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                0
  Open LV               0
  Max PV                0
  Cur PV                4
  Act PV                4
  VG Size               12.03 GiB
  PE Size               8.00 MiB
  Total PE              1540
  Alloc PE / Size       0 / 0   
  Free  PE / Size       1540 / 12.03 GiB
  VG UUID               78sXrm-wwY1-qSjs-5rIy-zaEp-AEMs-y6ajNj
```

### vgremove命令 : 删除一个 VG
> vgremove VolumeGroupName

```bash
## 我们就使用 /dev/sdb6 组成一个测试的 VG , 然后在删除
[root@localhost ~]# vgcreate vg_test /dev/sdb6
  Volume group "vg_test" successfully created

[root@localhost ~]# pvscan 
  PV /dev/sdb6   VG vg_test         lvm2 [3.01 GiB / 3.01 GiB free]  <== 已经被使用
  PV /dev/sdb1   VG vg_gkdaxue      lvm2 [3.01 GiB / 3.01 GiB free]
  PV /dev/sdb2   VG vg_gkdaxue      lvm2 [3.01 GiB / 3.01 GiB free]
  PV /dev/sdb3   VG vg_gkdaxue      lvm2 [3.01 GiB / 3.01 GiB free]
  PV /dev/sdb5   VG vg_gkdaxue      lvm2 [3.01 GiB / 3.01 GiB free

[root@localhost ~]# vgdisplay vg_test
  --- Volume group ---
  VG Name               vg_test
  System ID             
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  1
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                0
  Open LV               0
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               3.01 GiB
  PE Size               4.00 MiB
  Total PE              770
  Alloc PE / Size       0 / 0   
  Free  PE / Size       770 / 3.01 GiB
  VG UUID               4dgASB-p2z1-GpPB-ciEr-DJIW-SWg4-lYb3cP

## 然后删除 VG
[root@localhost ~]# vgremove vg_test
  Volume group "vg_test" successfully removed
[root@localhost ~]# pvscan 
  PV /dev/sdb6                      lvm2 [3.01 GiB]        <== 没有被使用
[root@localhost ~]# vgdisplay vg_test
  Volume group "vg_test" not found
  Cannot process volume group vg_test
```

## LV管理
我们可以打个比喻, 我们已经做好了一个蛋糕(VG), 然后还切好了每份的大小(PE), 具体每个人(LV)需要多大容量, 就拿多少块蛋糕就好了.

### lvcreate命令 : 在一个已经存在的 VG 上创建 LV
> lvcreate [ options ] -n LV_Name VG_Name

| 选项 | 作用 |
| :----: | ------ |
| -L Num{MGT} | 指定容量, 但是这个容量必须是 PE 的整数倍, 否则系统自动计算 PE 数 |
| -l PE_Num | 指定 PE 的数量, 需要自己计算需要多少 PE 数 |
| -n LV_Name | 指定 LV 的名称 |

```bash
## 使用指定容量的方式
[root@localhost ~]# lvcreate -L 7G -n lv_gkdaxue vg_gkdaxue
  Logical volume "lv_gkdaxue" created.

[root@localhost ~]# vgdisplay vg_gkdaxue
  --- Volume group ---
  VG Name               vg_gkdaxue
  System ID             
  Format                lvm2
  Metadata Areas        4
  Metadata Sequence No  4
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                1
  Open LV               0
  Max PV                0
  Cur PV                4
  Act PV                4
  VG Size               12.03 GiB
  PE Size               8.00 MiB
  Total PE              1540
  Alloc PE / Size       896 / 7.00 GiB    <== 已经分配的空间
  Free  PE / Size       644 / 5.03 GiB    <== 剩余的空间
  VG UUID               78sXrm-wwY1-qSjs-5rIy-zaEp-AEMs-y6ajNj
```

### lvdisplay命令 : 显示 LV 的属性
> lvdisplay VgNamePath/LV_Name1 .....

```bash
[root@localhost ~]# lvdisplay /dev/vg_gkdaxue/lv_gkdaxue
  --- Logical volume ---
  LV Path                /dev/vg_gkdaxue/lv_gkdaxue
  LV Name                lv_gkdaxue
  VG Name                vg_gkdaxue
  LV UUID                EGphV6-Iqg6-yi7r-93N3-Tgub-XROO-yB3hBo
  LV Write Access        read/write
  LV Creation host, time localhost.localdomain, 2019-04-27 06:34:11 +0800
  LV Status              available
  # open                 0
  LV Size                7.00 GiB
  Current LE             896
  Segments               3
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:1
````

### lvscan命令 :  查看所有磁盘上的 LV
```bash
[root@localhost ~]# lvscan 
  ACTIVE            '/dev/vg_gkdaxue/lv_gkdaxue' [7.00 GiB] inherit
  ACTIVE            '/dev/server/myhome'         [4.88 GiB] inherit
```

### lvchange命令 : 更改 LV 是否为活动状态
> lvchange -a {y|n} VGPATH/LVName

```bash
[root@localhost ~]# lvcreate -L 1G -n lv_test vg_gkdaxue
  Logical volume "lv_test" created.

[root@localhost ~]# lvdisplay /dev/vg_gkdaxue/lv_test 
  --- Logical volume ---
  LV Path                /dev/vg_gkdaxue/lv_test
  LV Name                lv_test
  VG Name                vg_gkdaxue
  LV UUID                tRn7qc-sHD8-9i4t-KUV9-Jtim-KB5I-tJdoEf
  LV Write Access        read/write
  LV Creation host, time localhost.localdomain, 2019-04-27 06:50:36 +0800
  LV Status              available
  # open                 0
  LV Size                1.00 GiB
  Current LE             128
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:2

## 设置为不活跃状态
[root@localhost ~]# lvchange -a n /dev/vg_gkdaxue/lv_test 
[root@localhost ~]# lvscan 
  ACTIVE            '/dev/vg_gkdaxue/lv_gkdaxue' [7.00 GiB] inherit
  inactive          '/dev/vg_gkdaxue/lv_test'    [1.00 GiB] inherit
  ACTIVE            '/dev/server/myhome'         [4.88 GiB] inherit

## 设置为活跃状态
[root@localhost ~]# lvchange -a y /dev/vg_gkdaxue/lv_test
[root@localhost ~]# lvscan
  ACTIVE            '/dev/vg_gkdaxue/lv_gkdaxue' [7.00 GiB] inherit
  ACTIVE            '/dev/vg_gkdaxue/lv_test'    [1.00 GiB] inherit
  ACTIVE            '/dev/server/myhome'         [4.88 GiB] inherit
```


### lvremove命令 : 删除一个 LV
> lvremove VolumeGroupPath/LogicalVolumeName

```bash
[root@localhost ~]# lvremove /dev/vg_gkdaxue/lv_test 
Do you really want to remove active logical volume lv_test? [y/n]: y
  Logical volume "lv_test" successfully removed

[root@localhost ~]# lvdisplay /dev/vg_gkdaxue/lv_test
  Failed to find logical volume "vg_gkdaxue/lv_test"
```

### lvresize命令 : 调整逻辑卷的大小( 可扩大/可缩小 )
**扩大 LV 的大小, 几乎没有风险, 但是缩小 LV 的容量一定有风险, 所以谨慎操作.**

> lvresize -L [+-]LogicalVolumeSize[KMGTPE]  LogicalVolumePath/LogicalVolumePathName

```bash
## 先查看大小, 现在 lv_gkdaxue 为 7G
[root@localhost ~]# lvdisplay /dev/vg_gkdaxue/lv_gkdaxue | grep 'LV Size'
  LV Size                7.00 GiB

## 使用相对运算, 扩大 1G, 在查看大小发现为 8G 了
[root@localhost ~]# lvresize -L +1G /dev/vg_gkdaxue/lv_gkdaxue 
  Size of logical volume vg_gkdaxue/lv_gkdaxue changed from 7.00 GiB (896 extents) to 8.00 GiB (1024 extents).
  Logical volume lv_gkdaxue successfully resized.
[root@localhost ~]# lvdisplay /dev/vg_gkdaxue/lv_gkdaxue | grep 'LV Size'
  LV Size                8.00 GiB

## 因为我这里面没有数据, 仅仅只是测试命令使用, 生产环境中不可直接进行此操作
## 然后使用相对运算, 缩小 1G, 在查看大小发现为 7G 了
[root@localhost ~]# lvresize -L -1G /dev/vg_gkdaxue/lv_gkdaxue 
  WARNING: Reducing active and open logical volume to 7.00 GiB.
  THIS MAY DESTROY YOUR DATA (filesystem etc.)
Do you really want to reduce vg_gkdaxue/lv_gkdaxue? [y/n]: y
  Size of logical volume vg_gkdaxue/lv_gkdaxue changed from 8.00 GiB (1024 extents) to 7.00 GiB (896 extents).
  Logical volume lv_gkdaxue successfully resized.
[root@localhost ~]# lvdisplay /dev/vg_gkdaxue/lv_gkdaxue | grep 'LV Size'
  LV Size                7.00 GiB
```

### lvextend命令 : 扩大 LV 的大小
**扩大 LV 的大小, 几乎没有风险, 但是缩小 LV 的容量一定有风险, 所以谨慎操作.**
> lvextend -L LogicalVolumeSize[KMGTPE]  LogicalVolumePath/LogicalVolumePathName

```bash
[root@localhost ~]# lvdisplay /dev/vg_gkdaxue/lv_gkdaxue | grep 'LV Size'
  LV Size                7.00 GiB

[root@localhost ~]# lvextend -L 8G /dev/vg_gkdaxue/lv_gkdaxue 
  Size of logical volume vg_gkdaxue/lv_gkdaxue changed from 7.00 GiB (896 extents) to 8.00 GiB (1024 extents).
  Logical volume lv_gkdaxue successfully resized.

[root@localhost ~]# lvdisplay /dev/vg_gkdaxue/lv_gkdaxue | grep 'LV Size'
  LV Size                8.00 GiB
```

### lvreduce命令 : 缩小 LV 的大小(谨慎操作)
**扩大 LV 的大小, 几乎没有风险, 但是缩小 LV 的容量一定有风险, 所以谨慎操作.**
> lvreduce -L LogicalVolumeSize[KMGTPE]  LogicalVolumePath/LogicalVolumePathName

```bash
[root@localhost ~]# lvdisplay /dev/vg_gkdaxue/lv_gkdaxue | grep 'LV Size'
  LV Size                8.00 GiB

[root@localhost ~]# lvreduce -L 7G /dev/vg_gkdaxue/lv_gkdaxue 
  WARNING: Reducing active and open logical volume to 7.00 GiB.
  THIS MAY DESTROY YOUR DATA (filesystem etc.)
Do you really want to reduce vg_gkdaxue/lv_gkdaxue? [y/n]: y
  Size of logical volume vg_gkdaxue/lv_gkdaxue changed from 8.00 GiB (1024 extents) to 7.00 GiB (896 extents).
  Logical volume lv_gkdaxue successfully resized.

[root@localhost ~]# lvdisplay /dev/vg_gkdaxue/lv_gkdaxue | grep 'LV Size'
  LV Size                7.00 GiB
```

## 挂载并使用
```bash
[root@localhost ~]# mkfs.ext3 /dev/vg_gkdaxue/lv_gkdaxue 
mke2fs 1.41.12 (17-May-2010)
Filesystem label=
OS type: Linux
Block size=4096 (log=2)
Fragment size=4096 (log=2)
Stride=0 blocks, Stripe width=0 blocks
458752 inodes, 1835008 blocks
91750 blocks (5.00%) reserved for the super user
First data block=0
Maximum filesystem blocks=1879048192
56 block groups
32768 blocks per group, 32768 fragments per group
8192 inodes per group
Superblock backups stored on blocks: 
	32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632

Writing inode tables: done                            
Creating journal (32768 blocks): done
Writing superblocks and filesystem accounting information: done

This filesystem will be automatically checked every 20 mounts or
180 days, whichever comes first.  Use tune2fs -c or -i to override.

[root@localhost ~]# mkdir -p /mnt/lvm
[root@localhost ~]# vim /etc/fstab
/dev/vg_gkdaxue/lv_gkdaxue /mnt/lvm ext3 defaults 0 0 

[root@localhost ~]# mount -a
[root@localhost ~]# df
Filesystem                       1K-blocks    Used Available Use% Mounted on
/dev/sda5                          1983056  310808   1569848  17% /
tmpfs                               502056       0    502056   0% /dev/shm
/dev/sda1                           194241   35163    148838  20% /boot
/dev/mapper/server-myhome          4904448   10008   4638648   1% /home
/dev/sda8                           991512    1308    939004   1% /tmp
/dev/sda3                          3966144 3070696    690648  82% /usr
/dev/sda6                          1983056   87140   1793516   5% /var
/dev/mapper/vg_gkdaxue-lv_gkdaxue  7224824  147320   6710504   3% /mnt/lvm
```

## resize2fs命令 : 调整 ext2/ext3/ext4 文件系统大小
> resize2fs [ -f ] device [ size ]

```bash
-f   : 强制进行 resize2fs 操作
size : 可以忽略不写, 如果忽略 默认设置为全部大小
```

## 扩大LV容量
```bash
1. 先查看 VG 是否有剩余的空间, 有则进行到第4步, 没有就进行下一步
2. 使用 pvcreate 创建 PV
3. 使用 vgextend 把 PV 加入到对应的 VG 中
4. 利用 lvresize 将新加入的 PV 内的 PE 加入到 LV 中
5. 利用 resize2fs 增加文件系统的容量(增/减 block group)


[root@localhost ~]# vgdisplay /dev/vg_gkdaxue
  --- Volume group ---
  VG Name               vg_gkdaxue
  System ID             
  Format                lvm2
  Metadata Areas        4
  Metadata Sequence No  6
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                1
  Open LV               1
  Max PV                0
  Cur PV                4
  Act PV                4
  VG Size               12.03 GiB
  PE Size               8.00 MiB
  Total PE              1540
  Alloc PE / Size       896 / 7.00 GiB
  Free  PE / Size       644 / 5.03 GiB               <== VG 剩余的空间
  VG UUID               78sXrm-wwY1-qSjs-5rIy-zaEp-AEMs-y6ajNj

## 虽然剩余的还有空间, 但是我们还是按照完整的流程走一遍吧
[root@localhost ~]# pvcreate /dev/sdb6
  Physical volume "/dev/sdb6" successfully created

[root@localhost ~]# vgextend vg_gkdaxue /dev/sdb6
  Volume group "vg_gkdaxue" successfully extended

[root@localhost ~]# vgdisplay vg_gkdaxue | grep 'Free'
  Free  PE / Size       1029 / 8.04 GiB              <== 空间确实增大了, 并且有可用的空间

## 查看 lv_gkdaxue 的大小
[root@localhost ~]# lvdisplay /dev/vg_gkdaxue/lv_gkdaxue | grep 'LV Size'
  LV Size                7.00 GiB

## lv_gkdaxue 的大小扩展到 10G 吧
[root@localhost ~]# lvextend -L 10G /dev/vg_gkdaxue/lv_gkdaxue 
  Size of logical volume vg_gkdaxue/lv_gkdaxue changed from 7.00 GiB (896 extents) to 10.00 GiB (1280 extents).
  Logical volume lv_gkdaxue successfully resized.
[root@localhost ~]# lvdisplay /dev/vg_gkdaxue/lv_gkdaxue | grep 'LV Size'
  LV Size                10.00 GiB

## 使用 resize2fs 来扩大 容量(因为 LV 容量增加了, 文件系统容量却没有增加)
[root@localhost ~]# df -hT /mnt/lvm
Filesystem                         Type  Size  Used Avail Use% Mounted on
/dev/mapper/vg_gkdaxue-lv_gkdaxue  ext3  6.9G  144M  6.4G   3% /mnt/lvm
[root@localhost ~]# resize2fs /dev/vg_gkdaxue/lv_gkdaxue 
resize2fs 1.41.12 (17-May-2010)
Filesystem at /dev/vg_gkdaxue/lv_gkdaxue is mounted on /mnt/lvm; on-line resizing required
old desc_blocks = 1, new_desc_blocks = 1
Performing an on-line resize of /dev/vg_gkdaxue/lv_gkdaxue to 2621440 (4k) blocks.
The filesystem on /dev/vg_gkdaxue/lv_gkdaxue is now 2621440 blocks long.

## 再次查看大小, 发现已经变为我们想要的
[root@localhost ~]# df -hT /mnt/lvm
Filesystem                         Type  Size  Used Avail Use% Mounted on
/dev/mapper/vg_gkdaxue-lv_gkdaxue  ext3  9.9G  144M  9.3G   2% /mnt/lvm
```

## 缩小LV容量
```bash
## 从我们之前的讲解中, 我们也发现了 缩小LV容量是有风险的, 所以我们操作的时候一定要谨慎.
1. 先卸载文件系统(扩容的时候可以不用卸载)
2. 然后使用 e2fsck 检查文件系统是否有问题
3. 使用 resize2fs 来设置文件系统的大小
4. 使用 lvreduce 设置 LV 的大小
5. 挂载并正常使用文件系统


## 设置 lv_gkdaxue 的容量为 8G
[root@localhost ~]# umount /mnt/lvm/

[root@localhost ~]# e2fsck -f /dev/vg_gkdaxue/lv_gkdaxue
e2fsck 1.41.12 (17-May-2010)
Pass 1: Checking inodes, blocks, and sizes
Pass 2: Checking directory structure
Pass 3: Checking directory connectivity
Pass 4: Checking reference counts
Pass 5: Checking group summary information
/dev/vg_gkdaxue/lv_gkdaxue: 11/655360 files (0.0% non-contiguous), 77968/2621440 blocks

[root@localhost ~]# resize2fs -f /dev/vg_gkdaxue/lv_gkdaxue 8G
resize2fs 1.41.12 (17-May-2010)
Resizing the filesystem on /dev/vg_gkdaxue/lv_gkdaxue to 2097152 (4k) blocks.
The filesystem on /dev/vg_gkdaxue/lv_gkdaxue is now 2097152 blocks long.

[root@localhost ~]# lvreduce -L 8G /dev/vg_gkdaxue/lv_gkdaxue 
  WARNING: Reducing active logical volume to 8.00 GiB.
  THIS MAY DESTROY YOUR DATA (filesystem etc.)
Do you really want to reduce vg_gkdaxue/lv_gkdaxue? [y/n]: y
  Size of logical volume vg_gkdaxue/lv_gkdaxue changed from 9.00 GiB (1152 extents) to 8.00 GiB (1024 extents).
  Logical volume lv_gkdaxue successfully resized.

[root@localhost ~]# lvdisplay  /dev/vg_gkdaxue/lv_gkdaxue 
  --- Logical volume ---
  LV Path                /dev/vg_gkdaxue/lv_gkdaxue
  LV Name                lv_gkdaxue
  VG Name                vg_gkdaxue
  LV UUID                EGphV6-Iqg6-yi7r-93N3-Tgub-XROO-yB3hBo
  LV Write Access        read/write
  LV Creation host, time localhost.localdomain, 2019-04-27 06:34:11 +0800
  LV Status              available
  # open                 0
  LV Size                8.00 GiB   <== 确实只有 8G 了
  Current LE             1024
  Segments               3
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:1

## 我们之前已经把挂载信息写入到了 配置文件中, 所以我们可以直接使用 mount -a 来挂载使用
[root@localhost ~]# cat /etc/fstab 
/dev/vg_gkdaxue/lv_gkdaxue /mnt/lvm ext3 defaults 0 0 

[root@localhost ~]# mount -a
[root@localhost ~]# mount | grep /mnt/lvm
/dev/mapper/vg_gkdaxue-lv_gkdaxue on /mnt/lvm type ext3 (rw)

[root@localhost ~]# df -hT /dev/vg_gkdaxue/lv_gkdaxue 
Filesystem                          Type  Size  Used Avail Use% Mounted on
/dev/mapper/vg_gkdaxue-lv_gkdaxue   ext3  7.9G  144M  7.4G   2% /mnt/lvm    <== 容量确实为 8G 了.
```

## 关闭LVM
```bash
如果我们想要关闭并删除LVM, 就需要按照之前的顺序倒过来做了
1. 删除 /etc/fstab 文件中的信息
2. 卸载系统上的 LVM 文件系统
3. 删除所有的 LV 以及快照
4. 删除所有的 VG
5. 删除所有的 PV


[root@localhost ~]# vim /etc/fstab 
/dev/vg_gkdaxue/lv_gkdaxue /mnt/lvm ext3 defaults 0 0      <== 删除此行

[root@localhost ~]# umount /mnt/lvm/

[root@localhost ~]# lvremove /dev/vg_gkdaxue/lv_gkdaxue 
Do you really want to remove active logical volume lv_gkdaxue? [y/n]: y
  Logical volume "lv_gkdaxue" successfully removed
[root@localhost ~]# lvdisplay  /dev/vg_gkdaxue/lv_gkdaxue
  Failed to find logical volume "vg_gkdaxue/lv_gkdaxue"

[root@localhost ~]# vgremove vg_gkdaxue
  Volume group "vg_gkdaxue" successfully removed
[root@localhost ~]# vgdisplay vg_gkdaxue
  Volume group "vg_gkdaxue" not found
  Cannot process volume group vg_gkdaxue

[root@localhost ~]# pvremove /dev/sdb{1,2,3,5,6}
  Labels on physical volume "/dev/sdb1" successfully wiped
  Labels on physical volume "/dev/sdb2" successfully wiped
  Labels on physical volume "/dev/sdb3" successfully wiped
  Labels on physical volume "/dev/sdb5" successfully wiped
  Labels on physical volume "/dev/sdb6" successfully wiped
```

# RAID10 + LVM 实战
**本节所有的实验都是建立在没有数据的基础上, 如果有数据, 请先把数据备份或者移动到其他地方在进行此操作.**

## 实验环境
```bash
## 执行先把硬盘分区如下所示
[root@localhost ~]# fdisk -l /dev/sdb

Disk /dev/sdb: 21.5 GB, 21474836480 bytes
255 heads, 63 sectors/track, 2610 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0xd140095f

   Device Boot      Start         End      Blocks   Id  System
/dev/sdb1               1         393     3156741   83  Linux
/dev/sdb2             394         786     3156772+  83  Linux
/dev/sdb3             787        1179     3156772+  83  Linux
/dev/sdb4            1180        2610    11494507+   5  Extended
/dev/sdb5            1180        1572     3156741   83  Linux
/dev/sdb6            1573        1965     3156741   83  Linux
```

## 实验要求
```bash
1. /dev/sdb1 /dev/sdb2 /dev/sdb3 /dev/sdb5 组成一个 RAID10 阵列
2. /dev/sdb6 作为 RAID10 阵列的热备盘
3. /dev/md0 组成一个卷组 名为 vg_gkdaxue 
4. 在划分出来一个大小为 5G 的 LV 名字叫做 lv_gkdaxue 开机自启动
5. RAID 10 的 4 块 3G 分区, 实际可用的为多少 ?
```

## RAID10
```bash
[root@localhost ~]# mdadm -Cv /dev/md0 -l 10 -n 4 -x 1 /dev/sdb{1,2,3,5,6}
mdadm: layout defaults to n2
mdadm: layout defaults to n2
mdadm: chunk size defaults to 512K
mdadm: size set to 3154432K
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md0 started.

[root@localhost ~]# mdadm -D /dev/md0
/dev/md0:
        Version : 1.2
  Creation Time : Fri Apr 26 03:56:24 2019
     Raid Level : raid10                        <== RAID 的级别为1 0 不是 10
     Array Size : 6308864 (6.02 GiB 6.46 GB)
  Used Dev Size : 3154432 (3.01 GiB 3.23 GB)
   Raid Devices : 4
  Total Devices : 5
    Persistence : Superblock is persistent

    Update Time : Fri Apr 26 03:56:56 2019
          State : clean 
 Active Devices : 4
Working Devices : 5
 Failed Devices : 0
  Spare Devices : 1

         Layout : near=2
     Chunk Size : 512K

           Name : localhost.localdomain:0  (local to host localhost.localdomain)
           UUID : 9b1333b9:4daa5f55:4eb9bf45:59460176
         Events : 17

    Number   Major   Minor   RaidDevice State
       0       8       17        0      active sync set-A   /dev/sdb1  <== A 组
       1       8       18        1      active sync set-B   /dev/sdb2  <== B 组
       2       8       19        2      active sync set-A   /dev/sdb3  <== A 组
       3       8       21        3      active sync set-B   /dev/sdb5  <== B 组

       4       8       22        -      spare   /dev/sdb6              <== 热备盘

[root@localhost ~]# cat /proc/mdstat 
Personalities : [raid10] 
md0 : active raid10 sdb6[4](S) sdb5[3] sdb3[2] sdb2[1] sdb1[0]
      6308864 blocks super 1.2 512K chunks 2 near-copies [4/4] [UUUU]
      
unused devices: <none>

[root@localhost ~]# vim /etc/mdadm.conf
ARRAY /dev/md0 UUID=9b1333b9:4daa5f55:4eb9bf45:59460176
```

## LVM
```bash
[root@localhost ~]# pvcreate /dev/md0
  Physical volume "/dev/md0" successfully created

[root@localhost ~]# vgcreate vg_gkdaxue /dev/md0
  Volume group "vg_gkdaxue" successfully created

[root@localhost ~]# pvdisplay /dev/md0
  --- Physical volume ---
  PV Name               /dev/md0
  VG Name               vg_gkdaxue
  PV Size               6.02 GiB / not usable 0   
  Allocatable           yes 
  PE Size               4.00 MiB
  Total PE              1540
  Free PE               1540
  Allocated PE          0
  PV UUID               C7NiD2-ct19-L42h-YulE-ogL8-FmQZ-3iL9Kr


[root@localhost ~]# vgdisplay vg_gkdaxue
  --- Volume group ---
  VG Name               vg_gkdaxue
  System ID             
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  1
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                0
  Open LV               0
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               6.02 GiB
  PE Size               4.00 MiB
  Total PE              1540
  Alloc PE / Size       0 / 0   
  Free  PE / Size       1540 / 6.02 GiB
  VG UUID               rYD8qZ-lkoH-Abaq-FJwe-g2rf-ScZe-YuhTYJ

[root@localhost ~]# lvcreate -L 6G -n lv_gkdaxue vg_gkdaxue
  Logical volume "lv_gkdaxue" created.

[root@localhost ~]# lvdisplay /dev/vg_gkdaxue/lv_gkdaxue 
  --- Logical volume ---
  LV Path                /dev/vg_gkdaxue/lv_gkdaxue
  LV Name                lv_gkdaxue
  VG Name                vg_gkdaxue
  LV UUID                UCchQy-k7hA-OUSM-Hwz4-p3dd-Vs6g-95nvjN
  LV Write Access        read/write
  LV Creation host, time localhost.localdomain, 2019-04-26 04:13:35 +0800
  LV Status              available
  # open                 0
  LV Size                6.00 GiB
  Current LE             1536
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     4096
  Block device           253:1

[root@localhost ~]# mkfs.ext3 /dev/vg_gkdaxue/lv_gkdaxue 
mke2fs 1.41.12 (17-May-2010)
Filesystem label=
OS type: Linux
Block size=4096 (log=2)
Fragment size=4096 (log=2)
Stride=128 blocks, Stripe width=256 blocks
393216 inodes, 1572864 blocks
78643 blocks (5.00%) reserved for the super user
First data block=0
Maximum filesystem blocks=1610612736
48 block groups
32768 blocks per group, 32768 fragments per group
8192 inodes per group
Superblock backups stored on blocks: 
	32768, 98304, 163840, 229376, 294912, 819200, 884736

Writing inode tables: done                            
Creating journal (32768 blocks): done
Writing superblocks and filesystem accounting information: done

This filesystem will be automatically checked every 31 mounts or
180 days, whichever comes first.  Use tune2fs -c or -i to override.

[root@localhost ~]# mkdir -p /mnt/lvm
[root@localhost ~]# vim /etc/fstab 
/dev/vg_gkdaxue/lv_gkdaxue /mnt/lvm ext3 defaults 0 0 
[root@localhost ~]# mount -a
[root@localhost ~]# mount | grep '/mnt/lvm'
/dev/mapper/vg_gkdaxue-lv_gkdaxue on /mnt/lvm type ext3 (rw)

[root@localhost ~]# reboot

[root@localhost ~]# cat /proc/mdstat 
Personalities : [raid10] 
md0 : active raid10 sdb1[0] sdb3[2] sdb5[3] sdb2[1] sdb6[4](S)
      6308864 blocks super 1.2 512K chunks 2 near-copies [4/4] [UUUU]
      
unused devices: <none>

[root@localhost ~]# mount | grep '/mnt/lvm'
/dev/mapper/vg_gkdaxue-lv_gkdaxue on /mnt/lvm type ext3 (rw)

[root@localhost ~]# dd if=/dev/zero of=/mnt/lvm/bigfile bs=1M count=480
480+0 records in
480+0 records out
503316480 bytes (503 MB) copied, 4.27219 s, 118 MB/s
```

## 删除LVM
```bash
[root@localhost ~]# vim /etc/fstab 
/dev/vg_gkdaxue/lv_gkdaxue /mnt/lvm ext3 defaults 0 0   <== 删除此行

[root@localhost ~]# umount /mnt/lvm

[root@localhost ~]# lvremove /dev/vg_gkdaxue/lv_gkdaxue 
Do you really want to remove active logical volume lv_gkdaxue? [y/n]: y
  Logical volume "lv_gkdaxue" successfully removed

[root@localhost ~]# vgremove vg_gkdaxue
  Volume group "vg_gkdaxue" successfully removed

[root@localhost ~]# pvremove /dev/md0
  Labels on physical volume "/dev/md0" successfully wiped
```

## 删除RAID10
```bash
[root@localhost ~]# mdadm -S /dev/md0
mdadm: stopped /dev/md0

[root@localhost ~]# cat /proc/mdstat 
Personalities : [raid10] 
unused devices: <none>

[root@localhost ~]# mdadm --misc --zero-superblock /dev/sdb1
[root@localhost ~]# mdadm --misc --zero-superblock /dev/sdb2
[root@localhost ~]# mdadm --misc --zero-superblock /dev/sdb3
[root@localhost ~]# mdadm --misc --zero-superblock /dev/sdb5
[root@localhost ~]# mdadm --misc --zero-superblock /dev/sdb6

[root@localhost ~]# vim /etc/mdadm.conf
ARRAY /dev/md0 UUID=9b1333b9:4daa5f55:4eb9bf45:59460176  <== 删除此行
```

