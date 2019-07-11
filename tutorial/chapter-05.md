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
> 默认系统上的账号信息会保存在 /etc/passwd 文件中, 密码则会保存在 
> 
>  文件中. 组信息则会保存在 /etc/group 文件中. 

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
记录了 GID 与 组名 的对应关系, 每行代表一个用户组, 以 ":" 来作为字段的分隔符共有四列
```bash
[root@localhost ~]# head -n 4 /etc/group
root:x:0:root
bin:x:1:bin,daemon
daemon:x:2:bin,daemon
sys:x:3:bin,adm

## 我们使用第一行 root 来解释
root:x:0:root
root : 用户组名称
x    : 组密码占位符, 密码已经被移动到 /etc/gshadow 中, 通常给用户组管理员使用
0    : 用户组的 GID 
root : 一个账号可以有多个用户组(用,分割,中间无空格), 本字段可以为空；如果字段为空表示用户组为GID的用户名
```

### /etc/gshadow 文件讲解
```bash
[root@localhost ~]# head -n 4 /etc/gshadow
root:::root
bin:::bin,daemon
daemon:::bin,daemon
sys:::bin,adm

我们使用下列来讲解
root:::root

root	: 用户组名
空		: 密码列, 开头为!表示无合法密码
空   	: 用户组管理员的账号
root    : 该用户组所属的账号

## 用户组的管理员可以将账号加入到自己的用户组中, 现在已经很少使用了
```

### 总结
了解完了 /etc/passwd、/etc/shadow、/etc/group之后, 我们来了解一下 UID/GID 与密码之间的关系, 重点是 /etc/passwd 文件, 其他的相关数据都是根据这个文件的字段去寻找出来的.
![账户密码用户组关联关系](https://github.com/gkdaxue/linux/raw/master/image/chapter_A5_0003.png)

登录时, 根据 root 用户名来找到 UID 和 GID (均为0), 然后在根据 GID 找到组名(root), 在根据用户名找到 密码, 这样就实现了关联起来.

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

所以我们只要执行命令 chmod 644 install.log 就可达到相同的权限效果, 那么分析一下 777 应该是什么样的?
[root@localhost ~]# chmod 777 install.log
[root@localhost ~]# ll install.log
-rwxrwxrwx. 1 root root 50698 Mar  3 11:42 install.log

## 特殊用法, 如果 chmod 的数字为 一个数字, 两个数字 又会有什么样的变化呢?
[root@localhost ~]# chmod 6 install.log
[root@localhost ~]# ll install.log
-------rw-. 1 root root 50698 Mar  3 11:42 install.log  <== 发现被赋值给了 other 用户
[root@localhost ~]# chmod 47 install.log
[root@localhost ~]# ll install.log
----r--rwx. 1 root root 50698 Mar  3 11:42 install.log  <== 4 赋值 group 用户 7 赋值给 other 用户

## 总结, 如果数字不足三位, 相当于在左边补零, 006, 047
[root@localhost ~]# chmod 757 install.log
[root@localhost ~]# ll install.log
-rwxr-xrwx. 1 root root 50698 Mar  3 11:42 install.log
[root@localhost ~]# chmod 47 install.log
[root@localhost ~]# ll install.log
----r--rwx. 1 root root 50698 Mar  3 11:42 install.log

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

## 如果等号后边, 没有跟上权限, 那说明权限为空
[root@localhost ~]# ls -l install.log
-rw-r--r--. 1 root root 50698 Mar  3 11:42 install.log
[root@localhost ~]# chmod ugo= install.log
[root@localhost ~]# ll install.log
----------. 1 root root 50698 Mar  3 11:42 install.log
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
> 3. 本权限只是在 **执行该程序的过程中** 有效
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
SBIT 只针对目录有效, 当用户对目录有 wx 权限时, 即写入的权限时, 如果此目录被设置了 SBIT 权限, 那么只有 **文件所有者**  以及 **root** 还有 **该目录的所有者** 可以删除该文件, 即使其他人有足够的权限, 也无法执行删除操作. 
**当目录被设置 SBIT 特殊权限位后，文件的其他人权限部分的 x 执行权限就会被替换成 t 或者 T ，原本有 x 执行权限则会写成 t，原本没有 x 执行权限则会被写成 T。**

```bash
## 查看一下 /tmp 的权限, 然后创建一个文件, 给与满权限也就是 777
[gkdaxue@localhost ~]$ ll -d /tmp
drwxrwxrwt. 11 root root 4096 Apr  7 03:09 /tmp    <== 注意其他人的权限为 rwt  
[gkdaxue@localhost ~]$ touch /tmp/gkdaxue_file.txt
[gkdaxue@localhost ~]$ chmod 777 /tmp/gkdaxue_file.txt 
[gkdaxue@localhost ~]$ ll /tmp/gkdaxue_file.txt 
-rwxrwxrwx. 1 gkdaxue gkdaxue 0 Apr  7 10:43 /tmp/gkdaxue_file.txt

## 使用另外一个用户来尝试删除目录, useradd rm_test 命令用于添加一个用户 rm_test
## su - rm_test 用于切换到 rm_test 用户
[root@localhost ~]# useradd rm_test
[root@localhost ~]# useradd gkdaxue_test
[root@localhost ~]# su - rm_test
[rm_test@localhost ~]$ cd /tmp
[rm_test@localhost tmp]$ ll gkdaxue_file.txt 
-rwxrwxrwx. 1 gkdaxue gkdaxue 0 Apr  7 10:43 gkdaxue_file.txt
[rm_test@localhost tmp]$ rm -rf gkdaxue_file.txt 
rm: cannot remove `gkdaxue_file.txt': Operation not permitted  <== 即使满权限, 也无法删除该文件
[rm_test@localhost tmp]$ exit
logout


## 然后给与 SUID 尝试删除
[root@localhost ~]# chmod u+s /tmp/gkdaxue_file.txt 
[root@localhost ~]# ll /tmp/gkdaxue_file.txt 
-rwsrwxrwx. 1 gkdaxue gkdaxue 0 Apr  7 10:43 /tmp/gkdaxue_file.txt
[root@localhost ~]# su - rm_test
[rm_test@localhost ~]$ rm -rf /tmp/gkdaxue_file.txt 
rm: cannot remove `/tmp/gkdaxue_file.txt': Operation not permitted  <== 也无法删除


## 验证文件夹目录的所有者也可以删除操作
[root@localhost ~]# mkdir /tmp/sbit_test
[root@localhost ~]# chown rm_test /tmp/sbit_test
[root@localhost ~]# chmod 1777 /tmp/sbit_test/
[root@localhost ~]# ll -d /tmp/sbit_test/
drwxrwxrwt. 2 rm_test root 4096 Mar 12 05:47 /tmp/sbit_test/
## 切换到 root 用户到该目录下创建一个 gkdaxue_user_file 文件
[root@localhost ~]# su - gkdaxue
[gkdaxue@localhost ~]$ touch /tmp/sbit_test/gkdaxue_user_file
[gkdaxue@localhost ~]$ exit
logout
## 在切换到 gkdaxue_test 用户尝试删除, 删除失败
[root@localhost ~]# su - gkdaxue_test
[gkdaxue_test@localhost ~]$ rm -rf /tmp/sbit_test/gkdaxue_user_file 
rm: cannot remove `/tmp/sbit_test/gkdaxue_user_file': Operation not permitted
[gkdaxue_test@localhost ~]$ exit
logout
## rm_test 用户为该目录的所有者, 执行删除操作, 发现删除成功.
[root@localhost ~]# su - rm_test
[rm_test@localhost ~]$ rm -rf /tmp/sbit_test/gkdaxue_user_file 
[rm_test@localhost ~]$ ll
total 0
[rm_test@localhost ~]$ exit
logout
[root@localhost ~]# rm -rf /tmp/sbit_test/
```

#### 总结
我们前边介绍了 SUID, SGID, SBIT 三种特殊权限, 然后那么我们如何配置他们呢?
> SUID : 用 s 或 S 表示 也可以用数字 4 表示 (出现在所有者 x 位置上)
>
> SGID : 用 s 或 S 表示 也可以用数字 2 表示 (出现在所有组 x 位置上)
>
> SBIT : 用 t 或 T 表示 也可以用数字 1 表示 (出现在其他人 x 位置上)
>
> umask 有四位数字, 后三位表示 owner, group, other 权限, 第一位表示的也就是特殊权限

所以我们就可以用 chmod 4755 filename 来设置文件的一般权限以及特殊权限(4 SUID), 也就是 ` chmod [特殊权限]一般权限 FILE `

#### 实例
```bash
[root@localhost ~]# cd /tmp
[root@localhost tmp]# touch permission_test
[root@localhost tmp]# ll permission_test 
-rw-r--r--. 1 root root 0 Apr  7 11:09 permission_test  <== 去掉 umask 之后的默认权限

[root@localhost tmp]# ll permission_test ; chmod 4755 permission_test ; ll permission_test 
-rw-r--r--. 1 root root 0 Apr  7 11:09 permission_test
-rwsr-xr-x. 1 root root 0 Apr  7 11:09 permission_test

[root@localhost tmp]# ll permission_test ; chmod 6755 permission_test ; ll permission_test 
-rwsr-xr-x. 1 root root 0 Apr  7 11:09 permission_test
-rwsr-sr-x. 1 root root 0 Apr  7 11:09 permission_test

[root@localhost tmp]# ll permission_test ; chmod 7666 permission_test ; ll permission_test 
-rwsr-sr-x. 1 root root 0 Apr  7 11:09 permission_test
-rwSrwSrwT. 1 root root 0 Apr  7 11:09 permission_test

[root@localhost tmp]# ll permission_test ; chmod u=rwxs,go=x permission_test ; ll permission_test 
-rwSrwSrwT. 1 root root 0 Apr  7 11:09 permission_test
-rws--x--x. 1 root root 0 Apr  7 11:09 permission_test
```

### ACL访问控制权限
从我们上面的讲解中, 我们可以发现一个问题, 所有的权限都是针对所有者、所有组和其他人的人来设置的, 那么现在问题来了, 有一个人没事总喜欢修改别人的文件, 但是他也是我们小组的成员, 那么我们怎么设置, 让他只能看不能修改呢? 这就需要用到我们所讲的 ACL 权限 来差异化的设置权限.
ACL 就是 Access Control List 的缩写, 主要的目的是为了提供传统 owner、group、other 的 read 、 write、 execute 权限之外的具体权限设置, 可以针对 单一用户、单一文件或目录来设置.

#### getfacl命令
getfacl命令用于显示文件上设置的 ACL 信息
> getfacl FILE_NAME

#### setfacl命令
设置某个文件/目录的访问控制权限.

| 参数  | 作用   |
| --- | -------------------------------------------- |
| -m   | 给文件设置 ACL |
| -R   | 递归(目录)设置 ACL |
| -b   | 删除所有的 ACL |
| -x { u:USERNAME \| g:GROUP_NAME } | 删除特定的 ACL | 
| -d | 设置默认的 ACL 参数, 只对目录有效(该目录新建的文件都会引用该默认值) | 
| -k | 删除默认的 ACL 参数 |
| --set-file=- | 复制其他文件的 acl 权限设置给该文件 |

##### 针对特定用户设置
> setfacl [ options ] { u | g }:[ 用户 | 用户组 ]:权限[,{ u | g }:[ 用户 | 用户组 ]:权限....]  FILE_NAME

```bash
## 在 /var 目录下创建一个 000 权限的文件和目录
[root@localhost ~]# cd /var
[root@localhost var]# mkdir -m 000 acl_test_dir
[root@localhost var]# touch acl_test_file ; chmod 000 acl_test_file
[root@localhost var]# ll -d acl_test*
d---------. 2 root root 4096 Apr 11 16:52 acl_test_dir
----------. 1 root root    0 Apr 11 16:52 acl_test_file

## 说明不存在这个用户, 等会验证用途
[root@localhost var]# id test_gkdaxue
id: test_gkdaxue: No such user

## 给一个不存在的用户设置则会报错, 所以一定要保证该用户存在
[root@localhost var]# setfacl -m u:test_gkdaxue:rwx /var/acl_test_file
setfacl: Option -m: Invalid argument near character 3

## 切换用户 gkdaxue  因为没有权限, 所以会无法写入文件 已经跳转到该目录
[root@localhost var]# su - gkdaxue
[gkdaxue@localhost ~]$ echo 'gkdaxue' > /var/acl_test_file
-bash: /var/acl_test_file: Permission denied
[gkdaxue@localhost ~]$ cd /var/acl_test_dir
-bash: cd: /var/acl_test_dir: Permission denied
[gkdaxue@localhost ~]$ exit
logout

## 给存在的用户 gkdaxue 设置权限
[root@localhost var]# setfacl -m u:gkdaxue:rw /var/acl_test_file
[root@localhost var]# setfacl -Rm u:gkdaxue:rwx /var/acl_test_dir/  # <== 目录不要忘了R选项

## 当无用户列表时, 代表设置该文件所有者
[root@localhost var]# setfacl -m u::rwx acl_test_file 

## 第一列的最后一位由 . => + 说明存在访问控制权限
[root@localhost var]# ll -d /var/acl_test_{dir,file}
d---rwx---+ 2 root root 4096 Apr 11 16:52 /var/acl_test_dir
-rwxrw----+ 1 root root    8 Apr 11 17:34 /var/acl_test_file

## 再次验证
[root@localhost var]# su - gkdaxue
[gkdaxue@localhost ~]$ echo 'gkdaxue' > /var/acl_test_file 
[gkdaxue@localhost ~]$ cd /var/acl_test_dir/
[gkdaxue@localhost acl_test_dir]$ cat ../acl_test_file 
gkdaxue
[gkdaxue@localhost acl_test_dir]$ exit
logout

## 查看 ACL 访问权限
[root@localhost var]# getfacl acl_test_{dir,file}
# file: acl_test_dir
# owner: root
# group: root
user::---         <== 如果没有用户, 默认为拥有者, 拥有者的权限为 000
user:gkdaxue:rwx  <== 而我们设置的用户却有权限
group::---        <== 没有用户组, 默认为属组
mask::rwx
other::---        <== 其他用户没有任何权限

# file: acl_test_file
# owner: root
# group: root
user::rwx         <== 之前为 ---, 因为我们使用 u::rwx 所以变成了 rwx
user:gkdaxue:rw-
group::---
mask::rw-
other::---

## 我们可以同时给多个用户或者用户组设置 acl 权限
setfacl -m u:test1:rwx,u:test2:rw......  FILE_NAME
setfacl -m g:test1:rwx,g:test2:rw......  FILE_NAME
setfacl -m u:test1:rwx,g:test1:rw....... FILE_NAME

## 还可以复制其他文件的 acl --set-file=-  避免了重复设置的麻烦
[root@localhost ~]# touch copy_acl_file{1,2}
[root@localhost ~]# getfacl copy_acl_file{1,2}
# file: copy_acl_file1
# owner: root
# group: root
user::rw-
group::r--
other::r--

# file: copy_acl_file2
# owner: root
# group: root
user::rw-
group::r--
other::r--

[root@localhost ~]# setfacl -m u:gkdaxue:rwx,g:gkdaxue:rwx copy_acl_file1
[root@localhost ~]# getfacl copy_acl_file1
# file: copy_acl_file1
# owner: root
# group: root
user::rw-
user:gkdaxue:rwx
group::r--
group:gkdaxue:rwx
mask::rwx
other::r--

[root@localhost ~]# getfacl copy_acl_file1 | setfacl --set-file=- copy_acl_file2
[root@localhost ~]# getfacl copy_acl_file{1,2}
# file: copy_acl_file1
# owner: root
# group: root
user::rw-
user:gkdaxue:rwx
group::r--
group:gkdaxue:rwx
mask::rwx
other::r--

# file: copy_acl_file2
# owner: root
# group: root
user::rw-
user:gkdaxue:rwx     <== 已经复制过来了
group::r--
group:gkdaxue:rwx    <== 已经复制过来了
mask::rwx
other::r--
```

##### 针对特定用户组的设置
> setfacl [ options ] g:[用户组]:权限  FILE_NAME

```bash
[root@localhost var]# getfacl acl_test_file 
# file: acl_test_file
# owner: root
# group: root
user::rwx
user:gkdaxue:rw-
group::---
mask::rw-
other::---
[root@localhost var]# setfacl -m g:gkdaxue:rwx acl_test_file 
[root@localhost var]# getfacl acl_test_file 
# file: acl_test_file
# owner: root
# group: root
user::rwx
user:gkdaxue:rw-
group::---
group:gkdaxue:rwx   <== 新设置的组权限
mask::rwx
other::---

## 删除所有的 ACL 权限
[root@localhost var]# setfacl -b acl_test_file
[root@localhost var]# getfacl acl_test_file 
# file: acl_test_file
# owner: root
# group: root
user::rwx
group::---
other::---
```

##### 删除特定的 ACL 权限
> -x : 删除特定的 ACL 权限
>
> -b : 删除所有的 ACL 权限

```bash
[root@localhost var]# setfacl -m g:gkdaxue:rwx acl_test_file 
[root@localhost var]# setfacl -m u:gkdaxue:rwx acl_test_file 
[root@localhost var]# getfacl acl_test_file 
# file: acl_test_file
# owner: root
# group: root
user::rwx
user:gkdaxue:rwx
group::---
group:gkdaxue:rwx
mask::rwx    <== 注意这个 mask , 稍后讲解
other::---

[root@localhost var]# setfacl -x u:gkdaxue  acl_test_file 
[root@localhost var]# getfacl acl_test_file 
# file: acl_test_file
# owner: root
# group: root
user::rwx
group::---
group:gkdaxue:rwx
mask::rwx    <== 注意这个 mask , 稍后讲解
other::---
```

#### mask有效权限
我们查看文件或者目录的 ACL 权限时, 会发现出现了 mask 这个东西, 它的意思是用户或组设置的权限必须要存在于 mask 的权限范围内才会生效, 即有效权限( effective permission), **设置了 mask 之后在设置 acl 会导致 mask 失效.**
> setfacl [ options ] m:权限  FILE_NAME

**注意事项 :**
> 除了所有者和其他人, 都会受到 mask 值的影响 mask 决定了他们最高的权限. 为了方便管理, 使用 mask 值时, 建议设置 其他人的权限为空.

```bash
[root@localhost var]# getfacl acl_test_file 
# file: acl_test_file
# owner: root
# group: root
user::rwx
group::---
group:gkdaxue:rwx
mask::rwx
other::---
[root@localhost var]# setfacl -m m:r acl_test_file
[root@localhost var]# getfacl acl_test_file 
# file: acl_test_file
# owner: root
# group: root
user::rwx
group::---
group:gkdaxue:rwx		#effective:r--
mask::r--
other::---

## 然后我们切换到 gkdaxue 用户尝试一下
## 虽然 gkdaxue 用户组拥有 777 权限, 但是有效权限还仅仅只是有 r 权限而已
[root@localhost var]# id gkdaxue
uid=500(gkdaxue) gid=500(gkdaxue) groups=500(gkdaxue)
[root@localhost var]# su - gkdaxue
[gkdaxue@localhost ~]$ echo 'test' > /var/acl_test_file 
-bash: /var/acl_test_file: Permission denied
[gkdaxue@localhost ~]$ cat /var/acl_test_file 
gkdaxue
[gkdaxue@localhost ~]$ exit
logout

## 这样我们就可以使用 mask 来设置最大允许的权限, 避免因为不小心开放了某些不该开放的权限给其他用户或用户组.
```

## 有效用户组(effective group)和初始用户组(initial group)
我们从 /etc/group 文件中可以得出: 一个人可以有多个用户组, 那么实际在运行时, 到底是用哪一个用户组的权限来运行程序或者脚本呢? 我们又该如何来切换用户的用户组呢? 这是一个很重要的问题.
> 在 /etc/passwd 文件中的第四个字段中的 GID 就是用户的初始用户组, 当用户登录系统时, 他就拥有了这个用户组的相关权限. 

```bash
[root@localhost ~]# id gkdaxue
uid=500(gkdaxue) gid=500(gkdaxue) groups=500(gkdaxue)
[root@localhost ~]# usermod -G users gkdaxue
[root@localhost ~]# grep gkdaxue /etc/passwd /etc/group
/etc/passwd:gkdaxue:x:500:500:gkdaxue:/home/gkdaxue:/bin/bash
/etc/group:users:x:100:gkdaxue  <== gkdaxue 用户的附加组
/etc/group:gkdaxue:x:500:       <== gkdaxue 用户的初始用户组 
[root@localhost ~]# id gkdaxue
uid=500(gkdaxue) gid=500(gkdaxue) groups=500(gkdaxue),100(users)

/etc/passwd 文件中, gkdaxue UID=500, GID=500
/etc/group 文件中  GID=500 gkdaxue   GID=100 users

因为 gkdaxue 同时支持 users 以及 gkdaxue 用户组, 所以在执行一般权限时, 针对用户组的部分, 只要是 users 以及
gkdaxue 用户组所拥有的功能, gkdaxue 用户都可以操作. 那么问题来了, 如果我们新建一个文件, 到底是以哪个组作为用户组呢?
```

## groups命令
当用户登录系统是, 可以使用 groups 命令来查看所有支持的用户组.
> groups

```bash
[gkdaxue@localhost ~]$ groups
gkdaxue users

## 我们可以看到 gkdaxue 这个用户属于 gkdaxue 和 users 这两个组, 第一个输出的组即为有效用户组, 也就是 gkdaxue
## 那么我们创建的文件属组也就是 gkdaxue
[gkdaxue@localhost ~]$ touch user_file.txt
[gkdaxue@localhost ~]$ ll user_file.txt 
-rw-rw-r--. 1 gkdaxue gkdaxue 0 Apr 12 18:49 user_file.txt
```

## newgrp命令
我们知道如何查看有效用户组了, 那么我们如何切换呢, 就要使用到我们所说的 newgrp 命令, 你想要切换的用户组必须是此用户已经支持的用户组, 才可以切换.
```bash
[gkdaxue@localhost ~]$ newgrp users
[gkdaxue@localhost ~]$ groups
users gkdaxue     <== 发现用户组的顺序已经改变了, users 变为了有效用户组
[gkdaxue@localhost ~]$ touch user_file2.txt
[gkdaxue@localhost ~]$ ll user_file*
-rw-r--r--. 1 gkdaxue users   0 Apr 12 18:53 user_file2.txt   <== 发现用户组已经改变了
-rw-rw-r--. 1 gkdaxue gkdaxue 0 Apr 12 18:49 user_file.txt

## newgrp 可以更改当前用户的有效用户组, 并且是以一个 shell 来提供的功能. 新的 shell 的有效用户组就是 users.
[gkdaxue@localhost ~]$ groups
users gkdaxue  <==  newgrp 新建的 shell
[gkdaxue@localhost ~]$ exit   # <== 退出 newgrp 新建的 shell, 就可以发现问题 
exit                          
[gkdaxue@localhost ~]$ groups
gkdaxue users  <== 发现有效用户组已经变回原来的 
```

## 总结
> 1. 用户能够进入某目录, 基本权限是什么? ( **至少拥有 x 权限** )
> 2. 用户在某个目录内读取一个文件, 那么基本权限是什么?
> ```bash
> 目录 : 至少拥有 x 权限
> 文件 : 至少拥有 r 权限
> ```
> 3. 用户可以修改一个文件的基本权限是什么?
> ```bash
> 目录 : 至少拥有 x 权限
> 文件 : 至少拥有 r w 权限
> ```
> 4. 让一个用户可以创建一个文件的基本权限是什么?
> ```bash
> 目录 : 至少有用 w x 权限
> ```
> 5. 让用户进入某目录并执行该目录下的某个命令, 基本权限是什么?
> ```bash
> 目录 : 至少拥有 x 权限
> 文件 : 至少拥有 x 权限
> ```

# 用户用户组管理
## hostname命令
设置或者修改主机名
> hostname [ options ]

| 选项 | 作用 |
| :-----: | ----- |
| -f  | 显示 FQDN(全限定域名) |

```bash
[root@localhost ~]# hostname
localhost.localdomain
[root@localhost ~]# hostname -f
localhost
```

## id命令
用来显示用户的 UID, GID 组名等账号属性信息.
> id [USER_NAME]

| 选项 | 作用 |
| ---- | ---- |
| -g | 只显示有效 GID |
| -n | 显示名称, 而不是显示数字 |
| -G | 打印所有组 ID |
| -u | 只显示有效的 UID |

### 实例
```bash
## 默认打印当前用户信息以及上下文
[root@localhost ~]# id
uid=0(root) gid=0(root) groups=0(root) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
[root@localhost ~]# id root
uid=0(root) gid=0(root) groups=0(root)
[root@localhost ~]# id -g root
0
[root@localhost ~]# id -gn root
root
[root@localhost ~]# id -G root
0
[root@localhost ~]# id -Gn root
root
[root@localhost ~]# id -u root
0
[root@localhost ~]# id -un root
root

## 也可以用来判断系统中是否存在这个用户
[root@localhost ~]# id aaaaaa
id: aaaaaa: No such user
```

## finger命令
查看用户账号相关的信息, 大部分都是 /etc/passwd/文件中的内容. 有些系统中没有安装这个软件, 就需要自己手动来安装一下
> finger [USER_NAME]

```bash
## 安装此软件 
[root@localhost ~]# yum install -y finger
.....

[root@localhost ~]# finger root
Login: root       <== 用户账号     	    Name: root         <== /etc/passwd 内第五字段的内容
Directory: /root  <== 用户家目录         Shell: /bin/bash   <== 默认的 shell
On since Sun Mar  3 16:07 (CST) on pts/0 from 192.168.1.11 <== 登录日期 终端 IP地址
No mail.   <== 没有邮件    (/var/spool/mail/USER_NAME 中的邮件数据)
No Plan.   <== 没有计划文档( ~/.plan 文件内容)

## 找出目前登录到系统的用户, 包含终端(tty) 和 登录时间(Login Time)
[root@localhost ~]# finger
Login     Name       Tty      Idle  Login Time   Office     Office Phone
root      root       pts/0          Mar  3 16:07 (192.168.1.11)
```

## useradd命令
useradd 命令用来添加一个用户
> useradd [ options ] USER_NAME

| 选项 | 作用 |
| ---- | ---- |
| -u UID | 使用指定的 UID 来创建用户 (UID 这个用户不能存在, 否则报错) |
| -g GID | 使用指定的 GID 或者组名 来创建账户 (GID 这个用户组必须已经存在) |
| -G GROUP_NAME | 设置 GROUP_NAME 作为 用户的附加组 (附加组必须事先存在, 多个附加组中间用 , 分割) |
| -M | 不要创建用户家目录 (系统账号默认值) |
| -m | 创建用户家目录 (一般账号默认值) |
| -c '备注信息' | 设置账户的备注信息 |
| -d HOME_DIR | 指定 HOME_DIR(绝对路径) 作为用户的家目录而不使用默认值 <br> 如果目录已存在, 则会提示一些信息, 并且缺少从/etc/skel/复制的一些文件 |
| -r | 创建一个系统账号 |
| -s SHELL | 设定用户的默认 SHELL, 如果没有指定, 默认为 /bin/bash |
| -D | 显示创建用户的默认值 |

### 实例
```bash
## 使用默认设置添加一个用户
[root@localhost ~]# grep gkdaxue /etc/{passwd,shadow,group}
/etc/passwd:gkdaxue:x:500:500::/home/gkdaxue:/bin/bash  <== 普通用户的 UID 从 500 开始
/etc/shadow:gkdaxue:!!:17958:0:99999:7:::
/etc/group:gkdaxue:x:500:   <== 会创建一个和用户名一模一样的用户组
[root@localhost ~]# ll /home
total 20
drwx------. 4 gkdaxue gkdaxue  4096 Mar  3 14:53 gkdaxue     <== 默认家目录
drwx------. 2 root    root    16384 Mar  3 11:31 lost+found

## -D : 显示创建用户的默认值, 这些内容怎么来的呢?
[root@localhost ~]# useradd -D
GROUP=100              <== 默认的用户组
HOME=/home             <== 用户家目录默认的位置
INACTIVE=-1            <== 密码失效日, shadow 文件的第七列
EXPIRE=                <== 账号失效日, shadow 文件的第八列
SHELL=/bin/bash        <== 默认的 shell
SKEL=/etc/skel         <== 用户家目录的内容数据参考目录
CREATE_MAIL_SPOOL=yes  <== 是否主动帮助用户创建邮箱
## 其实就是读取了 /etc/default/useradd 配置文件来的
[root@localhost ~]# cat /etc/default/useradd 
# useradd defaults file
GROUP=100
HOME=/home
INACTIVE=-1
EXPIRE=
SHELL=/bin/bash
SKEL=/etc/skel
CREATE_MAIL_SPOOL=yes
```
我们可以简单的总结一下, 系统帮我们做了哪些工作 :
> 1. 在 /etc/passwd 下创建了一行数据, 包含 UID GID 家目录 SHELL 等
> 2. 在 /etc/shadow 下将此账号的密码相关信息写入, 但是没有密码(只有使用 passwd 设置了密码了之后, 才算完成了用户创建的流程)
> 3. 在 /etc/group 下加入一个与账号名称一模一样的组名
> 4. 在 /home 下创建一个与账号同名的目录作为用户家目录且权限为 700

```bash
## 创建一个 uid 为 888 附属组为 gkdaxue 的 gkdaxue 2用户
[root@localhost ~]# useradd -u 888 -G gkdaxue gkdaxue2
[root@localhost ~]# grep gkdaxue2 /etc/{passwd,shadow,group}
/etc/passwd:gkdaxue2:x:888:888::/home/gkdaxue2:/bin/bash   <== UID 为 888
/etc/shadow:gkdaxue2:!!:17958:0:99999:7:::
/etc/group:gkdaxue:x:500:gkdaxue2   <== gkdaxue2 的附属组为 gkdaxue
/etc/group:gkdaxue2:x:888:

## 在创建一个系统用户 -r
[root@localhost ~]# useradd -r gkdaxue_r
[root@localhost ~]# grep gkdaxue_r /etc/{passwd,shadow,group}
/etc/passwd:gkdaxue_r:x:496:493::/home/gkdaxue_r:/bin/bash   <== 系统用户的 UID < 500
/etc/shadow:gkdaxue_r:!!:17958::::::
/etc/group:gkdaxue_r:x:493:
[root@localhost ~]# ll /home
total 24    <== 发现没有对应的用户家目录(系统用户默认不会创建家目录)
drwx------. 4 gkdaxue  gkdaxue   4096 Mar  3 14:53 gkdaxue
drwx------. 4 gkdaxue2 gkdaxue2  4096 Mar  3 15:37 gkdaxue2
drwx------. 2 root     root     16384 Mar  3 11:31 lost+found
```

### useradd 参考文件
#### /etc/default/useradd
```bash
## -D : 显示创建用户的默认值, 这些内容怎么来的呢?
[root@localhost ~]# useradd -D  # <== 内容就是  /etc/default/useradd 文件内容 
GROUP=100              <== 默认的用户组
HOME=/home             <== 用户家目录默认的位置
INACTIVE=-1            <== 密码失效日, shadow 文件的第七列
EXPIRE=                <== 账号失效日, shadow 文件的第八列
SHELL=/bin/bash        <== 默认的 shell
SKEL=/etc/skel         <== 用户家目录的内容数据参考目录(需要从里面复制文件到用户家目录)
CREATE_MAIL_SPOOL=yes  <== 是否主动帮助用户创建邮箱

## 查看 GID 为 100 的用户组
[root@localhost ~]# sort -nt ':' -k 3 /etc/group | grep 100
users:x:100:   <== GID 为 100 的用户组为 users
```
**GID=100 : 让新设置的用户的初始组为 users, 但是在 Centos中, 默认的用户组为与用户名同名的用户组.**
> 私有用户组 : 系统会创建一个和用户名同名的用户组并作为用户的初始用户组, 有 Redhat, Centos 等
>
> 公共用户组 : 以 GID=100 作为新建用户的初始用户组,因此所有账号都属于 users这个用户组, 有 SUSE 等

**INACTIVE=-1 : 密码到期后多长时间还可以使用旧密码登录**
> 0 : 密码过期后立即失效
>
> -1 : 代表密码永远不会失效
>
> 30 : 如果是数字, 比如30, 表示过期30天后才失效

**EXPIRE= : 账号失效日期**
> shadow 文件中的第八个字段, 账号在这个日期后直接失效, 不会考虑密码问题

**SHELL=/bin/bash : 默认使用的 shell 程序文件名**
新建用户默认使用的 shell 程序, 如果一个用户的 shell 被设置为 /sbin/nologin 那么他就无法登录系统, 查看系统中所有的 shell.
```bash
[root@localhost ~]# cat /etc/shells 
/bin/sh
/bin/bash
/sbin/nologin
/bin/dash
/bin/tcsh
/bin/csh
```

**SKEL=/etc/skel : 用户家目录参考目录**
我们可以在用户的家目录中发现一些隐藏文件, 这些文件大部分都是从 /etc/skel 中复制而来, 设置环境变量等内容. 如果自己手动创建用户, 就需要自己手动复制文件到用户的家目录中.
```bash
[root@localhost ~]# ll -A /home/gkdaxue/
total 20
-rw-r--r--. 1 gkaxue gkaxue   18 Mar 23  2017 .bash_logout
-rw-r--r--. 1 gkaxue gkaxue  176 Mar 23  2017 .bash_profile
-rw-r--r--. 1 gkaxue gkaxue  124 Mar 23  2017 .bashrc
drwxr-xr-x. 2 gkaxue gkaxue 4096 Nov 12  2010 .gnome2
drwxr-xr-x. 4 gkaxue gkaxue 4096 Mar  3 11:33 .mozilla
[root@localhost ~]# ll -A /etc/skel/
total 20
-rw-r--r--. 1 root root   18 Mar 23  2017 .bash_logout
-rw-r--r--. 1 root root  176 Mar 23  2017 .bash_profile
-rw-r--r--. 1 root root  124 Mar 23  2017 .bashrc
drwxr-xr-x. 2 root root 4096 Nov 12  2010 .gnome2
drwxr-xr-x. 4 root root 4096 Mar  3 11:33 .mozilla
```

**CREATE_MAIL_SPOOL=yes : 创建用户的 mailbox**
```bash
[root@localhost ~]# ll /var/spool/mail/gkdaxue 
-rw-rw----. 1 gkaxue mail 0 Mar  3 16:16 /var/spool/mail/gkdaxue
```

#### /etc/login.defs
```bash
[root@localhost ~]# grep -v '^#' /etc/login.defs 
MAIL_DIR	/var/spool/mail    <== 用户邮箱的存放地址

PASS_MAX_DAYS	99999          <== /etc/shadow 文件的第五列, 多长时间需要更改密码
PASS_MIN_DAYS	0              <== /etc/shadow 文件的第四列, 不可更改密码天数
PASS_MIN_LEN	5              <== 密码的最小长度, 但是已被 pam 替代, 所以无效
PASS_WARN_AGE	7              <== /etc/shadow 文件的第六列, 过期前警告的天数

UID_MIN			  500          <== 普通用户最小的 UID, UID < 500 的为系统用户
UID_MAX			60000          <== 普通用户能够使用的最大 UID
GID_MIN			  500          <== 普通用户组最小的 GID, GID < 500 的为系统使用
GID_MAX			60000          <== 普通用户组能够使用的最大 GID

CREATE_HOME	yes                <== 在不加 -m 或 -M 时, 是否主动给用户创建家目录

UMASK           077            <== 用户家目录的 umask 值, 所以用户家目录权限为 700

USERGROUPS_ENAB yes            <== 使用 userdel 删除时, 是否会删除初始用户组(没有人隶属这个用户组, 才会删除)

ENCRYPT_METHOD SHA512          <== 用户密码的加密方式

## 所以我们就能理解密码文件中的一些含义
[root@localhost ~]# grep gkdaxue /etc/shadow
gkdaxue:!!:17958:0:99999:7:::
                 0:99999:7
但是我们现在登录使用了 pam 模块来进行校验, 所以 PASS_MIN_LEN 已经失效了 
```
### UID 和 GID的规则
系统中的用户可以分为三种 :
1. 系统管理员 : UID 为 0 的用户, 默认为 root
2. 系统用户 : 0 < UID < 500 的用户 (系统用户默认不能登录系统且没有家目录)
3. 普通用户 : 或者叫做一般用户, 500(UID_MIN) <= UID <= 6000(UID_MAX) 的用户, 默认可以登录系统并且有家目录

> 普通用户 : 系统会默认先找到系统中 UID 最大的值, 如果没有大于或者等于500的, 则 UID 为 500 (UID_MIN) 开始, 否则就设置 UID 为系统中最大的 UID + 1. 比如系统中有一个用户的 UID 为 888, 但是 500-888 之间还有未分配的UID, 那么新建的用户的 UID 为 888 + 1, 不会使用 500-800 之间的 UID
>
> 系统用户 : 会找到比 500 小的最大的那个 UID - 1 作为 UID

### 总结
useradd 在创建 Linux 上的账号时至少会参考到以下文件(包含修改的文件) :
1. /etc/default/useradd
2. /etc/login.defs
3. /etc/skel/*
4. /etc/passwd
5. /etc/shadow
6. /etc/group
7. /etc/gshadow
8. /home/USER_NAME
9. /var/spool/mail/USER_NAME

## chsh命令
就是 change shell 的简写, 就是改变用户的 login shell 的作用
> chsh [ options ] [ USER_NAME ]

| 选项 | 作用 |
| ---- | ---- |
| -l  | 列出系统上目前可用的 shell ( /etc/shells 文件的内容) |
| -s SHELL | 设置修改用户的 shell (绝对路径) |

### 实例
```bash
## 就是查看 /etc/shells 文件的内容
[root@localhost ~]# chsh -l
/bin/sh
/bin/bash
/sbin/nologin   <== 不合法的 shell, 不能登录到系统
/bin/dash
/bin/tcsh
/bin/csh

## 查看 gkdaxue 用户的 shell, 也可以使用 finger 命令
[root@localhost ~]# grep gkdaxue /etc/passwd
gkdaxue:x:500:500::/home/gkdaxue:/bin/bash

## -s 修改 gkdaxue 用户的 shell 为 /sbin/nologin , 将会无法登录系统
[root@localhost ~]# chsh -s /sbin/nologin gkdaxue
Changing shell for gkdaxue.
Shell changed.
[root@localhost ~]# finger gkdaxue | grep Shell
Directory: /home/gkdaxue            	Shell: /sbin/nologin  <== shell 已改变
[root@localhost ~]# su - gkdaxue
This account is currently not available.  <==  尝试切换到 gkdaxue 发现不合法, 无法登录

## 切换到正常的shell /bin/bash 然后尝试登录
[root@localhost ~]# chsh -s /bin/bash gkdaxue
Changing shell for gkdaxue.
Shell changed.
[root@localhost ~]# finger gkdaxue | grep Shell
Directory: /home/gkdaxue            	Shell: /bin/bash  <== shell 已改变
[root@localhost ~]# su - gkdaxue
[gkdaxue@localhost ~]$   <== 成功切换到 gkdaxue 用户

## 普通用户也可以切换自己的 shell, 从下面的权限可以看出
[root@localhost ~]# ll -d $(which chsh)
-rws--x--x. 1 root root 20056 Mar 22  2017 /usr/bin/chsh  <== 拥有者有 rws 权限
```

## usermod命令
如果我们在添加用户的时候设置了错误的信息, 我们就可以通过 usermod 命令来修改或者直接修改对应文件的对应字段信息.
> usermod < options > USER_NAME

| 选项 | 作用 |
| ---- | ----- |
| -c '备注信息' | 修改用户的备注信息 |
| -d HOME_DIR| 修改用户的家目录 |
| -u UID | 更改用户的 UID |
| -g GID | 设置用户的初始用户组 |
| -G GROUP_NAME | 设置用户的附加组 (覆盖之前的附加组) |
| -a | 追加用户的附加组, 不会覆盖之前的附加组 |
| -l NEW_NAME | 修改用户的登录名 |
| -s SHELL | 更改用户的 shell |
| -e "YYYY-MM-DD" | 账号过期日 |
| -f  天数 | 密码过期后宽限时间 |
| -L | 锁定账户, 无法登录系统(就是修改了 /etc/shadow 文件的密码列, 使密码列前边多了一个 !) |
| -U | 解锁账户, 使用户可以登录系统 | 

### 实例
```bash
## 我们来测试一下 -G 以及 -a 的情况
## 新增 三个测试用户组, tmp1 tmp2 tmp3 在增加一个 tmp 用户
[root@localhost ~]# groupadd tmp1
[root@localhost ~]# groupadd tmp2
[root@localhost ~]# groupadd tmp3
[root@localhost ~]# groupadd tmp4
[root@localhost ~]# useradd -G tmp1,tmp2 tmp
[root@localhost ~]# grep '^tmp' /etc/{passwd,group}
/etc/passwd:tmp:x:500:503::/home/tmp:/bin/bash    <== 这是 tmp 用户的信息
/etc/group :tmp1:x:500:tmp                        <== tmp用户的附加组
/etc/group :tmp2:x:501:tmp                        <== tmp用户的附加组
/etc/group :tmp3:x:502:
/etc/group :tmp4:x:504:
/etc/group :tmp:x:503:
## 把  tmp3 也追加进去
[root@localhost ~]# usermod -a -G tmp3 tmp
[root@localhost ~]# grep '^tmp' /etc/{passwd,group}
/etc/passwd:tmp:x:500:503::/home/tmp:/bin/bash
/etc/group :tmp1:x:500:tmp
/etc/group :tmp2:x:501:tmp
/etc/group :tmp3:x:502:tmp                         <== 也成为了 tmp 用户的附加组
/etc/group :tmp4:x:504:
/etc/group :tmp:x:503:
## 然后我们不使用 -a 测试一下, 发现只有一个附加组 tmp4 了
[root@localhost ~]# usermod -G tmp4 tmp
[root@localhost ~]# grep '^tmp' /etc/{passwd,group}
/etc/passwd:tmp:x:500:503::/home/tmp:/bin/bash
/etc/group :tmp1:x:500:
/etc/group :tmp2:x:501:
/etc/group :tmp3:x:502:
/etc/group :tmp4:x:504:tmp
/etc/group :tmp:x:503:


## 查看用户
[root@localhost ~]# grep gkdaxue /etc/passwd
gkdaxue:x:500:500::/home/gkdaxue:/bin/bash

## 修改用户信息并查看
[root@localhost ~]# usermod -u 888 -s /sbin/nologin -l gkdaxue_test gkdaxue
[root@localhost ~]# grep gkdaxue /etc/passwd
gkdaxue_test:x:888:500::/home/gkdaxue:/sbin/nologin

## -f 宽限日  -e 账号失效日
[root@localhost ~]# grep gkdaxue /etc/shadow
gkdaxue_test:!!:17958:0:99999:7:::
[root@localhost ~]# usermod -f 5 -e '2019-05-20' gkdaxue_test
[root@localhost ~]# grep gkdaxue /etc/shadow
gkdaxue_test:!!:17958:0:99999:7:5:18036:

## -L -U 锁定和解锁账户, 必须先设置一个密码, 才能看出来区别
root@localhost ~]# grep gkdaxue /etc/shadow
gkdaxue_test:!!:17958:0:99999:7:5:18036:
[root@localhost ~]# passwd gkdaxue_test
Changing password for user gkdaxue_test.
New password: 
BAD PASSWORD: it is too short
BAD PASSWORD: is too simple
Retype new password: 
passwd: all authentication tokens updated successfully.
[root@localhost ~]# grep gkdaxue_test /etc/shadow
gkdaxue_test:$6$japdiOWm$kg1jBy/LLdJS98MUvZusRhPc4rMap.1LDlghJ2J.F..:17958:0:99999:7:5:18036:
[root@localhost ~]# usermod -L gkdaxue_test
## 锁定账户, 发现只有密码列前边多了一个 ! 导致按照加密规则不能计算出来密码, 相当于锁定了账户
[root@localhost ~]# grep gkdaxue_test /etc/shadow
gkdaxue_test:!$6$japdiOWm$kg1jBy/LLdJS98MUvZusRhPc4rMap.1LDlghJ2J.F.:17958:0:99999:7:5:18036:
[root@localhost ~]# usermod -U gkdaxue_test
[root@localhost ~]# grep gkdaxue_test /etc/shadow
gkdaxue_test:$6$japdiOWm$kg1jBy/LLdJS98MUvZusRhPc4rMap.1LDlghJ2J.F..:17958:0:99999:7:5:18036:
```

## userdel命令
删除用户的相关数据, 包含 /etc/passwd, /etc/shadow, /etc/group, /etc/gshadow, /home/USER_NAME, /var/spool/mail/USER_NAME 等
**删除用户时, 默认不会删除用户的家目录, 如果想要删除用户的家目录, 需要使用 -r 选项**
> userdel [ -r ] USER_NAME

| 选项 | 作用 |
| --- |--- |
| -r | 连同用户家目录一起删除 |

### 实例
```bash
## -r 连同用户家目录一起删除
[root@localhost ~]# userdel -r gkdaxue2

## 如果真的想要删除该用户所有的数据, 应该先找到属于该用户的所有文件, 然后在执行 userdel 操作
## 因为该用户已经在系统上操作了一段时间, 那么肯定会有其他的文件存在. 比如 /var/spool/mail/USER_NAME
find / -user USER_NAME 
userdel -r USER_NAME
```

## passwd命令
默认我们创建好用户之后, 还需要为用户设置好密码之后, 用户才可以正常的使用该账户. 否则默认是被锁定的状态, 无法登录.
> passwd [ options ] [ USER_NAME ]

| 选项 | 作用 |
| ---- | ---- |
| --stdin USERNAME | 接受前一个管道的数据, 作为密码输入, 在 shell script 中使用 |
| -l | 锁定该用户 (密码列前边有两个 !!) |
| -u | 解锁该用户 |
| -S USER_NAME | 显示密码相关参数 |
| -n 天数 | 不可更改密码日期 (/etc/shadow 第4字段) |
| -x 天数 | 密码最长使用时间 (/etc/shadow 第5字段) |
| -w 天数 | 密码过期前的警告日期 (/etc/shadow 第6字段) |
| -i 天数 | 密码延长使用时间 (/etc/shadow 第7字段) |
| -d USER_NAME | 删除用户的密码 | 

### 实例
```bash
## 没有用户, 默认为当前登录用户设置密码
[root@localhost ~]# passwd
Changing password for user root.
New password:      <== 输入新的密码
BAD PASSWORD: it is too short 
BAD PASSWORD: is too simple
Retype new password:    <==再次输入新的密码
passwd: all authentication tokens updated successfully.   <== 提示成功修改密码

## 使用 --stdin 给用户设置密码, 必须指明用户
[root@localhost ~]# echo 'root' | passwd --stdin root
Changing password for user root.
passwd: all authentication tokens updated successfully.

## 设置一系列参数, 尝试理解一下
[root@localhost ~]# grep gkdaxue /etc/shadow
gkdaxue:$6$japdiOWm$kg1jBy/LLdJS98MUvZusRhPc4rMap.1LDlghJ2J.F....:17958:0:99999:7:5:18036:
[root@localhost ~]# passwd -n 10 -x 20 -w 5 -i 7  gkdaxue
Adjusting aging data for user gkdaxue.
passwd: Success
[root@localhost ~]# grep gkdaxue /etc/shadow
gkdaxue:$6$japdiOWm$kg1jBy/LLdJS98MUvZusRhPc4rMap.1LDlghJ2J.F....:17958:10:20:5:7:18036:

## 锁定解锁账户, 密码列有两个 !!
[root@localhost ~]# passwd -l gkdaxue
Locking password for user gkdaxue.
passwd: Success
[root@localhost ~]# grep gkdaxue /etc/shadow
gkdaxue:!!$6$japdiOWm$kg1jBy/LLdJS98MUvZusRhPc4rMap.1LDlghJ2J.F....:17958:10:20:5:7:18036:
[root@localhost ~]# passwd -u gkdaxue
Unlocking password for user gkdaxue.
passwd: Success
[root@localhost ~]# grep gkdaxue /etc/shadow
gkdaxue:$6$japdiOWm$kg1jBy/LLdJS98MUvZusRhPc4rMap.1LDlghJ2J.F....:17958:10:20:5:7:18036:

## 切换到普通用户, 尝试修改密码
[root@localhost ~]# su - gkdaxue
[gkdaxue@localhost ~]$ passwd
Changing password for user gkdaxue.
Changing password for gkdaxue.
(current) UNIX password: 
You must wait longer to change your password
passwd: Authentication token manipulation error  <== 为什么会报错, 想一下

## 因为我们今天杠杆设置了密码, 然后有设置了 5 天之内不能更改密码, 导致的问题
[gkdaxue@localhost ~]$ exit
logout
[root@localhost ~]# passwd -n 0 gkdaxue  # <== 0 表示随时都可以修改密码
Adjusting aging data for user gkdaxue.
passwd: Success

## 重新尝试一下
[root@localhost ~]# su - gkdaxue
[gkdaxue@localhost ~]$ passwd
Changing password for user gkdaxue.
Changing password for gkdaxue.
(current) UNIX password:       <== 输入当前用户密码
New password:                  <== 输入新密码
BAD PASSWORD: it is too short  <== 提示密码太短
New password:                  <== 输入新密码
Retype new password:           <== 再输入一次密码
passwd: all authentication tokens updated successfully.  <== 设置密码成功
[gkdaxue@localhost ~]$ exit
logout

## -S 详细信息讲解
[root@localhost ~]# passwd -S gkdaxue
gkdaxue PS 2019-03-03 0 20 5 7 (Password set, SHA512 crypt.)

密码新建时间 (2019-03-03)
不可更改密码 (0)
密码最长使用 (20)
密码警告日期 (5)
密码延长日期 (7)
Password set, SHA512 crypt : 密码已经设置, 使用了 SHA512 加密方式加密密码

## 删除用户密码
[root@localhost ~]# passwd -d gkdaxue
Removing password for user gkdaxue.
passwd: Success
[root@localhost ~]# passwd -S gkdaxue
gkdaxue NP 2019-03-03 0 20 5 7 (Empty password.)
```
**root 设置自己的密码或者普通用户的密码, 不需要输入密码, 如果普通用户想要修改自己的密码, 则需要输入当前密码.**

## chage命令
我们在看用户密码文件的对应信息时,  有些数字比较不容易看出是什么时间, 比如 17958, 不计算鬼知道是哪一天, 所以这个时候就需要用到 chage 命令了
> chage [ options ] USER_NAME

| 选项 | 作用 |
| ---- | ---- |
| -l | 列出该账户的相信信息 |
| -d "YYYY-MM-DD" | 修改密码的最后一次修改时间 (/etc/shadow 第三字段) |
| -m 天数 | 不可更改密码时间 (/etc/shadow 第四字段) |
| -M 天数 | 最长使用时间 (/etc/shadow 第五字段) |
| -W 天数 | 密码过期前警告日期 (/etc/shasow 第六字段) |
| -I 天数 | 密码失效日 (/etc/shadow 第七字段) |
| -E "YYYY-MM-DD" | 账号的有效期 (/etc/shadow 第八字段) |

### 实例
```bash
## 密码刚被我们清除, 但是设置密码的时间却保留下来了
[root@localhost ~]# grep gkdaxue /etc/shadow
gkdaxue:.......:17958:1:20:5:7:18036:

## -l 列出账号的相信信息
[root@localhost ~]# chage -l gkdaxue
Last password change				: Mar 03, 2019    <== 最后一次设置密码的时间
Password expires					: Mar 23, 2019    <== 密码有效时间 03 + 20 = 23
Password inactive					: Mar 30, 2019    <== 密码失效时间 23 + 7 = 30
Account expires						: May 20, 2019    <== 账号失效日
Minimum number of days between password change		: 1   <== 不可更改日期
Maximum number of days between password change		: 20  <== 密码最长时间时间
Number of days of warning before password expires	: 5   <== 密码到期前提醒时间
```
**如果想让用户在第一次登录时, 强制修改它们的密码之后才能正常使用系统, 就可以使用如下方式处理 :**
```bash
useradd gkdaxue_test
echo 'root' | passwd --stdin gkdaxue_test
chage -d 0 gkdaxue_test

## 然后当用户登录时, 便会强制要求用户修改密码之后才可以操作系统
```

## groupadd命令
新增一个用户组
> groupadd [ options ] GROUP_NAME

| 选项 | 作用 |
| ---- | --- |
| -g GID | 指定 GROUP_NAME 的 GID |
| -r | 创建系统用户组 |

### 实例
```bash
## 如果默认添加用户组, 默认 GID 为 最大的 GID + 1 (/etc/login.defs)
[root@localhost ~]# groupadd -g 999 user1
[root@localhost ~]# grep user1 /etc/group
user1:x:999:
[root@localhost ~]# grep user1 /etc/gshadow
user1:!::
```

## gpasswd命令
可以让一个用户成为某个组的管理员, 这样用户组管理员就可以管理哪些账号可以 加入/移除 该用户组.
> gpasswd GROUP_NAME : 给组设置密码
>
> gpasswd [ options ] GROUP_NAME

| 选项 | 作用 |
|----|----|
| -A USER_NAME | 将 USER_NAME 设置为 GROUP_NAME 的管理员 |
| -M USER_NAME[,USER_NAME...] | 将这些用户加入到用户组中 |
| -r | 删除用户组密码 (密码字段为空) |
| -R | 让组密码失效 (密码字段为 ! ) |
| -a USER_NAME | 将用户加入到 GROUP_NAME 用户组中 |
| -d USER_NAME | 将用户从 GROUP_NAME 用户组中移除 |

```bash
[root@localhost ~]# grep user1 /etc/{group,gshadow}
/etc/group:user1:x:999:
/etc/gshadow:user1:!::
[root@localhost ~]# gpasswd user1
Changing the password for group user1
New Password: 
Re-enter new password: 
[root@localhost ~]# grep user1 /etc/{group,gshadow}
/etc/group:user1:x:999:
/etc/gshadow:user1:$6$hH8Tt/LCWCTZ$O6ymk2RGp.............::

## 查看一下文件内容, 现在有两个用户组, 一个用户 gkdaxue, 现在我想让 gkdaxue 成为 user_test 组的管理员
[root@localhost ~]# tail -n 2 /etc/{group,gshadow}
==> /etc/group <==
gkdaxue:x:500:
user_test:x:888:

==> /etc/gshadow <==
gkdaxue:!::
user_test:$6$hH8Tt/LCWCTZ$O6ymk2RGp/B.MIDHoxkgrQahqK2UtQ1lo.X8PAY4DFypOWlnCM.....::
[root@localhost ~]# tail -n 1 /etc/passwd
gkdaxue:x:888:500::/home/gkdaxue:/bin/bash

## 把 user_test 用户组的管理员设置为 gkdaxue
[root@localhost ~]# gpasswd -A gkdaxue user_test
[root@localhost ~]# tail -n 2 /etc/{group,gshadow}
==> /etc/group <==
gkdaxue:x:500:
user_test:x:888:

==> /etc/gshadow <==
gkdaxue:!::
user_test:$6$hH8Tt/LCWCTZ$O6ymk2RGp/B.MIDHoxkgrQahqK2UtQ1lo.X8PAY4DFypOWlnCM....:gkdaxue:

```

## groupmod命令
修改用户组的相关信息
> groupmod [ options ] GROUP_NAME

| 选项 | 作用 |
| ---- | ---- |
| -g GID | 修改用户组的 GID |
| -n NEW_GROUP_NAME | 修改用户组的组名 |

### 实例
```bash
## 虽然我们能修改 GID, 但是不建议随便修改
[root@localhost ~]# groupmod -g 888 -n user_test user1
[root@localhost ~]# grep 'user_test' /etc/group
user_test:x:888:
```

## groupdel命令
删除用户组, 如果有某个账号的初始用户组为该用户组, 则不能删除.
> groupdel  GROUP_NAME

```bash
## 查看 gkdaxue 的用户组
[root@localhost ~]# id gkdaxue
uid=888(gkdaxue) gid=500(gkdaxue) groups=500(gkdaxue)
[root@localhost ~]# grep gkdaxue /etc/{passwd,group}
/etc/passwd:gkdaxue:x:888:500::/home/gkdaxue:/bin/bash
/etc/group:gkdaxue:x:500:

## 尝试删除
[root@localhost ~]# groupdel gkdaxue
groupdel: cannot remove the primary group of user 'gkdaxue'  <== 不能删除

## 我们尝试修改, gkdaxue 的基本用户组为 user_test, 附加组为 gkdaxue
[root@localhost ~]# usermod -g user_test -G gkdaxue gkdaxue
[root@localhost ~]# id gkdaxue
uid=888(gkdaxue) gid=888(user_test) groups=888(user_test),500(gkdaxue)

## 然后在尝试删除 gkdaxue 用户组, 查看是否可以
[root@localhost ~]# groupdel gkdaxue
[root@localhost ~]# id gkdaxue
uid=888(gkdaxue) gid=888(user_test) groups=888(user_test)  <== 发现可以删除

## 如果一个用户组没有被用户当做初始用户组(基本组), 那么该用户组可以删除, 即使被其他用户作为附加组.
```

## 用户身份切换
从之前的案例我们知道, 管理员 root 的权限很大, 如果操作失误, 会导致灾难性的后果. 所以有些公司会要求不能使用 root 管理员来登录系统, 但是我们有些操作只有 root 可以操作, 那么应该怎么处理呢? 这就要用到我们所说的切换用户身份了.

### su
su 是最简单的切换命令了, 但是 su 切换到 root 用户时, 是需要输入 root 用户的密码的, 所以想要使用 su 命令切换到 root 用户, 前提是必须拥有 root 密码, 但是如果大家都知道了 root 密码, 这个好像又有点不安全, 比如某个人切换到 root 执行了爆炸性的命令 rm -rf /* , 谁知道是哪个人上去操作的.
> su [options] [USERNAME]

| 选项 | 作用 |
| ---- | ---- |
| - | 使用 login shell(环境变量完全切换) |
| -c 'COMMAND' | 切换到 root 用户, 执行一次命令 |

su 切换用户会有两种情况, 如果输入 su 命令, 默认切换到 root 用户, 当然也可以切换到其他用户
> 1. su - root : 表明使用 login shell 的流程 , 环境变量全部切换
> 2. su root   : 表明使用 non-login shell 的流程, 很多环境变量不会被改变 

#### 实例
```bash
## 默认切换到 root, 需要输入 root 密码
[gkdaxue@localhost ~]$ su - 
Password: 
[root@localhost ~]# exit   <== 退出 su 的环境
logout

## 使用 su root 切换
[gkdaxue@localhost ~]$ su root
Password:               <== 输入 root 密码
[root@localhost gkdaxue]# env
HOSTNAME=localhost.localdomain
SELINUX_ROLE_REQUESTED=
SHELL=/bin/bash
TERM=xterm
HISTSIZE=1000
SSH_CLIENT=192.168.1.11 2984 22
SELINUX_USE_CURRENT_RANGE=
QTDIR=/usr/lib64/qt-3.3
QTINC=/usr/lib64/qt-3.3/include
SSH_TTY=/dev/pts/1
USER=gkdaxue                 <== 还是原来用户
PATH=/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/gkdaxue/bin
MAIL=/var/spool/mail/gkdaxue <== 还是原来用户
PWD=/home/gkdaxue            <== 还是原来用户
LANG=en_US.UTF-8
SELINUX_LEVEL_REQUESTED=
HISTCONTROL=ignoredups
SSH_ASKPASS=/usr/libexec/openssh/gnome-ssh-askpass
HOME=/root
SHLVL=2
LOGNAME=gkdaxue             <== 还是原来用户
CVS_RSH=ssh
QTLIB=/usr/lib64/qt-3.3/lib
SSH_CONNECTION=192.168.1.11 2984 192.168.1.206 22
LESSOPEN=||/usr/bin/lesspipe.sh %s
G_BROKEN_FILENAMES=1
_=/bin/env
[root@localhost gkdaxue]# exit
exit

[gkdaxue@localhost ~]$ su - root
Password:                       <== 输入 root 密码
[root@localhost ~]# env
HOSTNAME=localhost.localdomain
SHELL=/bin/bash
TERM=xterm
HISTSIZE=1000
QTDIR=/usr/lib64/qt-3.3
QTINC=/usr/lib64/qt-3.3/include
USER=root                    <== 完全切换到 root 用户
MAIL=/var/spool/mail/root    <== 完全切换到 root 用户
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
PWD=/root                    <== 完全切换到 root 用户
LANG=en_US.UTF-8
SSH_ASKPASS=/usr/libexec/openssh/gnome-ssh-askpass
HISTCONTROL=ignoredups
SHLVL=1
HOME=/root                  <== 完全切换到 root 用户
LOGNAME=root                <== 完全切换到 root 用户
QTLIB=/usr/lib64/qt-3.3/lib
CVS_RSH=ssh
LESSOPEN=||/usr/bin/lesspipe.sh %s
G_BROKEN_FILENAMES=1
_=/bin/env

## -c 执行一次命令, 默认不能读取该文件. 只有 root 可以读取, 切换 root 后可读取.
[gkdaxue@localhost ~]$ ll /etc/shadow
----------. 1 root root 1026 Mar  7 15:07 /etc/shadow
[gkdaxue@localhost ~]$ cat /etc/shadow
cat: /etc/shadow: Permission denied
[gkdaxue@localhost ~]$ su -c 'cat /etc/shadow' - root
Password:      <== 输入 root 密码
root:$6$NnsNsHED$wTz2roXulfYEXmCGNU4B4lRxVDbCMfEipW1dBdLmE7IS3/:17962:0:99999:7:::
bin:*:17246:0:99999:7:::
daemon:*:17246:0:99999:7:::
adm:*:17246:0:99999:7:::
lp:*:17246:0:99999:7:::
sync:*:17246:0:99999:7:::
shutdown:*:17246:0:99999:7:::
halt:*:17246:0:99999:7:::
mail:*:17246:0:99999:7:::
uucp:*:17246:0:99999:7:::
............
```

#### 总结
> 1. 想要完整的切换新用户的环境, 使用 'su - USERNAME'
> 2. 如果只想要执行一次 root 的命令, 可以使用 -c 选项

### sudo命令
如果想要以 sudo命令 来执行 root 的命令串, 我们需要事先设置 sudo, 然后切换用户时需要输入当前用户自己的密码也可以设置为不需要密码, 这样就可以避免 root 的密码外流. **sudo可以让你以其他用户的身份执行命令(通常是root)**. 只有 /etc/sudoers 内的用户才可以使用 sudo 命令. 系统默认仅有 root 用户可以执行 sudo, 所以需要先使用 root 用户身份执行.
> sudo [ options ]

| 选项 | 作用 |
| ---- | ---- |
| -u USER_NAME | 要切换到 USER_NAME, 如果没有此选项, 则代表切换到 root |
| -b | 将要执行的指令放在后台执行 |

**sudo执行流程**
> 1. **当用户执行 sudo 时, 会去查询 /etc/sudoers 文件内查找该用户是否具有执行 sudo 的权限**
> 2. 当用户具有 sudo 可执行权限后, 让用户输入自己的密码来确认
> 3. 密码匹配成功后, 便开始执行 sudo 命令后接的命令(root 执行 sudo 不需要输入密码)
> 4. 如果想要切换的用户和执行者身份相同, 也不需要输入密码

#### 实例
```bash
## 切换到 gkdaxue ,然后创建一个 /tmp/gkdaxue.txt 文件
[root@localhost ~]# sudo -u gkdaxue  touch gkdaxue.txt  
touch: cannot touch `gkdaxue.txt': Permission denied       <== 想一下, 为什么没有权限
[root@localhost ~]# sudo -u gkdaxue touch /tmp/gkdaxue
[root@localhost ~]# ll /tmp/gkdaxue
-rw-r--r--. 1 gkdaxue gkdaxue 0 Mar  7 16:10 /tmp/gkdaxue  <== 为什么这里可以, 注意看 user, group

## sh -c '一串命令' : 来执行一串命令
[root@localhost ~]# sudo -u gkdaxue sh -c "mkdir ~/www; cd ~/www; \
> echo 'this is gkdaxue www directory conteent' > index.html "
[root@localhost ~]# tree /home/gkdaxue/
/home/gkdaxue/
└── www
    └── index.html

1 directory, 1 file
[root@localhost ~]# cat /home/gkdaxue/www/index.html 
this is gkdaxue www directory conteent

## 然后我们使用 gkdaxue 用户, 尝试使用 sudo 命令 切换到 root 用户
[gkdaxue@localhost ~]$ sudo cat /etc/shadow

We trust you have received the usual lecture from the local System
Administrator. It usually boils down to these three things:

    #1) Respect the privacy of others.           <== 提醒警告
    #2) Think before you type.
    #3) With great power comes great responsibility.

[sudo] password for gkdaxue:          <== 输入 gkdaxue 用户的密码
gkdaxue is not in the sudoers file.  This incident will be reported.  <== 提示不在 sudoers 文件中.
```

### visudo 和 /etc/sudoers
我们知道了能否使用 sudo 要看 /etc/sudoers 的设置值, 当然我们也可以直接编辑该文件, 但是该文件的内容是有一定规定的, 如果设置错误会导致无法使用 sudo 命令, 所以我们可以使用 visudo 命令来编辑. 因为使用 visudo 修改结束离开时, 系统会去检查 /etc/sudoers 的语法.  除了 root 之外, 如果想要让其他账户使用 sudo 执行属于 root 的命令, 那么就需要 root 用户先去使用 visudo 命令修改 /etc/sudoers 文件, 让其他用户使用 全部/部分 root 的命令. 其实 visudo 就是利用 vi 编辑器将 /etc/sudoers 文件调出来进行修改而已. 

#### /etc/sudoers 文件语法
```bash
[root@localhost ~]# cat -n /etc/sudoers
....省略....
90	## Allow root to run any commands anywhere 
  用户账号  登录者的来源主机名=(可切换的身份)   可执行的命令
91	root	            ALL=(ALL) 	           ALL    <== 这里加大了空格间距,这是默认的值
....省略....

用户账号          : 系统的哪个账户可以使用 sudo 这个命令
登录者的来源主机名 : 这个账号由哪台主机连接到本机, 可以指定客户端计算机
可切换的身份		 : 这个账号可以切换成什么身份来执行后续的命令
可执行的命令		 : 可以执行的命令(必须使用绝对路径, 可以使用 which 命令查看) 
ALL              : 特殊关键字, 表示任何身份 主机 命令的意思.

```

#### 针对单一用户设置
我们想让 gkdaxue 用户来使用 root 的任何命令, 那么我们就可以这么操作.
```bash
## 这里先了解即可, 因为还没有学 vim 编辑器, 下面一章开始讲解.
[gkdaxue@localhost ~]$ ll /etc/shadow
----------. 1 root root 1026 Mar  7 15:07 /etc/shadow
[gkdaxue@localhost ~]$ sudo cat /etc/shadow
gkdaxue is not in the sudoers file.  This incident will be reported.  <== 没有添加, 不能使用

## 此处使用 root 用户, 添加一个后续实验用户
[root@localhost ~]# useradd test_user
[root@localhost ~]# visudo
....省略....
## Allow root to run any commands anywhere
root    ALL=(ALL)       ALL
gkdaxue ALL=(ALL)       ALL      ## <== 添加此行
....省略....

## 然后发现 gkdaxue 用户可以正常访问了.
[gkdaxue@localhost ~]$ sudo cat /etc/shadow | head -n 5
[sudo] password for gkdaxue:     <== 输入 gkdaxue 用户的密码
root:$6$NnsNsHED$wTz2roXulfYEXmCGNU4B4lRxVDbCqcFVI9b99bS3/:17962:0:99999:7:::
bin:*:17246:0:99999:7:::
daemon:*:17246:0:99999:7:::
adm:*:17246:0:99999:7:::
lp:*:17246:0:99999:7:::

## 再次执行, 发现没有要求输入当前用户密码
## 如果两次 sudo 的间隔超过 5 分钟, 那么系统会要求你输入密码, 否则不要求输入密码.
[gkdaxue@localhost ~]$ sudo cat /etc/shadow | head -n 5
root:$6$NnsNsHED$wTz2roXulfYEXmCGNU4B4lRxVDbCqcFVI9b99bS3/:17962:0:99999:7:::
bin:*:17246:0:99999:7:::
daemon:*:17246:0:99999:7:::
adm:*:17246:0:99999:7:::
lp:*:17246:0:99999:7:::

## 然后我们发现, 这样给的权限太大了, 我们只想要他帮助我们修改其他用户的密码
[root@localhost ~]# visudo
....省略....
## Allow root to run any commands anywhere
root    ALL=(ALL)       ALL
gkdaxue ALL=(root)      NOPASSWD: /usr/bin/passwd   ## <== 修改如下, 命令的绝对路径, 请仔细查看此行和之前对比.
....省略....

## 我已经超过 5 分钟后才执行的这个命令, 心细的朋友不知道有没有发现一个以下代码的一个问题
## 他竟然没有要我输入当前用户的密码, 所以这就是 NOPASSWD 关键字的作用. 免除密码输入.
[gkdaxue@localhost ~]$ sudo passwd test_user   
Changing password for user test_user.
New password: 
BAD PASSWORD: it is too short
BAD PASSWORD: is too simple
Retype new password: 
passwd: all authentication tokens updated successfully.  <== 设置成功, 说明没有问题.

## 我们尝试切换到 test_user, 去创建一个文件, 结果不行, 想一下原因
## 因为我们没有设置 gkdaxue 用户可以切换为 test_user 用户, 所以自然不行.
[gkdaxue@localhost ~]$ sudo -u test_user mkdir /tmp/test_user.txt
Sorry, user gkdaxue is not allowed to execute '/bin/mkdir /tmp/test_user.txt' as test_user on localhost.localdomain.

## 如果我们想要设置除了不可以使用 /usr/bin/passwd 之外, 可以使用 root 的任何命令.
## 那么我们只要在对应的命令前边加上 !/usr/bin/passwd,!/usr/bin/passwd root 即可.

## 我们可以针对不同的用户设置不同的可执行命令, 保障系统的安全.
```

那么问题又来了, 来一个用户我就要这么设置一次, 这也太麻烦了吧, 所以我们也可以利用用户组的来操作.

#### 针对用户组设置
```bash
[root@localhost ~]# cat -n /etc/sudoers
....省略....
    98	## Allows people in group wheel to run all commands
    99	# %wheel	ALL=(ALL)	ALL
   100	
   101	## Same thing without a password
   102	# %wheel	ALL=(ALL)	NOPASSWD: ALL   <== 和上面的一样, 除了不需要输入密码
....省略....

%wheel : % 表示用户组的意思, 所以就是表示 wheel 用户组
#      : 表示注释的意思, 不生效, 所以我们需要去掉 # 号

修改如下, 别忘记保存 : 
    98	## Allows people in group wheel to run all commands
    99	%wheel	ALL=(ALL)	ALL      # <== 去掉最左边的 # 号
   100	
   101	## Same thing without a password
   102	# %wheel	ALL=(ALL)	NOPASSWD: ALL   # <== 如果不想要输入密码, 可以使用如下行. 去掉最左边的 # 号

## 使用 root 用户更改 test_user 用户的附加组
[root@localhost ~]# gpasswd -a test_user wheel
Adding user test_user to group wheel
[root@localhost ~]# id test_user
uid=501(test_user) gid=501(test_user) groups=501(test_user),10(wheel)

## 切换到 test_user 用户
[gkdaxue@localhost ~]$ su - test_user
Password: 
[test_user@localhost ~]$ cat /etc/shadow
cat: /etc/shadow: Permission denied  <== 不能访问
[test_user@localhost ~]$ sudo cat /etc/shadow | head -n 5
[sudo] password for test_user:    <== 需要输入密码, 因为没有设置免密
root:$6$NnsNsHED$wTz2roXulfYEXmCGNU4B4lRxVDbCqcFVI9b99bS3....../:17962:0:99999:7:::
bin:*:17246:0:99999:7:::
daemon:*:17246:0:99999:7:::
adm:*:17246:0:99999:7:::
lp:*:17246:0:99999:7:::

## 只要加入 wheel 用户组的用户, 都可以执行该操作. 这只是演示, 请根据自己实际需要设置执行的命令等等. 
## 可以参考上面部分 给用户设置执行的命令
```

#### sudo 搭配 su 的使用方式
有的时候我们既然切换为 root 用户, 肯定不可能只是输入一个命令, 基本上都是很多的命令, 按照我们之前的 sudo 方式来做, 效率太慢了. 那么我们应该怎么处理呢?

**别名的概念**
visudo 的别名可以是命令别名, 账户别名, 主机别名等, 如下:
> 1. **别名一定要使用大写字符**.
> 2. User_Alias : 账户别名
> 3. Cmnd_Alias : 命令别名
> 4. Host_ALias : 来源主机别名

```bash
/etc/sudoers 文件内容

User_Alias ADMPW = gkdaxue, test_user
Cmnd_Alias ADMPWCOM = !/usr/bin/passwd, !/usr/bin/passwd root

ADMPW  ALL=(root)  ADMPWCOM   # <== 按照之前的格式 正确的写入即可.

## 我们以后修改时, 只要修改 User_Alias 和 Cmnd_Alias 这两行即可.
```

了解了上面的知识, 那么我们来继续讲解内容
```bash
## 把我们之前添加的内容还原成最开始的样子, 内容修改如下, 保存退出
[root@localhost ~]# visudo
    90	## Allow root to run any commands anywhere 
    91	root	ALL=(ALL) 	ALL
    92	
    93	User_Alias ADMINS = gkdaxue
    94	ADMINS ALL=(root) /bin/su - 

## 然后我们 gkdaxue 用户只要执行 sudo su - 命令, 输入自己的密码就可以变身成为 root 用户
## 不但 root 密码不会外泄, 并且也可以以 root 身份执行很多条命令. 而不是一条一条执行.
[gkdaxue@localhost ~]$ sudo su -
[sudo] password for gkdaxue: 
[root@localhost ~]# id
uid=0(root) gid=0(root) groups=0(root) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
```

# 练习题
## 任务一
| 账号 | 备注 | 附加组 | 是否可登录 | 密码 |
| --- | --- | :---: | :---: | --- |
| myuser1 | 1st user | mygroup1 | 可以 | password |
| myuser2 | 2nd user | mygroup1 | 可以 | password |
| myuser3 | 3rd user | 无 | 不可以 | password |

```bash
groupadd mygroup1
useradd -c '1st user' -G mygroup1 myuser1
useradd -c '2nd user' -G mygroup1 myuser2
useradd -c '3rd user' -s /sbin/nologin myuser3

echo 'password' | passwd --stdin myuser1
echo 'password' | passwd --stdin myuser2
echo 'password' | passwd --stdin myuser3 
```

## 任务二
用户 pro1, pro2, pro3 属于同一个项目的开发人员, 想让这三个用户在同一个目录 (/srv/projecta) 下进行开发工作, 但是这个三个用户分别有自己的家目录和私有用户组. 项目组名称为 projecta, 用户密码为 password, **用户必须登录之后修改密码方可正常使用系统.**  应该如何设置,
```bash
groupadd projecta

useradd -G projecta pro1
useradd -G projecta pro2
useradd -G projecta pro3

echo 'password' | passwd --stdin pro1
echo 'password' | passwd --stdin pro2
echo 'password' | passwd --stdin pro3

chage -d 0 pro1
chage -d 0 pro2
chage -d 0 pro3

mkdir -p /srv/projecta
chgrp projecta /srv/projecta
chmod 2770 /srv/projecta
```

然后我们在修改, 让 myuser1 用户可以查看 /src/projecta 目录下的文件内容, 但是不能修改
```bash
## 因为 ACL 的权限设置不会被子目录所继承, 所以需要使用 d:u:myuser1:rx 来操作
setfacl -m d:u:myuser1:rx /srv/projecta
```

# 系统管理常用命令
## dd命令
它能够让用户按照指定大小和个数的数据块来复制文件的内容。Linux系统中有一个名为/dev/zero的设备文件，因为这个文件不会占用系统存储空间，但却可以提供无穷无尽的数据，因此可以使用它作为dd命令的输入文件，来生成一个指定大小的文件。
> dd if="input file" of="output file" count=number bs=block size

| 选项 | 作用 |
| ----- | ----- |
| if |	输入的文件名称 |
| of | 输出的文件名称 |
| bs | 设置每个块的大小 |
| count | 复制多少个块 | 

### 实例
```bash
## 比如我想要复制一个 500M的文件, 有多种方式 
## bs=100M  count=5  ; bs=250M  count=2 等
[root@localhost ~]# dd if=/dev/zero of=test.txt bs=100M count=5
5+0 records in
5+0 records out
524288000 bytes (524 MB) copied, 2.51087 s, 209 MB/s
[root@localhost ~]# ll -h test.txt 
-rw-r--r--. 1 root root 150M Mar 14 07:34 test.txt
```

## ps命令
ps命令用于查看系统中的进程状态, 所以**它仅仅只能表示当前系统某一个时刻的进程信息**.
> ps [ options ]

| 选项 | 作用 |
| :---: | ---- |
| -a | 显示所有进程（包括其他用户的进程） |
| -u | 用户以及其他详细信息 |
| -x | 显示没有控制终端的进程 |
| -F | 显示完整格式的进程信息 |
| -H | 以进程层级格式显示进程相关信息 |
| 显示格式 | <br> |
| l | 显示详细信息 |
| j | 工作的格式显示 |
| -f | 更完整的信息输出 |

**在Linux系统中，有5种常见的进程状态，分别为运行、中断、不可中断、僵死与停止**
> R（运行）：进程正在运行或在运行队列中等待。
>
> S（中断）：进程处于休眠中，当某个条件形成后或者接收到信号时，则脱离该状态。
> 
> D（不可中断）：进程不响应系统异步信号，即便用kill命令也不能将其中断。
> 
> Z（僵死）：进程已经终止，但进程描述符依然存在, 直到父进程调用wait4()系统函数后将进程释放。
> 
> T（停止）：进程收到停止信号后停止运行。

### 实例
```bash
## 只查看自己的bash相关进程
[root@localhost ~]# ps -l
F      : 进程标志(Process flags)
         	4 : 此进程的权限为 root
         	1 : 此子进程仅可进行复制(fork)而无法实际执行(exec)
S      : 进程的状态
UID    : 拥有者ID
PID    : 进程PID
PPID   : 此进程的父进程的PID
C      : CPU使用率
PRI/NI : 被CPU执行的优先级, 数字越小代表该进程越快被CPU执行
ADDR/SZ/WCHAN : 与内存有关.
TTY    : 登录的终端
TIME   : 花费CPU运行的时间
CMD    : 命令

F S   UID    PID   PPID  C PRI  NI ADDR SZ WCHAN  TTY          TIME CMD
4 S     0  35678  35674  0  80   0 - 27124 do_wai pts/0    00:00:00 bash
4 R     0  35870  35678  0  80   0 - 27037 -      pts/0    00:00:00 ps


进程状态中包含的其他符号
	+ : 前台进程
	l : 多线程进程
	N : 低优先级线程
	< : 高优先级进程
	s : session leader

[root@localhost ~]# ps aux
USER : 进程属主 
PID  : 进程ID 
%CPU : 占据CPU百分比 
%MEM : 占据内存百分比
RSS  : Virtual Memory Size(虚拟内存大小) 虚拟内存集 Resident Size, 常驻内存集 单位是KB(不能放到交换分区中)
TTY     : 所在终端 ( ? 表示不依赖于任何终端)  
STAT    : 进程状态
START   : 启动时间
TIME    : 运行占据CPU的累积时长
COMMAND : 命令

USER        PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root          1  0.0  0.1  19368  1636 ?        Ss   Mar03   0:01 /sbin/init
root          2  0.0  0.0      0     0 ?        S    Mar03   0:00 [kthreadd]
root          3  0.0  0.0      0     0 ?        S    Mar03   0:00 [migration/0]
root          4  0.0  0.0      0     0 ?        S    Mar03   0:00 [ksoftirqd/0]
.....

## -F :显示完整格式的进程信息
[root@localhost ~]# ps -F
UID   : 用户名 
PID   : 进程ID 
PPID  : 父进程ID 
C     : 运行的CPU编号 
SZ    : 使用的内存大小
PSR   : Resident Size, 常驻内存集 单位是KB(不能放到交换分区中) 
STIME : 启动时间 
TTY   : 终端 
TIME  : 运行占据CPU的累积时长	 
CMD   : 命令

UID         PID   PPID  C    SZ   RSS PSR STIME TTY          TIME CMD
root      16152  16148  0 27124  1920   0 Mar06 pts/0    00:00:00 -bash
root      18775  16152  0 27565  1148   0 11:23 pts/0    00:00:00 ps -F


## -a : 与终端相关的进程
[root@localhost ~]# ps -a
   PID TTY          TIME CMD
 18793 pts/0    00:00:00 ps

## -x : 与终端无关的进程
## 细心的同学应该发现了, 我有的选项前没有给上 - , 因为 ps 命令可以不跟上 - 也不会报错.
[root@localhost ~]# ps x
   PID TTY      STAT   TIME COMMAND
     1 ?        Ss     0:01 /sbin/init
     2 ?        S      0:00 [kthreadd]
     3 ?        S      0:00 [migration/0]
     4 ?        S      0:00 [ksoftirqd/0]
     5 ?        S      0:00 [stopper/0]
     6 ?        S      0:00 [watchdog/0]
     7 ?        S      1:49 [events/0]
     8 ?        S      0:00 [events/0]
     9 ?        S      0:00 [events_long/0]
    10 ?        S      0:00 [events_power_ef]
    11 ?        S      0:00 [cgroup]
    12 ?        S      0:00 [khelper]
    13 ?        S      0:00 [netns]
    14 ?        S      0:00 [async/mgr]
...

## -u : 和用户相关的进程
[root@localhost ~]# ps u
USER        PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root       2026  0.0  0.0   4068   544 tty2     Ss+  Mar03   0:00 /sbin/mingetty /dev/tty2
root       2028  0.0  0.0   4068   544 tty3     Ss+  Mar03   0:00 /sbin/mingetty /dev/tty3
root       2030  0.0  0.0   4068   540 tty4     Ss+  Mar03   0:00 /sbin/mingetty /dev/tty4
root       2032  0.0  0.0   4068   544 tty5     Ss+  Mar03   0:00 /sbin/mingetty /dev/tty5
root       2040  0.0  0.0   4068   540 tty6     Ss+  Mar03   0:00 /sbin/mingetty /dev/tty6
root       3248  0.0  0.1 108360  1768 tty1     Ss+  Mar03   0:00 -bash
root      16152  0.0  0.1 108496  1920 pts/0    Ss   Mar06   0:00 -bash
root      18799  0.0  0.1 110256  1152 pts/0    R+   11:32   0:00 ps u

## -H : 以进程层级格式显示进程相关信息
[root@localhost ~]# ps -efH
UID         PID   PPID  C STIME TTY          TIME CMD
......
root          1      0  0 Mar03 ?        00:00:01 /sbin/init           <== 第一个被启动起来的进程
root        572      1  0 Mar03 ?        00:00:00   /sbin/udevd -d     <== 第一个进程的子进程
root       2039    572  0 Mar03 ?        00:00:00     /sbin/udevd -d
root       2332    572  0 Mar03 ?        00:00:00     /sbin/udevd -d
.....
```

## pstree命令
以树状图的形式显示进程信息

| 选项 | 作用 |
| :--: | ---- |
| -p | 显示 PID |
| -n | 根据 PID 排序 |

### 实例
```bash
[root@localhost ~]# pstree
init─┬─NetworkManager───{NetworkManager}
     ├─abrtd
     ├─acpid
     ├─atd
     ├─auditd───{auditd}
     ├─automount───4*[{automount}]
     ├─certmonger
     ├─console-kit-dae───63*[{console-kit-da}]
     ├─crond
........

## -p : 显示 PID 号码
[root@localhost ~]# pstree -p
init(1)─┬─NetworkManager(1589)───{NetworkManager}(2622)
        ├─abrtd(1922)
        ├─acpid(1685)    <== 发现不是按照 pid 排序的
        ├─atd(1964)
        ├─auditd(1470)───{auditd}(1471)
        ├─automount(1778)─┬─{automount}(1779)
        │                 ├─{automount}(1780)
        │                 ├─{automount}(1795)
        │                 └─{automount}(1798)
        ├─certmonger(1980)
        ├─console-kit-dae(2072)─┬─{console-kit-da}(2073)
        │                       .........................
        ├─crond(1949)
.....

## -n : 按照 PID 号码排序
[root@localhost ~]# pstree -n -p
init(1)─┬─udevd(572)─┬─udevd(2039)
        │            └─udevd(2332)
        ├─auditd(1470)───{auditd}(1471)
        ├─rsyslogd(1504)─┬─{rsyslogd}(1505)
        │                ├─{rsyslogd}(1506)
        │                └─{rsyslogd}(1507)
        ├─rpcbind(1555)
        ├─dbus-daemon(1575)───{dbus-daemon}(1576)
        ├─NetworkManager(1589)───{NetworkManager}(2622)
        ├─modem-manager(1594)
        ├─rpc.statd(1615)
        ├─wpa_supplicant(1637)
        ├─cupsd(1653)
        ├─acpid(1685)
        ├─hald(1697)─┬─hald-runner(1698)─┬─hald-addon-inpu(1743)
        │            │                   └─hald-addon-acpi(1753)
        │            └─{hald}(1699)
        ├─automount(1778)─┬─{automount}(1779)
...........
```

## uptime命令
uptime命令真的很棒，它可以显示当前系统时间、系统已运行时间、启用终端数量以及平均负载值等信息。平均负载值指的是系统在最近1分钟、5分钟、15分钟内的压力情况；负载值越低越好，尽量不要长期超过1，在生产环境中不要超过5。

```bash
[root@localhost ~]# uptime
11:47:07                       : 当前系统时间
up 3 days, 21:05               : 系统运行时长, 不到1天(hours:mins), 不到一个小时(num min)
2 users                        : 登录终端数 
load average: 0.00, 0.00, 0.00 : 系统在过去的1分钟、5分钟和15分钟内的平均负载

 11:47:07 up 3 days, 21:05,  2 users,  load average: 0.00, 0.00, 0.00  
```

## free命令
显示系统的内存状态
> free [ options ]

| 选项 | 作用 |
| :--: | --- |
| -b	| 以Byte为单位显示内存使用情况 | 
| -k	| 以KB为单位显示内存使用情况 | 
| -t	| 显示内存总和列 | 
| -o	| 不显示缓冲区调节列 | 
| -m	| 以MB为单位显示内存使用情况 | 
| --si  | 	使用 1000为换算单位不是 1024 | 
| -g	| 以GB为单位显示内存使用情况 | 
| -h	| 人性化显示(自动选择单位) | 
| -s Refersh_Time | 持续观察内存使用状况 | 
| -c  NUM	| 自动执行NUM次, 需要和-s一起使用 | 

### 实例
```bash
[root@localhost ~]# free 
total(内存总量) 			: /proc/meminfo文件中的 MemTotal和SwapTotal的值
used(已用量) 			: {Mem|Swap}Total - {Mem|Swap}Free 
free(可用量) 			: /proc/meminfo文件中的 MemFree 和 SwapFree 的值
shared(进程共享的内存量) 	: /proc/meminfo文件中的 Shmem
                          (内核2.6.32上可用,不可用则显示为零)
buffers(磁盘缓存的内存量) : /proc/meminfo文件中的 Buffers 的值
cached(缓存的内存量) 		: /proc/meminfo文件中 Cached - Shme

             total       used       free   shared  buffers   cached
Mem:       1870760    1394920     475840    17312     9056   896284
-/+ buffers/cache:     489580    1381180
Swap:      1048572         28    1048544


--------------------- 尝试从 /proc/meminfo 来获取到 free 命令的内容 --------------------------------
1. 因为这个内存是实时变化的, 所以只能拷贝一份出来研究并查看, /proc/meminfo,得到如下信息, 信息有删减
---------- total -----------
MemTotal:        1870760 kB			
SwapTotal:       1048572 kB			
 
---------- used -----------
MemUsed:   MemTotal(1870760) - MemFree(475840) = 1394920
SwapUsed:  SwapTotal(1048572) - SwapFree(1048544) = 28
 
---------- free -----------
MemFree:          475840 kB
SwapFree:        1048544 kB
 
--------- shared ----------
Shmem:             17312 kB
 
--------- buffers ---------
Buffers:            9056 kB
 
--------- cached ----------
MemCached: Cached(913596) - Shmem(17312) = 896284
 
 
2. 整理得出 
             total       used       free   shared  buffers   cached
Mem:       1870760    1394920     475840    17312     9056   896284
Swap:      1048572         28    1048544

我们和free命令发现少了中间的一行  -/+ buffers/cache , 接下来我们讲解这行的含义

(-buffers/cache) used内存数：第一行Mem行中的 used – buffers – cached
	-buffers/cache used = 1394920 - 9056 - 896284 = 489580
	-buffers/cache反映的是被程序实实在在吃掉的内存
(+buffers/cache) free内存数: 第一行Mem行中的 free + buffers + cached
	+buffers/cache free = 475840 + 9056 + 896284 = 1381180
	+buffers/cache反映的是可以挪用的内存总数

3. 最后可以得出

             total       used       free    shared   buffers    cached
Mem:       1870760    1394920     475840     17312      9056    896284
-/+ buffers/cache:     489580    1381180
Swap:      1048572         28    1048544
---------------------------------------------------------------------------------------

## -s 持续的查看 每 3 秒自动打印一遍, 需要自己手动停止
[root@localhost ~]# free -s 3
             total       used       free    shared   buffers    cached
Mem:       1870760    1397600     473160     17312      9056    896344
-/+ buffers/cache:     492200    1378560
Swap:      1048572         28    1048544
 
             total       used       free    shared   buffers    cached
Mem:       1870760    1397608     473152     17312      9056    896344
-/+ buffers/cache:     492208    1378552
Swap:      1048572         28    1048544
 
             total       used       free    shared   buffers    cached
Mem:       1870760    1397608     473152     17312      9056    896344
-/+ buffers/cache:     492208    1378552
Swap:      1048572         28    1048544
 
^C

## -c -s 连用, 总共打印三次, 每次打印间隔 3 s
[root@localhost ~]# free -c 3 -s 3
             total       used       free    shared   buffers    cached
Mem:       1870760    1397232     473528     17312      9056    896352
-/+ buffers/cache:     491824    1378936
Swap:      1048572         28    1048544
 
             total       used       free    shared   buffers    cached
Mem:       1870760    1397240     473520     17312      9056    896352
-/+ buffers/cache:     491832    1378928
Swap:      1048572         28    1048544
 
             total       used       free    shared   buffers    cached
Mem:       1870760    1397240     473520     17312      9056    896352
-/+ buffers/cache:     491832    1378928
Swap:      1048572         28    1048544

## -k 以kb显示大小
[root@localhost ~]# free -k
             total       used       free    shared   buffers    cached
Mem:       1870760    1397508     473252     17312      9056    896344
-/+ buffers/cache:     492108    1378652
Swap:      1048572         28    1048544

## -h : 人性化显示(自动选择单位)
[root@localhost ~]# 
             total       used       free    shared   buffers    cached
Mem:          1.8G       1.3G       462M       16M      8.8M      875M
-/+ buffers/cache:       480M       1.3G
Swap:         1.0G        28K       1.0G
```

## top命令
ps命令提供了进程信息, 但是只是显示瞬间的信息, 而 top 则是动态地监视进程活动与系统负载等信息, **默认是按照占用CPU(%CPU)的大小排序, 是上一个刷新周期所占用的CPU的统计数据**, 是动态过程下一个周期内可能就发生了变化.
> top [ options ]

| 选项 | 作用 |
| :---: | ----- |
| -d Refresh_Time | 指定刷新时间间隔, 默认为3s |
| -b | 分批次显示信息, 而不总是显示第一屏 |
| -n NUM | 显示多少批次 |
| -p PORT1[,PORT2....]| 查看指定端口进程的信息 |
| -u USER_NAME | 查看指定用户的进程信息 |

**top 内置命令**

| 选项 | 作用 |
| :---: | --- |
| P | 按照占据CPU的百分比排序 |
| M | 按照占据内存的百分比排序 |
| T | 按照累积占用CPU时间排序 |
| l | (小写L)控制 top 命令行中的 top 行的显示和隐藏 |
| t | 控制 top 命令中 Tasks 和 %Cpu(s) 行的显示和隐藏 |
| m | 控制 top 命令中 KiB Mem 和 KiB Swap 行的显示和隐藏 |
| k PID | 终止指定的进程 PID |
| s | 更改刷新时间间隔, 默认是3s |
| q | 退出 top 命令行显示的页面信息 |
| h | 获取帮助信息 |
| f | 自定义显示的字段信息 |

### 实例
```bash
[root@localhost ~]# top
第一行 系统负载:
	top                            : 运行的命令
	12:37:14                       : 系统时间 
	up 3 days, 21:55               : 运行时间 
	2 users                        : 登录终端数
	load average: 0.00, 0.00, 0.00 : 系统负载（三个数值分别为1分钟、5分钟、15分钟内的平均值，数值越小意味着负载越低）

第二行 进程信息: 
	Tasks: 144 total : 进程总数
	1 running        : 运行中的进程数
	143 sleeping     : 睡眠中的进程数
	0 stopped        : 停止的进程数
	0 zombie         : 僵死的进程数

第三行 Cpu(s): 
	0.0%us   : 用户占用资源百分比
 	0.0%sy   : 系统内核占用资源百分比
	0.0%ni   : 改变过优先级的进程资源百分比
	99.9%id  : 空闲的资源百分比等
	0.0%wa   : IO等待占用CPU的百分比
	0.0%hi   : 硬中断（Hardware interruption）占用CPU的百分比
	0.0%si   : 软中断（Software interruption）占用CPU的百分比
	0.0%st   : 被偷走的比率

第四行 内存信息:
	1870760k total : 物理内存总量
	1394920k used  : 内存使用量
	475840k free   : 内存空闲量
	9056k buffers  : 作为内核缓存的内存量

第五行 swap信息:
	1023996k total : 虚拟内存总量
	0k used        : 虚拟内存使用量
	1023996k free  : 虚拟内存空闲量
	190088k cached : 已被提前加载的内存量

top - 12:37:14 up 3 days, 21:55,  2 users,  load average: 0.00, 0.00, 0.00
Tasks: 144 total,   1 running, 143 sleeping,   0 stopped,   0 zombie
Cpu(s):  0.0%us,  0.0%sy,  0.0%ni, 99.9%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
Mem:   1870760k total,   1394920k used,   475840k free,    9056k buffers
Swap:  1023996k total,        0k used,  1023996k free,   190088k cached

PID     : PID进程号
USER    : 用户 
PR      : 优先级 
NI      : nice值 
VIRT    : 虚拟内存集 
RES     : 常驻内存集 
SHR     : 共享内存大小 
S       : 进程状态 
%CPU    : 占用CPU百分比
%MEM    : 占用内存百分比 
TIME+   : 累积运行时长 
COMMAND : 命令

   PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
     1 root      20   0 19368 1636 1304 S  0.0  0.2   0:01.61 init
     2 root      20   0     0    0    0 S  0.0  0.0   0:00.01 kthreadd
     3 root      RT   0     0    0    0 S  0.0  0.0   0:00.00 migration/0
     4 root      20   0     0    0    0 S  0.0  0.0   0:00.06 ksoftirqd/0
     5 root      RT   0     0    0    0 S  0.0  0.0   0:00.00 stopper/0
     6 root      RT   0     0    0    0 S  0.0  0.0   0:00.30 watchdog/0
     7 root      20   0     0    0    0 S  0.0  0.0   1:50.92 events/0
     8 root      20   0     0    0    0 S  0.0  0.0   0:00.00 events/0
     9 root      20   0     0    0    0 S  0.0  0.0   0:00.00 events_long/0
    10 root      20   0     0    0    0 S  0.0  0.0   0:00.00 events_power_ef
    11 root      20   0     0    0    0 S  0.0  0.0   0:00.00 cgroup
    12 root      20   0     0    0    0 S  0.0  0.0   0:00.00 khelper
    13 root      20   0     0    0    0 S  0.0  0.0   0:00.00 netns
    14 root      20   0     0    0    0 S  0.0  0.0   0:00.00 async/mgr
    15 root      20   0     0    0    0 S  0.0  0.0   0:00.00 pm
    16 root      20   0     0    0    0 S  0.0  0.0   0:01.06 sync_supers
    17 root      20   0     0    0    0 S  0.0  0.0   0:00.02 bdi-default
    18 root      20   0     0    0    0 S  0.0  0.0   0:00.00 kintegrityd/0
......

## 剩余的内置命令可以自己试验体会作用
```

## pidof命令
pidof命令用于查询某个指定服务进程的PID值
> pidof program

### 实例
```bash
[root@localhost ~]# pidof sshd
16148 1822

[root@localhost ~]# ps aux | grep sshd
root       1822  0.0  0.1  66260  1208 ?        Ss   Mar03   0:00 /usr/sbin/sshd
root      16148  0.0  0.4 102104  4160 ?        Ss   Mar06   0:00 sshd: root@pts/0 
root      19211  0.0  0.0 103332   840 pts/0    S+   13:48   0:00 grep sshd
```

## watch命令
watch是一个非常实用的命令，可以帮你监测一个命令的运行结果，省得你一遍遍的手动运行,可以拿它来监测命令结果的变化, 按 ctrl + c 停止刷新并退出
> watch [ optioins ] COMMAND

| 选项 | 作用 |
| :---: | ---- |
| -n |	指定指令执行的间隔时间(秒) |
| -t |	不显示标题 |
| -d |	高亮显示指令输出信息不同之处 |
| -g |	结果有改变时退出循环执行 | 

### 实例
```bash
## 默认两秒刷新一次 
[root@localhost ~]# watch free
Every 10.0s: free                            Thu Mar  7 14:17:35 2019  <== 可以发现这个时间会变动

             total	 used       free     shared    buffers     cached
Mem:	   1004112     456656     547456        472	 81216     190196
-/+ buffers/cache:     185244     818868
Swap:	   1023996          0    1023996

## -n 5s 刷新一次   -d 高亮显示不同的部分
[root@localhost ~]# watch -n 5 -d free
Every 10.0s: free                                Thu Mar  7 14:19:36 2019

             total	 used       free     shared    buffers     cached
Mem:	   1004112     456640     547472        472	 81220     190196
-/+ buffers/cache:     185224     818888
Swap:	   1023996          0    1023996

## 不显示标题
[root@localhost ~]# watch -n 5 -d -t free
             total	 used       free     shared    buffers     cached
Mem:	   1004112     456532     547580        472	 81220     190204
-/+ buffers/cache:     185108     819004
Swap:	   1023996          0    1023996
```

## ifconfig命令
ifconfig命令用来查看和配置网络接口. 默认用来查看处于活动状态的接口地址.
**有些 Linux 版本中并没有 ifconfig 这个命令, 是因为没有安装对应的软件包, 这个时候就需要我们来安装一下软件包.**
> **yum install   net-tools   -y**


```bash
ifconfig                                                : 查看所有处于活动状态的接口地址
ifconfig -a                                             : 查看所有接口地址
ifconfig INTERFACE                                      : 查看特定的接口信息
ifconfig INTERFACE [up|down]                            : 启用或禁用特定的接口
ifconfig INTERFACE { IP/MASK掩码长度 | IP netmask MASK } : 临时切换 IP 地址

## ifconfig 查看所有处于活动状态的接口地址
[root@localhost ~]# ifconfig
eth0      Link encap:Ethernet  HWaddr 00:0C:29:27:50:34  
          inet addr:192.168.1.206  Bcast:192.168.1.255  Mask:255.255.255.0
          inet6 addr: fe80::20c:29ff:fe27:5034/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:299474 errors:0 dropped:0 overruns:0 frame:0
          TX packets:67333 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:24609986 (23.4 MiB)  TX bytes:7437392 (7.0 MiB)

## ifconfig -a 查看所有的接口地址
[root@localhost ~]# ifconfig -a
eth0      Link encap:Ethernet  HWaddr 00:0C:29:27:50:34  
          inet addr:192.168.1.206  Bcast:192.168.1.255  Mask:255.255.255.0
          inet6 addr: fe80::20c:29ff:fe27:5034/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:299507 errors:0 dropped:0 overruns:0 frame:0
          TX packets:67349 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:24612925 (23.4 MiB)  TX bytes:7439448 (7.0 MiB)

lo        Link encap:Local Loopback   <== 已经被禁用, 所以使用 ifconfig 无法显示
          inet addr:127.0.0.1  Mask:255.0.0.0
          LOOPBACK  MTU:65536  Metric:1
          RX packets:32 errors:0 dropped:0 overruns:0 frame:0
          TX packets:32 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:2352 (2.2 KiB)  TX bytes:2352 (2.2 KiB)

## 查看特定的网卡接口 lo 信息
[root@localhost ~]# ifconfig lo
lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          LOOPBACK  MTU:65536  Metric:1
          RX packets:32 errors:0 dropped:0 overruns:0 frame:0
          TX packets:32 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:2352 (2.2 KiB)  TX bytes:2352 (2.2 KiB)

## 这里启用 lo 这个网卡接口
[root@localhost ~]# ifconfig lo up
[root@localhost ~]# ifconfig
eth0      Link encap:Ethernet  HWaddr 00:0C:29:27:50:34  
          inet addr:192.168.1.206  Bcast:192.168.1.255  Mask:255.255.255.0
          inet6 addr: fe80::20c:29ff:fe27:5034/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:299700 errors:0 dropped:0 overruns:0 frame:0
          TX packets:67445 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:24629978 (23.4 MiB)  TX bytes:7449894 (7.1 MiB)

lo        Link encap:Local Loopback    <== 因为我们现在已经启用了, 所以使用 ifconfig 命令可以看到
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:32 errors:0 dropped:0 overruns:0 frame:0
          TX packets:32 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:2352 (2.2 KiB)  TX bytes:2352 (2.2 KiB)

## 给网卡临时切换 IP 地址 (重启失效), 如果使用 ssh 连接到服务器会自动断开链接.
## 因为网卡的 IP 地址已经改变. 所以需要使用新的 IP 地址来连接.
[root@localhost ~]# ifconfig eth0 192.168.1.207/24
[root@localhost ~]# ifconfig eth0
eth0      Link encap:Ethernet  HWaddr 00:0C:29:27:50:34  
          inet addr:192.168.1.207  Bcast:192.168.1.255  Mask:255.255.255.0
          inet6 addr: fe80::20c:29ff:fe27:5034/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:300510 errors:0 dropped:0 overruns:0 frame:0
          TX packets:67730 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:24706520 (23.5 MiB)  TX bytes:7481628 (7.1 MiB)


## 然后我们来分析一下显示的各个字段的含义
[root@localhost ~]# ifconfig eth0 | nl
     1	eth0      Link encap:Ethernet  HWaddr 00:0C:29:27:50:34  
     2	          inet addr:192.168.1.206  Bcast:192.168.1.255  Mask:255.255.255.0
     3	          inet6 addr: fe80::20c:29ff:fe27:5034/64 Scope:Link
     4	          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
     5	          RX packets:3129 errors:0 dropped:0 overruns:0 frame:0
     6	          TX packets:1328 errors:0 dropped:0 overruns:0 carrier:0
     7	          collisions:0 txqueuelen:1000 
     8	          RX bytes:293151 (286.2 KiB)  TX bytes:137208 (133.9 KiB)
第一行 : 
		eth0                : 网卡的名称代号
		Link encap:Ethernet : 连接类型以太网
		HWaddr              : 网卡的 MAC 地址为 00:0C:29:27:50:34
第二行 : 
		inet addr           : IPv4 的 IP 地址
		Bcast               : Broadcast 的地址
		Mask                : Netmask 的地址
第三行 :
		inet6 addr          : IPv6 的 IP 地址
第四行 : 
		UP                  : 网卡启用状态
		BROADCAST           : 支持组播
		RUNNING             : 网卡在工作中
		MULTICAST           : 主机支持多播
		MTU                 : 网络接口的最大传输单元
第五行 : 
		RX                  : 网络由启动到现在为止的数据包接收情况
							  packets  : 数据包的数量
							  errors   : 数据包发生错误的数量
							  dropped  : 数据包有问题而被丢弃的数量
							  overruns : 速度过快而丢失的数据包数
							  frame    : 发生frame错误而丢失的数据包数
第六行 :
		TX                  : 网络由启动到目前为止数据包的发送情况
							  carrier  : 发生carrier错误而丢失的数据包数
第七行 :
		collisions          : 数据包冲突的情况 
		txqueuelen          : 用来传输数据的缓冲区的存储长度 
第八行 : 
		RX bytes            : 接收的数据量
		TX bytes            : 发送的数据量
```

## netstat命令
显示网络连接  路由表  接口统计 等信息.

### 显示网络连接

| 选项 | 作用 |
| :---: | ----- |
| -t | tcp 协议相关 |
| -u | udp 协议相关 |
| -w | raw socket 相关 |
| -l | 处于监听状态 |
| -a | 所有状态(所有的连接 监听 Socket数据都列出来) |
| -n | 以数字格式显示 IP 和 端口 不列出进程的服务名称 |
| -e | 扩展格式 |
| -p | 显示相关的进程和程序 |

> 常用的组合有 : -tan  -uan  -tnl  -unl  -tulpn

```bash
[root@localhost ~]# netstat
Proto           : 网络的数据包协议
Recv-Q          : 表示收到的数据已经在本地接收缓冲，但是还有多少没有被进程取走
Send-Q          : 对方没有收到的数据或者说没有Ack的,还是本地缓冲区
Local Address   : 本机的 IP 以及端口情况
Foreign Address : 远程的 IP 以及端口情况
State           : 连接状态, ESTABLISHED(建立)   LISTEN(监听)
Active Internet connections (w/o servers)
Proto Recv-Q Send-Q Local Address               Foreign Address             State      
tcp        0     52 192.168.1.206:ssh           192.168.1.11:11126          ESTABLISHED 

Proto  : 一般是 unix
RefCnt : 连接到此 socket 的进程数量
Flags  : 连接的标识
Type   : socket 访问的类型, 主要有 确认连接的STREAM 和 不需要确认的 DGRAM 两种 
State  : 连接的状态, 若为 CONNECTED 则表示多个进程之间已经建立连接
I-Node : I-Node 编号
Path   : 连接到此 socket 的相关程序的路径 或者为 相关数据输出的路径
Active UNIX domain sockets (w/o servers)
Proto RefCnt Flags       Type       State         I-Node Path
unix  13     [ ]         DGRAM                    13646  /dev/log
unix  2      [ ]         DGRAM                    14584  @/org/freedesktop/hal/udev_event
unix  2      [ ]         DGRAM                    10554  @/org/kernel/udev/udevd
unix  2      [ ]         DGRAM                    59014  
unix  2      [ ]         DGRAM                    51683  
unix  3      [ ]         STREAM     CONNECTED     15821  /var/run/dbus/system_bus_socket
...................

[root@localhost ~]# netstat -tulpn
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address               Foreign Address             State       PID/Program name
tcp        0      0 0.0.0.0:111                 0.0.0.0:*                   LISTEN      1555/rpcbind
tcp        0      0 0.0.0.0:36179               0.0.0.0:*                   LISTEN      1615/rpc.statd
tcp        0      0 0.0.0.0:22                  0.0.0.0:*                   LISTEN      1822/sshd
tcp        0      0 127.0.0.1:631               0.0.0.0:*                   LISTEN      1653/cupsd
tcp        0      0 127.0.0.1:25                0.0.0.0:*                   LISTEN      1908/master
tcp        0      0 :::32998                    :::*                        LISTEN      1615/rpc.statd
tcp        0      0 :::111                      :::*                        LISTEN      1555/rpcbind
tcp        0      0 :::22                       :::*                        LISTEN      1822/sshd
tcp        0      0 ::1:631                     :::*                        LISTEN      1653/cupsd
tcp        0      0 ::1:25                      :::*                        LISTEN      1908/master
udp        0      0 0.0.0.0:57043               0.0.0.0:*                               1615/rpc.statd
udp        0      0 0.0.0.0:111                 0.0.0.0:*                               1555/rpcbind
udp        0      0 0.0.0.0:882                 0.0.0.0:*                               1555/rpcbind
udp        0      0 0.0.0.0:631                 0.0.0.0:*                               1653/cupsd
udp        0      0 127.0.0.1:943               0.0.0.0:*                               1615/rpc.statd
udp        0      0 :::36198                    :::*                                    1615/rpc.statd
udp        0      0 :::111                      :::*                                    1555/rpcbind
udp        0      0 :::882                      :::*                                    1555/rpcbind
```

### 显示路由表

| 选项 | 作用 |
| :---: | ----- |
| -r | 显示内核路由表 |
| -n | 数字形式 |

```bash
[root@localhost ~]# netstat -rn
Kernel IP routing table
Destination     Gateway         Genmask         Flags   MSS Window  irtt Iface
192.168.1.0     0.0.0.0         255.255.255.0   U         0 0          0 eth0
```

### 显示接口统计数据
> netstat { options }

| 选项 | 作用 |
| :---: | ---- |
| -i | 所有接口 |
| -IINTERFACE | 查看特定接口 INTERFACE 和 I 之间没有空格 | 

```bash
## -i 查看所有接口
[root@localhost ~]# netstat -i
Kernel Interface table
Iface       MTU Met    RX-OK RX-ERR RX-DRP RX-OVR    TX-OK TX-ERR TX-DRP TX-OVR Flg
eth0       1500   0   302246      0      0      0    68214      0      0      0 BMRU
lo        65536   0       34      0      0      0       34      0      0      0 LRU

## -IINTERFACE : 查看特定接口
[root@localhost ~]# netstat -Ieth0
Kernel Interface table
Iface       MTU Met    RX-OK RX-ERR RX-DRP RX-OVR    TX-OK TX-ERR TX-DRP TX-OVR Flg
eth0       1500   0   302346      0      0      0    68261      0      0      0 BMRU
```

## last命令
显示近期用户或终端的登录情况, 执行last命令时，它会读取/var/log目录下名称为wtmp的文件，并把该文件记录的登录系统或终端的用户名单全部显示出来. 
> last [ options ]

| 选项 | 作用 |
| :----: | ----- |
| -n Num | 显示 Num 行记录 |
| User_Name/tty | 显示指定 用户/终端 的登录信息 |

```bash
[root@localhost ~]# last
用户名    终端         登录IP/内核       登录时间            退出时间    
root     pts/0        192.168.1.11     Sun Mar 24 17:24   still logged in
root     pts/2        192.168.1.11     Wed Mar 20 14:23 - 14:30  (00:06)    
root     pts/1        192.168.1.11     Wed Mar 20 14:22 - 17:24 (4+03:02)   
root     pts/3        192.168.1.11     Wed Mar 20 14:20 - 14:22  (00:01)    
gkdaxue  pts/0        :pts/2:S.0       Wed Mar 20 14:20 - 14:23  (00:02)    
gkdaxue  pts/3        :pts/2:S.0       Wed Mar 20 14:16 - 14:20  (00:03)    
root     pts/0        192.168.1.11     Wed Mar 20 14:16 - 14:20  (00:04)    
gkdaxue  pts/3        :pts/2:S.0       Wed Mar 20 14:14 - 14:16  (00:01)
......

still logged in : 尚未退出
down            : 直到正常关键
crash           : 直到强制关机

## 显示 5  条记录
[root@localhost ~]# last -n 5
root     pts/0        192.168.1.11     Sun Mar 24 17:24   still logged in   
root     pts/2        192.168.1.11     Wed Mar 20 14:23 - 14:30  (00:06)    
root     pts/1        192.168.1.11     Wed Mar 20 14:22 - 17:24 (4+03:02)   
root     pts/3        192.168.1.11     Wed Mar 20 14:20 - 14:22  (00:01)    
gkdaxue  pts/0        :pts/2:S.0       Wed Mar 20 14:20 - 14:23  (00:02)    

wtmp begins Sun Mar  3 11:42:59 2019

## 显示指定用户的 5  条记录
[root@localhost ~]# last -n 5 gkdaxue
gkdaxue  pts/0        :pts/2:S.0       Wed Mar 20 14:20 - 14:23  (00:02)    
gkdaxue  pts/3        :pts/2:S.0       Wed Mar 20 14:16 - 14:20  (00:03)    
gkdaxue  pts/3        :pts/2:S.0       Wed Mar 20 14:14 - 14:16  (00:01)    
gkdaxue  pts/2        192.168.1.11     Wed Mar 20 14:14 - 14:23  (00:08)    
gkdaxue  pts/1        192.168.1.11     Sun Mar 10 11:04 - 11:43  (00:38)    

wtmp begins Sun Mar  3 11:42:59 2019

## 显示指定终端的 5 条记录
[root@localhost ~]# last -n 5 pts/0
root     pts/0        192.168.1.11     Sun Mar 24 17:24   still logged in   
gkdaxue  pts/0        :pts/2:S.0       Wed Mar 20 14:20 - 14:23  (00:02)    
root     pts/0        192.168.1.11     Wed Mar 20 14:16 - 14:20  (00:04)    
root     pts/0        192.168.1.11     Wed Mar 20 14:09 - 14:16  (00:07)    
root     pts/0        192.168.1.11     Wed Mar 20 09:35 - 14:09  (04:33)    

wtmp begins Sun Mar  3 11:42:59 2019
```

## lastlog命令
检查用户上次登录时间
> last [ options ]

| 选项 | 作用 |
| :----: | ----- |
| -u UID | 查询指定用户的登录信息 |

```bash
[root@localhost ~]# lastlog
用户名            终端     来源IP           最后登录的时间            
Username         Port     From             Latest
root             pts/0    192.168.1.11     Sun Mar 24 17:24:23 +0800 2019
bin                                        **Never logged in**
daemon                                     **Never logged in**
adm                                        **Never logged in**
lp                                         **Never logged in**
........
tcpdump                                    **Never logged in**
gkdaxue          pts/2    192.168.1.11     Wed Mar 20 14:14:13 +0800 2019

## 查询指定用户的登录信息
[root@localhost ~]# lastlog -u 0
Username         Port     From             Latest
root             pts/0    192.168.1.11     Sun Mar 24 17:24:23 +0800 2019
```

## traceroute命令
traceroute命令会显示出本机与其他服务器之间的全部路由，既可以有助于准确判断故障位置，也可以通过显示的时间、IP等信息了解数据的流向.

```bash
[root@localhost ~]# traceroute www.baidu.com
traceroute to www.baidu.com (180.97.33.108), 30 hops max, 60 byte packets
 1  192.168.1.1 (192.168.1.1)  0.621 ms  0.568 ms  0.531 ms
 2  100.69.128.1 (100.69.128.1)  2.265 ms  4.463 ms  4.429 ms
 3  58.217.22.149 (58.217.22.149)  3.646 ms  3.612 ms  3.484 ms
 4  58.217.58.113 (58.217.58.113)  5.789 ms  4.989 ms  5.711 ms
 5  202.102.69.198 (202.102.69.198)  8.834 ms 202.102.73.146 (202.102.73.146)  5.572 ms 202.102.73.158 (202.102.73.158)  10.084 ms
 7  180.97.32.26 (180.97.32.26)  5.822 ms 180.97.32.74 (180.97.32.74)  7.084 ms 180.97.32.78 (180.97.32.78)  6.286 ms
.......
```

## ping命令
通常用来测试与目标主机的连通性, 通过发送ICMP ECHO_REQUEST数据包到网络主机（send ICMP ECHO_REQUEST to network hosts），并显示响应情况，这样我们就可以根据它输出的信息来确定目标主机是否可访问（但这不是绝对的）。有些服务器为了防止通过ping探测到，通过防火墙设置了禁止ping或者在内核参数中禁止ping，这样就不能通过ping确定该主机是否还处于开启状态。**linux下ping不会自动终止,需要按ctrl+c终止或使用 -c 选项**.
> ping [ options ] hostname/ip_address

| 选项 | 作用 |
| :----: | ----- |
| -c Num | 发送 Num 次数据 |
| -w timeout | 设置超时时间 |

```bash
[root@localhost ~]# ping -c 3 -w 2 www.baidu.com
PING www.a.shifen.com (180.97.33.108) 56(84) bytes of data.
64 bytes from 180.97.33.108: icmp_seq=1 ttl=56 time=4.91 ms
64 bytes from 180.97.33.108: icmp_seq=2 ttl=56 time=5.30 ms

--- www.a.shifen.com ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 2005ms
rtt min/avg/max/mdev = 4.911/5.106/5.302/0.208 ms
```