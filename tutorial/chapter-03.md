# 数据流重定向

数据流重定向就是将某个命令执行后应该出现在屏幕上的数据传输到其他地方. 主要有以下三种形式 : 

> **标准输入重定向(Standard Input, STDIN)** : 文件描述符为0, 默认从键盘输入(也可从其他文件或者命令输入) 使用 < 或 << 
> 
> **标准输出重定向( Standard Output, STDOUT)** : 文件描述符为 1 , 默认输出到屏幕, 使用 > 或者 >>
> 
> **错误输出重定向( Standard Error, STDERR)** : 文件描述符为 2 , 默认输出到屏幕, 使用 2> 或者 2>>

![数据流重定向](https://github.com/gkdaxue/linux/raw/master/image/chapter_A3_0001.png)

当我们执行一个命令的时候, 这个命令可能会由文件读入数据, 经过处理之后, 再将数据输出到屏幕上. 然后就有两种输出 **"标准输出"**  和 **"标准错误输出"** 这两种形式.

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

### 实例
```bash
## 演示一下由键盘输入
[root@localhost ~]# cat > cat_file
testing
cat file test
<== 将光标移动到下一行, 然后按 ctrl + d 离开
[root@localhost ~]# cat cat_file 
testing
cat file test

## 用某个文件的内容来代替键盘输入
[root@localhost ~]# cat > catfile < ~/.bashrc
[root@localhost ~]# ll catfile ~/.bashrc
-rw-r--r--. 1 root root 176 Apr  6 19:45 catfile
-rw-r--r--. 1 root root 176 Sep 23  2004 /root/.bashrc
```

## 输出重定向

| 符号                                            | 作用                             |
| --------------------------------------------- | ------------------------------ |
| command > 文件                                  | 将标准输出重定向到一个文件中（清空原有文件的数据）      |
| command 2> 文件                                 | 将错误输出重定向到一个文件中（清空原有文件的数据）      |
| command  >> 文件                                | 将标准输出重定向到一个文件中（追加到原有内容的后面）     |
| command 2>> 文件                                | 将错误输出重定向到一个文件中（追加到原有内容的后面）     |
| command  >> 文件 2>  &1<br>或<br>command  &>> 文件 | 将标准输出与错误输出共同写入到文件中（追加到原有内容的后面） |

> 标准输出重定向的文件描述符为 1, 但是可以省略, 所以 command  > 文件  相当于  command  1>  文件
> 
> 文件描述符 与 >/>> 之间没有空格并且作为一个整体, 左右两边各有一个空格
> 
> \>    :  表示清空写入的方式(清空原有文件内容,然后写入)
> 
> \>\>  :  表示追加写入的方式(附加在原有文件内容之后)

### 输出重定向演示

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

### 其他情况

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

### 总结
我们为什么要使用输出重定向呢?
> 1. 输出的信息很重要, 我们需要保存下来
> 2. 在后台执行中的程序, 不希望它打扰屏幕结果的正常输出
> 3. 对于一些错误命令, 我们不想他们显示出来

## /dev/null 
可以想象是一个黑洞设备, 它可以吃掉任何导向这个设备的信息并且不占用磁盘空间.
```bash
[root@localhost ~]# cat xxxxx 2> /dev/null
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
| -n  N | 显示的行数 ( 负数 : 除了尾部 N 外,显示剩余所有内容 )       |
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

## 只查看文件系统信息
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
> Modify(修改时间 mtime) : 内容(文件的内容, 而不是文件的属性或权限) 更新就会更改(ls -l 显示的时间)
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

## tree命令
显示目录下的层级关系(**需要安装 tree 软件**)
> tree [ options ] [ PATH ]

### 选项
| 选项  | 含义         |
| --- | ---------- |
| -d  | 只显示目录 |
| -a  | 显示所有文件(包含隐藏文件)     |
| -L NUM  | 指定显示的 NUM 层级目录     |

### 实例
```bash
## 需要配置好 yum 源和网络, 才可以进行以下步骤, 不懂的只要理解作用就好
[root@localhost ~]# yum install -y tree
Loaded plugins: fastestmirror, refresh-packagekit, security
Setting up Install Process
.....
Installed:
  tree.x86_64 0:1.5.3-3.el6                                                                           

Complete!   <== 说明安装完成

## 创建测试目录 以及测试文件
[root@localhost ~]# mkdir tree_dir
[root@localhost ~]# cd tree_dir/

## 以 '.' 开头的文件为稳藏文件
[root@localhost tree_dir]# touch gkdaxue.txt .gkdaxue2.txt

## mkdir 为创建目录的意思, 稍后讲解
[root@localhost tree_dir]# mkdir -p a/b/c/d

## 如果我们使用 ls 命令查看, 也能达到效果, 但是显示不太直观
[root@localhost tree_dir]# ls -aR
.:
.  ..  a  .gkdaxue2.txt  gkdaxue.txt

./a:
.  ..  b

./a/b:
.  ..  c

./a/b/c:
.  ..  d

./a/b/c/d:
.  ..

## 不显示隐藏文件
[root@localhost tree_dir]# tree
.
├── a
│   └── b
│       └── c
│           └── d
└── gkdaxue.txt

4 directories, 1 file

## 只显示三级目录
[root@localhost tree_dir]# tree -L 3
.
├── a
│   └── b
│       └── c
└── gkdaxue.txt

3 directories, 1 file

## 显示所有文件, 包含隐藏文件
[root@localhost tree_dir]# tree -a
.
├── a
│   └── b
│       └── c
│           └── d
├── .gkdaxue2.txt
└── gkdaxue.txt

4 directories, 2 files

## 只显示目录
[root@localhost tree_dir]# tree -d
.
└── a
    └── b
        └── c
            └── d

4 directories

## 清理工作  cd .. 表示返回上一级目录
[root@localhost tree_dir]# cd ..
[root@localhost ~]# rm -rf tree_dir

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
## 使用 '默认权限' 创建一个目录
[root@localhost ~]# mkdir gkdaxue

## 再次创建同一个目录报错, 因为目录已经存在了
[root@localhost ~]# mkdir gkdaxue
mkdir: cannot create directory `gkdaxue': File exists

## '自定义权限' 来创建目录, 不使用默认权限
[root@localhost ~]# mkdir -m 777 gkdaxue1 gkdaxue2  # 等于 mkdir -m 777 gkdaxue{1,2} , "1,2"中间没有空格
[root@localhost ~]# ll -d gkdaxue*   #  * 表示为一个通配符, 以后讲解
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
## rmdir命令
删除 `空的` 目录, 如果目录中有文件(在Linux中一切皆文件, 所以不是单纯的指代文件), 则不能删除(使用较少)
### 选项
| 选项  | 含义         |
| --- | ---------- |
| -p  | 连同上层 空目录 一起删除     |
| -v  | 显示删除过程     |
### 实例
```bash
[root@localhost ~]# ls
anaconda-ks.cfg  Documents  install.log         Music     Public     Videos
Desktop          Downloads  install.log.syslog  Pictures  Templates

## 想一下 为什么要加 -p 参数
[root@localhost ~]# mkdir -p rm_dir/test1/test2

## 创建一个测试文件 rm_test.txt
[root@localhost ~]# touch rm_dir/test1/test2/rm_test.txt

## 查看一下 rm_dir 内容
[root@localhost ~]# ls -R rm_dir/
rm_dir/:   <== 表示目录
test1      <== 表示目录下的文件

rm_dir/test1:   
test2

rm_dir/test1/test2:
rm_test.txt   <== 此文件已经被创建

## 尝试删除 test2 目录报错, 提示非空
[root@localhost ~]# rmdir rm_dir/test1/test2
rmdir: failed to remove `rm_dir/test1/test2': Directory not empty

## 先使用 rm 命令删除一下文件, 稍后讲解
[root@localhost ~]# rm rm_dir/test1/test2/rm_test.txt 
rm: remove regular empty file `rm_dir/test1/test2/rm_test.txt'? y  <== 此 y 是我们确认删除添加的

## 确认一下, 发现确实被删除了
[root@localhost ~]# ls -R rm_dir
rm_dir:
test1

rm_dir/test1:
test2

rm_dir/test1/test2:   <== 此目录下没有内容

## 尝试删除 rm_dir 目录, 报错提示非空
[root@localhost ~]# rmdir -vp rm_dir
rmdir: removing directory, `rm_dir'
rmdir: failed to remove `rm_dir': Directory not empty

## -p : 连同上级空目录一起删除
## -v : 显示删除过程
[root@localhost ~]# rmdir -vp rm_dir/test1/test2/
rmdir: removing directory, `rm_dir/test1/test2/'
rmdir: removing directory, `rm_dir/test1'
rmdir: removing directory, `rm_dir'

## 查看一下, 发现被成功删除
[root@localhost ~]# ls
anaconda-ks.cfg  Documents  install.log         Music     Public     Videos
Desktop          Downloads  install.log.syslog  Pictures  Templates
```
## cp命令
复制文件或目录, 一般来说 目标文件的所有者通常都是命令操作者本身, 所以在复制有些特殊权限的文件(/etc/shadow)等, 就必须添加 -a 或者 -p 参数, 复制完整的权限信息. (了解即可, 以后讲解权限) 还有复制给其他用户的文件也要给予合理的权限, 让别的用户来进行相应的操作.


有如下三种情况 : 
> 1. 如果目标文件是目录，则会把源文件复制到该目录中
> 2. 如果目标文件也是普通文件，则会询问是否要覆盖它
> 3. 如果目标文件不存在，则执行正常的复制操作

### 语法 
> cp [ options ] 源文件(source)  目标文件(destination)
> 
> cp [ options ] source1 source2 ......  directory

### 选项
| 选项  | 含义         |
| --- | ---------- |
| -p  | 保留源文件或目录的属性     |
| -d  | 当源文件为符号链接(软链接)时，目标文件也为符号链接，指向与源文件指向相同     |
| -f  | 强行复制文件或目录，不论目标文件或目录是否已存在(不与 -i 连用, 连用无效)     |
| -i  | 覆盖已经存在的文件之前先询问用户是否覆盖     |
| -r  | 递归处理，将指定目录下的所有文件与子目录一并处理     |
| -a  | 相当于 -pdr 的意思(常用)     |
| -s  | 创建符号链接而不是复制 | 
|-l  | 创建硬链接而不是复制文件本身说|
```bash
## 创建实验所需要的目录和文件
[root@localhost ~]# mkdir -p cp_dir/test1/test2
[root@localhost ~]# touch cp_dir/test1/test2/cp_test.txt
[root@localhost ~]# ls -R cp_dir/
cp_dir/:
test1

cp_dir/test1:
test2

cp_dir/test1/test2:
cp_test.txt

## -r : 递归复制, 如果不递归复制, 文件夹中含有其他目录会导致失败 
[root@localhost ~]# cp cp_dir/test1 .    # <== . 表示当前目录, 之前讲过, 没有指定文件名, 则使用复制文件的文件名
cp: omitting directory `cp_dir/test1'      <== 如果不递归复制,会导致复制失败
[root@localhost ~]# ls -R test1
ls: cannot access test1: No such file or directory   <== 说明复制失败了
[root@localhost ~]# cp -r cp_dir/test1 .  
[root@localhost ~]# ls -R test1/
test1/:
test2

test1/test2:
cp_test.txt

## -i : 覆盖已存在的文件之前, 先询问用户是否覆盖
[root@localhost ~]# touch cp_i_test.txt   
[root@localhost ~]# cp -i cp_i_test.txt  cp_i_test.txt2    # <== 第一次没有出现提示, 是因为不存在这个文件, 所以不会提示
[root@localhost ~]# echo 'www.gkdaxue.com' > cp_i_test.txt2
[root@localhost ~]# cat cp_i_test.txt      # <== cp_i_test.txt 无内容
[root@localhost ~]# cat cp_i_test.txt2     # <== 我们写入了内容
www.gkdaxue.com
[root@localhost ~]# cp -i cp_i_test.txt  cp_i_test.txt2    # <== cp_i_test.txt2 文件已经存在, 使用会询问是否覆盖
cp: overwrite `cp_i_test.txt2'? y    <== 你可以输入 y(es) 或 n(o) 来选择是否进行覆盖, 我们选择了 yes
[root@localhost ~]# cat cp_i_test.txt2     # <== 查看无内容, 说明我们确实已经覆盖了
[root@localhost ~]#    

## 查看并取消别名, 避免影响以下实验
[root@localhost ~]# alias cp  # <== alias 别名的意思, 说明我们使用了 cp 命令相当于使用 cp -i 命令
alias cp='cp -i'
## 临时取消别名, 以后讲解
[root@localhost ~]# alias cp="cp"
[root@localhost ~]# alias cp
alias cp='cp'

## -f : 强制覆盖, 不进行提醒工作
[root@localhost ~]# echo 'www.gkdaxue.com' > cp_i_test.txt2
[root@localhost ~]# cp -f cp_i_test.txt cp_i_test.txt2  # <== 没有提示输出操作
[root@localhost ~]# 

## -p : 保留源文件或者目录的属性
## 案例 1
[root@localhost ~]# ls -l cp_i_test.txt*
-rw-r--r--. 1 root root 0 Mar 16 14:36 cp_i_test.txt
-rw-r--r--. 1 root root 0 Mar 16 16:14 cp_i_test.txt2    <== 未更改之前日期
[root@localhost ~]# cp -p cp_i_test.txt cp_i_test.txt2
[root@localhost ~]# ls -l cp_i_test.txt*
-rw-r--r--. 1 root root 0 Mar 16 14:36 cp_i_test.txt
-rw-r--r--. 1 root root 0 Mar 16 14:36 cp_i_test.txt2    <== 和 源文件日期一致
## 案例 2
[root@localhost ~]# cp /var/log/wtmp .   
[root@localhost ~]# cp -p /var/log/wtmp ./wtmp2   # <== 复制到当前目录, 并且文件名为 wtmp2
[root@localhost ~]# ls -lU /var/log/wtmp wtmp2 wtmp
-rw-rw-r--. 1 root utmp 24960 Mar 16 12:28 /var/log/wtmp  <== 源文件
-rw-rw-r--. 1 root utmp 24960 Mar 16 12:28 wtmp2          <== 保留之后的属性, 可以看到不同点
-rw-r--r--. 1 root root 24960 Mar 16 16:19 wtmp           <== 不保留源文件的属性, 比如 mtime, 所有者/所有组 权限等

## -s : 创建软链接
[root@localhost ~]# ls -l anaconda-ks.cfg*
-rw-------. 1 root root 1638 Mar  3 11:42 anaconda-ks.cfg
[root@localhost ~]# cp -s anaconda-ks.cfg anaconda-ks.cfg.soft
[root@localhost ~]# ls -l anaconda-ks.cfg*
-rw-------. 1 root root 1638 Mar  3 11:42 anaconda-ks.cfg
lrwxrwxrwx. 1 root root   15 Mar 16 16:59 anaconda-ks.cfg.soft -> anaconda-ks.cfg  <== 带上-> 就是软链接的意思, 以后讲解

## -d : 当源文件为符号链接(软链接)时，目标文件也为符号链接，指向与源文件指向相同
[root@localhost ~]# cp -d anaconda-ks.cfg.soft anaconda-ks.cfg.soft2
[root@localhost ~]# ls -l anaconda-ks.cfg*
-rw-------. 1 root root 1638 Mar  3 11:42 anaconda-ks.cfg
lrwxrwxrwx. 1 root root   15 Mar 16 16:59 anaconda-ks.cfg.soft -> anaconda-ks.cfg
lrwxrwxrwx. 1 root root   15 Mar 16 17:01 anaconda-ks.cfg.soft2 -> anaconda-ks.cfg

## -l : 创建硬链接文件, 而非复制文件本身
[root@localhost ~]# cp -l anaconda-ks.cfg anaconda-ks.cfg.hard
[root@localhost ~]# ls -l anaconda-ks.cfg*
-rw-------. 2 root root 1638 Mar  3 11:42 anaconda-ks.cfg  <== 细心的同学肯定会发现, 第二列从数字 1 -> 2, 原因以后讲解.
-rw-------. 2 root root 1638 Mar  3 11:42 anaconda-ks.cfg.hard
lrwxrwxrwx. 1 root root   15 Mar 16 16:59 anaconda-ks.cfg.soft -> anaconda-ks.cfg
lrwxrwxrwx. 1 root root   15 Mar 16 17:01 anaconda-ks.cfg.soft2 -> anaconda-ks.cfg

## 复制多个文件到同一个目录
[root@localhost ~]# mkdir cp_more_file_dir
[root@localhost ~]# cp wtmp wtmp2  cp_more_file_dir/
[root@localhost ~]# ls cp_more_file_dir/
wtmp  wtmp2

## 清空实验数据, rm 命令稍后讲解
[root@localhost ~]# rm -rf anaconda-ks.cfg.* cp_dir cp_i* wtmp* cp_more_test_dir cp_more_file_dir 
[root@localhost ~]# ls
anaconda-ks.cfg  Documents  install.log         Music     Public     Videos
Desktop          Downloads  install.log.syslog  Pictures  Templates
```
## mv命令
移动/重命名  文件/目录
### 语法
> mv [ options ] 原文件(source) 目标文件(destination)
> 
> mv [ options ] source1 source2 .....  directory

### 选项
| 选项  | 含义         |
| --- | ---------- |
| -f  | 目标文件存在, 强制覆盖不提示    |
| -i  | 覆盖已经存在的文件之前先询问用户是否覆盖     |

### 实例
```bash

[root@localhost ~]# mkdir mv_dir
[root@localhost ~]# cd mv_dir

## 取消设置的别名
[root@localhost mv_dir]# alias mv='mv'

## 创建实验目录和文件
[root@localhost mv_dir]# mkdir mv_dir_{1,2}
[root@localhost mv_dir]# touch mv_file_{1,2}
[root@localhost mv_dir]# ls
mv_dir_1  mv_dir_2  mv_file_1  mv_file_2

## 对文件重命名的操作
[root@localhost mv_dir]# mv mv_file_1 mv_file_3  # <== 在同一个目录中就是重命名操作
[root@localhost mv_dir]# ls
mv_dir_1  mv_dir_2  mv_file_2  mv_file_3

##  移动文件至目录的操作
[root@localhost mv_dir]# mv mv_file_2 mv_dir_1    # <== 如果只是输入了目标目录, 没有输入文件名, 则保持原文件名
[root@localhost mv_dir]# ls -R .
.:
mv_dir_1  mv_dir_2  mv_file_3

./mv_dir_1:
mv_file_2

./mv_dir_2:

## 移动文件到目录中, 并给与一个新的文件名
[root@localhost mv_dir]# mv mv_file_3 mv_dir_1/mv_file_4  # <== 把 mv_file_3  -> mv_file_4 并移动到 mv_dir_1 下面
[root@localhost mv_dir]# ls -R 
.:
mv_dir_1  mv_dir_2

./mv_dir_1:
mv_file_2  mv_file_4

./mv_dir_2:

## -i : 当目标目录下存在同名文件时, 询问是否覆盖
[root@localhost mv_dir]# touch mv_file_{2,4}
[root@localhost mv_dir]# mv mv_file_2 mv_dir_1      # <== 虽然已经存在了同名文件, 直接覆盖没有提示( -f )
[root@localhost mv_dir]# mv -i mv_file_4 mv_dir_1   # <== -i, 提示是否覆盖
mv: overwrite `mv_dir_1/mv_file_4'? y  <== y 或 n 是否覆盖

## 把目录移动到 目录中
[root@localhost mv_dir]# ls
mv_dir_1  mv_dir_2
[root@localhost mv_dir]# mv mv_dir_1 mv_dir_2
[root@localhost mv_dir]# ls -R
.:
mv_dir_2

./mv_dir_2:
mv_dir_1

./mv_dir_2/mv_dir_1:
mv_file_2  mv_file_4
```
## basename命令
```base
## 取得文件名
[root@localhost ~]# basename /etc/sysconfig/network-scripts/ifcfg-eth0 
ifcfg-eth0
```
## dirname命令
```base
## 取得完整目录名
[root@localhost ~]# dirname /etc/sysconfig/network-scripts/ifcfg-eth0 
/etc/sysconfig/network-scripts
```
## rm命令
删除文件或者目录
### 语法
> rm [ options ] FILE ....

### 选项
| 选项  | 含义         |
| --- | ---------- |
| -f  | 强制删除不提示(即使不存在,也不提示)    |
| -i  | 在删除前会询问使用者是否执行删除动作     |
| -r | 递归删除, 最常用在目录的删除 (这是非常危险的选项！！！) |

### 实例
```bash
## 取消 rm 别名 或者 \rm 也可以
[root@localhost ~]# alias rm
alias rm='rm -i'

[root@localhost ~]# mkdir rm_dir
[root@localhost ~]# cd rm_dir
[root@localhost rm_dir]# touch test_{1,2,3,4,5,6}
[root@localhost rm_dir]# ls
test_1  test_2  test_3  test_4  test_5  test_6


## \rm 屏蔽 alias的作用, -i 询问是否执行操作
[root@localhost rm_dir]# rm test_1  # <== 默认执行 rm = rm -i, 因为有alias的作用
rm: remove regular empty file `test_1'? n
[root@localhost rm_dir]# \rm test_1 # <== 这样就可以直接删除, 不需要询问 
[root@localhost rm_dir]# ls
test_2  test_3  test_4  test_5  test_6

## -f : 强制删除, 不询问, 即使文件不存在, 也不报错
[root@localhost rm_dir]# rm -if test_2
[root@localhost rm_dir]# ls
test_3  test_4  test_5  test_6
[root@localhost rm_dir]# rm -rf test_7
[root@localhost rm_dir]#

## 创建了一个错误文件, 如何删除, - 是一个特殊符号
[root@localhost rm_dir]# touch ./-test7.txt
[root@localhost rm_dir]# ls
test_3  test_4  test_5  test_6  -test7.txt
[root@localhost rm_dir]# \rm -test7.txt  # <== 不能删除
rm: invalid option -- 't'
Try `rm ./-test7.txt' to remove the file `-test7.txt'.
Try `rm --help' for more information.
[root@localhost rm_dir]# \rm ./-test7.txt # <== 可以, 所以特殊符号的文件名,都可以使用此方式
[root@localhost rm_dir]# ls
test_3  test_4  test_5  test_6

## -r : 递归删除
[root@localhost rm_dir]# cd ..
[root@localhost ~]# rm rm_dir  # <== 直接删除一个目录, 不允许  
rm: cannot remove `rm_dir': Is a directory
[root@localhost ~]# rm -r rm_dir # <== 因为没有取消别名,会询问是否删除
rm: descend into directory `rm_dir'? y
rm: remove regular empty file `rm_dir/test_3'? y
rm: remove regular empty file `rm_dir/test_4'? y
rm: remove regular empty file `rm_dir/test_6'? y
rm: remove regular empty file `rm_dir/test_5'? y
rm: remove directory `rm_dir'? y

## rm -rf /* 是一个非常危险的命令, 表示是删除根目录下所有的文件 
## 这会导致它会把系统也删除, 出现大问题, 所以使用 rm 命令一定要谨慎.
```
## who命令
显示谁登陆了系统, 可以查看用户登录的IP, 时间终端,PID等信息
> who [ options ]

### 选项
| 选项  | 含义         |
| --- | ---------- |
| -s  | 仅列出名字、tty和时间。(默认) who = who -s    |
|-m | 仅显示关于当前终端的信息。who -m = who am i = who am I|
|-q	| 所有登录名和登录用户数|
|-b	| 最近系统启动的时间|
|-r	| 显示当前运行级别|
|-T	| 添加一个字符，指示终端的状态|
|-l	| 打印系统登录进程|
|-H | 打印列标题行|
|-u | 显示每个当前用户的用户名、tty、登录时间、IDLE和进程标识(PID)|
|-a	| -b -d -l -p -r -t -T -u|

### 实例
```bash
[root@localhost ~]# who   # 等于 who -s 命令
root     tty1         2019-03-21 12:55
root     pts/0        2019-03-21 12:37 (192.168.1.11)

## -m : 仅显示当前终端信息
[root@localhost ~]# who -m
root     pts/0        2019-03-21 12:37 (192.168.1.11)

## -q : 显示所有登录名和登录用户数(因为一个终端算一个用户, 所以并不是严格意义上的用户)
[root@localhost ~]# who -q
root root
# users=2

## -b : 显示最近系统启动时间
[root@localhost ~]# who -b
         system boot  2019-03-15 10:03

## 显示当前运行级别, 以及上次运行级别
[root@localhost ~]# who -r
         run-level 3  2019-03-20 21:07                   last=5

## -T : 指示终端的状态
## "+" : 终端是可写的 
## "-" 或 "? " : 终端不是可写的        
[root@localhost ~]# who -T
root     + tty1         2019-03-21 12:55
root     + pts/0        2019-03-21 12:37 (192.168.1.11)

## -l : 打印系统登录进程
[root@localhost ~]# who -l
LOGIN    tty3         2019-03-15 10:03              2210 id=3
LOGIN    tty4         2019-03-15 10:03              2212 id=4
LOGIN    tty2         2019-03-15 10:03              2208 id=2
LOGIN    tty5         2019-03-15 10:03              2214 id=5
LOGIN    tty6         2019-03-15 10:03              2216 id=6

## -H : 打印列标题行
[root@localhost ~]# who -H
NAME     LINE         TIME             COMMENT
root     tty1         2019-03-21 12:55
root     pts/0        2019-03-21 12:37 (192.168.1.11)

## -u : 显示每个当前用户的用户名、tty、登录时间、IDLE和进程标识(PID)
[root@localhost ~]# who -Hu
NAME     LINE         TIME             IDLE          PID COMMENT
root     tty1         2019-03-21 12:55 23:52       29106
root     pts/0        2019-03-21 12:37   .         28982 (192.168.1.11)

NAME : 登录用户名
LINE : 登录的终端
TIME : 登录的时间
IDLE : 空闲时间 包含了最近最后一次活动以来消逝的时间. 
	   01:05   	: 用户root那么久没执行过命令了
	   . 符号	: 是指该终端过去的一分钟有过活动
       old    	: 该用户已超过24小时没有任何动作
PID  : 用户shell程序的进程ID号
```
## whoami命令
显示当前有效用户, 本指令相当于执行"id -un"指令
```bash
[root@localhost ~]# whoami
root
[root@localhost ~]# id -un
root
```
## w命令
显示系统当前所有的登录会话以及进行的操作.
> w [ options ] [ USER_NAME ]

### 选项
| 选项  | 含义         |
| --- | ---------- |
| -r  | 显示用户从何处登入系统    |
|-h | 不显示标题信息列|
|-s	| 使用简洁格式列表|

### 实例
```bash
## 默认显示所有用户
[root@localhost ~]# w
 13:45:08 up 7 days,  3:41,  3 users,  load average: 0.00, 0.00, 0.00
USER     TTY      FROM              LOGIN@   IDLE   JCPU   PCPU WHAT
gkdaxue  pts/1    192.168.1.11     13:45    2.00s  0.02s  0.02s -bash
root     tty1     -                Thu12   24:49m  0.02s  0.02s -bash
root     pts/0    192.168.1.11     Thu12    0.00s  0.31s  0.10s w

## 只显示指定用户, 牵扯到后边的知识 了解即可
[root@localhost ~]# w gkdaxue
 13:45:39 up 7 days,  3:42,  3 users,  load average: 0.00, 0.00, 0.00
USER     TTY      FROM              LOGIN@   IDLE   JCPU   PCPU WHAT
gkdaxue  pts/1    192.168.1.11     13:45   33.00s  0.02s  0.02s -bash

## -f : 显示用户从何处登录系统
[root@localhost ~]# w -f
 13:45:59 up 7 days,  3:42,  3 users,  load average: 0.00, 0.00, 0.00
USER     TTY        LOGIN@   IDLE   JCPU   PCPU WHAT
gkdaxue  pts/1     13:45   53.00s  0.02s  0.02s -bash
root     tty1      Thu12   24:50m  0.02s  0.02s -bash
root     pts/0     Thu12    0.00s  0.22s  0.00s w -f

## 信息讲解
 13:45:59 		 : 系统当前时间
up 7 days,  3:42 : 系统运行时间
3 users 		 : 当前系统登陆的终端数(一个用户可以通过多个终端登录系统)
0.00, 0.00, 0.00 : 系统在过去1，5，10分钟内的负载程度,数值越小系统负载越轻
USER   : 显示登陆用户帐号名。用户重复登陆，该帐号也会重复出现。
TTY    : 用户登陆所用的终端。
FROM   : 显示用户在何处登陆系统。
LOGIN@ : 是LOGIN AT的意思，表示登陆进入系统的时间。
IDLE   : 用户空闲时间，从用户上一次任务结束后，开始记时。
JCPU   : 在这段时间内, 所有与该终端相关的进程任务所耗费的CPU时间(终端代号区分)
PCPU   : 指WHAT域的任务执行后耗费的CPU时间。
WHAT   : 表示当前执行的任务。

## -h : 不显示标题信息列
[root@localhost ~]# w -h
gkdaxue  pts/1    192.168.1.11     13:45    4:25   0.02s  0.02s -bash
root     tty1     -                Thu12   24:53m  0.02s  0.02s -bash
root     pts/0    192.168.1.11     Thu12    0.00s  0.22s  0.00s w -h

## -s : 使用简洁模式
[root@localhost ~]# w -s
 13:49:34 up 7 days,  3:46,  3 users,  load average: 0.00, 0.00, 0.00
USER     TTY      FROM               IDLE WHAT
gkdaxue  pts/1    192.168.1.11      4:28  -bash
root     tty1     -                24:53m -bash
root     pts/0    192.168.1.11      0.00s w -s
```

## alias命令
定义或者显示别名操作, 比如一个名字太长了, 我们就可以为它自己定义一个简短的名字, 只是临时生效, 退出后在登录无效, 如果想要永久生效, 需要定义在配置文件中. 如果还想要当前 shell 也生效, 就需要重新加载配置文件.
> **alias [name[='value'] ...]**

#### 实例
```bash
## 发现 alias 是内核自带的命令
[root@localhost ~]# type alias
alias is a shell builtin

## 尝试使用 cdnet 命令, 发现系统中没有这个命令
[root@localhost ~]# cdnet
-bash: cdnet: command not found

## 先查询是否已经定义, 发现没有定义
[root@localhost ~]# alias cdnet
-bash: alias: cdnet: not found

## 自定义一个 cdnet 别名命令, 跳转到对应目录
[root@localhost ~]# alias cdnet='cd /etc/sysconfig/network-scripts'
[root@localhost ~]# alias cdnet
alias cdnet='cd /etc/sysconfig/network-scripts'

## 使用 cdnet 命令, 发现成功跳转(如何判断成功跳转的? 请自己分析)
[root@localhost ~]# cdnet
[root@localhost network-scripts]# cd
[root@localhost ~]# 

## 查看系统中所有的别名信息
[root@localhost ~]# alias
alias cp='cp -i'
alias l.='ls -d .* --color=auto'
alias ll='ls -l --color=auto'
alias ls='ls --color=auto'
alias mv='mv -i'
alias rm='rm -i'
alias which='alias | /usr/bin/which --tty-only --read-alias --show-dot --show-tilde'
```

如果别名和原命令名称一致, 比如 ` cp='cp -i' `, 那么我如果使用 cp 命令时, 遇到同名的文件会提示我是否覆盖, 但是我不想要提示怎么办, 我们就可以使用 ` \COMMAND ` 命令的形式来避免别名的影响.

## unalias命令
移除定义的别名, 这里的移除只是暂时的移除, 等重新登录 shell 时依然会有这些定义的别名, 如果需要彻底移除, 就需要修改配置文件并重新加载配置文件, 使当前 shell 生效.
> unalias [-a] name [name ....]

### 选项
| 选项  | 含义         |
| --- | ---------- |
| -a  | 移除所有定义的别名(临时)    |

### 实例
```bash
## 先查看别名
[root@localhost ~]# alias cdnet
alias cdnet='cd /etc/sysconfig/network-scripts'

## 删除别名在查看
[root@localhost ~]# unalias cdnet
[root@localhost ~]# alias cdnet
-bash: alias: cdnet: not found


[root@localhost ~]# alias
alias cp='cp -i'
alias l.='ls -d .* --color=auto'
alias ll='ls -l --color=auto'
alias ls='ls --color=auto'
alias mv='mv -i'
alias rm='rm -i'
alias which='alias | /usr/bin/which --tty-only --read-alias --show-dot --show-tilde'

## 删除所有别名记录
[root@localhost ~]# unalias -a
[root@localhost ~]# alias
```

## which命令
which会在 ` PATH变量 ` 里查找命令是否存在以及命令的存放位置(绝对路径)并返回第一个搜索到的结果
>  which [options] programname [...]

### 选项
| 选项  | 含义         |
| --- | ---------- |
| -a  | 打印 PATH 中所有匹配的可执行文件，而不仅仅是第一个    |
| --skip-alias | 不显示别名 |

### 实例
```bash
## 显示 rm 别名
[root@localhost ~]# alias rm
alias rm='rm -i'

## 查找 rm 命令, 默认会显示别名
[root@localhost ~]# which rm
alias rm='rm -i'
	/bin/rm

## 查找 rm 命令并且不显示别名
[root@localhost ~]# which --skip-alias rm
/bin/rm

## 查找 shell 自带的命令发现没有
[root@localhost ~]# type cd
cd is a shell builtin
[root@localhost ~]# which cd
/usr/bin/which: no cd in (/usr/lib64/qt-3.3/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin)

## 验证只查询 PATH 变量定义的目录
[root@localhost ~]# which --skip-alias cp
/bin/cp
[root@localhost ~]# cp $(which --skip-alias cp ) .
[root@localhost ~]# ll cp
-rwxr-xr-x. 1 root root 122896 Apr  7 14:05 cp
[root@localhost ~]# which --skip-alias cp
/bin/cp      <== 还是只显示 PATH 变量下的内容
[root@localhost ~]# echo $PATH
/usr/lib64/qt-3.3/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
[root@localhost ~]# PATH="${PATH}:/root"
[root@localhost ~]# echo $PATH
/usr/lib64/qt-3.3/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin:/root
[root@localhost ~]# which --skip-alias cp
/bin/cp 
[root@localhost ~]# which -a --skip-alias cp
/bin/cp
/root/cp  <== 如果想要查询所有 就要使用 -a 选项

## 还原环境
[root@localhost ~]# PATH=${PATH%:/root}
[root@localhost ~]# echo $PATH
/usr/lib64/qt-3.3/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
[root@localhost ~]# rm -rf cp

[root@localhost ~]# which -a --skip-alias cp
/bin/cp   <== 说明已经成功还原环境
```

## whereis命令
找到命令的二进制文件、源文件和帮助页文件, whereis 和 locate 都是利用数据库来查找的数据, 所以速度比较快, 因为没有实际去硬盘上查询.
>  whereis [ options ] filename...

### 选项
| 选项 | 含义   |
| --- | ---------------- |
| -b  | 只查找二进制文件         |
| -m  | 只查找帮助文件          |
| -s  | 源代码文件            |

### 实例
```bash
## 默认显示搜索到的所有数据
[root@localhost ~]# whereis ls
ls: /bin/ls /usr/share/man/man1p/ls.1p.gz /usr/share/man/man1/ls.1.gz

## -b 只显示二进制文件
[root@localhost ~]# whereis -b ls
ls: /bin/ls

## -m 只显示帮助文件
[root@localhost ~]# whereis -m ls
ls: /usr/share/man/man1p/ls.1p.gz /usr/share/man/man1/ls.1.gz

## -s 只显示源代码文件
[root@localhost ~]# whereis -s ls
ls:
```

## locate命令
按照名称查找文件
> locate [OPTION]... PATTERN...

### 选项
|   选项  |    含义 |
| --- | ---------------- |
| -i  | 忽略大小写         |

### 实例
```bash
[root@localhost ~]# locate passwd | head -n 3
/etc/passwd
/etc/passwd-
/etc/pam.d/passwd

[root@localhost ~]# locate Passwd
/usr/share/system-config-network/netconfpkg/conf/ConfPasswd.py
/usr/share/system-config-network/netconfpkg/conf/ConfPasswd.pyc
/usr/share/system-config-network/netconfpkg/conf/ConfPasswd.pyo

## -i 忽略大小写
[root@localhost ~]# locate -i Passwd | head -n 3
/etc/passwd
/etc/passwd-
/etc/pam.d/passwd
```

### 注意事项
locate 是从 /var/lib/mlocate 里面的数据找到所需要的数据, 所以查找速度很快, 不需要从硬盘上来查找, 但是也有一定的弊端, 就是这个数据库不是实时更新的(按照系统配置自动更新), 当你新建文件时, 然后使用 locate 命令可能会存在找不到的情况, 所以这个时候就需要我们手动更新数据库, 使用 **updatedb** 命令.

```bash
[root@localhost ~]# touch gkdaxue_file.txt
[root@localhost ~]# locate gkdaxue_file.txt
[root@localhost ~]#   <== 查找不到文件

## 手动更新一下数据库 
[root@localhost ~]# updatedb
[root@localhost ~]# locate gkdaxue_file.txt 
/root/gkdaxue_file.txt

## updatedb 会去读取 /etc/updatedb.conf 的配置, 然后去更新 /var/lib/mlocate 内的数据库文件
```

## find命令
