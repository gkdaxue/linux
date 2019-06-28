# 再谈bash
我们之前就说过管理整个计算机硬件的其实就是操作系统的内核(kernel), 而内核是被保护起来的, 所以我们只能通过 shell 将我们输入的命令与内核通信, 让内核控制硬件进行工作来达到我们想要的效果.
```bash
## 查看系统中可以使用的 shell
[root@localhost ~]# cat /etc/shells 
/bin/sh
/bin/bash
/sbin/nologin <== 奇怪的 shell, 可以让用户无法登陆系统
/bin/dash
/bin/tcsh
/bin/csh
```
系统在某些服务运行的过程中, 会去检查用户能够使用的 shells, 而这些 shell 就被记录在 /etc/shells 中, 那么当我们用户登录的时候, 系统会给我们一个 shell 来让我们工作, 那么这个 shell 是什么呢? 系统怎么知道会分配给每个人的 shell 是什么? 其实这个 shell 是被记录在 /etc/passwd 文件中.
```bash
## 查看 /etc/passwd 文件内容并只保留前3行
[root@localhost ~]# cat /etc/passwd | head -n 3
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin

## 那么多信息, 我们只要看最后一个字段就好了, 也就是 /bin/bash, /sbin/nologin ...
## 看到这些, 是不是就发现了这就是我们的 shell, 所以等你登录时, 系统提供给你的 shell 就是在此字段中定义的.

## 比如我现在是 root 用户, 那么我的 shell 就应该是 /bin/bash , 我们来验证一下
[root@localhost ~]# echo $SHELL
/bin/bash  <== 发现没有问题
```
## bash的优点
### 历史命令功能(history)
我们只要在命令行中按上下键就可以找到 前一个/后一个 输入的命令, 并且默认能记录1000个, 所以基本上我们的命令都能记录下来.
```bash
## 显示最后 3 个执行的命令
[root@localhost ~]# history | tail -n 3
  661  cat /etc/passwd | head -n 3
  662  echo $SHELL
  663  history | tail -n 3
```
> 命令都被记录在家目录下的 .bash_history 中, 但是 .bash_history 记录的是此次登录以前执行的命令, 而此次登录执行的命令都被保存在内存缓存中, 当我们退出系统时, 才会被写入到 .bash_history 中.


### 命令和文件名补全功能
> 跟在不完全的命令后面, 补全命令 ( 比如 c[Tab][Tab] )
> 
> 跟在不完全的文件名后面, 补全文件名 ( 比如 cat  /root/anacond[Tab][Tab] )

### 命令别名功能 (alias)
> **在命令行中定音的别名, 仅对当前 shell 进程有效, 如果想永久有效, 需要在配置文件中定义**
>
> 对当前用户有效 : ~/.bashrc
>
> 对所有用户有效 : /etc/bashrc

但是我们修改了配置文件, 默认当前进程是不生效的, 所以我们有以下两种方式来时配置文件生效
1. source  CONFIG_FILE
2. **.** CONFIG_FILE (前边有个点, 表示当前目录的意思) 

```bash
## 比如把 rm 命令定义为 rm -i, 可以帮助我们在一定程度上防止误删文件. 会在删除之前要求我们确认
[root@localhost ~]# alias rm
alias rm='rm -i'

## 如果 alias 不带任何选项和参数, 将显示所有定义的别名
[root@localhost ~]# alias
alias cp='cp -i'
alias l.='ls -d .* --color=auto'
alias ll='ls -l --color=auto'
alias ls='ls --color=auto'
alias mv='mv -i'
alias rm='rm -i'
alias which='alias | /usr/bin/which --tty-only --read-alias --show-dot --show-tilde'

## 定义一个别名并查看
[root@localhost ~]# alias cp='cp'
[root@localhost ~]# alias cp
alias cp='cp'

## 还原别名的设置
[root@localhost ~]# alias cp='cp -i'
[root@localhost ~]# alias cp
alias cp='cp -i'
```

### 变量功能
针对不同的用户, 同一个变量的值可能会不同, 体现了灵活的特性.

### 命令行展开
```bash
~         : 展开为用户家目录
~USERNAME : 展开为指定用户的家目录
{}        : 可承载一个一个以逗号分割的列表(中间不能有空格), 并将其展开为多个路径
            /tmp/{a,b} 就相当于 /tmp/a   /tmp/b
            /tmp/{rose,jack}/hi 相当于 /tmp/rose/hi    /tmp/jack/hi
			那么, 尝试分析 /tmp/x/{y1,y2}/{a,b} 是什么情况
			/tmp/{bin,sbin,usr/{bin/sbin}} 又是什么情况
```
### 上一条命令的执行结果状态
如果命令执行成功没有错误, 则返回 0, 执行失败有错误, 则返回 非0, **使用 ? 变量表示**. 以后有案例.
```bash
[root@localhost ~]# pwd
/root 
[root@localhost ~]# echo $?
0   <== 命令执行成功, 所以返回 0  
[root@localhost ~]# cat xxxxxxxxxxxxxxxxx
cat: xxxxxxxxxxxxxxxxx: No such file or directory
[root@localhost ~]# echo $?
1   <== 因为文件并不存在, 所以返回 非0
```

### 程序脚本
我们可以把很多命令写到一个文件中, 然后我们就可以通过执行这个脚本, 来简化我们的操作(自动化运行).

### 通配符(glob)
bash 还支持许多的通配符, 可以帮助用户查询和命令的执行, 能够加速用户的操作.

## bash的变量功能
### 变量的可变性
Linux 是多用户 多任务的环境. 每个人登录都能取得一个 shell, 但是有可能每个人的 shell 都不同, 所以我们就需要一个变量来表示不同的值.
> 用一个不变的变量名(**严格区分大小写**)来替代一个比较复杂或者容易变动的变量值
>
> 如 SHELL 为变量名, 如果登录用户为 root, 则变量值为 /bin/bash


```bash
[root@localhost ~]# head -2 /etc/passwd
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/bin:/sbin/nologin

## 变量严格区分大小写
[root@localhost ~]# echo $shell  # <== 如果使用了一个没有定义的变量, 则变量值为空

[root@localhost ~]# 

## 比如我们现在用 root 用户登录, 它的 shell 为 /bin/bash
[root@localhost ~]# echo $SHELL 
/bin/bash   

## 那么如果我们用 bin 用户登录(其实它不能登录,只是假设), 那么它的 shell 应该是啥呢?
## 按照我们之前的推论, 所以应该是
[bin@localhost ~]# echo $SHELL
/sbin/nologin

## 所以这就是变量的功能.
```
![变量](https://github.com/gkdaxue/linux/raw/master/image/chapter_A4_0001.png)
### 影响 bash 环境操作的变量
有些变量会影响到 bash 的环境, 比如我们之前所说的 PATH 变量,  为什么它能影响到 bash 环境变量呢? 因为对于不同的用户, 同样的变量值可能会不同, 从而进一步会影响到 bash 的环境.(因为在 PATH 中搜索命令从左到右)
```bash
[root@localhost ~]# echo $PATH
/usr/lib64/qt-3.3/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin

[gkdaxue@localhost ~]$ echo $PATH
/usr/lib64/qt-3.3/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/home/gkdaxue/bin
```

## 变量的显示, 设置, 修改和销毁
### echo命令
我们如何想知道变量的值, 就需要我们使用 echo 命令来进行输出操作
> **在变量的前边加上 $ 符号**, 比如 echo $PATH 或 echo ${PATH}

```bash
[root@localhost ~]# echo $PATH
/usr/lib64/qt-3.3/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin

[root@localhost ~]# echo ${PATH}
/usr/lib64/qt-3.3/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
```
### 变量的设置和修改规则
用一个 "=" 号来连接变量名和它的值就好了, 当一个变量未被设置时, 默认的值是 '空' 的. 所以在设置时, 还是需要符合某些规定, 否则会导致设置失败.
> 1. 变量名只能是英文字母或数字, 但是不能以数字开头
> 2. 变量名和变量值以一个 '=' 连接, 并且 '=' 号不能有空格
> 3. 变量值若含有空格符, 可以使用 '' 或 "" 将变量内容包含起来(使用'' 或 "" 会有区别, 稍后讲解)
> 4. 可以使用转义字符 '\' (如 $, \, !)来变成一般字符
> 5. 通过反单引号 \`\` (键盘上方数字1的左边那个按键) 或 **` $(命令) `** 来使用其他命令提供的信息
> 6. 如果变量需要在 `子进程` 中使用, 需要使用 **`export 变量名`** 来使变量变成环境变量(稍后讲解)
> 7. 自己设置的变量建议使用小写字母表示, 因为默认系统的变量全部使用大写字母.

```bash
## 等号两边不能有空格, 否则报错
[root@localhost ~]# myname = gkdaxue
-bash: myname: command not found

## 不能以数字开头
[root@localhost ~]# 2myanme=test
-bash: 2myanme=test: command not found

## 正常使用
[root@localhost ~]# myname=test
[root@localhost ~]# echo $myname
test

## 如果变量值中有空格, 建议使用 '' 或 "" 包含起来
[root@localhost ~]# myname=www gkdaxue com
-bash: gkdaxue: command not found

## 接下来我们就看一下 '' 和 "" 包含起来的区别, 我想输出为金额为 $5
[root@localhost ~]# price=5
[root@localhost ~]# echo $${price}
33577{price}  <== 这个输出的是什么鬼, 其实表示当前Shell进程的ID，即pid
[root@localhost ~]# echo \$${price}
$5                 <== 所以我们可以使用转义符号 \ 来转义一下, 也可以使用我们说的 '' 或 ""
[root@localhost ~]# echo "$price"
5                  <== 使用 "", 其中的变量会自动解析为变量值, 保持原有的特性
[root@localhost ~]# echo '$price'
$price             <== 仅为一般字符, 不会转换为变量值.
## 那么如果变量值中有 ' 或 ", 那么我们又该如何处理呢? 请自己搜索解决方案.(转义字符或其他方案)

## 使用反单引号 `` 或 $() , 来使用其他命令提供的变量值
[root@localhost ~]# uname -r
2.6.32-696.el6.x86_64
[root@localhost ~]# version=$(uname -r)
[root@localhost ~]# echo ${version}
2.6.32-696.el6.x86_64

## 如果我们想增加变量值的内容应该怎么操作?
[root@localhost ~]# echo $myname
test
[root@localhost ~]# myname="${myname}_test2"
[root@localhost ~]# echo $myname
test_test2

## 然后我们来讲解一下 `export 变量名`的用法, 变量名前没有 $
[root@localhost ~]# myname="${myname}_test2"
[root@localhost ~]# echo $myname
test_test2
[root@localhost ~]# bash            # <== 打开一个子进程
[root@localhost ~]# echo ${myname}
                                    # <== 发现值为空的
[root@localhost ~]# exit            # <== 退出子进程
exit
[root@localhost ~]# export myname   # <== export 一下
[root@localhost ~]# bash 
[root@localhost ~]# echo ${myname}   
test_test2                          # <== 子进程中可以使用
```
> 子进程就是在当前 shell (父进程) 中去打开一个新的 shell, 新的 shell 也就是子进程, **在一般状态下. 父进程中的自定义变量无法在子进程中使用**, 但是经过 export 将变量变成 **`环境变量`** 后, 就可以在子进程中使用.

```bash
[root@localhost ~]# version=$(uname -r)
[root@localhost ~]# echo ${version}
2.6.32-696.el6.x86_64
```
可以看成做了两次操作 :
1. 先执行命令 uname -r 得到内核信息, 也就是 2.6.32-696.el6.x86_64
2. 把得到的内核值赋值给 version 变量, 所以我们输出的变量 也就是 2.6.32-696.el6.x86_64

### unset取消设置的变量
```bash
[root@localhost ~]# echo ${version}
2.6.32-696.el6.x86_64
[root@localhost ~]# unset version
[root@localhost ~]# echo ${version}

[root@localhost ~]# 
```
## 环境变量的作用
### env命令:查看环境变量
env(environment) 列出了所有的环境变量. 注意是环境变量, 不是变量. 因为自定义变量没有被 export 过, 就不会再这里显示出来.
```bash
[root@localhost ~]# env
HOSTNAME=localhost.localdomain    <== 主机名
SELINUX_ROLE_REQUESTED=
TERM=xterm                        <== 终端机使用的环境类型
SHELL=/bin/bash                   <== 使用的 shell, 之前见过
HISTSIZE=1000                     <== 记录命令的条数
SSH_CLIENT=192.168.1.11 1766 22   <== 因为我使用的是 ssh 连接, 所以会出现IP地址和端口
SELINUX_USE_CURRENT_RANGE=
QTDIR=/usr/lib64/qt-3.3
QTINC=/usr/lib64/qt-3.3/include
SSH_TTY=/dev/pts/0                <== ssh 所使用的终端类型
USER=root                         <== 当前用户
LS_COLORS=rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=01;05;37;41:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.lz=01;31:*.xz=01;31:*.bz2=01;31:*.tbz=01;31:*.tbz2=01;31:*.bz=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.rar=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.axv=01;35:*.anx=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=01;36:*.au=01;36:*.flac=01;36:*.mid=01;36:*.midi=01;36:*.mka=01;36:*.mp3=01;36:*.mpc=01;36:*.ogg=01;36:*.ra=01;36:*.wav=01;36:*.axa=01;36:*.oga=01;36:*.spx=01;36:*.xspf=01;36:
MAIL=/var/spool/mail/root         <== 用户的邮箱地址
PATH=/usr/lib64/qt-3.3/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin  <== PATH 变量
PWD=/root                         <== 当前路径, 随目录的变化而变化
LANG=en_US.UTF-8                  <== 语言
SELINUX_LEVEL_REQUESTED=
myname=test_test2                 <== 自定义的变量,被 export 设置过
SSH_ASKPASS=/usr/libexec/openssh/gnome-ssh-askpass
HISTCONTROL=ignoredups            <== 历史命令的控制
SHLVL=1
HOME=/root                        <== 家目录
LOGNAME=root
QTLIB=/usr/lib64/qt-3.3/lib
CVS_RSH=ssh
SSH_CONNECTION=192.168.1.11 1766 192.168.1.206 22
LESSOPEN=||/usr/bin/lesspipe.sh %s
G_BROKEN_FILENAMES=1
_=/bin/env

## 我们可以看到很多我们之前讲过的一些变量, 接下来我们会对一些常见的变量进行系统的梳理一下
```
### set命令查看所有变量(包含自定义变量和环境变量)
```bash
[root@localhost ~]# set
BASH=/bin/bash                     <== 使用的 bash
BASHOPTS=checkwinsize:cmdhist:expand_aliases:extquote:force_fignore:hostcomplete:interactive_comments:login_shell:progcomp:promptvars:sourcepath
BASH_ALIASES=()
BASH_ARGC=()
BASH_ARGV=()
BASH_CMDS=()
BASH_LINENO=()
BASH_SOURCE=()
BASH_VERSINFO=([0]="4" [1]="1" [2]="2" [3]="2" [4]="release" [5]="x86_64-redhat-linux-gnu")
BASH_VERSION='4.1.2(2)-release'    <== bash 的版本
COLORS=/etc/DIR_COLORS
COLUMNS=93
CVS_RSH=ssh
DIRSTACK=()
EUID=0
GROUPS=()
G_BROKEN_FILENAMES=1
HISTCONTROL=ignoredups            <== 历史命令的控制方式
HISTFILE=/root/.bash_history      <== 存放历史命令的文件(隐藏文件, 以 点 开头)
HISTFILESIZE=1000                 <== 保存文件命令的最大记录条数
HISTSIZE=1000                     <== 当前环境下可记录的最大命令数
HOME=/root                        <== 家目录
HOSTNAME=localhost.localdomain    <== 主机名
HOSTTYPE=x86_64                   <== 主机类型
ID=0
IFS=$' \t\n'                      <== 默认的分割符
LANG=en_US.UTF-8
LESSOPEN='||/usr/bin/lesspipe.sh %s'
LINES=41
LOGNAME=root                      <== 登录的用户
LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=01;05;37;41:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.lz=01;31:*.xz=01;31:*.bz2=01;31:*.tbz=01;31:*.tbz2=01;31:*.bz=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.rar=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.axv=01;35:*.anx=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=01;36:*.au=01;36:*.flac=01;36:*.mid=01;36:*.midi=01;36:*.mka=01;36:*.mp3=01;36:*.mpc=01;36:*.ogg=01;36:*.ra=01;36:*.wav=01;36:*.axa=01;36:*.oga=01;36:*.spx=01;36:*.xspf=01;36:'
MACHTYPE=x86_64-redhat-linux-gnu
MAIL=/var/spool/mail/root         <== 邮箱地址
MAILCHECK=60               
OLDPWD=/root                      <== 使用 cd - , 跳转到上次所在目录使用的变量
OPTERR=1
OPTIND=1
OSTYPE=linux-gnu                  <== 操作系统的类型
PATH=/usr/lib64/qt-3.3/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
PIPESTATUS=([0]="0")
PPID=33573
PROMPT_COMMAND='printf "\033]0;%s@%s:%s\007" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/~}"'
PS1='[\u@\h \W]\$ '               <== 命令提示符, 之前讲过
PS2='> '                          <== 如果使用转义字符(\), 第二行的提示符
PS4='+ '
PWD=/root                         <== 当前所在工作目录 
QTDIR=/usr/lib64/qt-3.3
QTINC=/usr/lib64/qt-3.3/include
QTLIB=/usr/lib64/qt-3.3/lib
RANDOM=3184
SELINUX_LEVEL_REQUESTED=
SELINUX_ROLE_REQUESTED=
SELINUX_USE_CURRENT_RANGE=
SHELL=/bin/bash                   <== 使用的 shell
SHELLOPTS=braceexpand:emacs:hashall:histexpand:history:interactive-comments:monitor
SHLVL=1
SSH_ASKPASS=/usr/libexec/openssh/gnome-ssh-askpass
SSH_CLIENT='192.168.1.11 1766 22'
SSH_CONNECTION='192.168.1.11 1766 192.168.1.206 22'
SSH_TTY=/dev/pts/0
TERM=xterm
UID=0
USER=root
_=0
colors=/etc/DIR_COLORS
myname=test_test2      <== 这些都是我们自定义的变量, 并且 export, 可以查看
number=0               <== 这些都是我们自定义的变量, 并且没有 export, 也可以查看
price=5
......
```

### HOME环境变量
代表用户的家目录, 我们使用 ` cd ~ ` 或者 ` cd ` 命令就可以跳转到自己的家目录, 就是使用了这个变量.
> root 用户的家目录为 /root
>
> 一般用户的默认(因为家目录可以自己设置, 以后讲解)家目录为 /home/USERNAME

```bash
[root@localhost ~]# echo $HOME
/root
```
### SHELL环境变量
可以告诉我们当前环境使用的 shell 是哪个应用程序, **Linux 默认的 shell 为 /bin/bash**

### HISTSIZE环境变量
记录历史命令的条数, 就由此变量控制

### PATH环境变量
执行命令查找的路径, 目录和目录之间用 ":" 分隔, 因为是按照 PATH 定义的顺序从左到右查询, 所以目录的顺序是非常重要的, 一般不要随意更改. 并且对于不同的用户它们 PATH 变量的值可能不同, 所以导致执行有些命令会出现 command not found 的提示信息. 我们也可以使用 ` 绝对路径 ` 来执行命令, 但是一定要保证有执行的权限才可以.

> 不同用户默认 PATH 不同, 所以默认能够执行的命令也不同
> PATH 变量是可以修改的, 但是不建议修改
> 使用绝对路径或相对路径来执行, 会比使用 PATH 更准确(需要由执行权限)
> 自己源码安装的软件, 命令应该放置在正确的目录中, 执行才会比较方便

### RANDOM环境变量
在环境变量中, RANDOM 变量的值内容介于 0 - 32767 之间
```bash
[root@localhost ~]# echo $RANDOM
29126

// 如果我们想要得到 0-9 之间的数字, 可以使用 declare 
[root@localhost ~]# declare -i number=$RANDOM*10/32768; echo $number
0
[root@localhost ~]# declare -i number=$RANDOM*10/32768; echo $number
4
[root@localhost ~]# declare -i number=$RANDOM*10/32768; echo $number
6
[root@localhost ~]# declare -i number=$RANDOM*10/32768; echo $number
1
```
### $ 变量
其实 $ 也是一个变量, 所以我们如果想要输出 $ 字符, 就需要使用转义字符来操作. $ 代表目前这个 shell 的进程ID, 也就是 PID(Process ID). 
```bash
[root@localhost ~]# echo $$
33577
```
### ? 变量
" ? " 也是一个特殊的变量, 它表示的是 **上一个执行的命令所回传的值**, 这句话是什么意思呢, 当我们执行某个命令时, 这些命令都会回传一个执行后的代码. 一般来说 :
> 如果成功执行该命令, 则会返回 0 
> 如果执行过程中发生错误, 则会返回 非0

```bash
[root@localhost ~]# echo $SHELL
/bin/bash
[root@localhost ~]# echo $?
0   <== 上一条命令执行的没有问题, 所以返回 0 
[root@localhost ~]# cat xxxxxxxxxxxxx
cat: xxxxxxxxxxxxx: No such file or directory
[root@localhost ~]# echo $?
1   <== 上一条命令有问题报错, 所以返回为 非0(有些Linux是1, 有些是2,所以只能说是 非0)
[root@localhost ~]# echo $?
0   <== 这个为啥又是 0 了呢? 因为 echo $? 成功执行了, 所以肯定也是 0 啊

## 所以切记是 上一条命令的返回值
```

### export命令
将自定义变量转换为环境变量 或者 显示所有的环境变量, 从 env 和 set 命令, 我们就知道有 **自定义变量** 和 **环境变量**, 那么这两者有啥区别呢? 最主要的区别就是 **"能否被子进程所使用"**, 那么什么是 子进程 什么是父进程呢? 我们来讲解一下.
> 当我们登录系统之后, 会取得一个 bash, 然后这个 bash 就是一个独立的进程, 被称为父进程. 那么我们在这个 bash 下面执行的任何命令都是由这个 bash 衍生出来的, 所以被执行的命令就被称为子进程.

![父进程&子进程](https://github.com/gkdaxue/linux/raw/master/image/chapter_A4_0002.png)

我们在 bash 下面又执行了另一个 bash, 然后就开启了一个子进程, 那么父进程会进入暂停的状态(sleep), 若要进入到父进程中, 就需要将子进程结束掉(exit 或 logout) 才可以.
> **子进程仅会继承父进程的环境变量, 而不会继承自定义变量**, 如果你在父进程中定义的自定义变量没有 export 时, 进入到子进程中, 这些变量就会消失不见, 所以你也就无法使用这些变量, 一直到你退出子进程, 这些变量才可以被使用.

```bash
[root@localhost ~]# export
declare -x CVS_RSH="ssh"
declare -x G_BROKEN_FILENAMES="1"
declare -x HISTCONTROL="ignoredups"
declare -x HISTSIZE="1000"
declare -x HOME="/root"
declare -x HOSTNAME="localhost.localdomain"
declare -x LANG="en_US.UTF-8"
declare -x LESSOPEN="||/usr/bin/lesspipe.sh %s"
declare -x LOGNAME="root"
declare -x LS_COLORS="rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=01;05;37;41:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.lz=01;31:*.xz=01;31:*.bz2=01;31:*.tbz=01;31:*.tbz2=01;31:*.bz=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.rar=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.axv=01;35:*.anx=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=01;36:*.au=01;36:*.flac=01;36:*.mid=01;36:*.midi=01;36:*.mka=01;36:*.mp3=01;36:*.mpc=01;36:*.ogg=01;36:*.ra=01;36:*.wav=01;36:*.axa=01;36:*.oga=01;36:*.spx=01;36:*.xspf=01;36:"
declare -x MAIL="/var/spool/mail/root"
declare -x OLDPWD="/root"
declare -x PATH="/usr/lib64/qt-3.3/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin"
declare -x PWD="/root"
declare -x QTDIR="/usr/lib64/qt-3.3"
declare -x QTINC="/usr/lib64/qt-3.3/include"
declare -x QTLIB="/usr/lib64/qt-3.3/lib"
declare -x SELINUX_LEVEL_REQUESTED=""
declare -x SELINUX_ROLE_REQUESTED=""
declare -x SELINUX_USE_CURRENT_RANGE=""
declare -x SHELL="/bin/bash"
declare -x SHLVL="1"
declare -x SSH_ASKPASS="/usr/libexec/openssh/gnome-ssh-askpass"
declare -x SSH_CLIENT="192.168.1.11 1766 22"
declare -x SSH_CONNECTION="192.168.1.11 1766 192.168.1.206 22"
declare -x SSH_TTY="/dev/pts/0"
declare -x TERM="xterm"
declare -x USER="root"
declare -x myname="test_test2"   <== 我们自己设置的环境变量
```
## 变量的有效范围
被 export 设置过的变量, 在父进程或者子进程中都可以访问, 我们称它为 ` 环境变量(全局变量) `, 其他的自定义变量则称为 ` 自定义变量(局部变量) `, 不可在子进程中访问.
```bash
[root@localhost ~]# myname="test_test2"
[root@localhost ~]# echo $myname
test_test2
[root@localhost ~]# bash            # <== 打开一个子进程
[root@localhost ~]# echo ${myname}
                                    # <== 发现值为空的
[root@localhost ~]# exit            # <== 退出子进程
exit
[root@localhost ~]# export myname   # <== export 一下
[root@localhost ~]# bash 
[root@localhost ~]# echo ${myname}   
test_test2                          # <== 子进程中可以使用
```
## 变量内容的删除﹑替换和删除
变量除了直接设置来修改原本的内容之外, 也可以通过一些操作来对变量的内容就行删除与替换.

### 变量内容的删除与替换
| 设置方式             | 说明                               |
| ---------------- | -------------------------------- |
| ${变量#关键字}        | 若变量内容从头开始的数据符合"关键字", 则将符合的最短数据删除 |
| ${变量##关键字}       | 若变量内容从头开始的数据符合"关键字", 则将符合的最长数据删除 |
| ${变量%关键字}        | 若变量内容从尾向前的数据符合"关键字", 则将符合的最短数据删除 |
| ${变量%%关键字}       | 若变量内容从尾向前的数据符合"关键字", 则将符合的最长数据删除 |
| ${变量/旧字符串/新字符串}  | 若变量内容符合"旧字符串", 则第一个旧字符串会被新字符串替换  |
| ${变量//旧字符串/新字符串} | 若变量内容符合"旧字符串", 则全部的旧字符串会被新字符串替换  |

#### 实例
```bash
[root@localhost ~]# echo $path

[root@localhost ~]# path=${PATH}
[root@localhost ~]# echo $path
/usr/lib64/qt-3.3/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin

## ${变量#关键字}   * 表示通配符匹配任意长度字符
[root@localhost ~]# echo ${path#/*bin:}
/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
[root@localhost ~]# echo ${path#/*:}
/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin

## ${变量##关键字} 
[root@localhost ~]# echo $path
/usr/lib64/qt-3.3/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
[root@localhost ~]# echo ${path##/*:}
/root/bin

## ${变量%关键字}
[root@localhost ~]# echo $path
/usr/lib64/qt-3.3/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
[root@localhost ~]# echo ${path%:*bin}
/usr/lib64/qt-3.3/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

${变量%%关键字}
[root@localhost ~]# echo $path
/usr/lib64/qt-3.3/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
[root@localhost ~]# echo ${path%%:*bin}
/usr/lib64/qt-3.3/bin

## 测试一
[root@localhost ~]# echo ${MAIL}
/var/spool/mail/root
[root@localhost ~]# echo ${MAIL##/*/}
root

## 测试二
[root@localhost ~]# echo ${MAIL}
/var/spool/mail/root
[root@localhost ~]# echo ${MAIL%/*}
/var/spool/mail

## ${变量/旧字符串/新字符串}   ${变量//旧字符串/新字符串}
[root@localhost ~]# echo ${PATH}
/usr/lib64/qt-3.3/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
[root@localhost ~]# echo ${PATH/sbin/SBIN}
/usr/lib64/qt-3.3/bin:/usr/local/SBIN:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
[root@localhost ~]# echo ${PATH//sbin/SBIN}
/usr/lib64/qt-3.3/bin:/usr/local/SBIN:/usr/local/bin:/SBIN:/bin:/usr/SBIN:/usr/bin:/root/bin
```

### 变量的测试与内容替换
在某些时刻, 我们需要判断一个变量的值是否存在, 存在就输出变量的值, 不存在则给予一个默认值.

| 设置方式 | str为空字符串 | str已设置且非空字符串 | str没有设置 | 
| ---------------- | -------------------- | -------------------- | ------------------ |
| var=${str-expr}  | var=              | var=$str           | var=expr             | 
| var=${str:-expr} | var=expr          | var=$str           | var=expr             |
| var=${str+expr}  | var=expr          | var=expr           | var=                 |
| var=${str:+expr} | var=              | var=expr           | var=                 |
| var=${str=expr}  | str不变<br>var=    | str不变<br>var=$str  | str=expr<br>var=expr |
| var=${str:=expr} | str=expr<br>var=expr | str不变<br >var=$str | str=expr<br>var=expr |
| var=${str?expr}  | var=              | var=$str            | expr 输出至 stderr      |
| var=${str:?expr} | expr 输出至 stderr | var=$str      | expr 输出至 stderr      |

```bash
## 我们只是设置了 str1 为空字符串, str2 得值为 str2 没有设置 str3 变量
[root@localhost ~]# str1=
[root@localhost ~]# str2='str2'
[root@localhost ~]# echo ${str1} ; echo ${str2} ; echo ${str3}

str2

[root@localhost ~]# set | grep str[123]
str1=
str2=str2
[root@localhost ~]# 

## ${str-expr}
[root@localhost ~]# echo ${str1-str11} ; echo ${str2-str22} ; echo ${str3-str33}

str2
str33

## var=${str:-expr}
[root@localhost ~]# echo ${str1:-str11} ; echo ${str2:-str22} ; echo ${str3:-str33}
str11
str2
str33

## var=${str+expr}
[root@localhost ~]# echo ${str1+str11} ; echo ${str2+str22} ; echo ${str3+str33}
str11
str22

## var=${str:+expr}
[root@localhost ~]# echo ${str1:+str11} ; echo ${str2:+str22} ; echo ${str3:+str33}

str22

## var=${str=expr}
[root@localhost ~]# echo ${str1} ; echo ${str1=str11} ; echo ${str1}



[root@localhost ~]# echo ${str2} ; echo ${str2=str22} ; echo ${str2}
str2
str2
str2
[root@localhost ~]# echo ${str3} ; echo ${str3=str33} ; echo ${str3}

str33
str33

## 还原默认情况
[root@localhost ~]# echo ${str1} ; echo ${str2} ; echo ${str3}

str2
str33
[root@localhost ~]# unset str3
[root@localhost ~]# echo ${str1} ; echo ${str2} ; echo ${str3}

str2

## var=${str:=expr}
[root@localhost ~]# echo ${str1} ; echo ${str1:=str11} ; echo ${str1}

str11
str11
[root@localhost ~]# echo ${str2} ; echo ${str2:=str22} ; echo ${str2}
str2
str2
str2
[root@localhost ~]# echo ${str3} ; echo ${str3:=str33} ; echo ${str3}
str33
str33
str33

## 还原设置
[root@localhost ~]# echo ${str1} ; echo ${str2} ; echo ${str3}
str11
str2
str33
[root@localhost ~]# str1=
[root@localhost ~]# unset str3
[root@localhost ~]# echo ${str1} ; echo ${str2} ; echo ${str3}

str2

## var=${str?expr}
[root@localhost ~]# echo ${str1?str11} 

[root@localhost ~]# echo ${str2?str22} 
str2
[root@localhost ~]# echo ${str3?str33}
-bash: str3: str33

## var=${str:?expr}
[root@localhost ~]# echo ${str1:?str11}
-bash: str1: str11
[root@localhost ~]# echo ${str2:?str22}
str2
[root@localhost ~]# echo ${str3:?str33}
-bash: str3: str33
```

## 通配符(glob)与特殊符号
我们利用通配符可以来快速的完成我们想要的操作.

| 符号    | 含义                                                                       |
| ----- | ------------------------------------------------------------------------ |
| *     | 任意长度的任意字符                                                                |
| ?     | 任意单个字符                                                                   |
| []    | 匹配指定范围内的任意单个字符                                                           |
| \[-\] | 连续范围内的所有字符 <br>\[0-9\] 表示 0-9 之间的所有数字<br>\[a-z\] 不区分字母大小写<br>\[A-Z\] 大写字母 |
| \[^\] | 匹配指定范围之外的任意单个字符, 如 \[^a-z\] 表示除了字母之外都行                               |

### 专用字符集合
从上表中我们可以知道, [a-z] 可以表示字母,但是不区分大小写, 如果我们只想要小写字母如何表示, 并且还有特殊符号等等. 所以需要专用字符集合来更准确的描述, **请仔细观看描述信息**

| 字符            | 描述                                 |
| ------------- | ---------------------------------- |
| \[\:digit\:\] | 任意数字, 相当于 0-9, 注意是 0-9 而不是 \[0-9\] |
| \[\:lower\:\] | 任意小写字母  a-z                        |
| \[\:upper\:\] | 任意大写字母  A-Z                        |
| \[\:alpha\:\] | 任意大小写字母  a-z A-Z                   |
| \[\:alnum\:\] | 任意数字或字母  a-z A-Z 0-9               |
| \[\:space\:\] | 空格                                 |
| \[\:punct\:\] | 标点符号                               |

#### 实例
```bash
## 找到 /etc 下以 cron 开头的文件名
[root@localhost ~]# ll -d /etc/cron*
drwxr-xr-x. 2 root root 4096 Mar  3 11:38 /etc/cron.d
drwxr-xr-x. 2 root root 4096 Mar  3 11:39 /etc/cron.daily
...

## 找到 /etc 下文件名刚好为五个字符的文件名
[root@localhost ~]# ll -d /etc/?????
drwxr-x---. 3 root root 4096 Mar  3 11:39 /etc/audit
drwxr-xr-x. 2 root root 4096 Mar  3 11:35 /etc/avahi
...

## 找到 /etc 下文件名包含数字的文件名
[root@localhost ~]# ll -d /etc/*[0-9]*
drwxr-xr-x. 4 root root 4096 Mar  3 11:35 /etc/dbus-1
-rw-r--r--. 1 root root 5139 Feb  7  2017 /etc/DIR_COLORS.256color
...

## 找到 /etc 下文件名开头不是小写
[root@localhost ~]# ll -d /etc/[^[:lower:]]*
drwxr-xr-x. 5 root root 4096 Mar  3 11:35 /etc/ConsoleKit
-rw-r--r--. 1 root root 4439 Feb  7  2017 /etc/DIR_COLORS
...

## 显示 /var 下以  l(小写L) 开头, 以一个小写字母结尾且中间至少出现一位数字的文件名
[root@localhost ~]# ls -d /var/l*[0-9]*[[:lower:]]
ls: cannot access /var/l*[0-9]*[[:lower:]]: No such file or directory
[root@localhost ~]# touch /var/lable2364l
[root@localhost ~]# ls -d /var/l*[0-9]*[[:lower:]]
/var/lable2364l

## 显示 /etc 下, 以任意一位数字开头且以非数字结尾的文件名
[root@localhost ~]# ll -d /var/[[:digit:]]*[^[:digit:]]

## 显示 /etc 下, 以非字母开头, 后面跟了一个字母及其他任意长度任意字符的文件名
[root@localhost ~]# ll -d /etc/[^[:alpha:]][a-z]*
ls: cannot access /etc/[^[:alpha:]][a-z]*: No such file or directory

## 显示 /etc 下, 所有以m开头, 以非数字结尾的文件名
[root@localhost ~]# ll -d /etc/m*[^0-9]
-rw-r--r--. 1 root root   111 May 11  2016 /etc/magic
-rw-r--r--. 1 root root   272 Nov 18  2009 /etc/mailcap
...

## 显示 /etc 下, 所有以 .d 结尾的文件或目录
[root@localhost ~]# ll -d /etc/*.d
drwxr-xr-x.  2 root root 4096 Mar  3 11:40 /etc/bash_completion.d
drwxr-xr-x.  2 root root 4096 May 11  2016 /etc/chkconfig.d
...

## 显示 /etc 下, 以 .conf 结尾, 且以m,n,r,p 开头的文件名
[root@localhost ~]# ll -d /etc/[mnrp]*.conf
-rw-r--r--. 1 root root  827 Mar 23  2017 /etc/mke2fs.conf
-rw-r--r--. 1 root root 2620 Aug 17  2010 /etc/mtools.conf
...
```

### 特殊符号

| 符号    | 含义                                    |
| :-----: | ------------------------------------- |
| #     | shell script 第一行表示声明, 其余表示注释, 其后数据不执行 |
| \     | 转义符号, 将特殊字符或者通配符转义为一般字符               |
| \|     | 管道符号(pipe), 分割两个管道命令的界定               |
| ;     | 连续命令执行的分隔符                            |
| ~     | 用户的家目录                                |
| $     | 变量的前导符                                |
| &     | 作业控制(job control), 在后台执行命令            |
| !     | 逻辑运算符 "非" 的意思                         |
| /     | 目录分隔符                                 |
| >, >> | 标准输出重定向                               |
| <, << | 标准输入重定向                               |
| ' '   | 单引号, 其中的变量不置换                         |
| " "   | 双引号, 其中的变量会置换                         |
| \` \` | 反引号, 中间是可先执行的命令, 也可使用 $()             |
| ( )   | 中间为子shell的开始与结束                       |
| {}    | 中间为命令块的组合                             |

> **所以以后在文件命名中, 尽量不要使用到上面这些符号**

# Bash Shell 的操作环境
## 路径与命令查找顺序
我们之前就已经讲过了命令的查找顺序, 然后我们今天来复习一下, 然后来讲解接下来的知识点
> 1. 是否已绝对路径或相对路径执行命令, 如果是立即执行
> 2. 检查用户输入的命令是否是 alias 命令
> 3. 判断用户输入的是不是内部命令, 如果是 直接执行
> 4. 先去查找该命令是否被 hash 所保存下来
> ```bash
> [root@localhost ~]# hash | head -n 3
> hits	command
>    7	/bin/
>    
>    1	/bin/hostname
> 如果保存下来, 直接根据路径, 无需查找, 否则就在 PATH 中执行查找(从左至右顺序符合条件的第一个命令)操作并 hash
> ```

## /etc/issue 和 /etc/motd
我们可以在 bash 也有登录页面和欢迎信息, 在 (tty1-6)登录的时候, 会有几行提示信息, 那就是登录页面, 提示信息被写在 /etc/issue 里面
```bash
## tty1 - tty6 登录提示信息
CentOS release 6.9 (Final)
Kernel 2.6.32-696.el6.x86_64 on an x86_64

## 查看 /etc/issue
[root@localhost ~]# cat /etc/issue
CentOS release 6.9 (Final)
Kernel \r on an \m

## 那么 \r  \m 又都是代表什么含义呢?
```

| /etc/issue 文件中变量    | 含义                                    |
| :-----: | ------------------------------------- |
| \d     | 当前日期 |
| \t     | 当前时间 |
| \l (小写L)     | 显示第几个终端 |
| \m     | 显示硬件等级(x86_64) |
| \n     | 显示主机的网络名称                                |
| \r     | 显示内核版本(uname -r)            |
| \s     | 操作系统的名称                         |
| \v    | 操作系统的版本                                 |

所有我们就知道, 为什么我们使用 tty1-tty6时会显示对应的提示信息以及显示变量的设置, 还有一个 /etc/issue.nett 是提供给 telnet 远程登录程序使用的, 当我们使用 telnet 登录系统时就会显示 /etc/issue.net 文件中的内容, 但是实际的情况是 我们使用的最多的是 ssh 方式登录到系统中, 如果我们想要显示提示信息, 那么就需要用到我们所说的 /etc/motd 文件了.
```bash
## 该文件默认为空文件, 然后我们尝试写入一些信息
[root@localhost ~]# cat /etc/motd
[root@localhost ~]# echo 'Hi, How are you ?' > /etc/motd 
[root@localhost ~]# cat /etc/motd 
Hi, How are you ?

## 我们退出当前终端, 重新登录
[root@localhost ~]# exit
logout
[d:\~]$ ssh root@192.168.1.206
Last login: Sat Apr 13 10:45:13 2019
Hi, How are you ?  <== 发现出现了我们所添加的信息
```
### 总结
> /etc/issue : 给 tty1-tty6 终端设置相应的提示信息, 允许使用特定的变量
>
> /etc/issue.net : 给 telnet 的用户设置提示信息
>
> /etc/motd : 给所有的终端设置提示信息(不解析 /etc/issue 中提供的变量) 

## bash 的环境配置文件
当我们登录系统时, 什么都没有做就可以使用一些变量, 就是因为环境配置文件的存在, bash 在启动是回去读取这些配置文件, 而这些配置文件可以分为 ` 全局配置文件 ` 和 ` 用户个人配置文件 `, 例如我们之前所说的别名 变量这些, 如果没有写入到配置文件中, 当我们退出 bash 时即失效, 如果我们想要保留这些设置, 就需要将这些配置写入到对应的配置文件中.
> login shell : 取得 bash 时需要完整的登录流程(比如登录时, 需要输入账号和密码)
>
> non-login shell : 取得 bash 接口的方法不需要重复登录的动作(比如你已经登录系统了, 重新打开一个新的bash 不需要登录)

```bash
login shell :
	正常通过终端登录
	su - USERNAME
	su -l USERNAME

non-login shell :
	su USERNAME
	图形终端下打开命令窗口
	自动执行的 shell 脚本
```

### login shell 配置文件
login shell 只会读取两个配置文件 /etc/profile 和 ~/.bash_profile .
> /etc/profile : 系统整体的配置文件, 所有用户都可以使用
>
> ~/.bash_profile : 用户个人的配置文件, 只能用户自己使用

#### /etc/profile
```bash
## 利用用户的标识符 (UID) 来设置很多的变量, 每个用户取得 bash 时都会读取的配置文件.设置的环境变量有:
[root@localhost ~]# cat /etc/profile
pathmunge () {
    case ":${PATH}:" in
        *:"$1":*)
            ;;
        *)
            if [ "$2" = "after" ] ; then
                PATH=$PATH:$1
            else
                PATH=$1:$PATH
            fi
    esac
}


if [ -x /usr/bin/id ]; then
    if [ -z "$EUID" ]; then
        # ksh workaround
        EUID=`/usr/bin/id -u`    <== 设置有效用户的 ID 给 EUID
        UID=`/usr/bin/id -ru`    <== 显示真实的 ID, 而不是有效的 ID 
    fi
    USER="`/usr/bin/id -un`"     <== 设置用户名
    LOGNAME=$USER                <== 设置登录名
    MAIL="/var/spool/mail/$USER" <== 设置邮箱地址变量
fi

# Path manipulation      <== 主要用来设置 PATH 变量
if [ "$EUID" = "0" ]; then  
    pathmunge /sbin
    pathmunge /usr/sbin
    pathmunge /usr/local/sbin
else
    pathmunge /usr/local/sbin after
    pathmunge /usr/sbin after
    pathmunge /sbin after
fi

HOSTNAME=`/bin/hostname 2>/dev/null`          <== 设置主机名
HISTSIZE=1000                                 <== 设置历史命令记录条数
if [ "$HISTCONTROL" = "ignorespace" ] ; then  <== 设置历史命令的控制方式
    export HISTCONTROL=ignoreboth
else
    export HISTCONTROL=ignoredups
fi

export PATH USER LOGNAME MAIL HOSTNAME HISTSIZE HISTCONTROL  <== 提升为环境变量

## 针对不同的用户设置不同的 umask 值
if [ $UID -gt 199 ] && [ "`/usr/bin/id -gn`" = "`/usr/bin/id -un`" ]; then
    umask 002
else
    umask 022
fi

## 循环读取 /etc/profile.d/*.sh 下的配置文件
for i in /etc/profile.d/*.sh ; do
    if [ -r "$i" ]; then
        if [ "${-#*i}" != "$-" ]; then
            . "$i"
        else
            . "$i" >/dev/null 2>&1
        fi
    fi
done

unset i
unset -f pathmunge
```

#### /etc/profile.d/*.sh
只要在/etc/profile.d/ 目录下并且扩展名为 .sh 的文件, 并且用户具有 r 权限, 那么该文件就会被 /etc/profile 调用, 有兴趣的同学可以自己查看一下. 我们主要讲解 /etc/sysconfig/il8n 这个文件, 这个文件是被 /etc/profile.d/lang.sh 调用的, 它决定了 bash 默认使用的什么语系, 这个文件中最重要的就是 LANG 这个变量的设置

#### ~/.bash_profile
bash 在读取完整体环境设置的 /etc/profile 并调用了其他相应的文件后,  接下来就会读取用户的个人配置文件, 个人配置文件主要有三个, 依序是 :
> 1. ~/.bash_profile
> 2. ~/.bash_login
> 3. ~/.profile

**只会按照上面的顺序读取三个配置文件中的一个**, 主要是为了照顾其他 shell 转换过来的用户习惯.
```bash
[root@localhost ~]# cat ~/.bash_profile 
# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then   <== 判断是否存在该文件, 如果存在则并读取设置
	. ~/.bashrc   
fi

PATH=$PATH:$HOME/bin 
export PATH
```

#### ~/.bashrc
```bash
[root@localhost ~]# cat ~/.bashrc
# .bashrc

# User specific aliases and functions

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Source global definitions
if [ -f /etc/bashrc ]; then   <== 如果 /etc/bashrc 文件存在, 就加载 /etc/bashrc
	. /etc/bashrc
fi
```

#### /etc/bashrc
```bash
[root@localhost ~]# cat /etc/bashrc
if [ "$PS1" ]; then
  if [ -z "$PROMPT_COMMAND" ]; then
    case $TERM in
    xterm*)
        if [ -e /etc/sysconfig/bash-prompt-xterm ]; then
            PROMPT_COMMAND=/etc/sysconfig/bash-prompt-xterm
        else
            PROMPT_COMMAND='printf "\033]0;%s@%s:%s\007" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/~}"'
        fi
        ;;
    screen)
        if [ -e /etc/sysconfig/bash-prompt-screen ]; then
            PROMPT_COMMAND=/etc/sysconfig/bash-prompt-screen
        else
            PROMPT_COMMAND='printf "\033]0;%s@%s:%s\033\\" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/~}"'
        fi
        ;;
    *)
        [ -e /etc/sysconfig/bash-prompt-default ] && PROMPT_COMMAND=/etc/sysconfig/bash-prompt-default
        ;;
      esac
  fi
  shopt -s checkwinsize
  [ "$PS1" = "\\s-\\v\\\$ " ] && PS1="[\u@\h \W]\\$ "   <== 设置 PS1 变量
fi

if ! shopt -q login_shell ; then # We're not a login shell
    pathmunge () {
        case ":${PATH}:" in
            *:"$1":*)
                ;;
            *)
                if [ "$2" = "after" ] ; then
                    PATH=$PATH:$1
                else
                    PATH=$1:$PATH
                fi
        esac
    }

    # 设置 umask 值
    if [ $UID -gt 199 ] && [ "`/usr/bin/id -gn`" = "`/usr/bin/id -un`" ]; then
       umask 002
    else
       umask 022
    fi

    # 加载 /etc/profile.d/*.sh
    for i in /etc/profile.d/*.sh; do
        if [ -r "$i" ]; then
            if [ "$PS1" ]; then
                . "$i"
            else
                . "$i" >/dev/null 2>&1
            fi
        fi
    done

    unset i
    unset pathmunge
fi
# vim:ts=4:sw=4
```
![login_shell](https://github.com/gkdaxue/linux/raw/master/image/chapter_A4_0003.png)

### non-login shell
当你取得 non-login shell 时, 该 bash 仅会读取 ~/.bashrc 而已

#### ~/.bashrc   
```bash
[root@localhost ~]# cat ~/.bashrc    <== root 用户的 .bashrc 文件
alias rm='rm -i'   <== 普通用户的 .bashrc 文件没有如下别名, 主要是因为防止 root 误操作.
alias cp='cp -i'
alias mv='mv -i'

# Source global definitions
if [ -f /etc/bashrc ]; then  <== 判断是否存在该文件, 存在就加载 /etc/bashrc 文件
	. /etc/bashrc
fi

## 普通用户
[root@localhost ~]# cat ~gkdaxue/.bashrc   <== 普通用户的 .bashrc 文件  

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific aliases and functions

```

#### /etc/bashrc
和之前讲过的文件一样, 不在讲解.
```bash
[root@localhost ~]# cat /etc/bashrc
......
    for i in /etc/profile.d/*.sh; do    <== 加载 /etc/profile.d/*.sh 文件
        if [ -r "$i" ]; then
            if [ "$PS1" ]; then
                . "$i"
            else
                . "$i" >/dev/null 2>&1
            fi
        fi
    done

    unset i
    unset pathmunge
fi
# vim:ts=4:sw=4
```
#### /etc/profile.d/*.sh
同之前所讲解的一样.
![non-login_shell](https://github.com/gkdaxue/linux/raw/master/image/chapter_A4_0004.png)

#### 总结
```bash
profile类文件
	设定环境变量
	运行命令或脚本

bashrc类的文件
	设定本地变量
	定义别名命令
```

#### 提问
当我们不小心执行了一个操作, 使命令提示符变成了如下所示, 那么原因是什么?
```bash
[gkdaxue@localhost ~]$   <== 以前正常的提示符 
-bash-4.1$               <== 现在的类似于乱码

## 我们先看一下 PS1 环境变量
-bash-4.1$ echo $PS1 
\s-\v\$      <== 非正常的环境变量, 结合我们之前所说的 PS1 变量是在 /etc/bashrc 文件中加载的

## /etc/bashrc 文件内容
[ "$PS1" = "\\s-\\v\\\$ " ] && PS1="[\u@\h \W]\\$ " 

## 查看 /etc/bashrc 是否存在
-bash-4.1$ ll /etc/bashrc 
-rw-r--r--. 1 root root 2699 Mar 22  2017 /etc/bashrc

## 然后推上一级 ~/.bashrc , 发现不存在
-bash-4.1$ ll ~/.bashrc 
ls: cannot access /home/gkdaxue/.bashrc: No such file or directory

## 然后复制一下, 退出或者重新加载配置文件即可
-bash-4.1$ cp -a /etc/skel/.bashrc ~/
-bash-4.1$ exit  
logout

## 成功解决问题
[gkdaxue@localhost ~]$ 
```

### 其他文件
#### /etc/man.config
这个文件的内容规定了 man 的时候 man page 的路径到哪里去寻找.

#### ~/.bash_history
我们的历史命令就记录在这个文件中, 这个文件能够记录的几条数据和 HISTSIZE 这个变量有关, 每次登陆 bash 时, bash 会先读取这个文件, 然后将所有的历史命令读入内存, 这样当我们登陆 bash 后就可以查看上次使用过的哪些命令.

#### ~/.bash_logout
但我们注销 bash 后系统在帮我完成什么样的操作后才离开. 比如我们可以备份一些重要的数据.

## soure 命令 
由于 /etc/profile 与 ~/.bash_profile 都是取得 login shell 的时候才读取的配置文件, 那么如果我们更改了这两个文件中的设置, 难道只能退出在登录才能生效吗? 当然是 NO, 所以我们就可以使用 source 命令.
> source 配置文件名

```bash
[root@localhost ~]# source /etc/profile
[root@localhost ~]# .    ./.bashrc         # <== 可以使用 . 的形式
```

# Linux 基本命令(3)
## read命令
读取用户从键盘输入的变量值, **从 read 输入的内容都是字符串.**
> read [ options ] 变量名....

| 选项 | 作用 |
|---- | -----|
|-p 提示符 | 提示用户输入的提示信息 |
| -t time_out | 超时时间, 用户超过这个时间没有输入, 自动结束(单位 s) |

### 实例
```bash
[root@localhost ~]# read NAME
gkdaxue   <== 如果你不输入, 它就会一直等待, 因为我们没有设置超时时间, 也没有提示客户进行输入
[root@localhost ~]# echo $NAME
gkdaxue

## -p  -t 等待5秒不操作, 自动关闭
[root@localhost ~]# read -p "Input Your name " -t 5 NAME
Input Your name [root@localhost ~]# 
[root@localhost ~]# read -p "Input Your name " -t 5 NAME
Input Your name gkdaxue
[root@localhost ~]# echo $NAME
gkdaxue

## 输入参数个数 = 变量个数
[root@localhost ~]# read -p "请输入多个参数:" a b c 
请输入多个参数:1 2 3
[root@localhost ~]# echo $a $b $c
1 2 3

## 输入参数个数 < 变量个数
[root@localhost ~]# read -p "请输入多个参数:" a b c d
请输入多个参数:1 2 3
[root@localhost ~]# echo $a $b $c $d
1 2 3

## 输入参数个数 > 变量个数
[root@localhost ~]#  read -p "请输入多个参数:" a b c
请输入多个参数:1 2 3 4
[root@localhost ~]# echo $a $b $c
1 2 3 4
[root@localhost ~]# echo $c
3 4
```

## declare命令 / typeset命令
声明变量的类型, 变量的类型默认为 字符串, 并且 bash 中数组运算, 默认最多仅能达到整数类型
> declare [ options ] variable

| 选项   | 作用                    |
| --- | ----------------------------- |
| -   | 指定变量的类型属性                     |
| +   | 取消变量类型的设置                     |
| f   | 仅显示函数                         |
| r   | 将变量设置为只读 (变量不可更改, 也不能重设)                     |
| x   | 指定的变量会成为环境变量，可供shell以外的程序来使用。 (export 作用一样) |
| i   | [设置值]可以是数值,数字字符串或运算式          |
| a   | 将变量声明为数组                      |
| p   | 显示指定变量的声明类型                   |

### 实例
```bash
## 因为默认为字符串, 所以没有想要的变量的效果
[root@localhost ~]# sum=100+200+300
[root@localhost ~]# echo $sum
100+200+300

## -i 设置为整型, 所以可以计算变量值
[root@localhost ~]# declare -i sum=100+200+300
[root@localhost ~]# echo $sum
600
[root@localhost ~]# declare -p sum
declare -i sum="600"

## 设置只读属性, unset 或者 +r 形式 均无法生效, 通常需要注销在登录才能操作
[root@localhost ~]# declare -r sum  
[root@localhost ~]# declare -p sum
declare -ir sum="600"
[root@localhost ~]# sum=200
-bash: sum: readonly variable   <== 无法重新设置值
```

### 数组(array) 变量类型(了解即可)
```bash
## 有一个 test 数组, [] 中的为索引值, 为一些数字
[root@localhost ~]# test[1]=['test1']
[root@localhost ~]# test[2]=['test2']
[root@localhost ~]# test[3]=['test3']
[root@localhost ~]# echo ${test[1]}, ${test[2]}, ${test[3]}
[test1], [test2], [test3]

## 数组的下标从 0 开始 
[root@localhost ~]# gkdaxue=(aa bb cc dd)
[root@localhost ~]# echo ${gkdaxue[0]}
aa			<== gkdaxue[0]  对应的为  aa

## 查看数组里面所有的元素
[root@localhost ~]# echo ${gkdaxue[*]}
aa bb cc dd
[root@localhost ~]# echo ${gkdaxue[@]}
aa bb cc dd

## 查看所有下标
[root@localhost ~]# echo ${!gkdaxue[*]}
0 1 2 3		<== 数组下标从 0 开始

## 查看数组里面有多少个元素
[root@localhost ~]# echo ${#gkdaxue[*]}
4
```

## wc命令
统计文件中的字节数、字数和行数
> wc [ options ] FILE...

| 选项 | 作用 |
| --- | -------- |
| -c  | 显示Bytes数 |
| -l  | 显示行数     |
| -w  | 统计字数     |

### 实例
```bash
## 准备实验文件
[root@localhost ~]# echo '世界 你好' > wc_file.txt
[root@localhost ~]# file wc_file.txt 
wc_file.txt: UTF-8 Unicode text

## 按照字节数显示内容(包含控制符), 现在了解即可
[root@localhost ~]# sed -n l wc_file.txt 
\344\270\226\347\225\214 \344\275\240\345\245\275$  <== 14 个字节
           6     +      空格(1) +   6   + $   = 14

## 默认使用
[root@localhost ~]# wc wc_file.txt 
 1  2 14 wc_file.txt   <== 行数  单词数   字节数
[root@localhost ~]# wc -l wc_file.txt 
1 wc_file.txt
[root@localhost ~]# wc -w wc_file.txt 
2 wc_file.txt
[root@localhost ~]# wc -c wc_file.txt 
14 wc_file.txt  <== 6 + 空格(1) + 6 + 控制符$(1) = 14
```

## cut命令
提取每行的指定部分, 以行为单位
> cut [options] FILE_NAME

| 选项 | 作用 |
| ---- | -----|
| -d DELIM | 指定分隔符 |
| -f LIST | 要提取的列 |
| -c 字符范围 | 以字符的单位取出固定字符区间 | 
 
### 实例
```bash
[root@localhost ~]# echo $PATH
/usr/lib64/qt-3.3/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
            1              2               3           4    5       6         7        8   

## -f 后边有多种用法  1  1-3    1-3,6      5-
[root@localhost ~]# echo $PATH | cut -d ':' -f 1
/usr/lib64/qt-3.3/bin
[root@localhost ~]# echo $PATH | cut -d ':' -f 1-3
/usr/lib64/qt-3.3/bin:/usr/local/sbin:/usr/local/bin
[root@localhost ~]# echo $PATH | cut -d ':' -f 1-3,6
/usr/lib64/qt-3.3/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin
[root@localhost ~]# echo $PATH | cut -d ':' -f 5-
/bin:/usr/sbin:/usr/bin:/root/bin

## -c 的用法, 如果不想要 declare -x 应该怎么操作
[root@localhost ~]# export | head -n 5
declare -x CVS_RSH="ssh"
declare -x G_BROKEN_FILENAMES="1"
declare -x HISTCONTROL="ignoredups"
declare -x HISTSIZE="1000"
declare -x HOME="/root"
[root@localhost ~]# export | head -n 5 | cut -c 12-
CVS_RSH="ssh"
G_BROKEN_FILENAMES="1"
HISTCONTROL="ignoredups"
HISTSIZE="1000"
HOME="/root"
```

## grep命令
文本搜索工具, 根据用户指定的"模式"对目标文本**逐行**进行匹配检查, 打印匹配到的行(也是以行为单位), 简单来说就是 解析一行文字, 取得关键字, 如果存在关键字就将整行取出来.
> grep [ options ]  PATTERN  FILE_NAME

| 选项 | 作用 |
| --- | ---- |
| -i  | 忽略大小写 |
| -v | 反向选择, 显示没有匹配字符串的那行 | 
|-n | 显示匹配到的行号 | 
| -A NUMBER | 显示匹配到行的后 NUMBER 行 |
| -B NUMBER | 显示匹配到行的前 NUMBER 行 |
| -C NUMBER | 显示匹配到行的前后各 NUMBER 行 |
| --color=auto | 对找到的关键字进行标色处理 |
| -c | 统计含有匹配字符串的行数 |

### 实例
```bash
## 显示 5 个 不能登录系统的用户
[root@localhost ~]# grep '/sbin/nologin' /etc/passwd | head -n 5
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin
adm:x:3:4:adm:/var/adm:/sbin/nologin
lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin
mail:x:8:12:mail:/var/spool/mail:/sbin/nologin

## -v 反向选择
[root@localhost ~]# grep -v "/sbin/nologin" /etc/passwd | head -n 5
root:x:0:0:root:/root:/bin/bash
sync:x:5:0:sync:/sbin:/bin/sync
shutdown:x:6:0:shutdown:/sbin:/sbin/shutdown
halt:x:7:0:halt:/sbin:/sbin/halt
gkdaxue:x:500:500:gkdaxue:/home/gkdaxue:/bin/bash

## -n 显示行号
[root@localhost ~]# grep -vn "/sbin/nologin" /etc/passwd | head -n 5
1:root:x:0:0:root:/root:/bin/bash
6:sync:x:5:0:sync:/sbin:/bin/sync
7:shutdown:x:6:0:shutdown:/sbin:/sbin/shutdown
8:halt:x:7:0:halt:/sbin:/sbin/halt
34:gkdaxue:x:500:500:gkdaxue:/home/gkdaxue:/bin/bash

## -i 忽略大小写
[root@localhost ~]# grep '/SBIN/NOLOGIN' /etc/passwd | head -n 5
[root@localhost ~]# grep -i "/SBIN/NOLOGIN" /etc/passwd | head -n 5
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin
adm:x:3:4:adm:/var/adm:/sbin/nologin
lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin
mail:x:8:12:mail:/var/spool/mail:/sbin/nologin

## -A -B -C 演示
[root@localhost ~]# cat -n /etc/passwd | head -n 3
     1	root:x:0:0:root:/root:/bin/bash
     2	bin:x:1:1:bin:/bin:/sbin/nologin
     3	daemon:x:2:2:daemon:/sbin:/sbin/nologin

[root@localhost ~]# grep -n  '/bin:' /etc/passwd
2:bin:x:1:1:bin:/bin:/sbin/nologin

[root@localhost ~]# grep -n -A 1  '/bin:' /etc/passwd
2:bin:x:1:1:bin:/bin:/sbin/nologin
3-daemon:x:2:2:daemon:/sbin:/sbin/nologin

[root@localhost ~]# grep -n -B 1  '/bin:' /etc/passwd
1-root:x:0:0:root:/root:/bin/bash
2:bin:x:1:1:bin:/bin:/sbin/nologin

[root@localhost ~]# grep -n -C 1  '/bin:' /etc/passwd
1-root:x:0:0:root:/root:/bin/bash
2:bin:x:1:1:bin:/bin:/sbin/nologin
3-daemon:x:2:2:daemon:/sbin:/sbin/nologin

## 并且 grep 也支持我们之前所说的通配符
[root@localhost ~]# grep 'r..t' /etc/passwd
root:x:0:0:root:/root:/bin/bash
operator:x:11:0:operator:/root:/sbin/nologin
ftp:x:14:50:FTP User:/var/ftp:/sbin/nologin
rm_test:x:502:502::/home/rm_test:/bin/bash
```

## sort命令
对文本文件行进行排序, 可以按照不同的数据类型来排序, 例如数字和文字的排序方式就不同. 也可语系的编码有关. (**不会修改原文件**)
**默认按照 ASCLL 字母表的顺序排序, 逐个字符从左到右开始比较**
> sort [ options ] FILE_NAME

| 选项 | 作用 |
|----| ----|
| -n | 使用纯数字进行排序 |
| -r | 降序 |
| -t | 分隔符 | 
| -k | 以哪个字段为关键字进行排序 |
| -u | 相同的数据, 只出现一次 |
| -f | 排序时, 忽略大小写 | 

### 实例
```bash
## 数字排序测试
[root@localhost ~]# cat <<EOF > sort.txt
> 456
> 67
> 67
> 111
> 222
> 111
> EOF
[root@localhost ~]# cat sort.txt 
456
67
67
111
222
111
[root@localhost ~]# sort sort.txt 
111
111
222
456
67
67

## -u 相同内容(内容相邻切相同), 只出现一次
[root@localhost ~]# sort -u sort.txt 
111
222
456
67

## -n 按照数字进行排序(升序)
[root@localhost ~]# sort -n sort.txt 
67
67
111
111
222
456

## -r 降序显示
[root@localhost ~]# sort -nr sort.txt 
456
222
111
111
67
67

## 字母排序测试
[root@localhost ~]# cat /etc/passwd | head -n 5
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin
adm:x:3:4:adm:/var/adm:/sbin/nologin
lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin
[root@localhost ~]# sort /etc/passwd | head -n 5
abrt:x:173:173::/etc/abrt:/sbin/nologin
adm:x:3:4:adm:/var/adm:/sbin/nologin
apache:x:48:48:Apache:/var/www:/sbin/nologin
avahi-autoipd:x:170:170:Avahi IPv4LL Stack:/var/lib/avahi-autoipd:/sbin/nologin
bin:x:1:1:bin:/bin:/sbin/nologin
[root@localhost ~]# sort -r /etc/passwd | head -n 5
vcsa:x:69:69:virtual console memory owner:/dev:/sbin/nologin
vbird1:x:501:501::/home/vbird1:/bin/bash
uucp:x:10:14:uucp:/var/spool/uucp:/sbin/nologin
usbmuxd:x:113:113:usbmuxd user:/:/sbin/nologin
tcpdump:x:72:72::/:/sbin/nologin

## 如果我们想以UID(/etc/passwd文件的第三个字段) 排序 (0, 10, 11, 113)
[root@localhost ~]# sort -t : -k 3 /etc/passwd | head -n 5
root    :x:0:0:root:/root:/bin/bash
uucp    :x:10:14:uucp:/var/spool/uucp:/sbin/nologin
operator:x:11:0:operator:/root:/sbin/nologin
usbmuxd :x:113:113:usbmuxd user:/:/sbin/nologin
bin     :x:1:1:bin:/bin:/sbin/nologin
## 必须使用 -n 作为数字来处理 (0, 1, 2, 3, 4)
[root@localhost ~]# sort -t : -k 3 -n /etc/passwd | head -n 5
root  :x:0:0:root:/root:/bin/bash
bin   :x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin
adm   :x:3:4:adm:/var/adm:/sbin/nologin
lp    :x:4:7:lp:/var/spool/lpd:/sbin/nologin
```

## uniq命令
报告或省略重复行. **重复的行必须是相邻且重复,才算重复行**
> uniq [ options ] FILE_NAME

| 选项 | 作用 |
| --- | --- |
| -c | 统计重复的行 |
| -d | 只显示重复行 |
| -i | 忽略大小写 |

### 实例
```bash
[root@localhost ~]# cat sort.txt 
456
67
67
111
222
111

## 111 与 111 不相邻, 所以不能算重复行
[root@localhost ~]# uniq sort.txt 
456
67
111
222
111

## 所以我们就可以结合 sort 来处理
[root@localhost ~]# sort -n sort.txt | uniq 
67
111
222
456

## -c 统计重复行的次数
[root@localhost ~]# uniq -c sort.txt 
      1 456
      2 67
      1 111
      1 222
      1 111

## -d 只显示重复行
[root@localhost ~]# uniq -d sort.txt 
67
[root@localhost ~]# sort -n sort.txt | uniq -d
67
111
```

## tee命令
输出重定向 > 会将数据流整个传送给文件或设备, 因此除非我们去读取该文件或者设备, 否则我们就无法继续利用这个数据流了, 但是如果我们想要将数据流处理过程中的某段信息保存下来, 那么我们应该如何操作? 这个时候我们就可以使用 tee 命令.
> tee [-a] file

| 选项 | 作用 |
| ---- | ---- |
| -a | 以追加的方式将数据写入到 file 文件中 |

### 实例
```bash
## 保存到文件的同时
[root@localhost ~]# ls -l /etc | tee tee.txt | more
total 2044
drwxr-xr-x.  3 root root   4096 Mar  3 11:35 abrt
drwxr-xr-x.  4 root root   4096 Mar  3 11:39 acpi
-rw-r--r--.  1 root root     46 Mar 12 10:52 adjtime
-rw-r--r--.  1 root root   1512 Jan 12  2010 aliases
-rw-r--r--.  1 root root  12288 Mar  3 11:43 aliases.db
drwxr-xr-x.  2 root root   4096 Mar  3 11:38 alsa
drwxr-xr-x.  2 root root   4096 Mar  3 11:39 alternatives
-rw-------.  1 root root    541 Aug 24  2016 anacrontab
-rw-r--r--.  1 root root    245 Nov 11  2010 anthy-conf
-rw-r--r--.  1 root root    148 Jan 12  2016 asound.conf
......   <== more 命令来查看更多, 这里省略
[root@localhost ~]# cat tee.txt 
total 2044
drwxr-xr-x.  3 root root   4096 Mar  3 11:35 abrt
drwxr-xr-x.  4 root root   4096 Mar  3 11:39 acpi
-rw-r--r--.  1 root root     46 Mar 12 10:52 adjtime
-rw-r--r--.  1 root root   1512 Jan 12  2010 aliases
-rw-r--r--.  1 root root  12288 Mar  3 11:43 aliases.db
drwxr-xr-x.  2 root root   4096 Mar  3 11:38 alsa
drwxr-xr-x.  2 root root   4096 Mar  3 11:39 alternatives
-rw-------.  1 root root    541 Aug 24  2016 anacrontab
-rw-r--r--.  1 root root    245 Nov 11  2010 anthy-conf
-rw-r--r--.  1 root root    148 Jan 12  2016 asound.conf
-rw-r--r--.  1 root root      1 Mar 22  2017 at.deny
drwxr-x---.  3 root root   4096 Mar  3 11:39 audisp
....  省略
[root@localhost ~]# wc -l tee.txt 
252 tee.txt
```

## tr命令
转换或者删除字符, 可以用来删除一段信息中的文字或者进行文字信息的转换.
> tr [ options ] SET1 [SET2]

| 选项 | 作用 |
| ---- | ---- |
| -d | 删除信息当中的 SET1 这个字符串 |
| -s | 替换掉重复的字符串 |

### 实例
```bash
## 指的是替换 a 和 b, 而不是 ab ,  a -> A ; b -> B
[root@localhost ~]# tr ab AB
apple
Apple
Baby
BABy
^C

## 原始记录
[root@localhost ~]# head -n 3 /etc/passwd
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin

## 把小写全部转换成大写字母
[root@localhost ~]# head -n 3 /etc/passwd | tr '[a-z]' '[A-Z]'
ROOT:X:0:0:ROOT:/ROOT:/BIN/BASH
BIN:X:1:1:BIN:/BIN:/SBIN/NOLOGIN
DAEMON:X:2:2:DAEMON:/SBIN:/SBIN/NOLOGIN

## 删除 : 字符
[root@localhost ~]# head -n 3 /etc/passwd | tr -d ':'
rootx00root/root/bin/bash
binx11bin/bin/sbin/nologin
daemonx22daemon/sbin/sbin/nologin

## 在 DOS 下面会自动在每行的行尾加入 ^M 这个断行符号, 所以我们可以使用 tr 来将 ^M 去除
[root@localhost ~]# cp /etc/passwd .
[root@localhost ~]# unix2dos passwd passwd
unix2dos: converting file passwd to DOS format ...
[root@localhost ~]# file /etc/passwd passwd
/etc/passwd: ASCII text
passwd:      ASCII text, with CRLF line terminators  <== DOS 断行

## 断行为 ^M$
[root@localhost ~]# cat -e passwd | head -n 3
root:x:0:0:root:/root:/bin/bash^M$
bin:x:1:1:bin:/bin:/sbin/nologin^M$
daemon:x:2:2:daemon:/sbin:/sbin/nologin^M$

## 然后尝试删除 ^M (^M 可以使用 \r 来代替)
[root@localhost ~]# cat passwd | tr -d '\r' > passwd.linux
[root@localhost ~]# file passwd.linux 
passwd.linux: ASCII text
[root@localhost ~]# cat -e passwd.linux | head -n 3
root:x:0:0:root:/root:/bin/bash$
bin:x:1:1:bin:/bin:/sbin/nologin$
daemon:x:2:2:daemon:/sbin:/sbin/nologin$
```

## col命令
过滤控制字符, 在许多UNIX说明文件里，都有RLF控制字符。当我们运用shell特殊字符">"和">>"，把说明文件的内容输出成纯文本文件时，控制字符会变成乱码，col指令则能有效滤除这些控制字符。

| 选项 | 作用 |
| ---- | ----- |
| -b | 过滤掉所有的控制字符，包括RLF和HRLF |
| -x | 将 tab 键转换为对等的空格键 |

### 实例
```bash
## -x : 将 tab 键转换为对等的空格键
[root@localhost ~]# cat -A /etc/man.config | tail -n 17 | head -n 7
.gz^I^I/usr/bin/gunzip -c$
.bz2^I^I/usr/bin/bzip2 -c -d$
.lzma^I^I/usr/bin/unlzma -c -d$
.z^I^I$
.Z^I^I/bin/zcat$
.F^I^I$
.Y^I^I$
[root@localhost ~]# cat /etc/man.config | tail -n 17 | head -n 7 | col -x 
.gz             /usr/bin/gunzip -c
.bz2            /usr/bin/bzip2 -c -d
.lzma           /usr/bin/unlzma -c -d
.z
.Z              /bin/zcat
.F
.Y

## -b : 过滤掉所有的控制字符，包括RLF和HRLF
[root@localhost ~]# man man > man_test.txt
[root@localhost ~]# cat -A man_test.txt | head
man(1)                                                                  man(1)$
$
$
$
N^HNA^HAM^HME^HE$
       man - format and display the on-line manual pages$
$
S^HSY^HYN^HNO^HOP^HPS^HSI^HIS^HS$
       m^Hma^Han^Hn [-^H-a^Hac^Hcd^HdD^HDf^HfF^HFh^Hhk^HkK^HKt^Htv^HvV^HVw^HwW^HW] [-^H--^H-p^Hpa^Hat^Hth^Hh] [-^H-m^Hm _^Hs_^Hy_^Hs_^Ht_^He_^Hm] [-^H-p^Hp _^Hs_^Ht_^Hr_^Hi_^Hn_^Hg] [-^H-C^HC _^Hc_^Ho_^Hn_^Hf_^Hi_^Hg_^H__^Hf_^Hi_^Hl_^He]$
       [-^H-M^HM _^Hp_^Ha_^Ht_^Hh_^Hl_^Hi_^Hs_^Ht] [-^H-P^HP _^Hp_^Ha_^Hg_^He_^Hr] [-^H-B^HB _^Hb_^Hr_^Ho_^Hw_^Hs_^He_^Hr] [-^H-H^HH _^Hh_^Ht_^Hm_^Hl_^Hp_^Ha_^Hg_^He_^Hr] [-^H-S^HS  _^Hs_^He_^Hc_^Ht_^Hi_^Ho_^Hn_^H__^Hl_^Hi_^Hs_^Ht]$
[root@localhost ~]# vim man_test.txt
[root@localhost ~]# man man | col -b > col_man_test.txt
[root@localhost ~]# cat -A col_man_test.txt |  head
man(1)^I^I^I^I^I^I^I^I^Iman(1)$
$
$
$
NAME$
       man - format and display the on-line manual pages$
$
SYNOPSIS$
       man [-acdDfFhkKtvVwW] [--path] [-m system] [-p string] [-C config_file]$
       [-M pathlist] [-P pager] [-B browser] [-H htmlpager] [-S^I section_list]$

```

## join命令
通过公共的字段来连接两个文件的行, join 默认使用空格符分割数据并且对比 '第一个字段' 的数据, 如果两个文件相同, 则将两条数据连成一行且第一个字段放在第一位.

| 选项 | 作用 |
| ---- | ---- |
| -t 分隔符 | 使用指定的分隔符 |
| -i | 忽略大小写 |
| -l FIELD | 数字1, 表示第一个文件使用哪个字段来分析 |
| -2 FIELD | 表示第二个文件使用哪个字段来分析 |

### 实例
```bash
## 比如 /etc/passwd 和 /etc/shadow 文件都是以 : 分割 且 最第一列都是 账号, 所以我们就可以这么处理
[root@localhost ~]# head -n 5 /etc/passwd /etc/shadow
==> /etc/passwd <==
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin
adm:x:3:4:adm:/var/adm:/sbin/nologin
lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin

==> /etc/shadow <==
root:$6$FchKbWuH$xCX0Z5yND.LOe5LUZP.MAN9DfxHGbiXJ6BkfZiuFsfO/fZKU2hToloxpw/QVTqppdAccJrAxO3.iWJUoex8VE1:17958:0:99999:7:::
bin:*:17246:0:99999:7:::
daemon:*:17246:0:99999:7:::
adm:*:17246:0:99999:7:::
lp:*:17246:0:99999:7:::


## 开始使用 join 来连接, 相同字段被放在了第一个字段的位置上
[root@localhost ~]# join -t ':' /etc/passwd /etc/shadow | head -n 5
root:x:0:0:root:/root:/bin/bash:$6$FchKbWuH$xCX0Z5yND.LOe5LUZP.MAN9DfxHGbiXJ6BkfZiuFsfO/fZKU2hToloxpw/QVTqppdAccJrAxO3.iWJUoex8VE1:17958:0:99999:7:::
bin:x:1:1:bin:/bin:/sbin/nologin:*:17246:0:99999:7:::
daemon:x:2:2:daemon:/sbin:/sbin/nologin:*:17246:0:99999:7:::
adm:x:3:4:adm:/var/adm:/sbin/nologin:*:17246:0:99999:7:::
lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin:*:17246:0:99999:7:::


## /etc/passwd 文件的第四个字段为 组ID, 在 /etc/group 中却是第三个字段, 这就需要我们来指定拼接了
[root@localhost ~]# head -n 5 /etc/passwd /etc/group
==> /etc/passwd <==
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin
adm:x:3:4:adm:/var/adm:/sbin/nologin
lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin

==> /etc/group <==
root:x:0:
bin:x:1:bin,daemon
daemon:x:2:bin,daemon
sys:x:3:bin,adm
adm:x:4:adm,daemon


## 按照我们指定的字段来拼接数据
[root@localhost ~]# join -t ':' -1 4 /etc/passwd -2 3 /etc/group | head -n 5
join: file 1 is not in sorted order   <== 请注意这个提示
join: file 2 is not in sorted order   <== 请注意这个提示
0:root:x:0:root:/root:/bin/bash:root:x:
1:bin:x:1:bin:/bin:/sbin/nologin:bin:x:bin,daemon
2:daemon:x:2:daemon:/sbin:/sbin/nologin:daemon:x:bin,daemon
4:adm:x:3:adm:/var/adm:/sbin/nologin:adm:x:adm,daemon
7:lp:x:4:lp:/var/spool/lpd:/sbin/nologin:lp:x:daemon


## 使用 join 之前, 你需要处理的文件应该是事先经过排序的(sort)处理的, 否则有些对比的项目会被略过. 所以出现提示
## 关于 /etc/passwd  /etc/shadow  /etc/group 文件的内容以后会分析.
```

## paste命令
join 必须要对比两个文件的数据相关性, 而 paste 就直接将两行拼接在一起且中间使用 [tab]键 隔开.

| 选项 | 作用 |
| ---- | ----- |
| -d 分隔符 | 使用指定的分隔符分开 |

### 实例
```bash
## 用 空格隔开
[root@localhost ~]# paste /etc/passwd /etc/shadow | head -n 5
root:x:0:0:root:/root:/bin/bash	root:$6$FchKbWuH$xCX0Z5yND.LOe5LUZP.MAN9DfxHGbiXJ6BkfZiuFsfO/fZKU2hToloxpw/QVTqppdAccJrAxO3.iWJUoex8VE1:17958:0:99999:7:::
bin:x:1:1:bin:/bin:/sbin/nologin	bin:*:17246:0:99999:7:::
daemon:x:2:2:daemon:/sbin:/sbin/nologin	daemon:*:17246:0:99999:7:::
adm:x:3:4:adm:/var/adm:/sbin/nologin	adm:*:17246:0:99999:7:::
lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin	lp:*:17246:0:99999:7:::    <== 中间使用了空格分开
```

## expand命令
将 Tab按键 转化为空格键 

| 选项 | 作用 |
| ---- | ---- |
|  -t Num | 一个 Tab键 可以转化为多少个空格, 默认一个 Tab 用 8 个空格键替换 |

### 实例
```bash
## Tab 键会用 ^I 显示
[root@localhost ~]# cat -A /etc/man.config | tail -n 17 | head -n 7 
.gz^I^I/usr/bin/gunzip -c$
.bz2^I^I/usr/bin/bzip2 -c -d$
.lzma^I^I/usr/bin/unlzma -c -d$
.z^I^I$
.Z^I^I/bin/zcat$
.F^I^I$
.Y^I^I$

## 将 Tab 转换为 空格键, 默认为 8 个空格
[root@localhost ~]# cat /etc/man.config | tail -n 17 | head -n 7 | col -x
.gz             /usr/bin/gunzip -c
.bz2            /usr/bin/bzip2 -c -d
.lzma           /usr/bin/unlzma -c -d
.z
.Z              /bin/zcat
.F
.Y

## -t 将 Tab 键转换为 20 个空格
[root@localhost ~]# cat /etc/man.config | tail -n 17 | head -n 7 | expand -t 20
.gz                                     /usr/bin/gunzip -c
.bz2                                    /usr/bin/bzip2 -c -d
.lzma                                   /usr/bin/unlzma -c -d
.z                                      
.Z                                      /bin/zcat
.F                                      
.Y
```

## split命令
可以把一个大文件依据文件大小或者行数来切割成小文件.
> split [ options ] FILE PREFIX

| 选项 | 作用 |
| ----- | ---- |
| -b Num{bkm} | 切割成指定的文件大小 |
| -l | 以指定的行数切割 |
| PREFIX | 前导符, 可作为切割文件的前导文字 |

### 实例
```bash
[root@localhost ~]# cp /etc/man.config  .
[root@localhost ~]# split -l 10 man.config man_test
[root@localhost ~]# ll man_test*
-rw-r--r--. 1 root root 258 Mar 16 07:25 man_testaa
-rw-r--r--. 1 root root 388 Mar 16 07:25 man_testab
-rw-r--r--. 1 root root 576 Mar 16 07:25 man_testac
-rw-r--r--. 1 root root 243 Mar 16 07:25 man_testad
-rw-r--r--. 1 root root 242 Mar 16 07:25 man_testae
-rw-r--r--. 1 root root 277 Mar 16 07:25 man_testaf
-rw-r--r--. 1 root root 424 Mar 16 07:25 man_testag
-rw-r--r--. 1 root root 317 Mar 16 07:25 man_testah
-rw-r--r--. 1 root root 477 Mar 16 07:25 man_testai
-rw-r--r--. 1 root root 295 Mar 16 07:25 man_testaj
-rw-r--r--. 1 root root 209 Mar 16 07:25 man_testak
-rw-r--r--. 1 root root 215 Mar 16 07:25 man_testal
-rw-r--r--. 1 root root 460 Mar 16 07:25 man_testam
-rw-r--r--. 1 root root 236 Mar 16 07:25 man_testan
-rw-r--r--. 1 root root 297 Mar 16 07:25 man_testao
-rw-r--r--. 1 root root  26 Mar 16 07:25 man_testap
[root@localhost ~]# wc -l man_test*
  10 man_testaa
  10 man_testab
  10 man_testac
  10 man_testad
  10 man_testae
  10 man_testaf
  10 man_testag
  10 man_testah
  10 man_testai
  10 man_testaj
  10 man_testak
  10 man_testal
  10 man_testam
  10 man_testan
  10 man_testao
   2 man_testap
 152 total

## 可以切割文件, 那么我们如何合并文件呢?
[root@localhost ~]# cat man_test** >> count_man.txt
[root@localhost ~]# wc -l count_man.txt 
152 count_man.txt
```

## xargs参数代换
xargs 可以读入 stdin 的数据并且以 空格符或断行字符 进行分辨, 将 stdin 的数据分割成 arguments. xargs 没有接任何的命令时, 默认以 echo 进行输出.
> 使用 xargs 的主要目的是因为有些命令不支持管道符, 因此我们可以通过 xargs 来提供该命令提供的 Standard Input.
>
> xargs [ options ] command

| 选项 | 作用 |
| ---- | ---- |
| -0 | 如果输入的 stdin 含有特殊字符如(`, \)等 还原成一般字符 |
| -e [eof-str] |  当 xargs 解析到这个字符时停止工作 |
| -p | 执行每个命令的参数时, 询问用户是否执行操作 |
| -n Num | 每次 command 执行时, 要使用几个参数 |

### 实例
```bash
## 实验数据
[root@localhost ~]# cut -d ':' -f 1 /etc/passwd | head -n 3
root
bin
daemon

## -n 需要使用 1 个参数
[root@localhost ~]# cut -d ':' -f 1 /etc/passwd | head -n 3 | xargs -n 1 id
uid=0(root) gid=0(root) groups=0(root)
uid=1(bin) gid=1(bin) groups=1(bin),2(daemon),3(sys)
uid=2(daemon) gid=2(daemon) groups=2(daemon),1(bin),4(adm),7(lp)

## -p 提示
[root@localhost ~]# cut -d ':' -f 1 /etc/passwd | head -n 3 | xargs -p -n 1 id
id root ?...y
id bin ?...uid=0(root) gid=0(root) groups=0(root)
y
id daemon ?...uid=1(bin) gid=1(bin) groups=1(bin),2(daemon),3(sys)
y
uid=2(daemon) gid=2(daemon) groups=2(daemon),1(bin),4(adm),7(lp)


## 我们现在想要查找名字叫做 gkdaxue 的文件并查看权限等信息
[root@localhost ~]# find / -name gkdaxue
/tmp/test_zip/gkdaxue
/home/gkdaxue
/var/cache/gdm/gkdaxue
/var/spool/mail/gkdaxue
[root@localhost ~]# find / -name gkdaxue | ls -l
total 0                           <== 这是什么鬼? 我不是已经找到了文件, 没有列出来
## 原因就是 ls 命令不支持管道符, 所有显示的是当前目录下的内容, 那么我们就可以使用 xargs 来处理
[root@localhost ~]# find / -name gkdaxue | xargs ls -ld
drwx------. 4 gkdaxue gkdaxue 4096 Mar 11 06:24 /home/gkdaxue
drwxr-xr-x. 2 root    root    4096 Mar 11 14:01 /tmp/test_zip/gkdaxue
drwxr-xr-x. 2 gkdaxue gkdaxue 4096 Mar  3 11:45 /var/cache/gdm/gkdaxue
-rw-rw----. 1 gkdaxue mail       0 Mar 11 05:59 /var/spool/mail/gkdaxue
```

# screen不间断会话
当我们远程连接到主机上时, 当远程连接被关闭后, 那么在远程主机上运行的命令也被中断, 如果我们正在使用命令来打包文件，或者正在使用脚本安装某个服务程序，中途是绝对不能关闭在本地打开的终端窗口或断开网络链接的，甚至是网速的波动都有可能导致任务中断，此时只能重新进行远程链接并重新开始任务. 那么我们就可以使用 screen 来解决.
screen是一款能够实现多窗口远程控制的开源服务程序，简单来说就是为了解决网络异常中断或为了同时控制多个远程终端窗口而设计的程序。用户还可以使用screen服务程序同时在多个远程会话中自由切换，能够做到实现如下功能 :
> 会话恢复：即便网络中断，也可让会话随时恢复，确保用户不会失去对远程会话的控制。
>
> 多窗口：每个会话都是独立运行的，拥有各自独立的输入输出终端窗口，终端窗口内显示过的信息也将被分开隔离保存，以便下次使用时依然能看到之前的操作记录。
>
> 会话共享：当多个用户同时登录到远程服务器时，便可以使用会话共享功能让用户之间的输入输出信息共享。

## 安装
```bash
[root@localhost ~]# yum install -y screen
Loaded plugins: fastestmirror, refresh-packagekit, security
Setting up Install Process
base                                                    | 3.7 kB     00:00
base/primary_db                                         | 4.7 MB     00:02
extras                                                  | 3.4 kB     00:00
.....
Running Transaction
  Installing : screen-4.0.3-19.el6.x86_64               1/1
  Verifying  : screen-4.0.3-19.el6.x86_64               1/1

Installed:
  screen.x86_64 0:4.0.3-19.el6

Complete!
```

## 管理远程会话
screen命令能做的事情非常多, 如下所示：

| 选项 | 作用 |
| :---: | ---- |
| -S  Session_Name | 创建会话窗口 |
| -d   | 将指定会话进行离线处理 | 
| -r  Session_Name | 恢复指定会话 | 
| -x  | 一次性恢复所有的会话 |
| -ls | 显示当前已有的会话 |
| -wipe  | 把目前无法使用的会话删除 |

```bash
## 创建一个名称为backup的会话窗口。
## 在命令行中敲下这条命令的一瞬间，屏幕会快速闪动一下，这时就已经进入screen服务会话中了，在里面运行的任何操作都会被后台记录下来。
[root@localhost ~]# screen -S backup

## 看着好像什么不一样, 那么我们就使用 screen -ls 来查看一下
[root@localhost ~]# screen -ls
There is a screen on:
        3283.backup     (Attached)
1 Socket in /var/run/screen/S-root.

## 如果我们想退出会话怎么操作呢?
[root@localhost ~]# exit
[screen is terminating]

## 然后我们来创建一个会话, 模拟断网的情况存在
[root@localhost ~]# screen -S gkdaxue
[root@localhost ~]# tail -f /var/log/messages
Mar 20 09:34:13 localhost NetworkManager[1708]: <info> wpa_supplicant started
Mar 20 09:34:14 localhost acpid: starting up
Mar 20 09:34:14 localhost acpid: 1 rule loaded
Mar 20 09:34:14 localhost acpid: waiting for events: event logging is off
Mar 20 09:34:14 localhost acpid: client connected from 1892[68:68]
Mar 20 09:34:14 localhost acpid: 1 client rule loaded
Mar 20 09:34:25 localhost automount[1917]: problem reading master map, maximum wait exceeded
Mar 20 09:34:25 localhost automount[1917]: automount: warning: could not read at least one map source after waiting, continuing ...
Mar 20 09:34:26 localhost abrtd: Init complete, entering main loop
Mar 20 12:56:48 localhost yum[3066]: Installed: screen-4.0.3-19.el6.x86_64
   <== 光标在这里跳动, 因为使用了 -f 参数

## 然后强制关闭当前终端, 在重新打开一个新的终端
[root@localhost ~]# screen -ls
There is a screen on:
	3299.gkdaxue	(Detached)
1 Socket in /var/run/screen/S-root.    <== 可以看到我们之前的依然在

## 恢复一下, 发现还存在, 并没有因为终端的关闭而被关闭.
[root@localhost ~]# screen -r gkdaxue

[root@localhost ~]# tail -f /var/log/messages
Mar 20 09:34:13 localhost NetworkManager[1708]: <info> wpa_supplicant started
Mar 20 09:34:14 localhost acpid: starting up
Mar 20 09:34:14 localhost acpid: 1 rule loaded
Mar 20 09:34:14 localhost acpid: waiting for events: event logging is off
Mar 20 09:34:14 localhost acpid: client connected from 1892[68:68]
Mar 20 09:34:14 localhost acpid: 1 client rule loaded
Mar 20 09:34:25 localhost automount[1917]: problem reading master map, maximum wait exceeded
Mar 20 09:34:25 localhost automount[1917]: automount: warning: could not read at least one map source after waiting, continuing ...
Mar 20 09:34:26 localhost abrtd: Init complete, entering main loop
Mar 20 12:56:48 localhost yum[3066]: Installed: screen-4.0.3-19.el6.x86_64
     <== 发现存在, 并没有因为终端的关闭而被关闭.
```

## 会话共享功能(相同用户)
```bash
## 第一个打开的终端上, 执行以下命令
[root@localhost ~]# screen -S problem

## 然后在打开一个新的终端, 然后执行以下命令
[root@localhost ~]# screen -x

然后你在任何一个终端上执行的命令, 两个终端都可以同步的显示出来
```
