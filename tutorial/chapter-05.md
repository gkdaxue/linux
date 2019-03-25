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
> 2. 密码占位符(x) : 如果将密码放到此字段中太危险, 因为任何人都可以查看(read), 有泄漏的风险. 所以使用占位符, 真实密码被防止在 /etc/shadow 文件中. 我们可以分别看一下这两个文件的权限.
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


 
