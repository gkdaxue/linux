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

## 我们可以看出 pwd 有那么多的帮助文件信息
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
## 编写一个 shell 脚本, 判断运行了多久, 代码如下(了解即可)
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
[root@localhost ~]# ls
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

## -l : 长格式显示, 包含权限, 所有者, 所有组, 文件大小等信息
[root@localhost ~]# ls -l  # <== 可以简写为 ll 因为 alias 别名的原因.

total 72
-rw-------. 1 root root  1638 Mar  3 11:42 anaconda-ks.cfg
-rw-r--r--. 1 root root 50698 Mar  3 11:42 install.log
-rw-r--r--. 1 root root 10031 Mar  3 11:39 install.log.syslog

## -i : 显示 inode 节点信息, 如下面的 ( 7249, 18, 30 )等
[root@localhost ~]# ls -il  #<== 短格式可以合并, 并保留一个 '-'

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
| -p  | 有链接文件时，不使用链接路径，直接显示链接文件所指向的文件,<br>多层连接文件时，显示所有连接文件最终指向的文件全路径 |

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




