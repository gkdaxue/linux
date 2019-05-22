# 进程
我们之前讲解了 UID/GID 以及 文件属性 等相关概念, 程序一般是放在硬盘上的, 当一个程序被加载到内存中运行时, 那么在内存中的那个数据都会以进程的形式存在并且系统会给与这个进程一个ID(我们称为 PID)并且给予这个 PID 一组有效的权限设置, 根据执行的用户不同给予不同的权限设置.
> 程序 : 通常作为二进制文件存放存储设备中.
> 
> 进程 : 程序被触发后, 执行者的权限和属性 程序的代码以及数据等都会被加载到内存中, 操作系统给予这个内存单元一个 PID.

当我们登录系统后, 系统会给与我们一个 bash 接口去执行另外的一个命令, 然后执行的这个命令会打开一个新的进程, 我们称之为子进程, 原来的 bash 我们称之为父进程.

```bash
## 打印当前进程ID  PID
[root@localhost ~]# echo $$
22481

## 打开一个新的进程并输出 PID
[root@localhost ~]# bash
[root@localhost ~]# echo $$
23255
[root@localhost ~]# ps -l
F S   UID    PID   PPID  C PRI  NI ADDR SZ WCHAN  TTY          TIME CMD
4 S     0  22481  22477  0  80   0 - 27124 do_wai pts/0    00:00:00 bash
4 S     0  23255  22481  0  80   0 - 27124 do_wai pts/0    00:00:00 bash
4 R     0  23267  23255  0  80   0 - 27038 -      pts/0    00:00:00 ps

## 从上面我们可以看出进程之间是有相关性的, 中间省略了大部分数据
[root@localhost ~]# pstree -p
init(1)─┬─NetworkManager(1589)───{NetworkManager}(2622)
        ├─sshd(1822)───sshd(22477)───bash(22481)───bash(23255)───pstree(23294)
```

## fork and exec 
进程都会通过父进程以复制(fork)的方式产生一个一模一样的暂存进程, 暂存进程和父进程的唯一区别就是 PID 不同, 然后还会多出来一个 PPID 的参数, 然后暂存进程再以 exec 方式来执行实际要运行的进程, 最终成为一个子进程,

## 系统服务进程
我们系统中存在很多的一直在运行的进程, 比如 crond 进程每分钟去扫描 /etc/crontab 配置文件, 然后执行满足条件的操作等等, 这些服务进程是常驻在内存中的, 所以我们称之为服务, 比如 Apache, vsftpd, sshd 等

## 进程的管理
### 查看进程( [ps](https://github.com/gkdaxue/linux/blob/0ffaf8dd804e5c2097967bee0fc0eb86d05369ea/tutorial/chapter-05.md#ps%E5%91%BD%E4%BB%A4) 和 [top 命令](https://github.com/gkdaxue/linux/blob/0ffaf8dd804e5c2097967bee0fc0eb86d05369ea/tutorial/chapter-05.md#top%E5%91%BD%E4%BB%A4))

### 控制进程
我们可以关闭  启动或者重启服务器软件, 既然我们能控制程序, 那么我们就能控制进程, 那么程序是怎么管理进程的呢? 其实就是**给予该进程一个 信号(signal) 去告诉该进程应该做什么. 因此这个 signal 就很重要.** 那么到底有多少个 signal 呢, 我们可以使用 ` kill -l ` 命令来查看.

### kill命令
kill 命令主要用来终止一个进程
> kill -SIGNAL %job_number  : 表示对一个工作做什么操作, 不要忘记了前边的 %
> 
> kill -SIGNAL PID : 表示对一个进程做什么操作. 只有 PID 没有 % 
> 
> kill -l(小写L) : 列出目前 kill 能够使用的信号(SIGNAL)

| SIGNAL | 名称 | 作用 |
|:--: | ---- | ----- |
| 1 | SIGHUP | 启动被终止的进程, 可让该PID重新读取配置文件,然后启动 |
| 2 | SIGINT | 相当于使用 ctrl + c 中断一个进程 |
| 9 | SIGKILL | 强制中断一个进程的进行 |
| 15 | SIGTERM | 以正常的结束进程的方式来终止该进程, 如果进程出现问题, 输入无效 |
| 17 | SIGSTOP | 相当于使用 ctrl + z 来暂停一个进程的进行 |

```bash
## 列出 kill 所能使用的所有信号值
[root@localhost ~]# kill -l
 1) SIGHUP	 2) SIGINT	 3) SIGQUIT	 4) SIGILL	 5) SIGTRAP
 6) SIGABRT	 7) SIGBUS	 8) SIGFPE	 9) SIGKILL	10) SIGUSR1
11) SIGSEGV	12) SIGUSR2	13) SIGPIPE	14) SIGALRM	15) SIGTERM
16) SIGSTKFLT	17) SIGCHLD	18) SIGCONT	19) SIGSTOP	20) SIGTSTP
21) SIGTTIN	22) SIGTTOU	23) SIGURG	24) SIGXCPU	25) SIGXFSZ
26) SIGVTALRM	27) SIGPROF	28) SIGWINCH	29) SIGIO	30) SIGPWR
31) SIGSYS	34) SIGRTMIN	35) SIGRTMIN+1	36) SIGRTMIN+2	37) SIGRTMIN+3
38) SIGRTMIN+4	39) SIGRTMIN+5	40) SIGRTMIN+6	41) SIGRTMIN+7	42) SIGRTMIN+8
43) SIGRTMIN+9	44) SIGRTMIN+10	45) SIGRTMIN+11	46) SIGRTMIN+12	47) SIGRTMIN+13
48) SIGRTMIN+14	49) SIGRTMIN+15	50) SIGRTMAX-14	51) SIGRTMAX-13	52) SIGRTMAX-12
53) SIGRTMAX-11	54) SIGRTMAX-10	55) SIGRTMAX-9	56) SIGRTMAX-8	57) SIGRTMAX-7
58) SIGRTMAX-6	59) SIGRTMAX-5	60) SIGRTMAX-4	61) SIGRTMAX-3	62) SIGRTMAX-2
63) SIGRTMAX-1	64) SIGRTMAX	

## 然后我们来创建两个后台暂停的 job
[root@localhost ~]# vim test1.sh

[1]+  Stopped                 vim test1.sh
[root@localhost ~]# vim test2.sh

[2]+  Stopped                 vim test2.sh
[root@localhost ~]# jobs
[1]-  Stopped                 vim test1.sh
[2]+  Stopped                 vim test2.sh

## 尝试正常关闭一个文件和非正常关闭一个文件  9 非正常关闭文件
[root@localhost ~]# kill -9 %1

[1]-  Stopped                 vim test1.sh
[root@localhost ~]# jobs
[1]-  Killed                  vim test1.sh   <== 显示kill
[2]+  Stopped                 vim test2.sh
[root@localhost ~]# jobs
[2]+  Stopped                 vim test2.sh   <== 已经消失不见(被 kill 的那个)

## 我们之前说过 vim 编辑文件非正常关闭, 那么还有一个缓存文件. 正常情况下不存在该文件.
[root@localhost ~]# ll .test1.sh.swp 
-rw-------. 1 root root 4096 Mar 11 14:55 .test1.sh.swp


## 然后我们尝试关闭当前这个终端, 使用 kill 命令
[root@localhost ~]# echo $$
35678
## 发现立即被强制关闭了连接. 此时我们就需要重新登录
[root@localhost ~]# kill -9 35678
```

### killall命令
kill 命令使用的前提是我们必须要提前知道进程的 PID 才可以进行相应的操作, 那么如果我想根据 **执行命令的名称** 来执行某些操作呢? 那我们就需要使用到 killall 命令了
> killall [ options ] command_name

| 选项 | 作用 |
| :----: | ---- |
| -i  | 交互式删除, 需要删除是 让用户确认 |
| -I | 忽略命令名称大小写 |

```bash
## 杀掉我们当前的 bash 进程.
[root@localhost ~]# echo $$
36638
[root@localhost ~]# killall -i -9 bash
Signal bash(3248) ? (y/N) n
Signal bash(36638) ? (y/N) y
```

## 进程的执行顺序
我们通过 top 命令可以发现系统中有很多的进程, 但是绝大部分进程都是在 sleeping 状态, 那么如果所有的进程同时工作, 那么哪个进程执行的优先级比较高呢? 这就涉及到程序的优先级(Priority, PRI)与CPU调度. Linux 给予进程一个所谓的优先级概念, 这个 PRI 的值越低代表越能被优先执行的意思, 不过这个 PRI 的值是由内核来动态调整的, 我们无法直接操作. 如果我们想要调整进程的优先级, 那么可以使用 Nice 的值, 也就是 NI, 它们的关系粗略如下所示:
> PRI(new) = PRI(old) + NI

```bash
## 比如 ps -l 命令的 PRI 以及 top 命令中的 PR
[root@localhost ~]# ps -l
F S   UID    PID   PPID  C PRI  NI ADDR SZ WCHAN  TTY          TIME CMD
4 S     0   6373   6369  0  80   0 - 27124 do_wai pts/0    00:00:00 bash
4 R     0  15042   6373  0  80   0 - 27038 -      pts/0    00:00:00 ps
```

NI 的值只能影响到 PRI 的值, 但是不能决定 PRI 的值, 比如 PRI(old) 为 50, NI 的值为5, 那么PRI(new) 的值可能就不是 55, 因为 **PRI 的值是系统动态决定的, 所以最终的 PRI 仍要经过系统分析后才能决定 PRI 的值.**
**Nice 的值有正有负**并且有如下注意事项 :
> 1. Nice 的值为 -20 - 19
> 2. root 用户可以随意调整他人或者自己进程的 Nice 值 范围为  -20 - 19
> 3. 一般用户只能调整自己进程的 Nice值,范围为 0 -19, 且只能将 Nice 的值调高(比如现在为5, 那么只能调整 > 5) 

## nice命令
给新执行的命令设置一个 Nice 值
> nice [ -n NICE_VALUE ] COMMAND

```bash
## & 的意思是把程序放到后台中执行
[root@localhost ~]# nice -n -5 vi &
[1] 15142   <== job number 以及 PID , 稍后讲解
[root@localhost ~]# ps -l
F S   UID    PID   PPID  C PRI  NI ADDR SZ WCHAN  TTY          TIME CMD
4 S     0   6373   6369  0  80   0 - 27124 do_wai pts/0    00:00:00 bash
4 T     0  15142   6373  0  75  -5 - 28096 do_sig pts/0    00:00:00 vi   <== 我们可以发现 ni 的值为 -5
4 R     0  15146   6373  0  80   0 - 27038 -      pts/0    00:00:00 ps
```

## renice命令
给 已经存在的 PID 设置新的 Nice 值
> renice [ NICE_VALUE ] PID

```bash
[root@localhost ~]# ps -l
F S   UID    PID   PPID  C PRI  NI ADDR SZ WCHAN  TTY          TIME CMD
4 S     0   6373   6369  0  80   0 - 27124 do_wai pts/0    00:00:00 bash
4 T     0  15142   6373  0  75  -5 - 28096 do_sig pts/0    00:00:00 vi   <== 我们调整这个 Nice 值
4 R     0  15152   6373  0  80   0 - 27038 -      pts/0    00:00:00 ps

## 讲 PID 为 15142 的 Nice 值设置为 10
[root@localhost ~]# renice 10 15142
15142: old priority -5, new priority 10
[root@localhost ~]# ps -l
F S   UID    PID   PPID  C PRI  NI ADDR SZ WCHAN  TTY          TIME CMD
4 S     0   6373   6369  0  80   0 - 27124 do_wai pts/0    00:00:00 bash
4 T     0  15142   6373  0  90  10 - 28096 do_sig pts/0    00:00:00 vi  <== Nice 的值已经改变
4 R     0  15158   6373  0  80   0 - 27037 -      pts/0    00:00:00 ps
```

# 工作控制
Linux 是一个多用户 多任务的操作系统, 主要体现在以下方面:
> 1. 多用户 : 每个用户都可以根据自己的喜好来设置自己的工作环境
> 2. 多任务 : 在同一个 bash 环境中, 可以同时执行多个任务

假设我们只有一个终端, 因此可以出现提示符让你操作的环境称为前台(foreground), 其他的工作可以让你放到后台(background) 去暂停或运行, 放到后台的工作想要运行, 它必须不能和用户交互, 比如 vim 就不能放到后台去工作, 并且放到后台的工作不能通过 ctrl + c 来终止的.
> 1. 前台(foreground) : 你可以控制与执行命令的环境称为前台(foreground)的工作
> 2. 后台(background) : 可以自己运行的工作,无法通过 ctrl + c 终止它, 可以使用 bg/fg 调用该工作.
> 3. 后台中执行的进程不能等待 终端/shell 的输入工作.
> 4. 在后台里面的工作状态可以分为  **'暂停(stop)'**  和  **'运行中(running)'**.

## & : 把操作丢到后台中执行
假设我们只有一个 bash 环境, 如果想要同时进行多个工作, 那么可以将某些工作丢到后台环境中去, 让我们可以继续操作前台的工作. 那么我们就可以使用 ` & ` 来操作.
```bash
## 尝试着把一个工作丢到后台中去执行.使用 & 
[root@localhost ~]# tar -czpPf etc.tar.gz /etc &
job number  PID 
[1]         33118

## 然后继续执行我们其他的操作, 过一会就会出现下面这行, 表示这个 [1] 工作已经完成, 命令则是后边的一串字符.
[1]+  Done                    tar -czpPf etc.tar.gz /etc

## 查看一下, 把工作丢到后台中的好处就是不怕被 Ctrl+c 中断并且我们还可以继续做我们的工作,不必等待.
[root@localhost ~]# ll
total 10724
-rw-r--r--. 1 root root 10979432 Mar 10 19:36 etc.tar.gz

## 虽然是在后台运行, 但是如果有 stdout 以及 stderr 仍然会在屏幕上输出出来. 这个时候就需要我们数据流重定向来操作了.
[root@localhost ~]# tar -czPvf etc.tar.gz /etc
/etc/
/etc/autofs_ldap_auth.conf
/etc/autofs.conf
/etc/sysctl.conf
/etc/ipa/
/etc/dnsmasq.d/
/etc/latrace.d/
.....
[root@localhost ~]# tar -czPvf etc.tar.gz /etc &> etc.log.txt &
[1] 33158

## 这样就可以保证我们的屏幕比较整洁,不会有东西出来干扰我们正常的工作
[root@localhost ~]# 
[1]+  Done                    tar -czPvf etc.tar.gz /etc &>etc.log.txt
```

## ctrl+z : 将目前的工作丢到后台中暂停
比如我们现在正在编写一个脚本, 但是突然有一个很紧急的任务需要我们来处理一下, 难道我们只有先退出vim, 然后处理完成后在重新打开吗? 其实我们还有其他的处理方式. 只要把 vim 丢到后台中等待我们处理完成在让其返回前台即可.
```bash
## 比如我们在编写 get_user 这个脚本
[root@localhost ~]# vim get_user.sh
.....
.....
.....

## 此时我们需要返回到命令模式, 然后按 ctrl + z, 显示如下, 我们就可以处理我们的任务.
1 : 表示这是第一个工作
+ : 最近一个被丢进后台的工作, 如果我们使用 fg 命令会直接调用该工作.
[1]+  Stopped                 vim get_user.sh
[root@localhost ~]# 

## 比如我们执行以下命令, 然后在按下 ctrl + z
[root@localhost ~]# find / -print 
/
/.dbus
/.dbus/session-bus
/.dbus/session-bus/620dceee6da622dd1f8068670000000a-9
/lib64
如果使用 fg 命令, 会被优先调用, 因此 + 表示最近一次
[2]+  Stopped                 find / -print    <== 已经被暂停
```

## jobs命令
查看目前后台工作的状态
> jobs [ options ]

| 选项 | 作用 |
| :----: | ----- |
| -l(小写 L) | 列出 job number 以及 PID |
| -r | 仅列出在后台 run 的工作 |
| -s | 仅列出在后台暂停(stop)的工作 |

```bash
[root@localhost ~]# jobs -l
job number    PID   状态                    命令
[1]-          33286 Stopped                 vim get_user.sh
[2]+          33301 Stopped                 find / -print
[root@localhost ~]# jobs -r
[root@localhost ~]# jobs -s
[1]-  Stopped                 vim get_user.sh
[2]+  Stopped                 find / -print

## + 代表默认取用的工作, 现在我有两个任务在后台中暂停的, 那么我使用 fg 命令不加 job number, 默认调用 + 的这个
## + : 最后一个被放到后台的, 是动态变化的, 永远指的是最后一个
## - : 倒数第二个被放进后台的, 也是动态变化的. 超过三个就不会有 +/- 了 
```

## fg命令
**把后台的工作拿到前台来处理**. 我们之前紧急的任务已经处理完成了, 需要我们继续我们之前放到后台中的工作, 就需要使用到这个命令.
> fg [job_number]

```bash
[root@localhost ~]# jobs 
[1]-  Stopped                 vim get_user.sh
[2]+  Stopped                 find / -print

## 然后我们直接输入 fg 命令查看一下, 会默认调用 + 的那个工作 也就是 find / -print
## 然后我们在按 ctrl + z 让其进入后台暂停
[root@localhost ~]# fg
.......

## 进入我们的 job number 为 1 的工作, 也就是 vim get_user.sh
[root@localhost ~]# fg 1
.......

## 在ctrl + z 暂停, 查看 jobs, 发现我们打开的脚本后为 + 了, 所以 + 是动态表示的, 永远是最后一个被丢到后台中的
## 如果使用 fg 不加 job number, 那么就会调用脚本那行命令了
[root@localhost ~]# jobs
[1]+  Stopped                 vim get_user.sh
[2]-  Stopped                 find / -print
```

## bg命令
我们之前使用 ctrl + z 命令, 是把工作丢到后台中暂停(Stopped), 那么如果我想让工作在后台中变成运行状态, 那么该如何处理呢? 我们就可以使用 bg 命令
> bg job_number

```bash
## 输入以下命令, 立即按 ctrl + z 让其暂停
[root@localhost ~]# find / -print > test.txt

[root@localhost ~]# jobs
[1]   Stopped                 vim get_user.sh
[2]-  Stopped                 find / -print
[3]+  Stopped                 find / -print > test.txt

## 使用 bg 命令 
[root@localhost ~]# bg 3 ; jobs
[3]+ find / -print > test.txt &
[1]-  Stopped                 vim get_user.sh
[2]+  Stopped                 find / -print
[3]   Running                 find / -print > test.txt &   <== 状态为 Running,并且命令后多了 & 

## 过段时间在查看, job number 的工作已经完成了.
[root@localhost ~]# jobs
[1]-  Stopped                 vim get_user.sh
[2]+  Stopped                 find / -print
[3]   Done                    find / -print > test.txt
```

# nohup命令 : 脱机管理
我们之前工作管理中所说的后台是在终端下和终端相关, 可避免被 ctrl + c 中断, 而不是放到系统的后台, 所以工作管理的后台依旧和终端有关. 当出现意外时, 比如突然断电导致和服务器之间的连接中断, 那么之前所有的工作都不会继续进行, 而是被中断. 这个时候我们就需要用到 nohup 命令来处理了. **可以让你在脱机或者退出登录后, 让工作继续运行. 但是 nohup 不支持 bash 内置的命令, 所以命令必须是外部命令才可以.**
> nohub COMMAND   : 在终端机前台工作
>
> nohub COMMAND & : 在终端机后台工作

```bash
[root@localhost ~]# vim sleep.sh 
#!/bin/bash
/bin/sleep 500
[root@localhost ~]# chmod +x ./sleep.sh
[root@localhost ~]# nohup ./sleep.sh  &
[root@localhost ~]# exit

## 重新登录之后, 发现还能够继续运行, 和终端无关
[root@localhost ~]# ps aux | grep sleep.sh
root      35672  0.0  0.1 106120  1156 ?        S    10:17   0:00 /bin/bash ./sleep.sh
root      35707  0.0  0.0 103332   856 pts/0    S+   10:18   0:00 grep sleep.sh
```

# 其他常用命令
## uname命令
打印系统的信息

| 选项 | 作用 |
| :----: | ----- |
| -a | 打印下面的所有数据 |
| -s | 显示内核名称 |
| -n | 显示主机名 |
| -r | 显示内核版本 |
| -v | 显示内核信息 |
| -m | 显示硬件名称 |
| -p | CPU 类型 |
| -i | 硬件平台 |
| -o | 显示操作系统名称 |

```bash
[root@localhost ~]# uname -a
Linux localhost.localdomain 2.6.32-696.el6.x86_64 #1 SMP Tue Mar 21 19:29:05 UTC 2017 x86_64 x86_64 x86_64 GNU/Linux
[root@localhost ~]# uname -s
Linux
[root@localhost ~]# uname -n
localhost.localdomain
[root@localhost ~]# uname -r
2.6.32-696.el6.x86_64
[root@localhost ~]# uname -v
#1 SMP Tue Mar 21 19:29:05 UTC 2017
[root@localhost ~]# uname -m
x86_64
[root@localhost ~]# uname -p
x86_64
[root@localhost ~]# uname -o
GNU/Linux
```

## dmesg命令
分析内核产生的信息, 所有内核检测的信息都会被保存在内存中的某个保护区段, dmesg 命令可以读取该区段的信息, dmesg 命令显示的信息太多, 所以我们可以通过管道来一屏一屏的显示
```bash
[root@localhost ~]# dmesg | more
Initializing cgroup subsys cpuset
Initializing cgroup subsys cpu
Linux version 2.6.32-696.el6.x86_64 (mockbuild@c1bm.rdu2.centos.org) (gcc version 4.4.7 20120
313 (Red Hat 4.4.7-18) (GCC) ) #1 SMP Tue Mar 21 19:29:05 UTC 2017
Command line: ro root=UUID=64af9fff-884d-4cf2-afe6-ba3f7869cf35 rd_NO_LUKS rd_NO_LVM LANG=en_
US.UTF-8 rd_NO_MD SYSFONT=latarcyrheb-sun16 crashkernel=auto  KEYBOARDTYPE=pc KEYTABLE=us rd_
NO_DM rhgb quiet
KERNEL supported cpus:
  Intel GenuineIntel
  AMD AuthenticAMD
  Centaur CentaurHauls
Disabled fast string operations
BIOS-provided physical RAM map:
....

## 比如我们想查看我们的网卡, 网卡为 eth 
[root@localhost ~]# dmesg | grep eth
e1000 0000:02:01.0: eth0: (PCI:66MHz:32-bit) 00:0c:29:27:50:34
e1000 0000:02:01.0: eth0: Intel(R) PRO/1000 Network Connection
e1000: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: None
8021q: adding VLAN 0 to HW filter on device eth0
eth0: no IPv6 routers present
```

## vmstat命令
vmstat可以检测 CPU/内存/磁盘输入输出状态 等, 可以检测系统资源的变化.
> vmstat [-a] [-n] [-t] [-S unit] [delay [ count]]
> 
> vmstat [-s] [-n] [-S unit]
> 
> vmstat [-m] [-n] [delay [ count]]
> 
> vmstat [-d] [-n] [delay [ count]]
> 
> vmstat [-p disk_partition] [-n] [delay [ count]]
> 
> vmstat [-f]

| 选项 | 作用 |
| :----: | ----- |
| -a | 显示活跃和非活跃内存 |
| -f | 显示从系统启动至今的fork数量 |
| -s | 将一些事件(开机到目前为止)导致内存变化情况显示出来 |
| -S Unit | 以指定的单位显示数据, 默认显示为 bytes |
| -d | 显示磁盘统计信息 |
| -p disk_partition | 后面跟上分区, 可以显示该分区的读写总量统计表 |
| -n | 在开始时显示一次各字段名称 |
| delay | 刷新时间间隔。如果不指定，只显示一条结果。 |
| count | 刷新次数。如果不指定刷新次数，但指定了刷新时间间隔，这时刷新次数为无穷, 直到按下 ctrl + c 键 |

```bash
[root@localhost ~]# vmstat 1 3
procs -----------memory----------   --swap--   ---io----  -system-  -----cpu-----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs   us sy id wa st
 1  0      0 470868  79988 257420    0    0     1     1    9    9   0  0 100  0  0	
 0  0      0 470820  79988 257420    0    0     0     0   15   18   0  0 100  0  0	
 0  0      0 470820  79988 257420    0    0     0     0   11   12   0  0 100  0  0	

procs中选项的含义(进程字段) :
	r : 等待运行中的进程数量
	b : 不可被唤醒的进行数量
memory中选项的含义(内存字段) :
	swpd  : 虚拟内存被使用的容量
	free  : 未被使用的内存容量
	buff  : 用于缓存的存储器
	cache : 用于高速缓存
swap中选项的含义(交换分区) :
	si : 由磁盘中将程序取出的量
	so : 由于内存不足而将没用到的程序写入到磁盘的swap容量
io中选项的含义(IO) : 
	bi : 由磁盘写入的块数量
	bo : 写入到磁盘去的块数量
system中选项的含义 :
	in : 每秒被中断的进程次数
	cs : 每秒钟进行的事件切换次数
cpu中选项的含义 :
	us : 非内核层的cpu使用状态
	sy : 内核层所使用的cpu状态
	id : 闲置的状态
	wa : 等待 I/O 所耗费的 CPU状态
	st : 被虚拟机所盗用的 CPU 使用状态

## 查看系统上所有磁盘的读写状态
[root@localhost ~]# vmstat -d
disk- ------------reads------------ ------------writes----------- -----IO------
       total merged sectors      ms  total merged sectors      ms    cur    sec
ram0       0      0       0       0      0      0       0       0      0      0
ram1       0      0       0       0      0      0       0       0      0      0
ram2       0      0       0       0      0      0       0       0      0      0
ram3       0      0       0       0      0      0       0       0      0      0
ram4       0      0       0       0      0      0       0       0      0      0
ram5       0      0       0       0      0      0       0       0      0      0
ram6       0      0       0       0      0      0       0       0      0      0
ram7       0      0       0       0      0      0       0       0      0      0
ram8       0      0       0       0      0      0       0       0      0      0
ram9       0      0       0       0      0      0       0       0      0      0
ram10      0      0       0       0      0      0       0       0      0      0
ram11      0      0       0       0      0      0       0       0      0      0
ram12      0      0       0       0      0      0       0       0      0      0
ram13      0      0       0       0      0      0       0       0      0      0
ram14      0      0       0       0      0      0       0       0      0      0
ram15      0      0       0       0      0      0       0       0      0      0
loop0      0      0       0       0      0      0       0       0      0      0
loop1      0      0       0       0      0      0       0       0      0      0
loop2      0      0       0       0      0      0       0       0      0      0
loop3      0      0       0       0      0      0       0       0      0      0
loop4      0      0       0       0      0      0       0       0      0      0
loop5      0      0       0       0      0      0       0       0      0      0
loop6      0      0       0       0      0      0       0       0      0      0
loop7      0      0       0       0      0      0       0       0      0      0
sda    18769   6381  613800   13220  85067  51889 1095642  214632      0    170
sr0       45      0     360      16      0      0       0       0      0      0
dm-0     240      0    1914     134      3      0      24       2      0      0
```

## fuser命令
通过文件(或文件系统)找出正在使用该文件的程序. 比如我们想要卸载一个设备时, 恰巧有一个用户在该设备的目录中, 如果卸载就会出现 'device is busy', 这个时候我们就可以使用 fuser 命令来跟踪操作.
> fuser [-a|-s|-c] [-n  space ] [-k [-i] [-signal ] ] [-muvf] name ...
>  
> fuser -l

| 选项 | 作用 |
| :----: | ---- |
| -u | 显示进程的所有者 |
| -m name |  指定一个挂载文件系统上的文件或者被挂载的块设备。所有访问这个文件或者文件系统的进程都会被列出来。如果指定的是一个目录会自动转换成 ` name/ `,并列出所有挂载在那个目录下面的文件系统 | 
| -v | 详细模式, 输出每个文件与程序还有命令的相关性 |
| -k | 杀掉访问文件的进程。如果没有指定-signal就会发送SIGKILL信号 |
| -i | 杀掉进程之前询问用户，如果没有-k这个选项会被忽略 |
| -signal |  使用指定的信号，而不是用SIGKILL来杀掉进程。可以通过名称或者号码来表示信号(例如-HUP,-1),这个选项要和-k一起使用，否则会被忽略。|
| -l | 列出所有已知的信号名称。|

```bash
## 列出所有的已知信号名称
[root@localhost ~]# fuser -l
HUP INT QUIT ILL TRAP ABRT IOT BUS FPE KILL USR1 SEGV USR2 PIPE ALRM TERM
STKFLT CHLD CONT STOP TSTP TTIN TTOU URG XCPU XFSZ VTALRM PROF WINCH IO PWR SYS
UNUSED

## 找出当前目录所使用的 PID 账号 以及权限
[root@localhost ~]# fuser -uv .
                     USER        PID ACCESS COMMAND
.:                   root      25154 ..c.. (root)bash

## 然后我们来讲解一下  ACCESS 选项中的含义 
c : 此进程在当前的目录下(非子目录)
e : 可被触发为执行状态
f : 是一个被打开的文件
r : 代表顶层目录(root directory)
F : 代表文件被打开, 正在等待响应中
m : 可能为分享的动态函数库

```







# 特殊文件 /proc/* 
我们之前说过所有的进程都是在内存中的, 而内存当中的数据又都会写入到 /proc/* 这个目录下, 所有我们可以直接来查看 /proc 这个目录当中的文件.
```bash
## 主机上的所有进程的 PID 都是以目录的类型存在于 /proc 当中
[root@localhost ~]# ll /proc | less
total 0
dr-xr-xr-x.  8 root      root         0 Mar 12 00:26 1    <== 1 表示 PID, 为 init 进程, 那么我们查看一下内容
dr-xr-xr-x.  8 root      root         0 Mar 12 00:26 10
dr-xr-xr-x.  8 root      root         0 Mar 11 16:26 1090
dr-xr-xr-x.  8 root      root         0 Mar 12 00:26 11
dr-xr-xr-x.  8 root      root         0 Mar 12 00:26 114
dr-xr-xr-x.  8 root      root         0 Mar 11 16:26 1148
dr-xr-xr-x.  8 root      root         0 Mar 11 16:26 1149
dr-xr-xr-x.  8 root      root         0 Mar 11 16:26 1150
.......

## 查看 PID 为 1 的相关信息
[root@localhost ~]# ll /proc/1 | less
total 0
dr-xr-xr-x. 2 root root 0 Mar 18 16:40 attr
-rw-r--r--. 1 root root 0 Mar 18 16:40 autogroup
-r--------. 1 root root 0 Mar 18 16:40 auxv
-r--r--r--. 1 root root 0 Mar 18 16:40 cgroup
--w-------. 1 root root 0 Mar 18 16:40 clear_refs
-r--r--r--. 1 root root 0 Mar 12 00:26 cmdline            <== 命令串
-rw-r--r--. 1 root root 0 Mar 18 16:40 comm
-rw-r--r--. 1 root root 0 Mar 18 16:40 coredump_filter
-r--r--r--. 1 root root 0 Mar 18 16:40 cpuset
lrwxrwxrwx. 1 root root 0 Mar 18 16:40 cwd -> /
-r--------. 1 root root 0 Mar 18 16:40 environ            <== 一些环境变量
lrwxrwxrwx. 1 root root 0 Mar 12 00:26 exe -> /sbin/init
dr-x------. 2 root root 0 Mar 11 16:26 fd
.......
```

| 文件名 | 作用 |
| ------ | ----- |
| /proc/cmdline | 加载 kernel 时所执行的相关参数 |
| /proc/cpuinfo | 本机的 cpu 的相关信息, 如频率 类型 与 运算功能 |
| /proc/devices | 记录了系统各个主要设备的主要设备代号 |
| /proc/filesystems | 目前系统已经加载的文件系统 |
| /proc/meminfo | 内存相关信息 |
| /proc/modules | 已经加载的模块列表 |
| /proc/mounts | 系统已经挂载的数据 |
| /proc/partitions | 显示分区列表, 类似 fdisk -l 命令, 显示内容有所不同 |

# 