# 数据流重定向

数据流重定向就是将某个命令执行后应该出现在屏幕上的数据传输到其他地方. 主要有以下三种形式 : 

> **标准输入重定向(Standard Input, STDIN)** : 文件描述符为0, 默认从键盘输入(也可从其他文件或者命令输入) 使用 < 或 << 
> 
> **标准输出重定向( Standard Output, STDOUT)** : 文件描述符为 1 , 默认输出到屏幕, 使用 > 或者 >>
> 
> **错误输出重定向( Standard Error, STDERR)** : 文件描述符为 2 , 默认输出到屏幕, 使用 2> 或者 2>>

![数据流重定向](https://github.com/gkdaxue/linux/raw/master/image/chapter_A3_0001.png)

当我们执行一个命令的时候, 这个命令可能会由文件读入数据, 经过处理之后, 再讲数据输出到屏幕上. 然后就有两种输出 **"标准输出"**  和 **"标准错误输出"** 这两种形式.

> 标准输出 : 命令执行回传的正确的信息
> 
> 标准错误输出 : 命令执行失败后, 所回传的错误信息

然后我们来实际操作一下, 对比一下这两种输出信息:

```bash
[root@localhost ~]# ls 
anaconda-ks.cfg  Documents     Downloads    install.log.syslog  Pictures  Templates      Videos
Desktop          dos_type.txt  install.log  Music               Public    unix_type.txt

## 查看一个存在的文件   
[root@localhost ~]# ls -l anaconda-ks.cfg 
-rw-------. 1 root root 1638 Mar  3 11:42 anaconda-ks.cfg   <== 标准输出

## 查看一个不存在的文件
[root@localhost ~]# ls -l xxxx
ls: cannot access xxxx: No such file or directory   <== 标准错误输出, 因为返回的为错误信息
```

不管正确或错误的数据默认都是输出到屏幕上, 那么会使屏幕看上去很混乱, 那么我们如何将这两种信息分开来, 这就是我们所说的数据流重定向的功能, 会用到我们上面讲的 文件描述符 .

## 输入重定向

| 符号                  | 作用                       |
| ------------------- | ------------------------ |
| command <  文件       | 将文件作为命令的标准输入             |
| command <<  分界符     | 从标准输入中读入，直到遇见分界符才停止      |
| command < 文件1 > 文件2 | 将文件1作为命令的标准输入并将标准输出到文件2中 |

## 输出重定向

| 符号                                            | 作用                             |
| --------------------------------------------- | ------------------------------ |
| command > 文件                                  | 将标准输出重定向到一个文件中（清空原有文件的数据）      |
| command 2> 文件                                 | 将错误输出重定向到一个文件中（清空原有文件的数据）      |
| command  >> 文件                                | 将标准输出重定向到一个文件中（追加到原有内容的后面）     |
| command 2>> 文件                                | 将错误输出重定向到一个文件中（追加到原有内容的后面）     |
| command  >> 文件 2>  &1<br>或<br>command  &>> 文件 | 将标准输出与错误输出共同写入到文件中（追加到原有内容的后面） |

> 标准输出重定向的文件描述符为 1, 但是可以省略, 所以 command  > 文件  =  command  1>  文件
> 
> 文件描述符 与 >/>> 之间没有空格并且作为一个整体, 左右两边各有一个空格
> 
> \>    :  表示清空写入的方式(清空原有文件内容,然后写入)
> 
> \>\>  :  表示追加写入的方式(附加在原有文件内容之后)

## 输出重定向演示

```bash
## 查看当前
[root@localhost ~]# ls -l
total 104
-rw-------. 1 root root  1638 Mar  3 11:42 anaconda-ks.cfg
drwxr-xr-x. 2 root root  4096 Mar 12 09:53 Desktop
drwxr-xr-x. 2 root root  4096 Mar 12 09:53 Documents
drwxr-xr-x. 2 root root  4096 Mar 12 09:53 Downloads
-rw-r--r--. 1 root root 50698 Mar  3 11:42 install.log
-rw-r--r--. 1 root root 10031 Mar  3 11:39 install.log.syslog
drwxr-xr-x. 2 root root  4096 Mar 12 09:53 Music
drwxr-xr-x. 2 root root  4096 Mar 12 09:53 Pictures
drwxr-xr-x. 2 root root  4096 Mar 12 09:53 Public
drwxr-xr-x. 2 root root  4096 Mar 12 09:53 Templates
drwxr-xr-x. 2 root root  4096 Mar 12 09:53 Videos

## 标准输出重定向, 把输出的内容导入到 home_dir_file 文件中
[root@localhost ~]# ls -l > home_dir_file   # <== 使用 清空写入的方式
[root@localhost ~]# cat home_dir_file 
total 104
-rw-------. 1 root root  1638 Mar  3 11:42 anaconda-ks.cfg
drwxr-xr-x. 2 root root  4096 Mar 12 09:53 Desktop
drwxr-xr-x. 2 root root  4096 Mar 12 09:53 Documents
drwxr-xr-x. 2 root root  4096 Mar 12 09:53 Downloads
-rw-r--r--. 1 root root     0 Mar 13 22:37 home_dir_file
-rw-r--r--. 1 root root 50698 Mar  3 11:42 install.log
-rw-r--r--. 1 root root 10031 Mar  3 11:39 install.log.syslog
drwxr-xr-x. 2 root root  4096 Mar 12 09:53 Music
drwxr-xr-x. 2 root root  4096 Mar 12 09:53 Pictures
drwxr-xr-x. 2 root root  4096 Mar 12 09:53 Public
drwxr-xr-x. 2 root root  4096 Mar 12 09:53 Templates
drwxr-xr-x. 2 root root  4096 Mar 12 09:53 Videos

## 使用覆盖写入(清空写入)方式, 修改文件内容并查看
[root@localhost ~]# echo 'www.gkdaxue.com' > home_dir_file  # <== 清空写入的方式
[root@localhost ~]# cat home_dir_file 
www.gkdaxue.com    <== 发现之前的内容被清空

## 给文件中追加一个新内容,并查看
[root@localhost ~]# echo 'this is append content' >> home_dir_file  # <== 追加写入的方式
[root@localhost ~]# cat home_dir_file 
www.gkdaxue.com
this is append content  <== 内容被成功追加进去

## 使用 标准错误输出重定向  2>
[root@localhost ~]# echo 'www.gkdaxue.com' 2> home_dir_file 
www.gkdaxue.com  <== 此行显示是因为没有错误, 2> 只能处理错误信息, 所以标准输出继续执行.也就是输出 echo 的内容
[root@localhost ~]# cat home_dir_file   # <== 查看文件内容为空的, 因为没有错误并且是清空方式写入

[root@localhost ~]# 

## 查看一个不存在的文件
[root@localhost ~]# cat  xxxxxxx  2> home_dir_file   # <== 发现没有错误信息输出
[root@localhost ~]# cat home_dir_file 
cat: xxxxxxx: No such file or directory   <== 错误信息被成功的写入到文件中, 同理还有 2>> 追加写入.
```

home_dir_file 文件的处理方式为 :

> 1. 判断 home_dir_file 是否存在, 不存在则进行创建
> 
> 2. 我们使用的为 > , 表示为清空写入的意思, 清空原文件内容, 并把新内容写入, 查看
> 
> 3. 又使用了 >> 追加写入方式, 发现原内容没有被清空. 所以显示了我们添加的所有信息
> 
> 4. 然后我们使用了错误覆盖写入的方式(只能处理错误,不能处理标准输出), 因为没有错误,  所以标准输出继续执行, 文件内容为空
> 
> 5. 然后查看一个不存在的文件, 并把错误写入到文件中, 发现屏幕没有错误信息输出, 查看文件, 发现错误信息被写入

由此, 我们可以看到 标准输出 和 标准错误输出 它们是不同的事件, 所以处理它们的方式就要根据需求来处理. 那么我们如果想要同时处理这两种事件, 应该怎么处理呢? 请根据上面的表格, 自己试验.

> 1>   : 以覆盖的方式将 `正确的数据` 输出到指定的文件或者设备上
> 
> 1>> : 以追加的方式将 `正确的数据` 输出到指定的文件或者设备上
> 
> 2>   : 以覆盖的方式将 `错误的数据` 输出到指定的文件或者设备上
> 
> 2>> : 以追加的方式将 `错误的数据` 输出到指定的文件或者设备上

## 其他情况

```bash
## 将 stdout 和 stderr 写入到不同的文件中
command  > stdour_file  2>  stdout_err_file

## 将 stdout 和 stderr 写入到同一个文件中
## 由于两条数据同时写入到同一个文件中, 此时两条数据可能会交叉写入到文件中, 造成次序的混乱.
command  &>> stdout_file       <== stdout 和 stderr 信息都会被写入到文件中
command > stdout_file  2> &1   <== stdout 和 stderr 信息都会被写入到文件中

## /dev/null 是一个黑洞文件, 可以把任何无用的信息导入到此文件
## 只保留 stderr 信息, 不保留 stdout 文件( 一般日志的处理方式 )
command  > /dev/null 2> stdout_err_file
```

# 管道命令(pipe)

管道命令符 "|" (按下 Shift + \\ 键) 仅能处理前一个命令传来的正确数据, 也就是 Standard Output (STDOUT), 而 对于  Standard Error (STDERR) 则没有处理的功能, 所以总结如下:

> 管道命令仅能处理 STDOUT, 对于 STDERR  会进行忽略
> 
> 管道命令必须能够接收前一个命令的数据成为 Standard Input 继续处理才可以.比如(ls, cp, mv 就不是管道命令)

```bash
[root@localhost ~]# echo '/' > home_dir_file 
[root@localhost ~]# cat home_dir_file 
/

## 按道理来说应该是查看 / 文件下的内容, 但是不是管道命令, 所以还是查看当前目录下内容
[root@localhost ~]# cat home_dir_file  | ls
anaconda-ks.cfg  Documents  home_dir_file  install.log.syslog  Pictures  Templates
Desktop          Downloads  install.log    Music               Public    Videos
```

![管道命令](https://github.com/gkdaxue/linux/raw/master/image/chapter_A3_0002.png)

# Linux基础命令2

## more命令

之前我们学些的 nl, cat, tac 命令, 都会把数据全部显示出来, 根本无法正常查看, 所以对于文章内容过多的文件, 我们可以使用 more 命令来进行查看

### 交互式命令

| 按键                  | 说明                       |
| ------------------- | ------------------------ |
| **b**               | **向上翻页(只对文件有用)**         |
| **空格键 / Page Down** | **向下翻一页**                |
| **Enter**           | **向下翻一行**                |
| /字符串                | 向下搜索指定的字符串(n和N控制向下和向上查找) |
| =                   | 显示当前行号                   |
| **:f**              | **显示文件名以及当前显示的行号**       |
| v                   | 调用vi编辑器                  |
| **q**               | **退出**                   |

### 实例

```bash
[root@localhost ~]# man man > gkdaxue.txt
[root@localhost ~]# more gkdaxue.txt
man(1)                                                                  man(1)



NAME
       man - format and display the on-line manual pages

SYNOPSIS
       man [-acdDfFhkKtvVwW] [--path] [-m system] [-p string] [-C config_file]
       [-M pathlist] [-P pager] [-B browser] [-H htmlpager] [-S  section_list]
       [section] name ...


DESCRIPTION
       man formats and displays the on-line manual pages.  If you specify sec-
       tion, man only looks in that section of the manual.  name  is  normally
       the  name of the manual page, which is typically the name of a command,
       function, or file.  However, if name contains  a  slash  (/)  then  man
       interprets  it  as a file specification, so that you can do man ./foo.5
       or even man /cd/foo/bar.1.gz.

       See below for a description of where man  looks  for  the  manual  page
       files.


MANUAL SECTIONS
       The standard sections of the manual include:
--More--(8%)  <== 此处会显示文章进度, 同时光标也在此等待你的命令.


## 自己可以尝试以上的所有命令, 常用的就是标黑的按键
## 你可以输入 /man, 并按 Enter 键 即开始搜索, 按 n 键 可以查看下一个. 
```

## head命令

如果我们只是单纯的想要看文件的前 N 行, 使用 more 也可以完成, 但是比较麻烦, 所以就要用到我们说的 head 命令.

> head  \[  options \]  文件...

### 选项

| 选项    | 含义                                  |
| ----- | ----------------------------------- |
| -n  N | 显示的行数 ( 负数除了尾部 N 外,显示剩余所有内容 )       |
| -v    | 显示文件名 ( 默认单个文件不显示,多个文件显示 )          |
| -q    | 隐藏文件名 ( 当指定了多个文件时,在内容的前面会 以文件名作为开头) |

### 实例

```bash
## nl -n rz -w 3 /etc/passwd : 在行数字段右边显示行数 长度为3且补0
## | : 也就是我们所说的管道符, 可以把前边的内容交给后边的命令继续处理

## head -n 15 : 显示前15行内容
## > : 也就是标准输出重定向, 把前15行的内容覆盖写入到  head_file.txt 文件中
[root@localhost ~]# nl -n rz -w 3 /etc/passwd | head -n 15 > head_file.txt
[root@localhost ~]# cat head_file.txt
001	root:x:0:0:root:/root:/bin/bash
002	bin:x:1:1:bin:/bin:/sbin/nologin
003	daemon:x:2:2:daemon:/sbin:/sbin/nologin
004	adm:x:3:4:adm:/var/adm:/sbin/nologin
005	lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin
006	sync:x:5:0:sync:/sbin:/bin/sync
007	shutdown:x:6:0:shutdown:/sbin:/sbin/shutdown
008	halt:x:7:0:halt:/sbin:/sbin/halt
009	mail:x:8:12:mail:/var/spool/mail:/sbin/nologin
010	uucp:x:10:14:uucp:/var/spool/uucp:/sbin/nologin
011	operator:x:11:0:operator:/root:/sbin/nologin
012	games:x:12:100:games:/usr/games:/sbin/nologin
013	gopher:x:13:30:gopher:/var/gopher:/sbin/nologin
014	ftp:x:14:50:FTP User:/var/ftp:/sbin/nologin
015	nobody:x:99:99:Nobody:/:/sbin/nologin

## 如果直接 head 文件, 那么默认显示文件前 10 行
[root@localhost ~]# head head_file.txt   # 等于 head -n 10 head_file.txt, 10 前边可以带 + 号

001	root:x:0:0:root:/root:/bin/bash
002	bin:x:1:1:bin:/bin:/sbin/nologin
003	daemon:x:2:2:daemon:/sbin:/sbin/nologin
004	adm:x:3:4:adm:/var/adm:/sbin/nologin
005	lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin
006	sync:x:5:0:sync:/sbin:/bin/sync
007	shutdown:x:6:0:shutdown:/sbin:/sbin/shutdown
008	halt:x:7:0:halt:/sbin:/sbin/halt
009	mail:x:8:12:mail:/var/spool/mail:/sbin/nologin
010	uucp:x:10:14:uucp:/var/spool/uucp:/sbin/nologin

## -n 5 : 显示文件前 5 行, 可以带 + 号
[root@localhost ~]# head -n 5 head_file.txt
001	root:x:0:0:root:/root:/bin/bash
002	bin:x:1:1:bin:/bin:/sbin/nologin
003	daemon:x:2:2:daemon:/sbin:/sbin/nologin
004	adm:x:3:4:adm:/var/adm:/sbin/nologin
005	lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin

## -n -10 : 除了最后 10 行外, 全部显示
[root@localhost ~]# head -n -10 head_file.txt 
001	root:x:0:0:root:/root:/bin/bash
002	bin:x:1:1:bin:/bin:/sbin/nologin
003	daemon:x:2:2:daemon:/sbin:/sbin/nologin
004	adm:x:3:4:adm:/var/adm:/sbin/nologin
005	lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin

## 显示文件名, 默认单个文件不显示文件名, 多个文件显示文件名
[root@localhost ~]# head -n 5 -v head_file.txt 
==> head_file.txt <==          <== 这是文件名
001	root:x:0:0:root:/root:/bin/bash
002	bin:x:1:1:bin:/bin:/sbin/nologin
003	daemon:x:2:2:daemon:/sbin:/sbin/nologin
004	adm:x:3:4:adm:/var/adm:/sbin/nologin
005	lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin

## 显示文件名, 多文件默认显示文件名

[root@localhost ~]# head -n 5 head_file.txt head_file.txt # 等于  head -n 5 -v head_file.txt head_file.txt
==> head_file.txt <==
001	root:x:0:0:root:/root:/bin/bash
002	bin:x:1:1:bin:/bin:/sbin/nologin
003	daemon:x:2:2:daemon:/sbin:/sbin/nologin
004	adm:x:3:4:adm:/var/adm:/sbin/nologin
005	lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin

==> head_file.txt <==
001	root:x:0:0:root:/root:/bin/bash
002	bin:x:1:1:bin:/bin:/sbin/nologin
003	daemon:x:2:2:daemon:/sbin:/sbin/nologin
004	adm:x:3:4:adm:/var/adm:/sbin/nologin
005	lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin

## 隐藏文件名, 不显示
[root@localhost ~]# head -n 5 -q head_file.txt head_file.txt 
001	root:x:0:0:root:/root:/bin/bash
002	bin:x:1:1:bin:/bin:/sbin/nologin
003	daemon:x:2:2:daemon:/sbin:/sbin/nologin
004	adm:x:3:4:adm:/var/adm:/sbin/nologin
005	lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin
001	root:x:0:0:root:/root:/bin/bash
002	bin:x:1:1:bin:/bin:/sbin/nologin
003	daemon:x:2:2:daemon:/sbin:/sbin/nologin
004	adm:x:3:4:adm:/var/adm:/sbin/nologin
005	lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin
```

## tail命令

tail 命令用户查看文件的后 N 行 或者 检测文件直到按下 Ctrl + c 键.

### 选项

| 选项            | 含义                             |
| ------------- | ------------------------------ |
| -n  {+\|\-\}N | 显示文件最后几行(+N : 不显示文档开始的前 N-1 行) |
| -q            | 不输出各个文件名(多个文件)                 |
| -v            | 总是显示文件名                        |
| -f            | 动态监视文档最新追加的内容(比如日志)            |

### 实例

```bash
[root@localhost ~]# nl -n rz -w 3 /etc/passwd | head -n 15 > head_file.txt
[root@localhost ~]# cat head_file.txt 
001	root:x:0:0:root:/root:/bin/bash
002	bin:x:1:1:bin:/bin:/sbin/nologin
003	daemon:x:2:2:daemon:/sbin:/sbin/nologin
004	adm:x:3:4:adm:/var/adm:/sbin/nologin
005	lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin
006	sync:x:5:0:sync:/sbin:/bin/sync
007	shutdown:x:6:0:shutdown:/sbin:/sbin/shutdown
008	halt:x:7:0:halt:/sbin:/sbin/halt
009	mail:x:8:12:mail:/var/spool/mail:/sbin/nologin
010	uucp:x:10:14:uucp:/var/spool/uucp:/sbin/nologin
011	operator:x:11:0:operator:/root:/sbin/nologin
012	games:x:12:100:games:/usr/games:/sbin/nologin
013	gopher:x:13:30:gopher:/var/gopher:/sbin/nologin
014	ftp:x:14:50:FTP User:/var/ftp:/sbin/nologin
015	nobody:x:99:99:Nobody:/:/sbin/nologin

## 默认最后 10 行
[root@localhost ~]# tail head_file.txt # 等于  tail -n [-]10 head_file.txt  []表示可省略的意思

006	sync:x:5:0:sync:/sbin:/bin/sync
007	shutdown:x:6:0:shutdown:/sbin:/sbin/shutdown
008	halt:x:7:0:halt:/sbin:/sbin/halt
009	mail:x:8:12:mail:/var/spool/mail:/sbin/nologin
010	uucp:x:10:14:uucp:/var/spool/uucp:/sbin/nologin
011	operator:x:11:0:operator:/root:/sbin/nologin
012	games:x:12:100:games:/usr/games:/sbin/nologin
013	gopher:x:13:30:gopher:/var/gopher:/sbin/nologin
014	ftp:x:14:50:FTP User:/var/ftp:/sbin/nologin
015	nobody:x:99:99:Nobody:/:/sbin/nologin

## -n +5 : 表示除了前边 4 行, 都显示
[root@localhost ~]# tail -n +5 head_file.txt 
005	lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin
006	sync:x:5:0:sync:/sbin:/bin/sync
007	shutdown:x:6:0:shutdown:/sbin:/sbin/shutdown
008	halt:x:7:0:halt:/sbin:/sbin/halt
009	mail:x:8:12:mail:/var/spool/mail:/sbin/nologin
010	uucp:x:10:14:uucp:/var/spool/uucp:/sbin/nologin
011	operator:x:11:0:operator:/root:/sbin/nologin
012	games:x:12:100:games:/usr/games:/sbin/nologin
013	gopher:x:13:30:gopher:/var/gopher:/sbin/nologin
014	ftp:x:14:50:FTP User:/var/ftp:/sbin/nologin
015	nobody:x:99:99:Nobody:/:/sbin/nologin

## 接下来我们演示 -f 参数的作用. 主要用于查看日志等文件, 动态监听文件内容变化.
## tty 用于查看当前终端
[root@localhost ~]# tty
/dev/pts/0   <== 我们叫它 0 号终端

[root@localhost ~]# tail -f head_file.txt 
006	sync:x:5:0:sync:/sbin:/bin/sync
007	shutdown:x:6:0:shutdown:/sbin:/sbin/shutdown
008	halt:x:7:0:halt:/sbin:/sbin/halt
009	mail:x:8:12:mail:/var/spool/mail:/sbin/nologin
010	uucp:x:10:14:uucp:/var/spool/uucp:/sbin/nologin
011	operator:x:11:0:operator:/root:/sbin/nologin
012	games:x:12:100:games:/usr/games:/sbin/nologin
013	gopher:x:13:30:gopher:/var/gopher:/sbin/nologin
014	ftp:x:14:50:FTP User:/var/ftp:/sbin/nologin
015	nobody:x:99:99:Nobody:/:/sbin/nologin
      <== 光标在这个地方, 就像卡着了一样, 监听这变化

## 然后切换到 1 号终端, 并执行以下命令
[root@localhost ~]# tty
/dev/pts/1   <== 我们叫它 1 号终端

[root@localhost ~]# echo 'www.gkdaxue.com' >> head_file.txt 

## 此时在切换到 0 号终端
[root@localhost ~]# tail -f head_file.txt 
006	sync:x:5:0:sync:/sbin:/bin/sync
007	shutdown:x:6:0:shutdown:/sbin:/sbin/shutdown
008	halt:x:7:0:halt:/sbin:/sbin/halt
009	mail:x:8:12:mail:/var/spool/mail:/sbin/nologin
010	uucp:x:10:14:uucp:/var/spool/uucp:/sbin/nologin
011	operator:x:11:0:operator:/root:/sbin/nologin
012	games:x:12:100:games:/usr/games:/sbin/nologin
013	gopher:x:13:30:gopher:/var/gopher:/sbin/nologin
014	ftp:x:14:50:FTP User:/var/ftp:/sbin/nologin
015	nobody:x:99:99:Nobody:/:/sbin/nologin
www.gkdaxue.com   <== 这是我们在 1 号终端添加的内容

   <== 光标又停在了这个地方, 等待继续监听变化, 如果想结束, 按 Ctrl + c 键         
```

## stat命令

显示文件或文件系统状态等信息

> stat  \[  options  \]  FILE....

### 选项

| 选项  | 含义                       |
| --- | ------------------------ |
| -f  | 不显示文件本身的信息，显示文件所在文件系统的信息 |

### 实例

```bash
[root@localhost ~]# ls
anaconda-ks.cfg  Documents  gkdaxue.txt    install.log         Music     Public     Videos
Desktop          Downloads  head_file.txt  install.log.syslog  Pictures  Templates

[root@localhost ~]# stat anaconda-ks.cfg 
  File: `anaconda-ks.cfg'
  Size: 1638      	Blocks: 8          IO Block: 4096   regular file
Device: 805h/2053d	Inode: 7249        Links: 1
Access: (0600/-rw-------)  Uid: (    0/    root)   Gid: (    0/    root)
Access: 2019-03-13 13:04:52.090147568 +0800   <== 以下是文件的 3 种时间, 以后讲解

Modify: 2019-03-03 11:42:06.168998405 +0800
Change: 2019-03-03 11:42:22.232998400 +0800

[root@localhost ~]# stat -f anaconda-ks.cfg 
  File: "anaconda-ks.cfg"
    ID: c02549cbc78324f0 Namelen: 255     Type: ext2/ext3
Block size: 4096       Fundamental block size: 4096
Blocks: Total: 495764     Free: 418079     Available: 392479
Inodes: Total: 128000     Free: 120580
```

## touch命令

创建文件  或   修改文件/目录  的时间

### 文件名的限制

在 Linux 下创建文件时, 尽量避免使用一些特殊字符作为文件名, 比如 以 . 开头的文件, 在 Linux 中表示隐藏文件的含义,  例如下面这些 :

> \*   ?   >   <   ;   !   \[  \]  |   '   "   `   ()  {}  等

### 三种时间

> Access(访问时间 atime) : 读取文件内容，就会更新(more、cat等)
> 
> Modify(修改时间 mtime) : 内容更新就会更改(ls -l 时间)
> 
> Change(更改时间 ctime) : 当文件的状态被修改时(**链接数，大小，权限，Blocks数, 时间属性等**)

### 语法

> touch  \[  options  \]  FILE....

### 选项

| 选项                                | 含义                          |
| --------------------------------- | --------------------------- |
| -t    \[\[CC\]YY\]MMDDhhmm\[.ss\] | 使用指定时间代替当前时间 (atime, mtime) |
| -a                                | 只修改访问时间atime                |
| -m                                | 只修改修改时间mtime                |
| -d   <时间日期>                       | 使用指定的日期时间，而非现在的时间           |
| -f                                | 此参数将忽略不予处理，仅负责解决兼容性问题       |
| -r   <参考文件或目录>                    | 使用参考文件或目录的时间记录              |
| -c                                | 仅修改文件的三个时间，不创建任何文件          |

> CC    -  年份的前两位
> 
> YY     -  年份的后两位
> 
> MM  -  月份  \[01-12\]
> 
> DD    -  日期  \[01-31\]
> 
> hh     -  时  \[00-23\]
> 
> mm  -  分  \[00-59\]
> 
> SS     -  秒  \[00-61\]

### 实例

```bash
## 查看一下 gkdaxue.txt, 发现没有这个文件
[root@localhost ~]# ls gkdaxue.txt
ls: cannot access gkdaxue.txt: No such file or directory

## 创建 gkdaxue.txt 并查看文件信息
## 省略部分信息, 只保留三种时间信息
## 创建文件时,三个时间是一样的，创建的同时修改了它的内容，所以它的大小，Blocks也发生变化，也相当于一次访问
[root@localhost ~]# touch gkdaxue.txt
[root@localhost ~]# stat gkdaxue.txt 
Access: 2019-03-14 18:21:49.033085524 +0800
Modify: 2019-03-14 18:21:49.033085524 +0800
Change: 2019-03-14 18:21:49.033085524 +0800

## 修改文件的时间为当前系统时间, 发现三种时间都会改变
[root@localhost ~]# touch gkdaxue.txt
[root@localhost ~]# stat gkdaxue.txt 
Access: 2019-03-14 18:24:08.712085238 +0800
Modify: 2019-03-14 18:24:08.712085238 +0800
Change: 2019-03-14 18:24:08.712085238 +0800

## -t : 修改文件的 atime 以及 mtime, 因为时间属性变了, 所以 ctime 也会更改为系统当前时间
[root@localhost ~]# touch -t 200808082000 gkdaxue.txt
[root@localhost ~]# stat gkdaxue.txt
Access: 2008-08-08 20:00:00.000000000 +0800  <== 自动主动修改导致变化

Modify: 2008-08-08 20:00:00.000000000 +0800  <== 自己主动修改导致变化

Change: 2019-03-14 18:27:54.860082113 +0800  <== 因为时间属性发生变化, 所以被动发生变化


## -a : 只修改文件的 atime
[root@localhost ~]# touch -a gkdaxue.txt
[root@localhost ~]# stat gkdaxue.txt
Access: 2019-03-14 18:29:52.435085253 +0800  <== 自己主动修改导致变化

Modify: 2008-08-08 20:00:00.000000000 +0800
Change: 2019-03-14 18:29:52.435085253 +0800  <== 因为时间属性发生变化, 所以被动发生变化


## -m : 只修改文件的 mtime
[root@localhost ~]# touch -m gkdaxue.txt 
[root@localhost ~]# stat gkdaxue.txt 
Access: 2019-03-14 18:29:52.435085253 +0800
Modify: 2019-03-14 18:32:05.889078008 +0800  <== 自己主动修改导致变化

Change: 2019-03-14 18:32:05.889078008 +0800  <== 因为时间属性发生变化, 所以被动发生变化


## -d : 使用指定的时间, 而非现在的时间
[root@localhost ~]# touch -d '2 days ago' gkdaxue.txt 
[root@localhost ~]# stat gkdaxue.txt
Access: 2019-03-12 18:33:50.283816901 +0800  <== 时间都发生变化

Modify: 2019-03-12 18:33:50.283816901 +0800  <== 时间都发生变化

Change: 2019-03-14 18:33:50.283086754 +0800  <== 时间都发生变化


## -c : 只修改文件的三种时间(当前系统时间), 不创建文件
[root@localhost ~]# touch -c gkdaxue.txt 
[root@localhost ~]# stat gkdaxue.txt
Access: 2019-03-14 18:35:25.721087878 +0800
Modify: 2019-03-14 18:35:25.721087878 +0800
Change: 2019-03-14 18:35:25.721087878 +0800
```

## mkdir命令

用于创建目录, 格式为 :

> mkdir  \[ options \]  Directory ....

### 选项

| 选项  | 含义         |
| --- | ---------- |
| -m  | 创建目录同时设置权限 |
| -p  | 递归创建目录     |
| -v  | 显示创建过程     |

### 实例

```bash
## 使用默认权限创建一个目录
[root@localhost ~]# mkdir gkdaxue

## 再次创建同一个目录报错, 因为目录已经存在了
[root@localhost ~]# mkdir gkdaxue
mkdir: cannot create directory `gkdaxue': File exists

## 自定义权限来创建目录, 不使用默认权限
[root@localhost ~]# mkdir -m 777 gkdaxue1 gkdaxue2  # 等于 mkdir -m 777 gkdaxue{1,2} , "1,2"中间没有空格

[root@localhost ~]# ll -d gkdaxue*
drwxr-xr-x. 2 root root 4096 Mar 15 10:20 gkdaxue    <== drwxr-xr-x
drwxrwxrwx. 2 root root 4096 Mar 15 10:24 gkdaxue1   <== drwxrwxrwx
drwxrwxrwx. 2 root root 4096 Mar 15 10:24 gkdaxue2

## 创建递归的目录, 但是不存在 gkdaxue3 这个目录, 所以创建失败
[root@localhost ~]# mkdir gkdaxue3/test1/test2
mkdir: cannot create directory `gkdaxue3/test1/test2': No such file or directory

## -p : 递归创建目录, 即可以成功创建
[root@localhost ~]# mkdir -p -v gkdaxue3/test1/test2
mkdir: created directory `gkdaxue3'
mkdir: created directory `gkdaxue3/test1'
mkdir: created directory `gkdaxue3/test1/test2'

## 此处需要自己安装 tree 软件, 前提是配置好网络和yum源,如果不会请忽略, 自己使用其他办法查看即可.

[root@localhost ~]# tree gkdaxue3
-bash: tree: command not found   <== 出现此条提示, 说明需要安装 tree 软件
[root@localhost ~]# yum install -y tree
Loaded plugins: fastestmirror, refresh-packagekit, security
Setting up Install Process
.....
Installed:
  tree.x86_64 0:1.5.3-3.el6                                                                           

Complete!
[root@localhost ~]# tree gkdaxue3
gkdaxue3
└── test1
    └── test2

2 directories, 0 files
```

11
