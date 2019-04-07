# 用户身份和文件权限
Linux是一个多用户, 多任务的环境, 所以我们如何正确的管理这些用户, 给每个用户合理的分配权限来让他们完成自己的工作, 这些都是一个合格的系统管理员应该做的工作, 所以我们来讲解一些这些知识.

## 用户和用户组
我们之前在 ls -l 命令中就简单的描述了一下 所有者 所有组 其他人 以及 权限(rwx, acl)等, 今天我们就来系统的讲解一下这些知识.

```bash
[root@localhost ~]# ls -l install.log
-rw-r--r--. 1 root root 50698 Mar  3 11:42 install.log
```
假设我们现在在自己的家里面, 我们每个人都有自己的房间, 比如就有一个房间叫做 install.log, 也有一个叫做 root 的家人. 我们家庭的名称也叫做 root .
> 所有者 : install.log 房间的拥有者是 root
> 
> 所有组 : install.log 这个房间是我们这个家庭所有成员所拥有的, 所以我们可以使用客厅, 开电视等等.
> 
> 其他人 : 就是除了我们这个家庭之外的人

虽然我们在登录系统的时候输入的是用户名和密码, 每个登录的用户至少都会取得两个ID, 分别是 UID(user id) 和 GID(group id), 但是 Linux 其实并不认识用户名, 它仅能认识ID, UID和用户名的对应关系就被保存在 /etc/passwd 文件中. GID和组名的关系则被保存在 /etc/group 文件中.
> 默认系统上的账号信息会保存在 /etc/passwd 文件中, 密码则会保存在 /etc/shadow 文件中. 组信息则会保存在 /etc/group 文件中. 

那么当你在输入账号和密码时, 系统为你做了什么事情呢?
> 1. 先到 /etc/passwd 文件中查询是否有你输入的用户名, 没有则跳出, 给出错误信息. 如果有则将 UID/GID 读出来, 顺便也会将` 家目录 `和 ` shell ` 也一并读出来.
> 2. 然后就到 /etc/shadow 中找出对应的账号和UID, 然后核对里面的密码是否一致, 没有问题, 则进入shell 环境.

### /etc/passwd 文件讲解
```bash
[root@localhost ~]# head -n 4 /etc/passwd
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin
adm:x:3:4:adm:/var/adm:/sbin/nologin

root   x   0    0   root  /root   /bin/bash
[1]   [2] [3]  [4]  [5]    [6]       [7]
 ```
每一行代表一个账号, 有多少行就代表系统中有多少个账号, 每一行使用 " : "分割, 共有7个字段. 里面很多的账号是系统正常运行所必须的, 我们可以称为 '** 系统账号 '**, 比如 bin, daemon, nobody等, 这些账号不能随意删除, 否则可能会导致系统崩溃.
> 1. 账号 : 用来和 UID 相对应, 比如 root 用户的 UID 为 0, 也就是第三列
> 2. 密码占位符(x) : 如果将密码放到此字段中太危险, 因为任何人都可以查看(read), 有泄漏的风险. 所以使用占位符, 真实密码被放置在 /etc/shadow 文件中每行的第二个字段上. 我们可以分别看一下这两个文件的权限.
> ```bash
>[root@localhost ~]# ls -l /etc/{passwd,shadow}
>-rw-r--r--. 1 root root 1665 Mar 18 11:49 /etc/passwd
>----------. 1 root root 1055 Mar 22 13:44 /etc/shadow
> ```
> 3. UID : 这就是用户标识符. 还有一些其他的规定, 稍后讲解
> 4. GID : 用来规定组名和GID对应的, 与 /etc/group 有关
> 5. 备注用户的信息, 解释这个账号的意义.
> 6. 家目录 : 默认用户登录之后所在的目录
> ```bash
> root用户家目录 : /root 
> 一般用户家目录(默认) : /home/USERNAME 
> ```
> 7. 用户登录之后使用的 shell 程序. 比如如果用户的 shell 是 /sbin/nologin, 那么他将无法登录到系统中.

### UID描述
| UID 范围 | 含义 |
| ------------------- | ------------------------ |
| 0 | 当 UID 为 0 时, 表示此用户为**系统管理员**, 有的时候不受到权限的影响<br >比如 一个文件被设置为仅拥有者可以操作, 但是 **管理员** 却可以正常操作不受影响|
| 1 \- 499(系统账号) | 保留给系统使用的 UID, 因为系统正常的运行也需要一些其他的用户, 比如 bin, daemon等 |
| 500 \- 60000(一般账号) | 给一般用户使用的账号 UID |

**误区 :**
> 1. UID 为 0 的账号为系统管理员, 但是不能说root就是系统管理员, 因为可以改名不叫root, 但是一般我们都是叫做root, 所以了解即可.
> 2. 关于一般账号的起始 UID, 我们可以通过查看 /etc/login.defs 来找到, 因为不同版本的规定不同. 所以灵活运用.

```bash
[root@localhost ~]# cat /etc/login.defs 
## 找到如下两行信息
UID_MIN			  500    <== 一般用户的起始 ID, 小于此 ID 大于 0 的都为系统用户 ID
UID_MAX			60000    <== 一般用户的结束 ID
```

### /etc/shadow 文件讲解
虽然之前的密码也是加密的, 但是却被放置在了 /etc/passwd 的第二个字段上, 虽然是加密的, 但是还是很容易被利用, 所以后来就把密码移动到 /etc/shadow 中并设置只有 root 有权限来操作保证密码的安全.
```bash
## 查看 /etc/shadow 文件的权限, 发现只有我们超级用户 root 才可以读取, 虽然显示不可以, 但是root可以不受权限的影响.
[root@localhost ~]# ls -l /etc/shadow
----------. 1 root root 1055 Mar 26 09:27 /etc/shadow

## 查看密码文件前 4 行
[root@localhost ~]# head -n 4 /etc/shadow
root:$6$bhfh0f7W$4P.a0DKOZ7nPJvgXocBWl5awLC5G8T8W3yPlFUMTuUHQwd3r2uuifd/rd2RGlsSikuOhoKRVlU0iUWfHa1SJs/:17967:0:99999:7::: 
bin:*:17246:0:99999:7:::
daemon:*:17246:0:99999:7:::
adm:*:17246:0:99999:7:::

## 我们用第一行 root 来那讲解, 用 : 分割的 9 个字段
1. root
2. $6$bhfh0f7W$4P.a0DKOZ7nPJvgXocBWl5awLC5G8T8W3yPlFUMTuUHQwd3r2uuifd/rd2RGlsSikuOhoKRVlU0iUWfHa1SJs/
3. 17967
4. 0
5. 99999
6. 7
7. 空(因为是空的, 所以用 空来表示一下 )
8. 空
9. 空

[root@localhost ~]# ls -l /etc/shadow
----------. 1 root root 1055 Mar 26 09:27 /etc/shadow
```

> 1. 账号(必须要与 /etc/passwd 相同才行)
> 2. 加密过后的密码, 可以保证密码很难被破解出来(很难不代表不可能), 所以暂时只有 root 可以访问
> ```bash
> 固定的编码系统产生的密码长度必须一致, 当你改变了这个字段的长度后, 那么该密码就会失效(算出来密文不相等)
> 所以很多软件都会在该字段前加上 ! 或 * 改变密码长度, 让密码暂时失效
> ## 查看密码的加密方式,  明文 -> 加密方式 -> 密文
> [root@localhost ~]# cat /etc/login.defs | grep ENCRYPT_METHOD
> ENCRYPT_METHOD SHA512
> ```
> 3. 最近更改密码的日期(从 1970.1.1 作为1累加而来的日期)
> 4. 密码不可被更改的天数(与第三个字段相比, 最后一次修改后需要经过多少天才能再次被修改)
> ```bash
> 0 表示随时都可以更改
> 设置为 20 表示当你设置了密码后, 20 天之内都无法再次更改密码
> ```
> 5. 密码需要重新更改的天数(与第三个字段相比)
> ```bash
> 最后一次更改密码后, 在多少天内需要再次的更改密码才行, 在这个天数内必须重新设置你的密码, 否则这个账号的密码会过期.
> ```
> 6. 密码修改更改期限前的警告天数(与第五个字段相比)
> ```bash
> 当密码有效期快到的时候, 系统会根据这个字段的设置发出警告, 提醒再多多少天密码即将过期, 请尽快重新设置密码.
> ```
> 7. 密码过期后的宽限时间(密码失效日, 与第五个字段相比)
> ```bash
> 密码的有效期为 : 更新日期(第三字段) + 重新更改日期(第五字段), 过了该期限后用户仍然没有更新密码, 那么该密码就算过期了.
> 密码过期后仍然可以登录系统, 但是等你登录系统时要求你必须重新设置密码才可以使用.
> 该字段的含义是 : 密码过期几天后改密码就会失效, 该用户再也无法使用该密码登录系统
> 密码过期 和 密码失效并不相同
> ```
> 8. 账号失效日(总日期, 相对于1970年来设置)
> ```bash
> 这个账号在此字段之后的日期之后, 都无法在被使用.
> 账号失效 : 不论你的密码是否过期, 这个账号都不能在被使用
> ```
> 9. 保留, 暂未使用

#### 实例
```bash
[root@localhost ~]# grep gkdaxue /etc/shadow
gkdaxue:$6$6AgOxuJn$bC7f(密码太长, 省略一些):14299:5:60:7:5:14419:

## 14299 是哪一天呢? 先转换成秒, 然后在转换成时间 
[root@localhost ~]# echo $(( 14299*24*60*60 ))
1235433600
[root@localhost ~]# date -d "1970-01-01 1235433600 seconds" "+%F %T"
2009-02-24 00:00:00       <== 说明我是在这一天更改的密码

## 14419 是哪一天?  2009-06-24
[root@localhost ~]# date -d "1970-01-01 $(( 14419*24*60*60 )) seconds" "+%F %T"
2009-06-24 00:00:00

在 2009.02.24 (14299) 更改的密码
在 2009.03.01 (5) 之前 gkdaxue 用户不能修改自己的密码
在60天也就是 2009/04/25, 在 2009/03/01 - 2009/04/25 之间去修改自己的密码(5天的不可更改日期), 4/25之后还没修改, 密码过期
警告日期为 7 天, 也就是 2009/04/19 - 2009/04/25 这 7 天登录系统, 就会提示还有多久密码过期
宽限日期为 5 天, 也就是 2009/04/30 之前都可以使用旧密码登录系统, 不过登录时, 系统会出现强制更改密码. 必须重新设置密码
2009/04/30 后密码失效, 无法登录系统
2009/06/24 后密码也会失效, 不论之前的种种限制.

如果用户在 2009/04/25 之前修改了密码, 那么第三个字段会改变, 相应的所有限制日期也会改变
```
![linux_shadow](https://github.com/gkdaxue/linux/raw/master/image/chapter_A5_0001.png)

#### 忘记密码
> 一般用户 : 请求管理员重新设置密码
>
> 管理员  : 进入到系统维护模式, 设置密码, 重新启动系统  

### /etc/group 文件讲解


## 文件权限
### 普通权限(rwx)
```bash
[root@localhost ~]# ls -l install.log
-rw-r--r--. 1 root root 50698 Mar  3 11:42 install.log
```

结合我们之前所讲解的关于第一个字段中中间9个字符的含义, 每3个为一组, 且均为 'rwx' 3个字符的组合, r(read) 表示可读, w(write) 表示可写, x(execute) 表示可执行, 并且这三个权限的位置不会改变, 始终按照(rwx)方式排列, 如果没有权限,则会出现 '-' 符号. 所以我们可以得出 : 
> 1. 所有者(rw\-) : 可读  可写    不可执行
> 2. 所有组(r\-\-) : 可读  不可写  不可执行
> 3. 其他人(r\-\-) : 可读  不可写  不可执行

但是呢, 这三种权限对于目录和文件来说, 它们所代表的含义不同 :
#### 普通权限对文件的意义
文件是实际存放数据的地方, 包括一般文件, 数据库内容文件, 二进制文件等等.
```bash
r(read)    : 可读取此文件的实际内容, 如读取文本文件的内容等
w(write)   : 可以修改此文件的内容(但是不能删除该文件)
x(execute) : 能够运行一个脚本程序

## 在Windows中是通过扩展名来判断是否可以执行, 如 exe, bat等等
## 在Linux中, 文件能否被执行则由是否有 'x' 权限来决定, 和文件名没有关系
## 具有 'x' 权限只是说明了具有执行的能力, 具体能不能执行还是要看文件本身. 比如一个文本文件, 你给了执行权限, 它也无法执行.
```
#### 普通权限对目录的意义
目录主要的内容是记录文件名, 文件名与目录有关联关系.
```bash
r(read contents of directory)   : 能够读取目录内的文件列表
w(modify contents of directory) : 能够在目录内新增、删除或者重命名文件
x(access directory)             : 是否能够进入该目录
```

#### 总结实验
我们有一个用户 gkdaxue, 它不属于 root 用户组, 那么它对 test 目录有何权限, 能否进入 test 目录
```bash
[root@localhost ~]# ll -d test
drwxr--r--. 2 root root 4096 Mar 25 18:08 test

对于 test 目录而言, gkdaxue 用户属于其它人, 因为他既不是所有者, 也不在所有组里面. 所以他的权限为 r--
所以权限为 : 可以读取此目录的文件列表, 但是却不能进入该目录(因为没有 x 权限).
```

我们有一个 gkdaxue 用户, 他的家目录为 /home/gkdaxue, 目录以及文件权限, 如下所示, 那么 gkdaxue 这个用户能够对文件进行什么操作 ?
```bash
[root@localhost ~]# ls -ld /home/gkdaxue/ ; ls -l /home/gkdaxue/test_permisson.txt 
drwx------. 25 gkdaxue gkdaxue 4096 Mar 25 18:18 /home/gkdaxue/    <== 第一列第一个字符为d,说明是文件夹
-rwx------. 1  root    root    0    Mar 25 18:18 /home/gkdaxue/test_permisson.txt

因为 gkdaxue 目录的拥有者为 gkdaxue(rwx), 并且 test_permisson.txt(---) 在此文件夹中, 
所以他可以删除此文件(即使此文件的拥有者为系统管理员), 但是却没有此文件的读取权限, 
由此说明我们正确的设置权限是多么的重要.
```

### chgrp命令
更改文件或目录所属用户组, **组名可以是 GID 或者 组名, 组名必须在 /etc/group 里存在, 否则就会显示错误, 如果操作用户不是该文件的属主或管理员, 则不能更改该文件的组**.
> chgrp [ options ] DIR_NAME/FILE_NAME ...

#### 选项
| 选项 | 含义 |
| ------------------- | ------------------------ |
| -v | 显示执行过程 |
| -R | 递归处理, 将目录下的所有文件、目录一起处理 |

#### 实例
```bash
## 创建实验环境
[root@localhost ~]# mkdir chgrp_dir{1,2}
[root@localhost ~]# touch chgrp_dir2/test_file{1,2}
[root@localhost ~]# ls -lR
.:
total 8
drwxr-xr-x. 2 root root 4096 Mar 26 09:11 chgrp_dir1
drwxr-xr-x. 2 root root 4096 Mar 26 09:11 chgrp_dir2

./chgrp_dir1:
total 0

./chgrp_dir2:
total 0
-rw-r--r--. 1 root root 0 Mar 26 09:11 test_file1
-rw-r--r--. 1 root root 0 Mar 26 09:11 test_file2

## 查询是否存在 test 用户组, 发现不存在, 然后设置一个不存在的用户组, 报错
[root@localhost ~]# grep test /etc/group
[root@localhost ~]# chgrp test chgrp_dir1
chgrp: invalid group: `test'    <== 找不到此用户组
[root@localhost ~]# ls -ld chgrp_dir1
drwxr-xr-x. 2 root root 4096 Mar 26 09:11 chgrp_dir1

## 添加一个用户, 稍后讲解
[root@localhost ~]# useradd chgrp_user
## 组名为 chgrp_user, 组ID(GID) 为 502
[root@localhost ~]# grep chgrp_user /etc/group
chgrp_user:x:502:

## 使用 GID 设置用户组
[root@localhost ~]# ls -ld chgrp_dir1
drwxr-xr-x. 2 root root 4096 Mar 26 09:11 chgrp_dir1
[root@localhost ~]# chgrp 502 chgrp_dir1
[root@localhost ~]# ls -ld chgrp_dir1
drwxr-xr-x. 2 root chgrp_user 4096 Mar 26 09:11 chgrp_dir1

## 使用组名递归处理
[root@localhost ~]# ls -ld chgrp_dir2 ; ls -l chgrp_dir2
drwxr-xr-x. 2 root root 4096 Mar 26 09:11 chgrp_dir2
-rw-r--r--. 1 root root    0 Mar 26 09:11 test_file1
-rw-r--r--. 1 root root    0 Mar 26 09:11 test_file2
[root@localhost ~]# chgrp -R chgrp_user chgrp_dir2
[root@localhost ~]# ls -ld chgrp_dir2 ; ls -l chgrp_dir2
drwxr-xr-x. 2 root chgrp_user 4096 Mar 26 09:11 chgrp_dir2
-rw-r--r--. 1 root chgrp_user    0 Mar 26 09:11 test_file1
-rw-r--r--. 1 root chgrp_user    0 Mar 26 09:11 test_file2

## 还原实验环境
[root@localhost ~]# rm -rf chgrp*
[root@localhost ~]# userdel -r chgrp_user
```

### chown命令
更改文件的属主和属组信息. 用户必须已经存在于 /etc/passwd 文件中才可以.
> chown [ options ] OWNER FILE...
>
> chown [ options ] OWNER:GROUP FILE ...
>
> chown [ options ] :GROUP FILE ...
>
> 其中的 ' : ' 也可以使用 ' . ' 来替代, 但是不建议, 容易引起歧义

#### 选项
| 选项 | 含义 |
| ------------------- | ------------------------ |
| -R | 递归处理, 将目录下的所有文件、目录一起处理 |

#### 实例
```bash
## 创建实验环境
[root@localhost ~]# mkdir chown_dir1
[root@localhost ~]# touch chown_dir1/test_1
[root@localhost ~]# ls -lR
.:
total 8
drwxr-xr-x. 2 root root 4096 Mar 26 11:26 chown_dir1

./chown_dir1:
-rw-r--r--. 1 root root 0 Mar 26 11:27 test_1

## 查看 gkdaxue 用户, 如果不存在, 请使用 useradd gkdaxue 创建
[root@localhost ~]# id gkdaxue
uid=500(gkdaxue) gid=500(gkdaxue) groups=500(gkdaxue)

## chown OWNERE FILE : 仅改变所有者
[root@localhost ~]# chown gkdaxue chown_dir1
[root@localhost ~]# ls -ld chown_dir1
drwxr-xr-x. 2 root    root 4096 Mar 26 11:26 chown_dir1  <== 改变前, 仅做对比, 实际不存在此行
drwxr-xr-x. 2 gkdaxue root 4096 Mar 26 11:26 chown_dir1  <== 改变后

## chown :GROUP FILE : 仅改变所有组
[root@localhost ~]# chown :gkdaxue chown_dir1
[root@localhost ~]# ls -ld chown_dir1
drwxr-xr-x. 2 gkdaxue    root 4096 Mar 26 11:26 chown_dir1  <== 改变前, 仅做对比, 实际不存在此行
drwxr-xr-x. 2 gkdaxue gkdaxue 4096 Mar 26 11:26 chown_dir1  <== 改变后

##chown OWERE:GROUP FILE : 同时改变所有者和所有组(所属组)
[root@localhost ~]# chown root:root chown_dir1
[root@localhost ~]# ls -ld chown_dir1
drwxr-xr-x. 2 gkdaxue gkdaxue 4096 Mar 26 11:26 chown_dir1  <== 改变前, 仅做对比, 实际不存在此行
drwxr-xr-x. 2    root    root 4096 Mar 26 11:26 chown_dir1  <== 改变后

## -R : 递归改变
[root@localhost ~]# chown -R gkdaxue:gkdaxue chown_dir1
[root@localhost ~]# ls -lR
.:
total 4
drwxr-xr-x. 2 gkdaxue gkdaxue 4096 Mar 26 11:39 chown_dir1

./chown_dir1:
total 0
-rw-r--r--. 1 gkdaxue gkdaxue 0 Mar 26 11:39 test_1

## 清理实验环境
[root@localhost ~]# rm -rf chown_dir1
```

### chmod命令
复习一下我们之前所讲的知识点, 如下所示,  第一个字段的中间9位, 三位为一组, 分别对应 所有者(rw\-) 所有组(r\-\-) 和其他人(r\-\-)的权限, 那么我们如何修改它们的权限呢? 这就要用到我们所说的 chmod 命令. 我们除了可以用 ` r w x `来表示权限外, 也可以用数字来表示各个权限:
> chmod [-R ]  数字|符号类型  FILE 
>
> -R : 递归更改文件权限

```bash
[root@localhost ~]# ls -l install.log
-rw-r--r--. 1 root root 50698 Mar  3 11:42 install.log

我们可以用数字来表示 rwx
r : 4		w : 2		x : 1
所以我们可以得出 install.log 文件的权限为:
所有者(rw-) : 4 + 2 + 0 = 6
所有组(r--) : 4 + 0 + 0 = 4
其他人(r--) : 4 + 0 + 0 = 4  

所以我们只要执行命令 chmod 644 install.log 就可达到相同的权限效果


## 练习题
[root@localhost ~]# ls -al .bashrc 
-rw-r--r--. 1 root root 176 Sep 23  2004 .bashrc
如果我们想要把权限设置为 rw-rw-rw- , 那么我们应该执行什么命令(使用数字表示形式) ?
[root@localhost ~]# chmod 666 .bashrc    
[root@localhost ~]# ls -al .bashrc 
-rw-rw-rw-. 1 root root 176 Sep 23  2004 .bashrc
[root@localhost ~]# chmod 644 .bashrc      # <== 在改回原来的权限
[root@localhost ~]# ls -al .bashrc 
-rw-r--r--. 1 root root 176 Sep 23  2004 .bashrc

```

我们也可以使用 **符号类型** 来改变文件的权限 :
> 所有者(user )  : 用 u 来表示
>
> 所属组(group) : 用 g 来表示
>
> 其他人(other) : 用 o 来表示
>
> 所有身份(all) : 用 a 来表示(表示设置的权限对 以上 3 种都设置)

| 命令 | 用户 | 操作 | 权限 | 对象 |
| :--------: |:---------: |:-------------: | :-------------:  | :-------------:| 
| chmod | u <br> g <br> o <br> a | + (添加) <br> - (取消) <br> = (设置) | r <br> w <br> x | 文件或目录 |

```bash
## 先查看一下创建文件的默认权限
[root@localhost ~]# touch chmod_file.txt
[root@localhost ~]# ls -l chmod_file.txt
-rw-r--r--. 1 root root 0 Mar 26 16:01 chmod_file.txt

## = 绝对权限, 对应用户权限只能为 = 之后的权限
[root@localhost ~]# chmod u=r chmod_file.txt 
[root@localhost ~]# ls -l chmod_file.txt 
-r--r--r--. 1 root root 0 Mar 26 16:04 chmod_file.txt

## + 相对权限, 在原来的基础上加上对应的权限
[root@localhost ~]# chmod g+w,o+x chmod_file.txt 
[root@localhost ~]# ls -l chmod_file.txt 
-r--rw-r-x. 1 root root 0 Mar 26 16:01 chmod_file.txt

## - 相对权限, 在原来的基础上减去对应的权限
[root@localhost ~]# chmod g-w chmod_file.txt 
[root@localhost ~]# ls -l chmod_file.txt 
-r--r--r-x. 1 root root 0 Mar 26 16:01 chmod_file.txt

## 即使用绝对权限, 又使用相对权限
[root@localhost ~]# chmod ug=rw,o+w chmod_file.txt  # <== , 中间没有空格
[root@localhost ~]# ls -l chmod_file.txt 
-rw-rw-rwx. 1 root root 0 Mar 26 16:01 chmod_file.txt
[root@localhost ~]# chmod o-x chmod_file.txt 
[root@localhost ~]# ls -l chmod_file.txt 
-rw-rw-rw-. 1 root root 0 Mar 26 16:01 chmod_file.txt

## a 使用的操作, a可以省略
[root@localhost ~]# chmod +x chmod_file.txt 
[root@localhost ~]# ls -l chmod_file.txt
-rwxrwxrwx. 1 root root 0 Mar 26 16:01 chmod_file.txt
[root@localhost ~]# chmod -x chmod_file.txt 
[root@localhost ~]# ls -l chmod_file.txt
-rw-rw-rw-. 1 root root 0 Mar 26 16:01 chmod_file.txt

## 还原环境
[root@localhost ~]# rm -rf chmod_file.txt

在 + 与 - 的状态下, 如果没有指定到的权限, 那么该权限不会被改动,只会在对应权限上操作
在 = 的状态下, 权限只能拥有 = 之后设置的权限
```

### 总结实验1
在 /tmp下 有一个目录 chmod_test, 该目录下有一个文件 test_file.txt, 系统中存在一个用户 gkdaxue 并且该用户不属于 root 用户组, 然后开始下面的实验, 进一步了解 对于目录 rwx 的含义是什么
```bash
## 查看文件夹默认权限并修改权限
[root@localhost ~]# cd /tmp/
[root@localhost tmp]# mkdir chmod_test
[root@localhost tmp]# ll -d chmod_test
drwxr-xr-x. 2 root root 4096 Mar 26 16:26 chmod_test
[root@localhost tmp]# chmod 744 chmod_test
[root@localhost tmp]# ll -d chmod_test
drwxr--r--. 2 root root 4096 Mar 26 16:26 chmod_test

## 查看文件默认权限并修改权限
[root@localhost tmp]# touch chmod_test/test_file.txt
[root@localhost tmp]# ls -l chmod_test/test_file.txt 
-rw-r--r--. 1 root root 0 Mar 26 16:26 chmod_test/test_file.txt
[root@localhost tmp]# chmod 600 chmod_test/test_file.txt 
[root@localhost tmp]# ls -l chmod_test/test_file.txt 
-rw-------. 1 root root 0 Mar 26 16:26 chmod_test/test_file.txt

## 修改过后, 整体的权限
[root@localhost tmp]# ls -ald chmod_test chmod_test/test_file.txt 
drwxr--r--. 2 root root 4096 Mar 26 16:26 chmod_test
-rw-------. 1 root root    0 Mar 26 16:26 chmod_test/test_file.txt

## 问题一 : 存在一个用户叫做 gkdaxue, 那么这个用户对于 文件夹和文件分别有什么权限?
## 如果不存在此用户, 可以使用 useradd gkdaxue 来添加此用户
[root@localhost tmp]# su - gkdaxue     # <== 切换到 gkdaxue 用户登录
[gkdaxue@localhost ~]$ cd /tmp         # <== 注意现在是 $ 提示符, 而不是 # 了
[gkdaxue@localhost tmp]$ ls -l chmod_test
ls: cannot access chmod_test/test_file.txt: Permission denied   
total 0
-????????? ? ? ? ?            ? test_file.txt  <== 具有 r 权限可以查看文件名, 没有 x 权限, 所以会显示一堆问号.
[gkdaxue@localhost tmp]$ cd chmod_test/
-bash: cd: chmod_test/: Permission denied   <== 因为我们没有 x 权限, 自然无法进入此目录
[gkdaxue@localhost ~]$ exit    <== 退出此用户
logout

## 给与文件夹执行权限 o+x 
[root@localhost tmp]# chmod o+x chmod_test/
[root@localhost tmp]# ls -ld chmod_test/
drwxr--r-x. 2 root root 4096 Mar 26 16:26 chmod_test/
[root@localhost tmp]# su - gkdaxue
[gkdaxue@localhost ~]$ ls -l /tmp/chmod_test/
total 0
-rw----r--. 1 root root 0 Mar 26 16:26 test_file.txt

## 尝试删除 chmod_test 文件夹下文件, 提示没有权限, 因为没有 w 权限
[gkdaxue@localhost ~]$ rm -rf /tmp/chmod_test/test_file.txt
rm: cannot remove `/tmp/chmod_test/test_file.txt': Permission denied
[gkdaxue@localhost ~]$ exit
logout

## 可以自己切换到 root 用户后, 给与 w 权限,尝试删除
[root@localhost tmp]# chmod o+w chmod_test/
[root@localhost tmp]# su - gkdaxue
[gkdaxue@localhost ~]$ ls -ld /tmp/chmod_test/
drwxr--rwx. 2 root root 4096 Mar 26 16:26 /tmp/chmod_test/
[gkdaxue@localhost ~]$ rm -rf /tmp/chmod_test/test_file.txt 
[gkdaxue@localhost ~]$ ls -l /tmp/chmod_test/
total 0
[gkdaxue@localhost ~]$ exit
logout
[root@localhost tmp]# 

实验注意事项 : 
1. 当前是什么用户, 对文件或者文件夹具有什么权限
2. 当前处在什么目录中
3. 命令的组合形式, 比如 ls -l  和  ls -ld 它们的含义是不同的
```

### 总结实验2
在 /tmp 下新建一个目录 chmod_2, 所有者为 gkdaxue, 用户组 users 并且任何人都可以进入到该目录浏览文件, 除了 gkdaxue 之外, 其他人不能修改该目录下的文件.
```bash
mkdir /tmp/chmod_2
chown -R gkdaxue:users /tmp/chmod_2
chmod -R 755 /tmp/chmod_2
```

### umask : 显示或设置模式掩码
umask 命令就是指定目前用户在新建文件或者目录时候的权限默认值. 所以不同的用户 umask 值不同.
 
```bash
[root@localhost ~]# umask
0022      <== 它共有四位数字, 我们先了解后边三位即可, 前边一位稍后讲解
[root@localhost ~]# umask -S
u=rwx,g=rx,o=rx   <== 使用字符显示出来
```

### 默认权限
我们已经讲解了 rwx 权限, 那么我们新建文件或者文件夹默认的权限是什么呢? 这就牵扯到我们说我们所说的 umask 命令.而对于文件和目录, 它们的默认权限是不同的.
```bash
文件 : 一般文件不应该有执行权限, 因为一般文件通常用于记录数据, 所以就不需要执行权限, 所以默认的权限为 666 (-rw-rw-rw-)
目录 : 对于目录来说所有的权限默认均开放, 所以也就是 777 (drwxrwxrwx)
```
**但是 umask 的含义是默认权限应该中应该取消的权限. umask 后三位对应的分别是 u(-0) g(-2) o(-2) 应该减去的权限, 所以我们可以得出文件的实际权限为 :**

| <br> | u (user) | g (group) | o (other) | <br> |u (user) | g (group) | o (other) |
| :--------: |:-----: |:------: | :------:  | :--------:| :-------: |:-------:|:-------:|
| 文件 | rw- | rw-	| rw- | 目录 | rwx | rwx | rwx |
|umask值 | \-\-\- | -w- | -w- | <br> | \-\-\- | -w- | -w- |
|最后权限 | rw- | r\-\- | r\-\- | <br> | rwx | r-x | r-x |

所以可以得出:
> 目录的默认权限为 : rwx  r-x  r-x  = 755
> 
> 文件的默认权限为 : rw-  r\-\-  r\-\-   = 644

```bash
## 验证一下我们之上的理论知识
[root@localhost ~]# touch umask_test.txt
[root@localhost ~]# mkdir umask_test
[root@localhost ~]# ls -ld umask_test umask_test.txt 
drwxr-xr-x. 2 root root 4096 Mar 27 12:12 umask_test
-rw-r--r--. 1 root root    0 Mar 27 12:12 umask_test.txt
```
那么问题来了, 如果我们需要同组的用户编辑文件, 那么我们应该如何操作呢?(使用umask方式)
>首先文件的默认权限为 666, 因为 umask 为 022, 所以导致 g 的权限为 r\-\- , 那么我们如果想要同组用户也能编辑, 那么应该保留 w 权限, 所以导致 umask 的值应该为 002 (rw- 减去 \-\-\- 等于 rw- )

```bash
[root@localhost ~]# umask 002
[root@localhost ~]# touch umask_test2.txt
[root@localhost ~]# ll umask_test2.txt 
-rw-rw-r--. 1 root root 0 Mar 27 12:36 umask_test2.txt
```

#### 练习题
```bash
umask 值为 003 , 那么新建的文件和目录的权限是什么 ? 我们按照之前的分析 : 
文件 : 666 - 003 = 663  => rw-rw--wx
目录 : 777 - 003 = 774  => rwxrwxr--

但是事实真的是这样的吗?

文件:							目录:
	rw-   rw-  rw-					rwx   rwx   rwx
	---   ---  -wx					---   ---   -wx
	rw-   rw-  r--					rwx   rwx   r--

实际结果:
		文件 : rw- rw- r--  => 664
		目录 : rwx rwx r--  => 774	  

我们可以看出, 用数字操作时, 有的时候会出现不准确的结果, 所以推荐使用对应位相减法, 则不会存在问题.
```

### 隐藏权限
| 参数  | 作用                                           |
| --- | -------------------------------------------- |
| i   | 无法对文件进行修改；若对目录设置了该参数，则仅能修改其中的子文件内容而不能新建或删除文件 (仅root可设置) |
| a   | 仅允许补充（追加）内容，无法覆盖/删除内容（Append Only） (仅root可设置)           |
| S   | 文件内容在变更后立即同步到硬盘（sync）                        |
| s   | 彻底从硬盘中删除，不可恢复（用0填充原文件所在硬盘区域）                 |
| A   | 不再修改这个文件或目录的最后访问时间（atime）                    |
| b   | 不再修改文件或目录的存取时间                               |
| u   | 当删除该文件后依然保留其在硬盘中的数据，方便日后恢复                   |

#### chattr命令
设置文件的隐藏属性
> chattr [+-=]\[options]  FILE
>
> \+ : 增加某一项隐藏权限
> 
> \- : 取消某一项隐藏权限
>
> = : 设置仅有的隐藏权限, 其余全部取消

##### 实例
```bash
## 创建实验文件
[root@localhost ~]# touch chattr_test
[root@localhost ~]# rm -rf chattr_test 

## 使用 +a 添加隐藏选项, 无法删除
[root@localhost ~]# touch chattr_test
[root@localhost ~]# chattr +a chattr_test 
[root@localhost ~]# rm -rf chattr_test 
rm: cannot remove `chattr_test': Operation not permitted
```

#### lsattr命令
显示文件的隐藏权限
> lsattr [ options ] FILE

##### 选项
| 参数  | 作用                                           |
| --- | -------------------------------------------- |
| -i   | 将隐藏文件的属性显示出来 |
| -d   | 显示目录本身的属性, 而非目录内的文件名 |
| -R   | 连同子目录的数据也一并列出来 |

##### 实例
```bash
## ls 命令无法查看隐藏权限
[root@localhost ~]# ls -l chattr_test 
-rw-r--r--. 1 root root 0 Apr  1 19:00 chattr_test

## lsattr 可以查看隐藏权限
[root@localhost ~]# lsattr chattr_test 
-----a--------- chattr_test

## 取消隐藏权限
[root@localhost ~]# chattr -a chattr_test 
[root@localhost ~]# lsattr chattr_test 
--------------- chattr_test

## 还原环境, 删除文件
[root@localhost ~]# rm -rf chattr_test
```

### 特殊权限
我们之前讲解了 r w x 权限, 但是我们看下面这些怎么还出现了 s t, 这又是什么东西, 这就是我们所说的特殊权限.
```bash
[root@localhost ~]# ls -ld /tmp; ls -l /usr/bin/passwd
drwxrwxrwt. 14 root root 4096 Apr  2 03:50 /tmp
-rwsr-xr-x. 1 root root 30768 Nov 24  2015 /usr/bin/passwd
```

在复杂多变的生产环境中, 仅仅只靠文件的 rwx 权限有的时候无法满足我们的需求, 所有就有了 SUID、SGID 和 SBIT 的特殊权限位, 用来弥补一般权限不能实现的功能.

#### SUID
SUID 可以让二进制程序的执行者临时拥有属主的权限(注意看注意事项), 所有用户都可以执行 passwd 命令来修改自己的密码, 但是密码信息是被保存在 /etc/shadow 文件中, 这个文件的权限为 000, 只有 root 可以操作, 但是就是因为我们对 passwd 命令设置了 SUID 特殊权限位, 让执行者临时拥有了属主的权限, 所以他就可以执行这个命令了.
```bash
## 查看 passwd 命令所在的路径
[root@localhost ~]# which passwd
/usr/bin/passwd

## 查看 passwd 命令和 /etc/shadow 文件的权限
[root@localhost ~]# ls -l /usr/bin/passwd ; ls -l /etc/shadow
-rwsr-xr-x. 1 root root 30768 Nov 24  2015 /usr/bin/passwd  <== 注意属主的 x -> s
----------. 1 root root 1055 Apr  5 09:04 /etc/shadow
```

注意事项:
> 1. SUID 仅对 **二进制程序** 有效
> 2. **执行者对于该程序需要具备 x 的可执行权限**
> 3. 本权限只是在** 执行该程序的过程中** 有效
> 4. **执行者具有该程序所有者的权限**
> 5. 在设置 SUID 时, 如果程序属主者有 x 权限, 会显示为 s, 没有则会显示为 S .
> 6. 不可针对 shell script 以及目录设置.

##### 实例
```bash
## 我们开启了两个终端, 一个为 root, 一个为 gkdaxue 用户, 实验前请仔细观察执行命令的用户

## 查看 cat 命令以及 /etc/shadow 文件权限
[root@localhost ~]# ll $(which cat) /etc/shadow
-rwxr-xr-x. 1 root root 48568 Mar 23  2017 /bin/cat
----------. 1 root root  1055 Apr  5 16:00 /etc/shadow  <== 只有 root 可以操作

## 拥有者有无 x 权限, 显示的不同
[root@localhost ~]# ll /bin/cat ; chmod -x /bin/cat ; ll /bin/cat
-rwxr-xr-x. 1 root root 48568 Mar 23  2017 /bin/cat
-rw-r--r--. 1 root root 48568 Mar 23  2017 /bin/cat
[root@localhost ~]# ll /bin/cat ; chmod u+s /bin/cat ; ll /bin/cat 
-rw-r--r--. 1 root root 48568 Mar 23  2017 /bin/cat
-rwSr--r--. 1 root root 48568 Mar 23  2017 /bin/cat  <== 无 x 为 S
[root@localhost ~]# ll /bin/cat ; chmod ug+x /bin/cat ; ll /bin/cat
-rwSr--r--. 1 root root 48568 Mar 23  2017 /bin/cat
-rwsr-xr--. 1 root root 48568 Mar 23  2017 /bin/cat  <== 有 x 为 s 

## gkdaxue 查看 /etc/shadow 发现没有权限
[gkdaxue@localhost ~]$ cat /etc/shadow
-bash: /bin/cat: Permission denied     <== 即使赋予了 SUID 特殊权限, 也要求执行者对于命令有 x 权限

[root@localhost ~]# chmod o+x /bin/cat
[root@localhost ~]# ll /bin/cat
-rwsr-xr-x. 1 root root 48568 Mar 23  2017 /bin/cat   <== 给 gkdaxue 用户设置了 x 权限

## 然后在查看, 发现可以查看了, 虽然我们是 gkdaxue 普通用户
[gkdaxue@localhost ~]$ cat /etc/shadow | head -n 5
root:$6$bhfh0f7W$4P.a0DKO....:17967:0:99999:7:::
bin:*:17246:0:99999:7:::
daemon:*:17246:0:99999:7:::
adm:*:17246:0:99999:7:::
lp:*:17246:0:99999:7:::

## 还原设置
[root@localhost ~]# chmod 755 /bin/cat
[root@localhost ~]# ll /bin/cat
-rwxr-xr-x. 1 root root 48568 Mar 23  2017 /bin/cat

[gkdaxue@localhost ~]$ cat /etc/shadow
cat: /etc/shadow: Permission denied

## 由此说明, 我们的 SUID 权限不能随便设置, 否则有可能会导致密码泄露
```
![SUID_Permission](https://github.com/gkdaxue/linux/raw/master/image/chapter_A5_0002.png)

#### SGID
SGID 既可以针对文件也可以针对目录来设置, 这是与 SUID 不同的地方, 主要实现以下两种功能:
> 让执行者临时(运行时)拥有属组的权限(对拥有执行权限的二进制程序进行设置, 参考 SUID )
>
> 让某个目录中创建的文件自动继承该目录的所有组(只可以对目录设置, 不用再单独设置属组信息)

```bash
## locate 命令中 gkdaxue 属于其他人但是有 x 权限, 并且 属组上面有 s, 说明有 SGID, 所以就可以执行此命令 
[gkdaxue@localhost ~]$ ll $(which locate)
-rwx--s--x. 1 root slocate 38464 Mar 12  2015 /usr/bin/locate
[gkdaxue@localhost ~]$ locate man | head -n 2
/etc/man.config
/etc/alternatives/cdda2wav-cdda2wavman

## 自动设置属组信息, 主要用在项目开发中, 所有成员都归属到一个用户组, 这样用户组的每个成员都拥有权限操作,
## 而不用在单独设置每个成员所创建文件的属组信息. 稍后有案例.
```

#### SBIT