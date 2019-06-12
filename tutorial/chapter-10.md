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
>N  1 root@example.com      Sat Apr 27 05:46  26/970   "NOTE: You are exceeding your allocated disk space limits"
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

## RAID 0 (等量模式 stripe)
RAID 0技术能够有效地提升硬盘数据的吞吐速度，但是不具备数据备份和错误修复能力. 先把要存入的文件依据块的大小切割好, 然后在依序放到各个磁盘中, 数据会被等量的放置在各个磁盘中, 因此每个磁盘所负责的数据量降低了, 但是只要有一块磁盘损坏, 那么RAID上面的所有数据就会丢失而无法读取.

![linux_raid_0](https://github.com/gkdaxue/linux/raw/master/image/chapter_A10_0001.jpg)

```bash
1. 读写性能提升(多盘读入/写入)
2. 可用空间 : 磁盘数 * min(disk space), 比如 10G 20G 30G, 那么可用为 10 + 10 + 10 = 30G
3. 无容错能力(任意一块硬盘损坏, 将导致整个系统的数据都受到破坏)
4. 最小磁盘数 : 2 块
```


## RAID 1 (镜像模式 mirror)
它是把两块以上的硬盘设备进行绑定，在写入数据时，是将数据同时写入到多块硬盘设备上（可以将其视为数据的镜像或备份）。当其中某一块硬盘发生故障后，一般会立即自动以热交换的方式来恢复数据的正常使用。

![linux_raid_0](https://github.com/gkdaxue/linux/raw/master/image/chapter_A10_0002.jpg)

```bash
1. 读性能提升, 写性能略微下降
2. 可用空间 : 1 * min(disk space)
3. 有容错能力
4. 最小磁盘数 : 2 块
```
