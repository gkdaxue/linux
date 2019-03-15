# 命令的基本知识

     命令行模式登录后被取得的程序被称为shell, 这是因为这个程序负责了最外层跟用户通信工作, 所以被称为shell. 而我们的命令基本上都是在 shell 中输入完成的, 所以我们就需要了解一下命令的基本知识.

## 命令的基本格式

     要想高效, 准确的完成我们想要的目标, 仅仅只是依靠命令是不够的, 有的时候会根据实际情况来调整命令的选项 参数 命令对象等等, 所以常见的命令的格式如下:

> <br >
> 
> **命令(command)    \[ -|--选项(options) \]    \[ 参数(parameter1) \]  ...   \[命令对象\]**
> 
> <br >
> 
> **讲解 : (先了解即可)**
> 
> 1. 命令指的是 `Linux中的命令` 或者是 `可执行文件` ,  并且 **`严格区分大小写`** .   比如 `pwd`,  `/bin/pwd` 等.
> 
> 2. 命令  选项  参数 和 命令对象  之间 **`至少有一个空格键作为分割`** . 不论空几格, shell 都是为一格.
> 
> 3. "\[ \]" 并不存在实际的命令中, 只是表示可选而已. 有些命令会有选项, 参数, 对象等等, 有些命令则没有.
> 
> 4. 命令的选项有 **`长格式(如--help)`** , 和 **`短格式(如-h)`** 之分.
>    
>    > 长格式和长格式之间不能合并, 长格式和短格式之间不能合并, 短格式和短格式之间可以合并, 并保留一个 
>    > 
>    > **`-`** ,  有些特殊的命令 `-`  还可以省略, 以后会有实例, 了解即可
> 
> 5. `...`  表示选项或者参数可以有多个, **`参数`** 可能是命令或者选项的参数, 具体要根据命令来看
> 
> 6. 按下 **`[ Enter ]`**  键 , 表示命令立即执行, 代表着一行命令的开始.
> 
> 7. 命令过长时, 可以使用 **` \ `**  来转义 **`[ Enter ]`** 键,  使命令连续到下一行, **`( 反斜杠后立刻接特殊字符, 才能转义 )`** .
> 
> 8. 如果一次性想执行多个命令, 那么它们之间可以用 `;`  来分割.
> 
> 9. `命令对象` 一般是指要处理的 文件, 目录 用户等等

## 重要的热键

### `[Tab]`

之前我们说过 Bash 的一个好处就是 `Tab键补全`,  那么我们就可以输入命令或者文件的部分内容, 来使用补全的功能

> \[Tab\] 接在第一个命令的后面, 则是 `命令补全`
> 
> \[Tab\] 接在第二个命令的后面, 则是 `文件补全`
> 
> `如果唯一, 则会补全,  不唯一则会列举出来. 继续进行输入.`

```bash
## pwd : 显示当前工作目录, 输入pw, 然后按两下 [Tab], 则会显示出来所有以 pw 开头的命令(不唯一).
[root@localhost ~]# pw[Tab][Tab]
pwck      pwconv    pwd       pwdx      pwunconv  
[root@localhost ~]# pwd   <== 输入完按 [Enter] 键
/root

## ls : 显示当前文件夹下内容(不包含隐藏文件), 我们发现有一个叫 anaconda-ks.cfg 的文件
[root@localhost ~]# ls
anaconda-ks.cfg  install.log  install.log.syslog

## 输入 ls a然后下 [Tab], 系统就会补全文件名(唯一)
[root@localhost ~]# ls a[Tab]
[root@localhost ~]# ls anaconda-ks.cfg 
anaconda-ks.cfg
```

### `[Ctrl+c]`

     我们有时会输入错误的命令或者参数等等, 导致命令一直在不停的运行着, 这个时候我们就需要让这个程序停止下来, 就需要用到此热键. 

> 先按着 \[Ctrl\] 不松, 然后在按 c 键, 为组合键即可终止当前程序.

### `[Ctrl+d]`

意味着结束输入的意思(End Of Input),  比如我们以后讲解的 ` at ` 命令 会用到.

## 错误信息的查看

     假设我们输入了一个命令, 然后屏幕上面却显示了错误的信息, 那么我们应该怎么解决呢? 接下来演示一个最常见的错误, 使用 `pwd` 命令演示.

```bash
[root@localhost ~]# PWD 

-bash: PWD: command not found   # bash : 表示 shell 的名称, Linux 默认的就是 bash
```

command not found 出现的原因如下 : 

> 1. 输入了错误的命令, 应该是 pwd, (严格区分大小写)
> 
> 2. 没有安装对应的软件, 有些命令是需要安装软件之后才可以使用
> 
> 3. 没有加入到 bash 的 PATH 环境变量中

     所以有的时候执行命令时, 遇到了问题, 会把一些错误信息显示出来, 然后我们就可以快速的根据这些错误进行排错.

# Linux 目录讲解

     在Linux系统中 “一切皆文件”, 那么我们又该如何来找到它们呢?  在 Windows 系统中, 先进入到该文件所在的磁盘分区( 如 E盘 ), 然后在逐步进入到该文件所在的目录, 最后找到文件, 但是在 Linux 中并没有  C / D / E / F 等盘符的概念, 那我们应该如何找到文件呢? 

     在 Linux 系统中一切文件都是从` '根( / ) 目录' ` 开始的. 并按照 Filesystem Hierarchy Standard(文件系统层次化标准, FHS)  来存放文件, 以及定义了常见目录的用途,  让我们了解到应该在什么位置寻找和保存文件.事实上, FHS 针对 ` 目录树 (directory tree) ` 结构仅定义出三层目录下应该放什么内容. 分别为:

- / ( 根目录 ) : 与开机系统有关

- /usr ( Unix Software Resource ) : 与软件 安装/执行 有关

- /var (Variable) : 与系统运行过程有关

> FHS 只是一个标准, 具体遵守不遵守还是要看用户, 所以要在工作中灵活的使用.

## 根目录 ( / )

     根目录是整个系统中最重要的一个目录, 因为所有的目录都是从根目录衍生出来的, 并且根目录还与 开机/还原/系统修复 等操作有关. 所以建议根目录不要放在一个非常大的分区里面. 根据 FHS 建议应用软件安装目录最好不要和 根目录 放在同一个分区. 所以会在上面三层目录中定义了如下的子目录.

> **根目录与开机有关, 开机过程中仅有根目录会被挂载, 其他的分区会在开机完成后才会持续进行挂载的操作.**

| 目录          | 应放置文件的内容                                                       |
| ----------- | -------------------------------------------------------------- |
| /boot       | 开机所需文件—内核、开机菜单以及所需配置文件等                                        |
| /dev        | 以文件形式存放任何设备与接口                                                 |
| /etc        | 系统主要的配置文件目录                                                    |
| /home       | 系统默认用户 家目录/主目录 ( home directory )                              |
| /bin        | 存放单用户维护模式下还可以操作的命令                                             |
| /lib        | 开机时用到的函数库，以及/bin与/sbin下面的命令要调用的函数                              |
| /sbin       | 开机过程中需要的命令, 包含了 开机, 修复, 还原系统所需要的命令                             |
| /media      | 用于挂载设备文件的目录                                                    |
| /opt        | 放置第三方的软件                                                       |
| /root       | 系统管理员的家目录                                                      |
| /srv        | 一些网络服务的数据文件目录                                                  |
| /tmp        | 任何人均可使用的“共享”临时目录                                               |
| /proc       | 虚拟文件系统，例如系统内核、进程、外部设备及网络状态等<br >**所有数据都保存在内存中, 所以本身不占用任何磁盘空间** |
| /usr/local  | 用户自行安装的软件                                                      |
| /usr/sbin   | Linux系统开机时不会使用到的软件/命令/脚本                                       |
| /usr/share  | 帮助与说明文件，也可放置共享文件                                               |
| /var        | 主要存放经常变化的文件，如日志                                                |
| /lost+found | 当文件系统发生错误时，将一些丢失的文件片段存放在这里                                     |

## 目录树( Directory Tree)

所有的文件与目录都由根目录开始, 然后在一个一个的子目录, 有点像树枝状, 所以我们称这种目录配置方式为 "目录树", 主要的特征如下 :

- 目录树的起点为 根目录(/)

- 每一个文件在目录数中的文件名(绝对路径)都是独一无二的

```bash
## 查看一下根目录下的文件内容
[root@localhost ~]# ls -l /
total 102
dr-xr-xr-x.   2 root root  4096 Mar  3 12:27 bin
dr-xr-xr-x.   5 root root  1024 Mar  3 11:41 boot
drwxr-xr-x.   3 root root  4096 Mar  4 18:42 data
drwxr-xr-x.  21 root root  3920 Mar  3 14:28 dev
drwxr-xr-x. 118 root root 12288 Mar 11 03:12 etc
drwxr-xr-x.   4 root root  4096 Mar  3 11:45 home
dr-xr-xr-x.  11 root root  4096 Mar  3 11:37 lib
dr-xr-xr-x.   9 root root 12288 Mar  3 12:27 lib64
drwx------.   2 root root 16384 Mar  3 11:31 lost+found
drwxr-xr-x.   3 root root  4096 Mar  3 19:00 media
drwxr-xr-x.   2 root root     0 Mar  3 14:28 misc
drwxr-xr-x.   2 root root  4096 Sep 23  2011 mnt
drwxr-xr-x.   2 root root     0 Mar  3 14:28 net
drwxr-xr-x.   3 root root  4096 Mar  3 11:40 opt
dr-xr-xr-x. 172 root root     0 Mar  3 22:28 proc
dr-xr-x---.   4 root root  4096 Mar  8 14:56 root
dr-xr-xr-x.   2 root root 12288 Mar  3 12:27 sbin
drwxr-xr-x.   7 root root     0 Mar  3 22:28 selinux
drwxr-xr-x.   2 root root  4096 Sep 23  2011 srv
drwxr-xr-x   13 root root     0 Mar  3 22:28 sys
drwxrwxrwt.  16 root root  4096 Mar 11 03:12 tmp
drwxr-xr-x.  14 root root  4096 Mar  3 11:33 usr
drwxr-xr-x.  23 root root  4096 Mar  3 11:39 var
```

我们将整个目录树以图示的方法来显示, 如下图所示(省略部分信息) :

![FHS 文件标准](https://github.com/gkdaxue/linux/raw/master/image/chapter_A2_0001.png)

## 绝对路径与相对路径

> 绝对路径 : 由 根目录( / ) 开始写起的文件名或者目录名, 如 /etc/passwd
> 
> 相对路径 : 相对于 ` 目前路径 ` 的写法, 如  ./passwd ( 只要不是 / 开头的就是相对路径 )

- **. : 代表当前路径  ( ./ 代表本目录的意思)**

- **.. : 代表上一层目录, 也可以用 ../ 表示**

比如我们当前在 /home 目录下, 如果我们想要进入到 /etc/ssh 目录, 有以下两种写法:

1. cd /etc/ssh  : 绝对路径写法

2. cd ../etc/ssh : 相对路径写法  ../ 

以上两种写法都是正确的, 可以根据实际生活中的需要, 灵活的选用不同的方式.

# Linux 常用命令

## man(manual 操作说明) page

     Linux系统中有那么多命令，某个命令是干嘛用的？ 以及在日常工作中遇到了一个不熟悉的Linux命令，又如何才能知道它有哪些可用参数？只要执行 `man command` 即可, 我们使用 `pwd` 来实验

```bash
[root@localhost ~]# man pwd   ## 输入此命令后, 会进入 man page 功能界面
PWD(1)  <== 注意这个数字, 等会讲解         User Commands                          PWD(1)


NAME   <== 命令的名称和用途

       pwd - print name of current/working directory

SYNOPSIS   <== 命令语法（摘要）

       pwd [OPTION]...

DESCRIPTION  <== 详细描述命令作用，及其 选项、参数的作用

       Print the full filename of the current working directory.

       -L, --logical   <== 有长格式和短格式两种形式

              use PWD from environment, even if it contains symlinks

       -P, --physical
              avoid all symlinks  <== 选项说明


       --help display this help and exit

       --version
              output version information and exit

       NOTE:  your  shell may have its own version of pwd, which usually supersedes the ver-
       sion described here.  Please refer to your shell’s documentation  for  details  about
       the options it supports.


AUTHOR  <== 作者信息

       Written by Jim Meyering.

REPORTING BUGS  <== 反馈bug地址

       Report pwd bugs to bug-coreutils@gnu.org
       GNU coreutils home page: <http://www.gnu.org/software/coreutils/>
       General help using GNU software: <http://www.gnu.org/gethelp/>
       Report pwd translation bugs to <http://translationproject.org/team/>

COPYRIGHT    <== 版权信息

       Copyright © 2010 Free Software Foundation, Inc.  License GPLv3+: GNU GPL version 3 or
       later <http://gnu.org/licenses/gpl.html>.
       This is free software: you are free to change and redistribute it.  There is NO  WAR-
       RANTY, to the extent permitted by law.

SEE ALSO   <== 相关说明

       getcwd(3)

       The  full  documentation  for pwd is maintained as a Texinfo manual.  If the info and
       pwd programs are properly installed at your site, the command

              info coreutils 'pwd invocation'

       should give you access to the complete manual.
```

### man 手册分类

| 数字  | 含义                              |
| --- | ------------------------------- |
| 1   | 用户在 shell 环境中可以操作的命令或者可执行文件     |
| 2   | 系统内核可调用的函数和工具                   |
| 3   | 一些常用的函数(function) 与函数库(library) |
| 4   | 设备文件的说明                         |
| 5   | 配置文件或者某些文件的格式                   |
| 6   | 游戏                              |
| 7   | 杂项(包含惯例, 协议等)                   |
| 8   | 系统管理员可以使用的管理命令                  |
| 9   | 和内核有关的文件                        |

> 上表中的 `1, 5, 8` 这三个比较重要, 请记住这三个数字代表的含义

     从上表中, 我们知道每个数字代表的含义, 所以导致每个命令会有多个不同的文件man page文件, 那么我们如何查看一个命令有哪些 man page 文件呢, 这个时候我们就可以使用 `man -f command` 来查看.

```bash
[root@localhost ~]# man -f pwd
pwd                  (1p)  - return working directory name
pwd                  (1)  - print name of current/working directory
pwd [builtins]       (1)  - bash built-in commands, see bash(1)
pwd.h [pwd]          (0p)  - password structure

## 我们可以看出 pwd 有那么多的帮助文件信息, 显示信息如下:
命令(或文件)以及该命令的意义(数字) 以及 命令的简单说明
```

     `man command` 到底先显示 哪个数字里面的文件内容呢? 其实这和查询的顺序有关系, 查询的顺序记录在 `/etc/man.conf` 文件中, `先查询到的文件就会被先显示出来`,  一般来说, 因为排序的关系, 所以一般都是先找到数字较小的那个,并显示说来, 所以  `man pw = man 1 pwd`

     那么问题又来了,  `man pwd` 默认显示的是 `PWD(1)`, 那么我如果想要查看 `PWD(1p)` 如何查看呢,  那我们就可以使用  `man  数字  command`,  如 `man 1p pwd`, 具体内容, 请自己查看.

### man page 主要内容结构

     我们可以从上面的执行过程中,  发现 man page 的内容被分成了好几部分, 所以我们来介绍一下各个部分所代表的含义.

| 结构名称        | 描述                   |
| ----------- | -------------------- |
| NAME        | 命令名称和用途（摘要）          |
| SYNOPSIS    | 命令语法（摘要）             |
| DESCRIPTION | 详细描述命令作用，及其 选项、参数的作用 |
| EXAMPLES    | 演示（附带简单说明）           |
| OVERVIEW    | 概述                   |
| DEFAULTS    | 默认的功能                |
| OPTIONS     | 具体的可用选项（带介绍）         |
| ENVIRONMENT | 环境变量                 |
| FILES       | 用到的文件                |
| SEE ALSO    | 其他参考                 |
| BUGS        | bugs                 |
| AUTHOR      | 作者                   |
| COPYRIGHT   | 版权                   |

有的 man page 会有很多内容, 所以我们一般的查看方式为:

> 1. 先看 NAME 内容, 知道这个命令是干嘛用的
> 
> 2. 在看 SYNOPSIS , 知道如何使用各个选项
> 
> 3. 在看 DESCRIPTION 或 EXAMPLES 知道选项的作用及用法

### man page 按键

| 按键                     | 说明                                                              |
| ---------------------- | --------------------------------------------------------------- |
| **b, Page Up**         | **向文件首部翻一屏**                                                    |
| u, Ctrl+U              | 向文件首部翻半屏                                                        |
| y, k, \<up\>           | 向文件首部翻一行                                                        |
| d, Ctrl+D              | 向文件尾部翻半屏                                                        |
| **Space, Page Down**   | **向文件尾翻一屏**                                                     |
| **Enter, e, \<down\>** | **向文件尾部翻一行**                                                    |
| number                 | 跳转到当前行+number行                                                  |
| **g**                  | **回到顶部**                                                        |
| **G**                  | **回到底部**                                                        |
| **/KEYWORD**           | **从当前位置向文件尾部搜索KEYWORD, 不区分大小写<br >n : 下一个         N : 上一个**     |
| **?KEYWORD**           | **从当前位置向文件首部搜索,不区分大小写<br>n : 跟搜索命令同方向下一个      N : 跟搜索命令反放下上一个** |
| h                      | 显示帮助信息                                                          |
| **q**                  | **退出**                                                          |

> 上面的按键是在 man page 中才可使用的, 只要把加粗的记住就好了, 用的熟练了, 自然就记住了. 加油

```bash
[root@localhost ~]# man pwd
PWD(1)                           User Commands                          PWD(1)

NAME
       pwd - print name of current/working directory

SYNOPSIS
       pwd [OPTION]...

DESCRIPTION
       Print the full filename of the current working directory.

       -L, --logical
              use PWD from environment, even if it contains symlinks
.....省略很多...........

:  <== 这是刚进入 man page 时候显示的内容

/pwd   <== 然后按一下 '/' 键 然后输入要查看的关键字, 敲回车就可显示 加粗找到的关键字信息,然后 n 或 N
```

## 命令行执行命令的情况

从上面的练习中我们知道了在命令行模式里面执行命令时, 会有两种主要的情况:

> 1. 该命令会直接显示结果, 然后返回到命令提示符等待下一次命令的输入
> 
> 2. 进入到该命令的环境, 直到结束该命令才回到命令提示符的环境(比如 man)

## man 命令

我们可以通过 `man man` 来了解 man 这个命令有什么作用?

```bash
[root@localhost ~]# man man  <== 省略部分内容

man - format and display the on-line manual pages <== man 命令做什么的描述

man [-fk] [section] name ...  <== 常用选项

## 选项的用法, 具体干什么的, 自己 man 对应的命令去查看
-f     Equivalent to whatis. 列出该命令所有的系统说明文件(跟 man 命令有关的说明文件)
-k     Equivalent to apropos. 系统说明中只要含有 man 相关的就列出来.

[root@localhost ~]# man -f man
man                  (1)  - format and display the on-line manual pages
man                  (1p)  - display system documentation
man                  (7)  - macros to format man pages
man.config [man]     (5)  - configuration data for man
man [manpath]        (1)  - format and display the on-line manual pages
man-pages            (7)  - conventions for writing Linux man pages

[root@localhost ~]# man -k man | head -n 5
aconnect             (1)  - ALSA sequencer connection manager
add_key              (2)  - Add a key to the kernel's key management facility
alias [builtins]     (1)  - bash built-in commands, see bash(1)
alsactl_init         (7)  - alsa control management - initialization
.............
```

     经过我们上面的实验. 我们已经初步会使用了man 这个命令来查询命令, 操作都是一样的, 所以以后会省略很多这些方面的内容. 直接开始进行讲解.

## echo命令

### 描述

echo 命令用于输出字符串或者变量值

### 语法

> `echo [options] [ 字符串 | $变量 ]`
> 
> 之前我们已经讲解过`"[]"` 表示可选的意思, `"|"` 表示 类型可以是字符串或者是变量, 二选一的意思

### 选项

| 选项  | 含义        |
| --- | --------- |
| -n  | 不要输出尾部换行符 |
| -e  | 激活转义字符    |

### 实例

```bash
## 在 shell 中 # 表示注释的意思, 实际中不会运行注释的内容
[root@localhost ~]# echo 'www.gkdaxue.com'   # <== 输出字符串
www.gkdaxue.com

[root@localhost ~]# echo $SHELL   # <== 输出变量, 变量前有 $ 符号.以后讲解变量内容
/bin/bash

## ";" 表示连续执行多个命令时使用, echo 输出完成会自动换一行
[root@localhost ~]# echo 'www.gkdaxue.com' ; echo 'www.gkdaxue.com'
www.gkdaxue.com
www.gkdaxue.com
[root@localhost ~]# echo -n 'www.gkdaxue.com' ; echo 'www.gkdaxue.com' # <== 不输出尾部换行符
www.gkdaxue.comwww.gkdaxue.com

## echo 默认不支持转义字符, \n 表示换行且光标移至行首的意思, 以后再讲
[root@localhost ~]# echo "www.gkdaxue.com\nwww.gkdaxue.com"
www.gkdaxue.com\nwww.gkdaxue.com
[root@localhost ~]# echo -e "www.gkdaxue.com\nwww.gkdaxue.com"
www.gkdaxue.com
www.gkdaxue.com
```

## date命令

     date命令是我们使用比较频繁的一个命令, 比如我们需要每天备份数据库, 然后把文件自动按照“年-月-日”的格式备份. 只需要看一眼文件名称就能大概了解到文件的备份时间了. 这样便于我们的数据库出现问题时, 快速的进行修复工作.

### 描述

date 命令用于 显示(格式化)  或者 设置系统时间(仅root可以设置)

### 语法

> date   \[option\]   \[+format\]
> 
> 命令参数除了前边带有减号 "-"之外,  特殊情况下, 参数的前边也会带有正号"+"的情况存在.

### 选项

| 选项        | 含义                          |
| --------- | --------------------------- |
| -d  <字符串> | 显示字符串指定的日期与时间(字符串加上双引号)     |
| -s  <字符串> | 设置日期和时间(字符串加上双引号)(root才能设置) |
| -u        | 显示GMT ( GMT指的是格林威治中央区时 )    |

### format 支持的参数

| 参数  | 含义                          |
| --- | --------------------------- |
| %%  | 显示一个%                       |
| %Y  | 年份 ( 四位 )                   |
| %a  | 年份的最后两个数 ( 00～99 )          |
| %m  | 月份 ( 01～12 )                |
| %d  | 日期 ( 01～31 )                |
| %D  | same %m/%d/%y               |
| %F  | same %Y-%m-%d               |
| %H  | 小时 ( 00～23 )                |
| %M  | 分钟 ( 00-59 )                |
| %S  | 秒 ( 00～59 )                 |
| %T  | same %H:%M:%S               |
| %s  | 从1970.1.1 00:00:00 到目前经历的秒数 |
| %j  | 一年中第几天(001～336)             |

### 实例

```bash
## 显示当前系统时间
[root@localhost ~]# date
Thu Mar  7 14:36:56 CST 2019  <== CST 为中国标准时间

## 显示当前 GMT时区 系统时间
[root@localhost ~]# date -u
Thu Mar  7 06:36:56 UTC 2019  # <==  CST = GMT + 8 因为中国在 +8 时区, GMT 为 0 时区

## 格式化输出时间
[root@localhost ~]# date "+%Y-%m-%d %H:%M:%S"   # = date "+%F %T"
2019-03-07 14:38:20

## 显示今天是一年中的 第多少天
[root@localhost ~]# date "+%j"
066
```

#### -s  "字符串": 设置日期和时间(root才能设置)

```bash
## 各位能看出我现在是什么用户名吗? 为什么不允许操作
[gkdaxue@localhost ~]$ date -s "20080808"
date: cannot set date: Operation not permitted
Fri Aug  8 00:00:00 CST 2008

## 以下这些命令, 为什么又允许操作了?
## 只设置日期, 时间变为 00:00:00
[root@localhost ~]# date -s "20080808" ; date "+%F %T"
Fri Aug  8 00:00:00 CST 2008
2008-08-08 00:00:00

## 只设置时间, 不设置日期, 日期不会改变
[root@localhost ~]# date -s 08:08:08 ; date "+%F %T"
Fri Aug  8 08:08:08 CST 2008
2008-08-08 08:08:08

## 同时设置日期和时间, 以下四种方式效果一样
[root@localhost ~]# date -s "08:08:08 2008-08-08" ; date "+%F %T"
[root@localhost ~]# date -s "2008-08-08 08:08:08" ; date "+%F %T"
[root@localhost ~]# date -s "08:08:08 20080808"   ; date "+%F %T"
[root@localhost ~]# date -s "20080808 08:08:08"   ; date "+%F %T"
Fri Aug  8 08:08:08 CST 2008
2008-08-08 08:08:08
```

#### -d "字符串" : 显示字符串所指定的日期与时间

```bash
## 使用 now 字符串显示当前时间并格式化显示
[root@localhost ~]# date -d 'now'
Fri Aug  8 08:12:28 CST 2008
[root@localhost ~]# date -d 'now' "+%F %T"
2008-08-08 08:12:54

## 显示指定日期并格式化,没有指定时间 默认00:00:00
[root@localhost ~]# date -d "2008-08-08" "+%F %T"
2008-08-08 00:00:00

## 只有时间, 默认格式化是当前日期
[root@localhost ~]# date -d '08:08:08' "+%F %T"
2018-08-08 08:08:08

## 指定日期和时间并格式化
[root@localhost ~]# date -d "2008-08-08 08:08:08" "+%F %T"
2008-08-08 08:08:08

## apache格式转换
[~]# date -d "Aug 8, 2008 08:08:08 AM" "+%F %T"
2008-08-08 08:08:08

## 格式转换后时间游走
[~]# date -d "Aug 8, 2008 08:08:08 AM 2 year ago" "+%F %T"
2006-08-08 08:08:08

## 1234567890  时间戳指的是哪一天? GMT 时间
[root@localhost ~]# date -u -d "1970-01-01 1234567890  seconds" "+%F %T"
2009-02-13 23:31:30

## 显示前一天的日期, 下面两行代码结果一样
[root@localhost ~]# date "+%F %T" ; date -d "1 day ago" "+%F %T"
[root@localhost ~]# date "+%F %T" ; date -d "-1 day" "+%F %T"
2008-08-08 08:17:11
2008-08-07 08:17:11

## 显示后一天的日期
[root@localhost ~]# date "+%F %T" ; date -d "+1 day" "+%F %T"
2008-08-08 08:17:44
2008-08-09 08:17:44

## 显示上个月的日期
[root@localhost ~]# date "+%F %T" ; date -d "-1 month" "+%F %T"
2018-08-08 08:19:11
2018-07-08 08:19:11

## 显示下一月的日期
[root@localhost ~]# date "+%F %T" ; date -d "+1 month" "+%F %T" 
2018-08-08 08:19:24
2018-09-08 08:19:24

## 显示前一年的日期
[root@localhost ~]# date "+%F %T" ; date -d "-1 year" "+%F %T"
2018-08-08 08:19:42
2017-08-08 08:19:42

## 显示下一年的日期
[root@localhost ~]# date "+%F %T" ; date -d "+1 year" "+%F %T"
2018-08-08 08:19:59
2019-08-08 08:19:59

## 2s 之后的日期
[root@localhost ~]# date "+%F %T" ; date -d "2 second" "+%F %T"
[root@localhost ~]# date "+%F %T" ; date -d "+2 second" "+%F %T"
2018-08-08 08:20:19
2018-08-08 08:20:21

## 2s 之前的日期
[root@localhost ~]# date "+%F %T" ; date -d "-2 second" "+%F %T"
2018-08-08 08:20:55
2018-08-08 08:20:53
```

#### 其他应用

```bash
## 编写一个 shell 脚本, 判断脚本运行了多久, 代码如下(了解即可)
#!/bin/bash
start_time=$(date +%s)
.....
end_time=$(date +%s)
difference=$(( end_time - start_time ))
echo $difference seconds.
```

## ls命令

### 描述

列出目录的内容

### 语法

> ls \[ options \] ... \[ FILE \] ...

### 选项

| 选项          | 含义                              |
| ----------- | ------------------------------- |
| -a          | 显示所有文件(包含隐藏文件)                  |
| -A          | 显示所以文件(包含隐藏文件), 不显示 . 和 ..      |
| -l ( 小写 L ) | 长格式显示 (显示权限, 所有者, 所有组, 文件大小等信息) |
| -i          | 显示文件的 i 节点号                     |
| -d          | 显示目录本身信息，而不是目录下的文件. 一般与 -l 连用   |
| -h          | 人性化显示，按照我们习惯的单位显示文件大小           |
| -t          | 用文件和目录的更改时间排序                   |
| -S          | 以文件大小排序                         |
| -r          | 将文件以相反次序显示(原定依英文字母次序)           |

### 实例

```bash
## 默认列出当前目录下的内容
[root@localhost ~]# ls  # <== 默认不显示隐藏文件
anaconda-ks.cfg  install.log  install.log.syslog

## . 的意思表示为当前目录  ls = ls .
[root@localhost ~]# ls .
anaconda-ks.cfg  install.log  install.log.syslog

## .. 表示上一级目录的意思
[root@localhost ~]# ls ..
bin   data  etc   lib    lost+found  misc  net  proc  sbin     srv  tmp  var
boot  dev   home  lib64  media       mnt   opt  root  selinux  sys  usr

## ~ 表示用户家目录的意思, 比如 root 用户的家目录为 /root
[root@localhost ~]# ls ~
anaconda-ks.cfg  install.log  install.log.syslog

## 查看其它目录
[root@localhost ~]# ls /home/   #<== /home 默认为一般用户的家目录
gkdaxue  lost+found

## -a : 显示所有文件, 包含隐藏文件 ( .开头的文件叫做隐藏文件 )
[root@localhost ~]# ls -a
.   anaconda-ks.cfg  .bash_logout   .bashrc  .cshrc  install.log         .lesshst  .viminfo
..  .bash_history    .bash_profile  .config  .gconf  install.log.syslog  .tcshrc

## -A : 显示所有文件, 包含隐藏文件, 不包含( . 和 .. )
[root@localhost ~]# ls -A
anaconda-ks.cfg  .bash_logout   .bashrc  .cshrc  install.log         .lesshst  .viminfo
.bash_history    .bash_profile  .config  .gconf  install.log.syslog  .tcshrc

## -l : 长格式显示一些信息,  包含
## 文件类型(-),权限(rw-r--r--), ACL访问控制权限(.), 链接数(1), 
## 所有者(root), 所有组(root), 文件大小(50698), mtime(Mar 3 11:42), 文件名等信息
[root@localhost ~]# ls -l  # <== 可以简写为 ll 因为 alias 别名的原因.
total 72
-rw-------. 1 root root  1638 Mar  3 11:42 anaconda-ks.cfg
-rw-r--r--. 1 root root 50698 Mar  3 11:42 install.log
-rw-r--r--. 1 root root 10031 Mar  3 11:39 install.log.syslog

## -i : 显示 inode 节点信息, 如下面的 ( 7249, 18, 30 )等
[root@localhost ~]# ls -il  # <== 短格式可以合并, 并保留一个 '-'
total 72
7249 -rw-------. 1 root root  1638 Mar  3 11:42 anaconda-ks.cfg
  18 -rw-r--r--. 1 root root 50698 Mar  3 11:42 install.log
  30 -rw-r--r--. 1 root root 10031 Mar  3 11:39 install.log.syslog

## -h : 以人性化的方式显示文件大小, 如 1638 显示为 1.6k
[root@localhost ~]# ls -ilh
total 72K
7249 -rw-------. 1 root root 1.6K Mar  3 11:42 anaconda-ks.cfg
  18 -rw-r--r--. 1 root root  50K Mar  3 11:42 install.log
  30 -rw-r--r--. 1 root root 9.8K Mar  3 11:39 install.log.syslog

## 显示当前目录本身的信息, 而不是文件
[root@localhost ~]# ls -ld
dr-xr-x---. 4 root root 4096 Mar  8 14:56 .

## -r : 按照文件名, 倒叙排列 ( z-a ), 默认为( a-z )
[root@localhost ~]# ls -lr
total 72
-rw-r--r--. 1 root root 10031 Mar  3 11:39 install.log.syslog
-rw-r--r--. 1 root root 50698 Mar  3 11:42 install.log
-rw-------. 1 root root  1638 Mar  3 11:42 anaconda-ks.cfg

## -S : 按照文件大小排序(从大 -> 小)
[root@localhost ~]# ls -lSh
total 72K
-rw-r--r--. 1 root root  50K Mar  3 11:42 install.log
-rw-r--r--. 1 root root 9.8K Mar  3 11:39 install.log.syslog
-rw-------. 1 root root 1.6K Mar  3 11:42 anaconda-ks.cfg
```

## pwd命令

### 描述

     以 `绝对路径的方式( 讲解FHS时细说 )` 显示当前工作目录 ( print working directory ),  绝对路径现在只要知道是以 '/ ' 开头的路径即可.

### 语法

> pwd \[ options \]

### 选项

都是显示当前路径, 选项主要是针对链接文件显示的不同而已

| 选项  | 含义                                                           |
| --- | ------------------------------------------------------------ |
| -L  | 有链接文件时，直接显示链接文件的路径，(不加参数时默认此方式)                              |
| -P  | 有链接文件时，不使用链接路径，直接显示链接文件所指向的文件,<br>多层连接文件时，显示所有连接文件最终指向的文件全路径 |

### 实例

```bash
## 显示当前工作目录
[root@localhost ~]# pwd
/root

## 链接文件和我们 Windows 中常说的快捷方式类似.
## /var/mail 为链接文件 实际指向 /var/spool/mail 这个文件
[root@localhost ~]# ls /var/mail
lrwxrwxrwx. 1 root root 10 Mar  3 11:33 /var/mail -> spool/mail

## cd 命令是跳转工作目录的意思( 稍后讲解 ), 然后在查看当前工作目录
[root@localhost ~]# cd /var/mail/
[root@localhost mail]# pwd -L # <==  等于 pwd 命令
/var/mail

## -P 显示链接文件所指向的文件的路径
[root@localhost mail]# pwd -P
/var/spool/mail
```

## cd命令

### 描述

     用来切换工作目录至 DIR_NAME, DIR_NAME 可以使用绝对路径或者相对路径, 也可省略(表示跳转到登录用户的家目录, 家目录也就是用户登录成功之后所在的目录). 

>  ` ~ ` :  变量表示当前登录用户的家目录
> 
>  ` ~USERNAME`  :  切换到 USERNAME 用户的家目录
> 
> ` . ` :  表示当前目录
> 
> ` .. ` : 表示上一级目录
> 
> ` - ` : 切换到上次所在的目录, 变量 ` OLDPWD` 变量所表示的内容
> 
> ` !$ ` : 把上个命令的参数作为 cd 参数使用

### 语法

> cd    \[ DIR_NAME \]

### 实例

```bash
## 显示当前工作目录
[root@localhost ~]# pwd
/root

## 跳转到根目录并显示当前路径
[root@localhost ~]# cd /
[root@localhost /]# pwd
/

## 根目录的上一层目录还是根目录
[root@localhost /]# cd ..

[root@localhost /]# pwd
/

## 直接 cd 命令, 没有加上路径, 表示跳转到当前用户家目录
[root@localhost /]# cd    # 等于  cd ~ 命令
[root@localhost ~]# pwd
/root    <== root 用户的家目录为 /root

## - 返回到上一次所在的目录
[root@localhost ~]# cd -
/
[root@localhost /]# pwd
/

## 跳转到当前用户家目录
[root@localhost /]# cd ~
[root@localhost ~]# pwd
/root

## 跳转到 /home 目录, 显示当前目录下文件
[root@localhost ~]# cd /home
[root@localhost home]# ls
gkdaxue  lost+found

## 注意 - 是动态变化的, 始终表示上一次所在的目录, 所以是 /root
[root@localhost home]# cd -
/root

## !$ : 把上个命令的参数作为 cd 参数使用, 也就是 - 
[root@localhost ~]# cd !$
cd -
/home
[root@localhost home]# pwd
/home

## 先查看是否有 gkdaxue 这个用户, 确定有这个用户
[root@localhost /]# useradd gkdaxue
useradd: user 'gkdaxue' already exists   <== 说明这个用户已经存在,不存在则没有此行提示
[root@localhost /]# cd ~gkdaxue
[root@localhost gkdaxue]# pwd
/home/gkdaxue
```

## cal 命令

### 描述

显示 当前/指定日期 的日历

### 语法

> cal  \[ options \]  \[ \[ \[ day \] month \] year \]

### 选项

| 选项               | 含义            |
| ---------------- | ------------- |
| 1( 数字1, 不是小写的L ) | 仅显示当前月份( 默认 ) |
| -3               | 显示上一个,当前和下个月  |
| -m               | 星期一作为一周的第一天   |
| -s               | 星期日作为一周的第一天   |
| -j               | 一年中的第几天       |
| -y               | 显示当前年的日历      |

### 实例

```bash
## 今天时间为  2019-03-11 所以 3月11 应该是高亮显示的,但是有问题
## 显示当前月份
[root@localhost ~]# cal    # <==  等于 cal -l 
     March 2019     
Su Mo Tu We Th Fr Sa
                1  2
 3  4  5  6  7  8  9
10 11 12 13 14 15 16
17 18 19 20 21 22 23
24 25 26 27 28 29 30
31

## -m : 星期一作为一周的第一天
[root@localhost ~]# cal -m
     March 2019     
Mo Tu We Th Fr Sa Su
             1  2  3
 4  5  6  7  8  9 10
11 12 13 14 15 16 17
18 19 20 21 22 23 24
25 26 27 28 29 30 31

## -s : 星期日作为一周的第一天
[root@localhost ~]# cal -s
     March 2019     
Su Mo Tu We Th Fr Sa
                1  2
 3  4  5  6  7  8  9
10 11 12 13 14 15 16
17 18 19 20 21 22 23
24 25 26 27 28

## -3 : 显示上个月 本月 和 下个月
[root@localhost ~]# cal -3
    February 2019          March 2019            April 2019     
Su Mo Tu We Th Fr Sa  Su Mo Tu We Th Fr Sa  Su Mo Tu We Th Fr Sa
                1  2                  1  2      1  2  3  4  5  6
 3  4  5  6  7  8  9   3  4  5  6  7  8  9   7  8  9 10 11 12 13
10 11 12 13 14 15 16  10 11 12 13 14 15 16  14 15 16 17 18 19 20
17 18 19 20 21 22 23  17 18 19 20 21 22 23  21 22 23 24 25 26 27
24 25 26 27 28        24 25 26 27 28 29 30  28 29 30            
                      31  

## -j : 一年中的第几天
[root@localhost ~]# cal -j
         March 2019        
Sun Mon Tue Wed Thu Fri Sat
                     60  61
 62  63  64  65  66  67  68
 69  70  71  72  73  74  75
 76  77  78  79  80  81  82
 83  84  85  86  87  88  89
 90

## -y : 显示当前的日历
[root@localhost ~]# cal 2019  # <== 等于 cal -y 2019
                               2019                               

       January               February                 March       
Su Mo Tu We Th Fr Sa   Su Mo Tu We Th Fr Sa   Su Mo Tu We Th Fr Sa
       1  2  3  4  5                   1  2                   1  2
 6  7  8  9 10 11 12    3  4  5  6  7  8  9    3  4  5  6  7  8  9
13 14 15 16 17 18 19   10 11 12 13 14 15 16   10 11 12 13 14 15 16
20 21 22 23 24 25 26   17 18 19 20 21 22 23   17 18 19 20 21 22 23
27 28 29 30 31         24 25 26 27 28         24 25 26 27 28 29 30
                                              31
        April                   May                   June        
Su Mo Tu We Th Fr Sa   Su Mo Tu We Th Fr Sa   Su Mo Tu We Th Fr Sa
    1  2  3  4  5  6             1  2  3  4                      1
 7  8  9 10 11 12 13    5  6  7  8  9 10 11    2  3  4  5  6  7  8
14 15 16 17 18 19 20   12 13 14 15 16 17 18    9 10 11 12 13 14 15
21 22 23 24 25 26 27   19 20 21 22 23 24 25   16 17 18 19 20 21 22
28 29 30               26 27 28 29 30 31      23 24 25 26 27 28 29
                                              30
        July                  August                September     
Su Mo Tu We Th Fr Sa   Su Mo Tu We Th Fr Sa   Su Mo Tu We Th Fr Sa
    1  2  3  4  5  6                1  2  3    1  2  3  4  5  6  7
 7  8  9 10 11 12 13    4  5  6  7  8  9 10    8  9 10 11 12 13 14
14 15 16 17 18 19 20   11 12 13 14 15 16 17   15 16 17 18 19 20 21
21 22 23 24 25 26 27   18 19 20 21 22 23 24   22 23 24 25 26 27 28
28 29 30 31            25 26 27 28 29 30 31   29 30

       October               November               December      
Su Mo Tu We Th Fr Sa   Su Mo Tu We Th Fr Sa   Su Mo Tu We Th Fr Sa
       1  2  3  4  5                   1  2    1  2  3  4  5  6  7
 6  7  8  9 10 11 12    3  4  5  6  7  8  9    8  9 10 11 12 13 14
13 14 15 16 17 18 19   10 11 12 13 14 15 16   15 16 17 18 19 20 21
20 21 22 23 24 25 26   17 18 19 20 21 22 23   22 23 24 25 26 27 28
27 28 29 30 31         24 25 26 27 28 29 30   29 30 31

## 还能帮我们判断是否存在, 比如判断 2019 2 29 是否存在?
[root@localhost ~]# cal 29 2 2019
cal: illegal day value: use 1-28
```

## bc命令

### 描述

简单的计算器

### 实例

```bash
[root@localhost ~]# bc  # <== 会进入 bc 功能界面
bc 1.06.95
Copyright 1991-1994, 1997, 1998, 2000, 2004, 2006 Free Software Foundation, Inc.
This is free software with ABSOLUTELY NO WARRANTY.
For details type `warranty'. 
1+2+3+4+5   # 光标会等待输入, 输入完成计算后, 继续等待用户输入
15

5-6+9
8

10/100   <== 为什么 10/100 结果是 0 而不是 0.1 呢
0

10*20
200

2%5    % : 表示余数
2

2^3    ^ : 指数 2^3 = 8
8

quit  <== 退出 bc 功能界面
```

为啥 10/100 结果为 0 呢, 因为 bc 默认输出整数, 如果想要输出小数, 必须执行 `scale=number` , 其中 nunber 表示小数点后的位数. 实例如下所示 : 

```bash
[root@localhost ~]# bc
bc 1.06.95
Copyright 1991-1994, 1997, 1998, 2000, 2004, 2006 Free Software Foundation, Inc.
This is free software with ABSOLUTELY NO WARRANTY.
For details type `warranty'. 
scale=3  <== 在此处定义
10/100
.100     <== 会发现如果为小数点前为0, 就会把0 省略掉, 保留3位小数, 也就是 .100

10/3
3.333

quit     <== 退出
```

## sync命令

所有的数据都要被读入内存后才能被 CPU 所处理, 但是数据又经常需要由内存写回到硬盘当中(比如存储数据), 但是硬盘的速度太慢(相当于内存), 所以如果频繁的让数据在内存和硬盘中来回操作, 会降低系统的性能. 
因此在 Linu 中,为了加快数据的读取速度, 在默认的情况下, 某些已经加载在内存中的数据将不会被直接写回到硬盘, 而是暂存在内存中, 系统会不定时的把内存中的数据写入到硬盘中, 因此有些时候可以直接从内存中读取出来, 在速度上会提升很多. 但是也造成了一些困扰, 比如非正常关机, 可能就导致数据的更新不正常. 从而导致服务不能正常启动等等.

### 描述

强制将内存中的文件缓冲内容写到磁盘。

> root  用户 : 更新整个系统中的缓存数据
> 普通用户  : 更新自己的缓存数据 

### 实例

```bash
[root@localhost ~]# sync ; sync; sync  ## 一般执行三次, 特别是在 关机 或 重启, 建议执行一下此命令.
```

## reboot命令

reboot 命令用于重启系统, 格式为 ` reboot ` , 因为牵扯到硬件资源的管理权限,  所以默认只有 root 管理员来重启.

```bash
[root@localhost ~]# reoot
```

## poweroff命令

poweroff 命令用于关闭操作系统, 语法为 ` poweroff`,  默认只有 root 管理员你可以关闭电脑

```bash
[root@localhost ~]# poweroff
```

## shutdown命令

可以选择在什么时间  关闭/重启 操作系统 并且可以给出提示信息 

### 语法

> shutdown  \[ -t  秒  ]   \[ options \]  时间  \[  警告信息  ]

### 选项

| 选项       | 含义                                                                   |
| -------- | -------------------------------------------------------------------- |
| -t   sec | 过多少秒后关机                                                              |
| -r       | 将系统服务关闭后就重启                                                          |
| -h       | 将系统服务关闭后就关机                                                          |
| -c       | 取消关机                                                                 |
| 时间       | now : 立即操作<br >+Num : Num分钟之后进行操作 <br >Hours:Min : 在Hours小时Min分钟进行操作 |

### 实例

```bash
## -h : 10 分钟之后关机并给出提示信息
[root@localhost ~]# shutdown -h +10 'I will shutdown after 10 min'

Broadcast message from root@localhost.localdomain
    (/dev/pts/0) at 20:38 ...

The system is going down for halt in 10 minutes!
I will shutdown after 10 min   <== 自定义的提示信息

## 如果想取消, 可以 按 Ctrl + c 键取消
```

## init命令

### 运行等级(run level)

Linux系统中, 默认存在7个 run level ( 可以通过查看 /etc/inittab 了解 ), 每个等级对应的信息如下所示 :

| run level | 含义                                                                    |
| --------- | --------------------------------------------------------------------- |
| 0         | halt (Do NOT set initdefault to this)                                 |
| 1         | Single user mode                                                      |
| 2         | Multiuser, without NFS (The same as 3, if you do not have networking) |
| 3         | 完全多用户模式( 字符界面 )                                                       |
| 4         | 系统未使用，保留                                                              |
| 5         | X11控制台，登陆后进入图形GUI模式                                                   |
| 6         | reboot (Do NOT set initdefault to this)                               |

### 实例

```bash
## 显示前一个运行级别(无则显示 N ), 当前运行级别
[root@localhost ~]# runlevel
5 3

## 显示当前运行级别以及切换时间, 以及上一次的运行级别
[root@localhost ~]# who -r  
         run-level 3  2019-03-11 21:13                   last=5

## 切换到字符界面
[root@localhost ~]# init 3

## 切换到图形化界面(必须提前安装好图形化软件)
[root@localhost ~]# init 5
```

## wget命令

**wget命令用于下载网络文件, 前提是你必须安装好此软件才可以使用这个命令.**

### 语法

> wget  \[ options \]   下载链接地址

### 选项

| 选项  | 含义                 |
| --- | ------------------ |
| -b  | 后台下载模式             |
| -P  | 下载到指定目录            |
| -t  | 最大尝试次数             |
| -c  | 断点续传               |
| -p  | 下载页面内所有资源，包括图片、视频等 |
| -r  | 递归下载               |

### 实例

```bash
## 比如我们需要下载一个图片, 出现没有找到此命令, 说明没有安装 wget 软件, 现在只要了解即可
[root@localhost ~]# wget https://github.com/gkdaxue/linux/raw/master/image/chapter_A2_0001.png
-bash: wget: command not found

## 等确定你安装了 wget 软件, 在执行一下操作
[root@localhost ~]# wget https://github.com/gkdaxue/linux/raw/master/image/chapter_A2_0001.png
--2019-03-12 12:14:30--  https://github.com/gkdaxue/linux/raw/master/image/chapter_A2_0001.png
Resolving github.com... 52.74.223.119, 13.229.188.59, 13.250.177.223
Connecting to github.com|52.74.223.119|:443... connected.
HTTP request sent, awaiting response... 302 Found
Location: https://raw.githubusercontent.com/gkdaxue/linux/master/image/chapter_A2_0001.png [following]
--2019-03-12 12:14:33--  https://raw.githubusercontent.com/gkdaxue/linux/master/image/chapter_A2_0001.png
Resolving raw.githubusercontent.com... 151.101.108.133
Connecting to raw.githubusercontent.com|151.101.108.133|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 39200 (38K) [image/png]
Saving to: “chapter_A2_0001.png”

100%[=======================================================>] 39,200      54.4K/s   in 0.7s    

2019-03-12 12:14:34 (54.4 KB/s) - “chapter_A2_0001.png” saved [39200/39200]  <== 此行说明成功下载并保存

## 查看一下, 发现这个文件确实存在.
[root@localhost ~]# ls chapter_A2_0001.png 
chapter_A2_0001.png
```

## file命令

file 命令用于查看文件的类型, 因为` 在 Linux 中 一切皆文件(目录, 设备, 文本等等都是文件) ` ,  那我们怎么能知道这个文件到底是什么类型的文件?( Linux 不依靠后缀名区别文件, 后缀名只是给用户看的, 仅此而已).  所以就要用到 file 命令

> file  \[ options \] 文件名

### 选项

| 选项  | 含义                 |
| --- | ------------------ |
| -b  | 只显示文件格式和编码, 不显示文件名 |
| -i  | 显示 MIME 类型         |

### MIME类型

| text/plain         | 普通文本   |
| ------------------ | ------ |
| application/pdf    | PDF文档  |
| application/msword | Word文档 |
| image/png          | PNG图片  |
| image/jpeg         | JPEG图片 |
| application/x-tar  | TAR文件  |
| application/x-gzip | GZIP文件 |

### 实例

```bash
[root@localhost ~]# ls
anaconda-ks.cfg  Documents  install.log         Music     Public     Videos
Desktop          Downloads  install.log.syslog  Pictures  Templates

[root@localhost ~]# file anaconda-ks.cfg  

anaconda-ks.cfg: ASCII English text  <== 这是一个ASCII 的存文本文件

[root@localhost ~]# file Desktop/
Desktop/: directory   <== 这是一个目录

[root@localhost ~]# file anaconda-ks.cfg 
anaconda-ks.cfg: ASCII English text

[root@localhost ~]# file -b anaconda-ks.cfg 
ASCII English text    <== 只显示文件编码和格式, 不显示文件名


[root@localhost ~]# file -i anaconda-ks.cfg 
anaconda-ks.cfg: text/plain; charset=us-ascii  <== 显示 MIME 类型
```

## DOS 与 Linux 的换行符

DOS 与 Linux 换行符是不同的, 必须使用特殊的命令, 才能看到它们换行符的不同,比如 ( cat -A ) , 在

```bash
DOS   : CR 和 LF ( $ ) 两个符号, 为 ^M$ .
Linux : 仅有 LF ( $ )这个符号, 为 $ .
```

在 Linux 中 命令开始执行时, 它的判断依据为 Enter , 而 Linux 的 Enter 为 LF 符号.但是 DOS 为 CRLF, 多了一个 ^M, 如果是在一个 Windows 下写的 shell 程序, 放到 Linux 上面执行, 将有可能出现 程序无法执行, 就是因为误判的原因导致的.这个时候我们就需要把 CRLF → LF .

#### dos2unix 与 unix2dos 命令

使用这两个命令之前, 你必须设置好 你的网络 和 yum 源信息, 可以使用如下命令进行安装. 初学者只要了解即可, 现在只是为了讲解内容, 涉及到的内容会以后讲解.

> yum install -y dos2unix  unix2dos   wget

##### 选项

| 选项                       | 含义                                           |
| ------------------------ | -------------------------------------------- |
| -k                       | 不修改文件的 `mtime`                               |
| -n   OLD_FILE   NEW_FILE | 保留原文件( OLD_FILE ), 并把转换的内容输出到新文件( NEW_FILE ) |

##### 实例

```bash
## 下载我们需要转换的文件
[root@localhost ~]# wget https://raw.githubusercontent.com/gkdaxue/linux/master/tutorial_document/unix_type.txt

--2019-03-12 20:41:43--  https://raw.githubusercontent.com/gkdaxue/linux/master/tutorial_document/unix_type.txt
Resolving raw.githubusercontent.com... 151.101.228.133
Connecting to raw.githubusercontent.com|151.101.228.133|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 4617 (4.5K) [text/plain]
Saving to: “unix_type.txt”

100%[==================================================================>] 4,617       --.-K/s   in 0s      

2019-03-12 20:41:44 (98.5 MB/s) - “unix_type.txt” saved [4617/4617]

[root@localhost ~]# ls unix_type.txt 
unix_type.txt

[root@localhost ~]# file unix_type.txt 
unix_type.txt: ASCII English text   <== 显示文件的编码格式  这说明他是一个 unix 类型的文件

## 使用 -n 选项,
[root@localhost ~]# unix2dos -n unix_type.txt dos_type.txt
unix2dos: converting file unix_type.txt to file dos_type.txt in DOS format ...

## 对比两个文件, 为下面讲解做铺垫
[root@localhost ~]# file unix_type.txt dos_type.txt 
unix_type.txt: ASCII English text
dos_type.txt:  ASCII English text, with CRLF line terminators <== CRLF 说明这是 DOS 的换行类型
```

## cat命令

cat( concatenate, cat) 命令用于查看文本内容, 一般用于查看一些文件内容较少的文件, 因为文件过多会在屏幕上一闪而过, 无法正常查看.

### 选项

| 选项  | 含义                    |
| --- | --------------------- |
| -b  | 针对非空白行编号              |
| -E  | 讲行尾的断行字符 $ 显示出来       |
| -n  | 打印行号( 所有行, 包括空白行)     |
| -T  | 将 Tab 键以 ^I ( 大写的 i ) |
| -v  | 列出一些看不出来的特殊字符         |
| -A  | 相当于 -vET              |

### 实例

```bash
## 不加选项参数, 查看
[root@localhost ~]# cat /etc/issue
CentOS release 6.9 (Final)
Kernel \r on an \m

## -E 显示换行符 $
[root@localhost ~]# cat -E /etc/issue
CentOS release 6.9 (Final)$  <== 换行符 $ 
Kernel \r on an \m$
$

## -b : 不对空白行编号
[root@localhost ~]# cat -b /etc/issue
     1    CentOS release 6.9 (Final)
     2    Kernel \r on an \m
                             <== 这是空白行, 不编号

## -n : 对所有行编号
[root@localhost ~]# cat -n /etc/issue
     1    CentOS release 6.9 (Final)
     2    Kernel \r on an \m
     3                         <== 空白行也进行了编号 

## -T : 将 Tab 键以 ^I 显示出来
## tail 以及 |(管道符) 的作用是显示最后 5 行, 稍后讲解

[root@localhost ~]# cat -T unix_type.txt  | tail -n 5
.bz2^I^I/usr/bin/bzip2 -c -d   <== 能看到很多 ^I
.z^I^I
.Z^I^I/bin/zcat
.F^I^I
.Y^I^I

## 对比 DOS 和 Linux 的换行符显示结果,同样的内容, 转换之后换行符不同.
[root@localhost ~]# cat -A unix_type.txt | tail -n 5
.bz2^I^I/usr/bin/bzip2 -c -d$    <== 这是 $
.z^I^I$ 
.Z^I^I/bin/zcat$
.F^I^I$
.Y^I^I$
[root@localhost ~]# cat -A dos_type.txt | tail -n 5
.bz2^I^I/usr/bin/bzip2 -c -d^M$  <== 这是 ^M$
.z^I^I^M$
.Z^I^I/bin/zcat^M$
.F^I^I^M$
.Y^I^I^M$
```

### 其他使用方式

1. **接受标准输入, 常用在脚本中提供菜单选项**

   ```bash
   [root@localhost ~]# cat <<EOF
   > [1] Start
   > [2] Restart
   > [3] Shutdown
   > [4] Exit
   > EOF
   [1] Start
   [2] Restart
   [3] Shutdown
   [4] Exit
   ```

2. **将多个文件内容导入到一个文件中**

   ```bash
   ## 关于 >(标准覆盖输出重定向) 的用法 以后讲解
   [root@localhost ~]# cat /etc/issue
   CentOS release 6.9 (Final)
   Kernel \r on an \m
          <== 此处为自带空白行
   [root@localhost ~]# cat /etc/issue /etc/issue > issue_new.txt
   [root@localhost ~]# cat issue_new.txt 
   CentOS release 6.9 (Final)
   Kernel \r on an \m
   
   CentOS release 6.9 (Final)
   Kernel \r on an \m
   ```

3. **清空文件内容**

   ```bash
   [root@localhost ~]# cat issue_new.txt 
   CentOS release 6.9 (Final)
   Kernel \r on an \m
   
   CentOS release 6.9 (Final)
   Kernel \r on an \m
   
   ## /dev/null 就是一个空文件
   [root@localhost ~]# cat /dev/null > issue_new.txt 
   [root@localhost ~]# cat issue_new.txt 
   [root@localhost ~]#
   ```

4. **直接把内容存储到文件中**

   ```bash
   [root@localhost ~]# cat issue_new.txt 
   
   ## 先输入内容, 输入完成后按 Enter 键进入下一个新行, 然后按 Ctrl + d 结束输入即可
   [root@localhost ~]# cat > issue_new.txt 
   gkdaxue.com
   [root@localhost ~]# cat issue_new.txt 
   gkdaxue.com
   ```

   # 

## tac命令

看到这个命令, 大家是不是觉得就是 ` cat ` 命令反着来写吗, 所以它的功能就是` 从文件最后一行到第一行反向在屏幕上显示出来` . 其他选项和 ` cat ` 一致.

### 实例

```bash
[root@localhost ~]# cat /etc/issue
CentOS release 6.9 (Final)
Kernel \r on an \m

[root@localhost ~]# tac /etc/issue

Kernel \r on an \m
CentOS release 6.9 (Final)
```

## nl命令

显示文件的行数

### 选项

| 选项     | 含义                          |
| ------ | --------------------------- |
| -b  a  | 给所有行编号(包含空白行) 类似于 cat -n 命令 |
| -b  t  | 空白行不编号(默认值), 类似于 cat -b 命令  |
| -n  ln | 在特定字段的最左方显示行号               |
| -n  rn | 在特定字段的最右方显示且不加 0            |
| -n  rz | 在特定字段的最右方显示且加 0             |
| -w     | 行号字段占用的位数                   |

### 实例

```bash
## 空白行不编号
[root@localhost ~]# nl /etc/issue  # = nl -b t /etc/issue = cat -b /etc/issue
     1    CentOS release 6.9 (Final)
     2    Kernel \r on an \m

## 对所有行进行编号       
[root@localhost ~]# nl -b a /etc/issue  # = cat -a /etc/issue
     1    CentOS release 6.9 (Final)
     2    Kernel \r on an \m
     3    

## 列出行号(默认行号占6位)
[root@localhost ~]# nl -n ln /etc/issue
1         CentOS release 6.9 (Final)
2         Kernel \r on an \m

[root@localhost ~]# nl -n rn /etc/issue
     1    CentOS release 6.9 (Final)
     2    Kernel \r on an \m

[root@localhost ~]# nl -n rz /etc/issue
000001    CentOS release 6.9 (Final)  <== 显示为 000001

000002    Kernel \r on an \m

## 指定行号所占用的位数       
[root@localhost ~]# nl -n rz -w 3 /etc/issue
001    CentOS release 6.9 (Final)  <== 显示为 001

002    Kernel \r on an \m

[root@localhost ~]#
```

# 简单文本编辑器:nano

` nano FILE_NAME ` 就可以打开或者新建一个文件,

```bash
[root@localhost ~]# nano gkdaxue.txt
## | : 表示光标的意思
## ^ : 此处表示为 Ctrl 按键
## M : 表示 Alt 按键
  GNU nano 2.0.9                File: gkdaxue.txt                                      
|         <== 光标在此处等待输入, 比如我们输入 gkdaxue, 就会变成下面这样
gkdaxue|  <== 我们输入内容后, 就变成这样




                                     [ New File ]  <== 说明这是在新建文件并写入内容

^G Get Help   ^O WriteOut   ^R Read File  ^Y Prev Page  ^K Cut Text   ^C Cur Pos
^X Exit       ^J Justify    ^W Where Is   ^V Next Page  ^U UnCut Text ^T To Spell

## 然后我们可以使用 Ctrl + X 退出, 会有如下提示(只有有内容才会提示,否则直接退出)
  GNU nano 2.0.9               File: gkdaxue.txt                           Modified 

gkdaxue


Save modified buffer (ANSWERING "No" WILL DESTROY CHANGES) ?          
 Y Yes
 N No           ^C Cancel

## 然后按下 Y 键, 变成如下内容
  GNU nano 2.0.9               File: gkdaxue.txt                           Modified  

gkdaxue



File Name to Write: gkdaxue.txt |                                                      

^G Get Help          ^T To Files          M-M Mac Format       M-P Prepend
^C Cancel            M-D DOS Format      M-A Append           M-B Backup File

## 直接敲 Enter 键即可保存内容并退出, 具体更多的功能自己可以根据帮助文档 Ctrl + G 来实验
[root@localhost ~]# cat gkdaxue.txt 
gkdaxue
```

# CentOS6 修改root密码

有的时候刚设置好root密码, 结果就忘记密码了, 那么我们就可以使用 `单用户维护模式` 登录系统,  修改 root 密码即可.

> 1. 在读秒界面按下任意键, 出现如下信息
>    
>    ```bash
>    CentOS 6 (2.6.32-696.el6.x86_64)
>    
>    ## 然后下面还有一些操作的提示说明
>    ```
> 
> 2. 然后根据菜单说明, 按 e 键, 出现如下菜单
>    
>    ```bash
>    root (hd0, 0)
>    kernel /vmlinuz-2.6.32-696.el6.x86_64 ro root=.........
>    initrd /initramfs-2.6.32-696.el6.x86_64.img
>    ```
> 
> 3. 根据菜单提示, 按下 下方向键( ↓ ), 选中 kernel 这行, 然后按 e 键
> 
> 4. 然后在最后追加输入 ` single`, 前边有一个空格不要忘记, 输入完成, 按 Enter 键
> 
> 5. 然后根据菜单提示 按 b 键 重新引导启动系统
> 
> 6. 等待一会, 出现如下界面:
>    
>    ```bash
>    ## 我们现在是以root身份并且没有输入root密码
>    [root@localhost /]# passwd ## <== 使用 passwd 命令修改密码即可.
>    ...
>    ```
> 
> 7. 然后输入 reboot 重新启动系统即可
>    
>    ```bash
>    ## 重启系统
>    [root@localhost /]# reboot
>    ```
