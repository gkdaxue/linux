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

## 看一下有没有使用 /proc 这个目录的进程, 结果发现没有
[root@localhost ~]# fuser -uv /proc/
## 然后在查看一下使用到 /proc 目录下文件的进程
[root@localhost ~]# fuser -mvu /proc
                     USER        PID ACCESS COMMAND
/proc:               root       1582 f.... (root)rsyslogd
                     root       1779 f.... (root)acpid
                     haldaemon   1796 f.... (haldaemon)hald
```

## lsof命令
fuser 是由 文件/设备 去找到使用使用该 文件/设备 的进程, lsof 则是找到某个进程所 打开/使用 的文件/设备.
> lsof [ options ]

| 选项 | 作用 |
| :----: | ------ |
| -a | 需要满足多个条件才显示出结果 |
| -u User_Name | 列出 User_Name 用户相关进程打开的文件 |
| +d Dir_Name | 找出某个目录下已经被打开的文件 |

```bash
## 列出当前系统上所有已经被打开的文件与设备
[root@localhost ~]# lsof | less
COMMAND     PID      USER   FD      TYPE             DEVICE SIZE/OFF       NODE NAME
init          1      root  cwd       DIR                8,5     4096          2 /
init          1      root  rtd       DIR                8,5     4096          2 /
init          1      root  txt       REG                8,5   150352        450 /sbin/init
init          1      root  mem       REG                8,5    66432        139 /lib64/libnss_files-2.12.so
init          1      root  mem       REG                8,5  1930416       7269 /lib64/libc-2.12.so
.....

## 仅列出 root 用户所打开的文件和设备
[root@localhost ~]# lsof -u root | less
COMMAND     PID USER   FD      TYPE             DEVICE SIZE/OFF       NODE NAME
init          1 root  cwd       DIR                8,5     4096          2 /
init          1 root  rtd       DIR                8,5     4096          2 /
init          1 root  txt       REG                8,5   150352        450 /sbin/init
init          1 root  mem       REG                8,5    66432        139 /lib64/libnss_files-2.12.so
init          1 root  mem       REG                8,5  1930416       7269 /lib64/libc-2.12.so
init          1 root  mem       REG                8,5    93320       2041 /lib64/libgcc_s-4.4.7-20120601.so.1
init          1 root  mem       REG                8,5    47760       7272 /lib64/librt-2.12.so
.....

## 列出 /dev 目录下打开的文件和设备
[root@localhost ~]# lsof +d /dev
COMMAND     PID      USER   FD   TYPE             DEVICE SIZE/OFF  NODE NAME
init          1      root    0u   CHR                1,3      0t0  4601 /dev/null
init          1      root    1u   CHR                1,3      0t0  4601 /dev/null
init          1      root    2u   CHR                1,3      0t0  4601 /dev/null
udevd       575      root    0u   CHR                1,3      0t0  4601 /dev/null
udevd       575      root    1u   CHR                1,3      0t0  4601 /dev/null
.......
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

# 计划任务服务程序
计划任务分为一次性任务以及长期性任务, 比如 :
> 一次性任务 : 今天 23:59 网站维护半小时(临时的工作需求)
>
> 长期性任务 : 每天备份数据库文件(每天例行性的工作)

## at命令(一次性任务)
一次性任务只执行一次, 一般用于满足临时的工作需求, 所以我们可以使用 ` at命令 ` 来实现这种功能. (要执行 at 时, 必须有 atd 这个服务的支持才行, 所以需要检查是否安装了此软件以及服务是否启动). at命令 来生成要运行的工作, 然后将这个工作以文本文件的方式写入到 **/var/spool/at 目录中**, 然后等待 atd 服务的调用和执行即可.  **并不是所有的人都可以使用 at 命令**, 我们可以利用 **/etc/at.allow** 和 **/etc/at.deny** 两个文件来进行限制. at 工作情况如下:
> 1. 先寻找 /etc/at.allow 文件, 如果找到, 则只有这个文件中存在的用户才可以使用 at 命令.
> 2. 如果 /etc/at.allow 文件不存在, 则寻找 /etc/at.deny 文件, 这个文件存在的用户不能使用 at 命令, 不在这个文件中的用户则可以使用.
> 3. 如果这两个文件都不存在, 那就只有 root 用户可以使用这个命令了

命令格式
> at [ options ] TIME
>
> at -c 工作号码

| 选项 | 作用 |
| :---: | --- |
| -m | 当 at 的工作完成后, 即使没有输出信息, 也要发 mail 通知用户该工作已完成 |
| -l | 相当于 atq, 列出目前系统上所有用户的任务 |
| -d | 相当于 atrm, 删除一个任务 |
| -v | 使用指定的日期时间格式显示任务列表 |
| -c 工作号码 | 列出该工作号码的内容 |


```bash
TIME : 时间可以有以下几种格式
	HH:MM : 指定时间执行 (在今天的 HH:MM 时刻执行, 如果已超过该时刻, 则明天该时刻执行)
	HH:MM YYYY-MM-DD : 指定日期时间执行
	HH:MM[am|pm] + Num {minutes|hours|days|weeks} : 以当前时间为基准, 多长时间后执行
```

### 实例
```bash
## 查看是否安装服务以及服务是否启动, 以后讲解
[root@localhost ~]# rpm -qa | grep at-3.1.10
at-3.1.10-49.el6.x86_64

## 查询服务已经正确的启动
[root@localhost ~]# service atd status
atd (pid  2098) is running...   <== 表示该服务已经启动

## 重启 atd 服务, 也可以使用 /etc/init.d/atd restart
[root@localhost ~]# service atd restart 
Stopping atd:                                              [  OK  ]
Starting atd:                                              [  OK  ]

## 10分钟之后输出 :hello
[root@localhost ~]# at now + 10 minutes
at> echo :hello
at> <EOT>   <== 这是跳转到下一行, 然后按 ctrl + d 出来的 <EOT> 非手动输入
job 3 at 2019-03-25 19:20     <== 第 3 个任务在 2019-03-25 19:20 执行

## 查看计划列表
[root@localhost ~]# at -l
3	2019-03-25 19:20 a root
[root@localhost ~]# ll /var/spool/at/a00003018b1428 
-rwx------. 1 root root 2829 Mar 25 19:10 /var/spool/at/a00003018b1428

## 查看计划的内容 ( 和我们直接查看文件内容一致 )
[root@localhost ~]# at -c 3  
#!/bin/sh
# atrun uid=0 gid=0
# mail root 0
umask 22
HOSTNAME=localhost.localdomain; export HOSTNAME
SELINUX_ROLE_REQUESTED=; export SELINUX_ROLE_REQUESTED
SHELL=/bin/bash; export SHELL
HISTSIZE=1000; export HISTSIZE
SSH_CLIENT=192.168.1.11\ 13143\ 22; export SSH_CLIENT
SELINUX_USE_CURRENT_RANGE=; export SELINUX_USE_CURRENT_RANGE
QTDIR=/usr/lib64/qt-3.3; export QTDIR
QTINC=/usr/lib64/qt-3.3/include; export QTINC
SSH_TTY=/dev/pts/1; export SSH_TTY
USER=root; export USER
MAIL=/var/spool/mail/root; export MAIL
PATH=/usr/lib64/qt-3.3/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin; export PATH
PWD=/root; export PWD
LANG=en_US.UTF-8; export LANG
SELINUX_LEVEL_REQUESTED=; export SELINUX_LEVEL_REQUESTED
SSH_ASKPASS=/usr/libexec/openssh/gnome-ssh-askpass; export SSH_ASKPASS
HISTCONTROL=ignoredups; export HISTCONTROL
SHLVL=1; export SHLVL
HOME=/root; export HOME
LOGNAME=root; export LOGNAME
QTLIB=/usr/lib64/qt-3.3/lib; export QTLIB
CVS_RSH=ssh; export CVS_RSH
SSH_CONNECTION=192.168.1.11\ 13143\ 192.168.1.206\ 22; export SSH_CONNECTION
LESSOPEN=\|\|/usr/bin/lesspipe.sh\ %s; export LESSOPEN
G_BROKEN_FILENAMES=1; export G_BROKEN_FILENAMES
cd /root || {
	 echo 'Execution directory inaccessible' >&2
	 exit 1
}
${SHELL:-/bin/sh} << 'marcinDELIMITER3c8750f7'
echo :hello    <== 命令的实际内容

marcinDELIMITER3c8750f7


## 如果我们使用 at 来执行计划任务, 那么命令最好使用绝对路径的形式. 防止因为 PATH 变量有问题导致的问题.
## 然后我们等待了 10 分钟之后, 发现并没有输出 :hello, 这是为啥呢?
因为 at 的执行和终端机无关是被放到后台中执行的, 所以 标准输出/标准错误输出 信息都会被传送到执行这的 mailbox 中去了
如果我们想要显示在当前终端显示一下, 应该怎么操作呢? 先查看一下当前的终端信息
[root@localhost ~]# tty
/dev/pts/1
[root@localhost ~]# at now +1 minutes
at> echo "hello" > /dev/pts/1
at> <EOT>
job 7 at 2019-03-25 19:25

## 过一分钟就有如下显示
[root@localhost ~]# hello
^C

如果 at 执行的任务没有任何的信息输出, 那么 at 默认不会发邮件给执行这, 如果一定要发送邮件给执行者, 可以使用 at -m TIME 来操作.
```

## batch命令
at 命令是在你指定的时间, 无论系统状态怎么样都会执行. 但是如果我们想的是系统比较空闲的时候才执行, 那么我们就可以使用 batch命令, batch 命令也是利用 at 命令来执行的, 只不过加入了一些控制的参数而已. (当 cpu 的工作负载小于0.8 时, 才会执行工作任务), 其他的内容和 at 命令一致.

## crontab命令(长期性任务)
**crontab 使用 crond 这个系统服务来控制的**. 它的安全性和 at 类似, 也有两个文件 **/ect/cron.allow** 和 **/etc/cron.deny** 系统默认保留 /etc/cron.deny 文件, 只要将不想执行 crontab 的用户写入到此文件中即可. 当用户使用 crontab 命令来创建任务时, 会在 **/var/spool/cron/USER_NAME**  文件中被记录. (建议不要通过vim直接编辑该文件, 防止由于语法错误, 导致无法执行 cron)
> crontab [ -u USER_NAME ] [ -l | -e | -r ]

| 选项 | 作用 |
| :----: | ---- |
| -u USER_NAME | 可以帮助其他用户 新建/删除 crontab 任务(仅root可用) |
| -e | 编辑任务 |
| -l | 查看任务 |
| -r | 删除所有的任务, 如果只是想删除某条任务, 请使用 -e 参数来编辑删除 |

**crond服务设置任务的参数格式 : “分、时、日、月、星期 命令”**

| 含义 | 分 | 时 | 日 | 月 | 星期 | 命令 |
| :---: | ----- | ---- | --- | ---- | ---- | ---- |
| 范围 | 0-59 | 0-23 | 1-31 | 1-12 | 0-7 (0和7都表示星期天) | 命令或脚本(最好使用绝对路径) |

**“日”和“星期”字段不能同时使用，否则就会发生冲突**
```bash
比如你想要每年的 5月21号星期六执行一个任务, 那么系统可能会判断为 5月21 或 星期六 执行任务. 所以注意.
```

**可以使用的特殊字符:  **

| 特殊字符 | 含义 |
| :---: | ----- |
| * (星号) | 有些字段无需设置, 则使用 * 来替代, 表示任何时刻都可以 |
| , (逗号) | 间隔时段的意思, 比如月使用 8,9,12 则表示 8月 9月 和 12月 |
| - (减号) | 一段范围, 比如时用8-12, 则表示 8点到12点 | 
| /Num (斜线) | Num 表示数字, 每隔 Num 的意思, 比如分钟为 */5 表示每隔 5 分钟 | 

```bash
## 输入以下命令, 会进入 vim 编辑界面来编辑 crontab, 编辑完成后, 保存退出
## 每隔 1 分钟输出一个 hello gkdaxue
[root@localhost ~]# crontab -e
*/1 * * * * /bin/echo 'Hello world'

## 查看内容
[root@localhost ~]# crontab -l
*/1 * * * * /bin/echo 'hello gkdaxue'

## 查看 cron 文件
[root@localhost ~]# ll /var/spool/cron/root
-rw-------. 1 root root 38 Mar 26 09:36 /var/spool/cron/root
[root@localhost ~]# cat /var/spool/cron/root 
*/1 * * * * /bin/echo 'hello gkdaxue'

## 移除所有用户的任务. 如果想要删除某一条, 请使用 crontab -e
[root@localhost ~]# crontab -r

## 因为任务是在后台运行的, 所以也不会在终端上有输出的信息.

## 然后我们使用安全机制, 禁止 gkdaxue 用户创建计划任务, 一定要保证这个用户存在
[root@localhost ~]# vim /etc/cron.deny
gkdaxue
[root@localhost ~]# su - gkdaxue
[gkdaxue@localhost ~]$ crontab -e
You (gkdaxue) are not allowed to use this program (crontab)  <== 不允许
See crontab(1) for more information
[gkdaxue@localhost ~]$ exit
logout
```

### 系统的计划任务
我们上面所说的是针对用户来说的计划任务, 如果是我们系统计划任务, 那么我们应该怎么做呢, 我们只需要编辑 **/etc/crontab** 这个文件即可. **cron 服务最低的检测频率是分钟, 所以它会每分钟读取 /etc/crontab 以及 /var/spool/cron 里面的内容**. 然后我们来看一下 /etc/crontab 文件的内容
```bash
[root@localhost ~]# cat /etc/crontab 
SHELL=/bin/bash                       <== 使用的 shell
PATH=/sbin:/bin:/usr/sbin:/usr/bin    <== PATH 环境变量
MAILTO=root                           <== 发生错误时或有输出信息时, 发送邮件给什么用户
HOME=/                                <== 家目录

# For details see man 4 crontabs

# Example of job definition:
# .---------------- minute (0 - 59)
# |  .------------- hour (0 - 23)
# |  |  .---------- day of month (1 - 31)
# |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
# |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
# |  |  |  |  |
# *  *  *  *  * user-name command to be executed

## 相对于用户编辑来说, 我们发现仅仅只是多了一个 user-name 字段, 说明是以谁的身份运行.

[root@localhost ~]# find /etc -name cron.* -type d | xargs ls -ld
drwxr-xr-x. 2 root root 4096 Mar  3 11:38 /etc/cron.d
drwxr-xr-x. 2 root root 4096 Mar  3 11:39 /etc/cron.daily      <== 每天
drwxr-xr-x. 2 root root 4096 Mar  3 11:37 /etc/cron.hourly     <== 每小时
drwxr-xr-x. 2 root root 4096 Mar  3 11:39 /etc/cron.monthly    <== 每月1号
drwxr-xr-x. 2 root root 4096 Sep 27  2011 /etc/cron.weekly     <== 每周日

如果我们想要系统每小时帮我们执行一个任务, 那么我们就可以写成一个脚本, 放到 /etc/cron.hourly 目录下即可.
```

所以我们看出, /etc/crontab 文件支持两种执行命令的方式
> 1. 直接命令
> 2. 以目录来规划执行(将可执行文件都放到该目录下即可)

### anacron命令(可唤醒停机期间的计划任务)
比如我们公司有一台存储资料的共享服务器, 每到了节假日的时候为了数据安全, 我们就会把服务器关机, 在上班的时候在重新打开, 但是存在一个问题, 比如我设置了一个每天的备份计划, 那么我关机了之后, 我的计划任务怎么办? 这个时候就需要用到我们所说的 anacron 来操作了. 它会去监测我们停机期间应该进行但是没有进行的计划任务, 然后执行该计划, 执行完成后就该停止了. anacron 运行的时间通常有两个, 一个是系统开机期间运行, 另一个则是写入到 crontab 的任务中.
> anacron [ -sfn ] [ job ] ...
>  
> anacron -u [ job ]

| 选项 | 作用 |
| :---: | ----- |
| -s | 立即开始执行各项工作, 并根据时间记录文件判断是否进行 |
| -f | 强制进行 |
| -n | 立即开始进行, 而不延迟(delay)等待时间 |
| -u | 仅更新时间记录文件的时间戳, 不进行任何工作 |
| job | 由 /etc/anacrontab 定义的各项工作内容 |

```bash
## 查看一下存在的 anacron
[root@localhost ~]# ll /etc/cron.*/*ana*
-rwxr-xr-x. 1 root root 409 Aug 24  2016 /etc/cron.hourly/0anacron

## 查看一下文件内容
[root@localhost ~]# cat /etc/cron.hourly/0anacron 
#!/bin/bash
# Skip excecution unless the date has changed from the previous run 
if test -r /var/spool/anacron/cron.daily; then
    day=`cat /var/spool/anacron/cron.daily`
fi
if [ `date +%Y%m%d` = "$day" ]; then
    exit 0;
fi

# Skip excecution unless AC powered
if test -x /usr/bin/on_ac_power; then
    /usr/bin/on_ac_power &> /dev/null
    if test $? -eq 1; then
    exit 0
    fi
fi
/usr/sbin/anacron -s

## 查看一下 /etc/anacrontab 文件
[root@localhost ~]# cat /etc/anacrontab 
# /etc/anacrontab: configuration file for anacron

# See anacron(8) and anacrontab(5) for details.

SHELL=/bin/sh
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root
# the maximal random delay added to the base delay of the jobs
RANDOM_DELAY=45
# the jobs will be started during the following hours only
START_HOURS_RANGE=3-22

天数               延迟时间(分钟)      工作名称          实际要进行的命令
#period in days   delay in minutes   job-identifier   command
1	              5	                 cron.daily		  nice run-parts /etc/cron.daily
7	              25	             cron.weekly	  nice run-parts /etc/cron.weekly
@monthly          45	             cron.monthly	  nice run-parts /etc/cron.monthly

@monthly : 因为月份日期不固定, 可能是 28  29 30 31, 所以使用 @monthly 来替代

## 查看一下时间戳记录文件
[root@localhost ~]# more /var/spool/anacron/cron.*
::::::::::::::
/var/spool/anacron/cron.daily
::::::::::::::
20190326
::::::::::::::
/var/spool/anacron/cron.monthly
::::::::::::::
20190326
::::::::::::::
/var/spool/anacron/cron.weekly
::::::::::::::
20190326
```

**整体工作流程(每天为例)**
> 1. 读取 /etc/anacrontab 文件, 分析到 cron.daily 的天数为 1
> 2. 读取 /var/spool/anacron/cron.daily 最近执行的时间戳
> 3. 判断 当前时间和取得时间戳差异是否为 1天以上(包括一天), 准备开始工作
> 4. 延迟时间为 5 分钟, 所以 5 分钟后开始执行后边的命令, 执行完成后 anacron 结束.

# service(服务) 和 daemon(守护进程)
系统为了某些功能必须要提供一些服务, 这个服务我们称为 service(服务), 但是服务的运行需要进程(daemon)的运行, 所以实现服务的进程我们称之为 daemon(守护进程). 比如我们之前说的启动 apache 服务, 它的守护进程为 httpd.
**守护进程(daemon)**是一类在后台运行的特殊进程，用于执行特定的系统任务。很多守护进程在系统引导的时候启动，并且一直运行直到系统关闭, 而不像我们连接的 bash 进程, 断开连接后进程就被销毁了.

## daemon分类(启动方式)
### stand alone
这种类型的进程可以自行启动而不必通过其他机制的管理, 启动并加载到内存之后就一直占用内存与系统资源. 一直在内存内持续的提供服务, 所以对于客户端的请求响应速度较快. 常见的有 www(httpd), ftp(vsftpd) 等服务.

### super daemon
通过一个统一的 daemon 来负责唤醒服务, 这个特殊的 daemon 称为 super daemon, 当没有客户端的请求时, 各项服务都是未启动的状态, 接收到客户端的请求时 super daemon (xinetd) 才开始唤醒对应的服务(响应速度较慢, 需要先唤醒对应的服务), 当客户端的请求结束时, 被唤醒的服务将会被关闭并释放系统资源. super daemon 的处理模式有两种 :
> multi-threaded : 多线程模式
> 
> single-threaded : 单线程

### 总结
比如我们以我们在银行办理业务为例子来说明, 我们有两个窗口, 一个是单一取钱窗口, 一个是综合业务窗口, stand alone 负责单一取钱窗口, 只要你去了就可以直接去取钱, 不需要告诉工作人员你是来办理什么业务的.  而 super daemon 则是综合窗口, 比如有的是来办卡的 有的是来存钱的 等等, 所以需要先告诉工作人员你来办理什么业务, 然后工作人员在提供对应的服务, 所以响应速度较慢. 这是单线程模式, 如果有多个综合业务窗口, 则是多线程模式.

## daemon分类(工作状态)
### signal-control
这种 daemon 是通过信号来管理的, 只要有客户端的请求过来, 就会去立即处理. 比如 cupsd(打印机服务)

### interval-control
这种 daemon 则是每隔一段时间就主动去执行某项工作, 我们只要在对应配置文件中写入需要工作的内容和时间即可. 比如我们之前所说的 atd 和 crond 就是这种形式.

## daemon命名规范
服务被创建后, 通常会在服务的名称后边加上一个 d, 例如 at 和 cron 则是 atd 和 crond, d 表示的就是 daemon 的意思. 所以我们使用 ps 命令可以看出有好多以 d 结尾的进程, 这些都是 daemon.

## daemon脚本存放位置
提供某个服务的 daemon 虽然只是一个进程而已, 它的执行还是需要执行文件、配置文件、执行环境等配合完成, 因此启动一个 daemon 不仅仅只是单纯的执行一个进程就好了. 通常系统会提供一个脚本来进行环境的检测、配置文件的分析、PID文件的放置等工作, 我们只要执行这个脚本, 就可以顺利简单的启动这个 daemon. 这个脚本会放置在什么地方呢?

```bash
/etc/init.d/*                     : 每个服务的启动脚本
/etc/sysconfig/*                  : 每个服务的初始化环境配置文件
/etc/xinetd.conf, /etc/xinetd.d/* : super daemon 配置文件 
/etc/*                            : 每个服务的配置文件
/var/lib/*                        : 每个服务的数据库文件
/var/run/*                        : 每个服务的PID记录文件

## super daemon 默认配置主文件为 /etc/xinetd.conf 但是因为是一个综合的命令, 
## 所以它所管理的其他的 daemon 配置文件则写在 /etc/xinetd.d 目录下
```

## 服务和端口的关系
系统所有的功能都是某些程序所提供的, 而进程则是通过触发程序而产生的. 因此我们的系统是如何区分不同的服务请求呢? 事实上, 每个服务都会绑定对应的端口号, 这样就可以根据端口号以及协议来区分不同的服务, 比如 www 为 80端口 ftp 为 21 端口 ssh 为 22 端口等等, 我**们可以通过查看 /etc/services 来 修改/查看 服务对应的端口信息.(通常不建议修改端口)**
```bash
[root@localhost ~]# less /etc/services
.......
daemon          port/protocol   description
ftp             21/tcp
ftp             21/udp          fsp fspd
ssh             22/tcp                          # The Secure Shell (SSH) Protocol
ssh             22/udp                          # The Secure Shell (SSH) Protocol
...
http            80/tcp          www www-http    # WorldWideWeb HTTP
http            80/udp          www www-http    # HyperText Transfer Protocol
.....
```

## daemon启动方式
### stand alone启动方式
几乎系统上所有的服务都在 /etc/init.d 下面, 这里面的脚本回去检测环境、查找配置文件、加载函数、判断此环境是否可以运行此 daemon等等. 等一切都检测无误就可以运行此服务了. 比如我们以日志服务 /etc/init.d/rsyslog 启动脚本来讲解
> Centos5 使用 syslog, 启动脚本为 /etc/init.d/syslog
> 
> Centos6 使用 rsyslog 启动脚本为 /etc/init.d/rsyslong

```bash
## 没有选项, 然后会提示我们可以跟上哪些选项 
[root@localhost ~]# /etc/init.d/rsyslog 
Usage: /etc/init.d/rsyslog {start|stop|restart|condrestart|try-restart|reload|force-reload|status}

## 我们来查看一下状态
[root@localhost ~]# /etc/init.d/rsyslog status
rsyslogd (pid  6055) is running...

## 重启一下服务
[root@localhost ~]# /etc/init.d/rsyslog restart
Shutting down system logger:                               [  OK  ]
Starting system logger:                                    [  OK  ]
[root@localhost ~]# /etc/init.d/rsyslog status
rsyslogd (pid  6112) is running...     <== 发现 PID 改变了
```

### service命令启动
service 也是可以**启动 stand alone 服务**的一个脚本, service 仅仅只是一个脚本, 它会去分析脚本后边的参数, 然后根据参数到 /etc/init.d 下去取得正确的服务来操作. 语法如下
> service [ Service_Name ] {start|restart|stop|status|...} 
>
> service --status-all : 将系统所有的 stand alone 的服务状态全部列出来

```bash
## 重启 rsyslog 服务
[root@localhost ~]# service rsyslog restart
Shutting down system logger:                               [  OK  ]
Starting system logger:                                    [  OK  ]

## 查看状态 
[root@localhost ~]# service rsyslog status
rsyslogd (pid  6169) is running...

## 查看所有的 stand alone 的状态
[root@localhost ~]# service --status-all
abrt-ccpp hook is installed
abrtd (pid  2090) is running...
abrt-dump-oops is stopped
.......
```

### super daemon启动方式
super daemon (xinetd) 也是一个 stand alone 的服务, 因为 super daemon 要管理其他的服务, 所以他必须要常驻在内存中, 所以 super daemon 的启动方式和 stand alone 是相同的, 但是它所管理的其他 daemon 则就不是这么做的了. 必须要在配置文件中设置为启动该 daemon 才行, 配置文件就是 /etc/xinetd.d 目录下的文件.

```bash
## 查看一下 rsync 是否设置了启动
[root@localhost ~]# cat /etc/xinetd.d/rsync 
# default: off
# description: The rsync server is a good addition to an ftp server, as it \
#	allows crc checksumming etc.
service rsync
{
	disable      	= yes       <== 是否禁用此服务, yes 表示禁用 no 表示启用         
	flags		    = IPv6
	socket_type     = stream
	wait            = no
	user            = root
	server          = /usr/bin/rsync
	server_args     = --daemon
	log_on_failure  += USERID
}

## 然后我们把 diable = yes 改为 disable = no
[root@localhost ~]# vim /etc/xinetd.d/rsync 
....
	disable      	= no
....

## 先安装一下 xinetd 服务, 然后启动 xinetd 服务
[root@localhost ~]# yum install xinetd -y
[root@localhost ~]# /etc/init.d/xinetd start
Starting xinetd:                                           [  OK  ]

## 查看端口并查看是查看端口是否被监听
[root@localhost ~]# grep 'rsync' /etc/services 
rsync           873/tcp                         # rsync
rsync           873/udp                         # rsync
[root@localhost ~]# netstat -tulpn | grep 873
tcp        0      0 :::873     :::*    LISTEN      6924/xinetd    
## 会发现程序为 xinted 而不是 rsync, 因为 xinted 控制 rsync


## 然后我们再把 /etc/xinetd.d/rsync 中的 disable = no 改为 yes 尝试一下
[root@localhost ~]# vim /etc/xinetd.d/rsync
....
	disable      	= yes
....
[root@localhost ~]# /etc/init.d/xinetd restart
Stopping xinetd:                                           [  OK  ]
Starting xinetd:                                           [  OK  ]
[root@localhost ~]# grep 'rsync' /etc/services 
rsync           873/tcp                         # rsync
rsync           873/udp                         # rsync
[root@localhost ~]# netstat -tulpn | grep 873
[root@localhost ~]# 

## 所以如果我们修改 /etc/xinetd.d 下面的配置文件, 就需要重启 xinetd 服务.而 xinetd 需要使用 stand alone 方式启动.
```

## super daemon配置文件
super daemon 是一个管理进程, 它是由 xinetd 这个进程所实现的, **xinetd 服务的默认配置文件为 /etc/xinetd.conf**, 为什么说是默认的呢? 我们先看看默认配置文件内容.
```bash
[root@localhost ~]# grep -v '^#' /etc/xinetd.conf 

defaults
{
## 服务启动成功或失败以及相关登录行为的日志文件
	log_type	= SYSLOG daemon info            <== 日志文件的记录服务类型
	log_on_failure	= HOST                      <== 失败时需要记录的信息为主机(HOST)
	log_on_success	= PID HOST DURATION EXIT    <== 成功启动时记录信息

## 允许或限制连接的默认值
	cps		    = 50 10   <== 一秒内最大连接数为50 超过则暂停10s
	instances	= 50      <== 同一服务的最大同时连接数
	per_source	= 10      <== 同一来源的客户端最大连接数

## 网络相关默认设置
	v6only		= no      <== 是否允许 IPV6

## 环境参数的设置
	groups		= yes    
  	umask		= 002

}

includedir /etc/xinetd.d <== 更多的设置在 /etc/xinetd.d 目录内
```

**我们为什么说 /etc/xinetd.conf 为默认的配置文件呢? 如果在服务中没有设置上述的选项, 那么就会使用上述的选项来作为默认选项使用, 所以称为默认的配置文件.** 我们也看到了更多的设置在 /etc/xinetd.d 目录中, 那么我们可以来设置哪些值呢? 格式又是什么样的格式呢 ? 我们先来看 /etc/xinetd.d/rsync 文件
```bash
[root@localhost ~]# cat /etc/xinetd.d/rsync
# default: off
# description: The rsync server is a good addition to an ftp server, as it \
#	allows crc checksumming etc.
service rsync
{
	disable	        = yes
	flags		    = IPv6
	socket_type     = stream
	wait            = no
	user            = root
	server          = /usr/bin/rsync
	server_args     = --daemon
	log_on_failure  += USERID
}

## 我们可以看出来格式为 
service Service_Name
{
	Attribute  Operator   Attribute_Value
}

## 注意事项
Service_Name 的值则与 /etc/services 有关, 因为它需要对照这个文件的服务名称和端口号来启用对应的端口.
[root@localhost ~]# cat /etc/services  | grep rsync
rsync <==Service_Name          873/tcp                         # rsync
rsync                          873/udp                         # rsync

Operator 主要形式有以下几种:
	= : 绝对属性值, 属性值就是这样, 不能多不能少, 如 log_on_failure	 = HOST
   += : 相对属性值, 在原来的设置中加上该属性值,   如 log_on_failure += USERID
   -= : 相对属性值, 在原来的设置中去掉该属性值     
```

| Attribute | 作用 |
| :-----: | ----- |
| 一般设置 | <br> |
| disable (是否禁用) | 设置值 : yes / no <br/>是否禁用, 默认为 yes |
| id (服务识别)  | 设置值 : Service_Name <br>服务名称有时会有重复值, 所以使用 id 来取代服务名称, 可以参考 /etc/xinetd.d/time-stream | 
| server (程序文件) | 设置值 : 程序的完整文件名 <br> 如 server = /usr/bin/rsync |
| server args (程序参数) | 设置值 : 程序的相关参数 <br> 比如 rsync \-\-daemon, 就可以写成 server_args = \-\-daemon |
| user (用户身份)| 设置值 : User_Name <br> 以指定用户的身份来启动该服务程序 |
| group (组身份)| 设置值 : Group_Name <br> 以指定用户组身份来启动该服务程序 |
| socket_type (数据包类型) | 设置值 : stream / dgram / raw <br> 数据包类型 , stream 使用 TCP数据包, dgram 使用 UDP数据包, raw 代表 server 需要与 IP 直接交互 |
| protocol (网络协议) | 设置值 : tcp / udp <br> 使用的网络协议, 由于和 socket_type 重复, 所以可以不指定 |
| wait (连接机制)| 设置值 : yes / no 默认值为 no <br> yes 表示 single-threaded, no 表示 multi-threaded, 一般 udp 为 yes, tcp 为 no |
| instances (最大连接数) | 设置值 : 数字 / UNLIMITED <br> 最大连接数, 可以为 数字/UNLIMITED |
| per_source (单用户连接数) | 设置值 : 数字 / UNLIMITED <br> 每个 IP 的最大连接数 |
| cps (新连接限制) | 设置值 : 数字1 数字2 <br> 数字1 一秒内能够接受的最多新连接数;  数字2 暂时关闭该服务的秒数 |
| 日志文件的记录 | <br> |
| log_type (日志文件类型) | 设置值 : 日志选项等级, 默认为 info |
| log_on_success <br> log_on_failure | 设置值 : PID HOST USERID EXIT DURATION <br> 登录成功或失败需要记录的信息, DURATION 使用该服务多久 |
| 环境 端口和连接机制 | <br> |
| env (额外变量设置) | 设置值 : 变量名称=变量值 <br> 设置环境变量 |
| port (端口号) | 设置值 : 端口号 (没有被使用且小于65534) <br> 一般用于自定义服务使用, 确保 port 和 服务名称必须与 /etc/services 内记录保持一致 |
| redirect (重定向) | 设置值 : IP Port <br> 将请求转发到另外一台主机上 |
| includedie (调用外部文件) | 设置值 : Dir_Name <br> 可以把配置文件写入 /etc/xinetd.d 目录下, 调用即可 |
| 安全设置, 可以实现类似防火墙的管控 | <br> |
| bind (服务端口绑定) | 设置值 : IP <br> 可以绑定允许使用此服务的 IP 地址 |
| interface | 设置值 : IP <br> 同 bind |
| only_from (防火墙机制) | 设置值 : 0.0.0.0 / 192.168.1.0/24 / hostname / domain_name <br> 只有设置的 IP , 主机名, 域名可以登录 |
| no_access (防火墙机制) |  设置值 : 0.0.0.0 / 192.168.1.0/24 / hostname / domain_name <br> 用来管理是否可以进入 linux 主机启用你的服务, **no_access 表示不可登录的 PC** |
| access_times (时间控制) | 设置值 : 00:00-24:00 [00:00-24:00] <br> 比如 ftp 从 8点 到 16点 则为 08:00\-16:00 |
| umask | 设置值 : 000 / 777 / 022 <br> 新建目录或者文件的权限和 umask值有关, 建议为 022 |

### rsync简单的防火墙设置
我们从上面的选项可以看出, super daemon 可以看做是一个简易的防火墙, 那么我们就来使用 rsync 做一个实验, 要求如下 
```bash
现在电脑上有两个接口 192.168.1.206 和  127.0.0.1 , 然后对于两个接口, 划分不同的权限设置

192.168.1.206(外网)
	1. 对外绑定 192.168.1.206 这个接口
	2. 仅在 192.168.1.0/24 以及 .gkdaxue.com 这个域名可以登录
	3. 开放时间为 01:00-09:00 和 20:00-24:00 时间段
	4. 最多允许 10 条同时连接的限制
	
127.0.0.1 (内网)
	1. 绑定 127.0.0.1 这个接口
	2. 对 127.0.0.0/8 开放登录 rsync 服务, 除了 127.0.0.100 和 127.0.0.200
	3. 不进行任何连接限制, 包含连接数和时间
```

#### 实验步骤
```bash
## 先来查看一下 /etc/xinetd.d/rsync 文件
[root@localhost ~]# cat /etc/xinetd.d/rsync
# default: off
# description: The rsync server is a good addition to an ftp server, as it \
#	allows crc checksumming etc.
service rsync
{
	disable	        = no
	flags		    = IPv6
	socket_type     = stream
	wait            = no
	user            = root
	server          = /usr/bin/rsync
	server_args     = --daemon
	log_on_failure += USERID
}

## 先备份一份, 出现意外可以恢复
[root@localhost ~]# cp -apdf /etc/xinetd.d/rsync .

## 重启并查看端口信息
[root@localhost xinetd.d]# /etc/init.d/xinetd restart
Stopping xinetd:                                           [  OK  ]
Starting xinetd:                                           [  OK  ]
[root@localhost xinetd.d]# netstat -tulpn | grep 873
tcp        0      0 :::873                  :::*          LISTEN      10462/xinetd


## 然后我们按照实验要求, 开始修改
[root@localhost ~]# vim /etc/xinetd.d/rsync
## 现针对较为宽松的来设置
service rsync
{
    disable         = no
    bind            = 127.0.0.1
    only_from       = 127.0.0.0/8
    no_access       = 127.0.0.100 127.0.0.200
    instances       = UNLIMITED
    socket_type     = stream
    wait            = no
    user            = root
    server          = /usr/bin/rsync
    server_args     = --daemon
    log_on_failure += USERID
}

## 在设置外网
service rsync
{
   disable         = no
   bind            = 192.168.1.206
   only_from       = 192.168.1.0/24 
   only_from      += .gkdaxue.com
   access_times    = 01:00-09:00
   access_times   += 20:00-24:00
   instances       = 10
   socket_type     = stream
   wait            = no
   user            = root
   server          = /usr/bin/rsync
   server_args     = --daemon
   log_on_failure += USERID
}

## 重启再次查看端口, 并且他们的 PID 相同 10590
[root@localhost xinetd.d]# service xinetd restart
Stopping xinetd:                                           [  OK  ]
Starting xinetd:                                           [  OK  ]
[root@localhost xinetd.d]# netstat -tulpn | grep 873
tcp        0      0 127.0.0.1:873               0.0.0.0:*       LISTEN      10590/xinetd
tcp        0      0 192.168.1.206:873           0.0.0.0:*       LISTEN      10590/xinetd
```

# 服务的防火墙管理 xinetd, Tcp Wrappers
通过我们前边的学习我们知道, 要控制 at 的使用可以通过修改 /etc/at.{ allow | deny } 来实现, crontab 则可以通过 /etc/cron.{ allow | deny } 来实现, 那么我们应该如何管理某些程序的网络使用呢? 简单来说就是针对 源IP/域 来进行允许/拒绝的操作, 决定此连接是否能够成功连接. 比如我们之前设置的 rsync 的 no_access 和 only_from 也是一种防火墙的设置, 但是**使用 /etc/hosts.deny 以及 /etc/hosts.allow 则更容易的进行管理.**
**/etc/hosts.deny 以及 /etc/hosts.allow 是 /usr/sbin/tcpd 的配置文件**, tcpd 是分析进入系统的 TCP数据包的一个软件, TCP的数据包的文件头记录了来源和主机的 IP 和 port , 因此我们就可以和 /etc/hosts.{ allow | deny } 规则进行比较, 则就决定了该连接能够连接到我们的系统中. **因此只要不支持 TCP Wrappers 函数功能的软件程序就无法使用 /etc/hosts.{ allow | deny } 来进行控制.**, 那么我们如何查看一个程序是否支持 TCP Wrappers 呢, 这就需要用到我们的 ldd 命令

## ldd命令
ldd(library dependency discovery) 打印共享库依赖项
> ldd [ options ] FILE

```bash
[root@localhost ~]# ldd $(which sshd httpd)
/usr/sbin/sshd:
	linux-vdso.so.1 =>  (0x00007fff56f74000)
	libfipscheck.so.1 => /lib64/libfipscheck.so.1 (0x00007f69d59fc000)
	libwrap.so.0 => /lib64/libwrap.so.0 (0x00007f69d57f1000)     <== 发现支持 wrap
	libaudit.so.1 => /lib64/libaudit.so.1 (0x00007f69d55cc000)
	.................

/usr/sbin/httpd:                                                 <== 没有找到 wrap
	linux-vdso.so.1 =>  (0x00007ffd99d2a000)
	libm.so.6 => /lib64/libm.so.6 (0x00007fdd86835000)
	libpcre.so.0 => /lib64/libpcre.so.0 (0x00007fdd86608000)
	......

## 所以我们可以知道, sshd 服务可以使用 /etc/hosts.{ allow | deny } 来实现类似防火墙的功能. 而 httpd 则没有此功能
```

## /etc/hosts.{ allow | deny }配置语法
```bash
程序的文件名    : IP 或 域 或 主机名       : 操作
program_name   : IP | domain | hostname : { allow | deny }

## 比如我们所说的  rsync 路径为 /usr/bin/rsync

## 我们现在是以 ssh 方式连接到服务器的, 那么我们就用 sshd 来做个试验
## 禁止我本机使用 ssh 连接到服务器 (此操作有风险, 请勿在服务器上使用)
## 我本机的 ip 地址为  192.168.1.11 
[root@localhost ~]# which sshd
/usr/sbin/sshd
[root@localhost ~]# vim /etc/hosts.deny 
sshd : 192.168.1.11 : deny

## 退出连接, 尝试重新连接到服务器
[root@localhost ~]# exit
logout

## 发现无论如何都连接不上, 已经被拒绝了. 所以只能进入到虚拟机里面来操作了.
Connecting to 192.168.1.206:22...
Connection established.
To escape to local shell, press Ctrl+Alt+].

Connection closed by foreign host.

Disconnected from remote host(1.206) at 12:51:23.

## 然后到虚拟机里面把对应的记录删除, 我们又可以快乐的玩耍了.
## 所以提醒在操作服务器的时候, 一定要特别注意小心.
```

**这两个文件的判断的顺序为 /etc/hosts.allow 优先, 然后在判断 /etc/hosts.deny .** 所以我们一般的操作是把允许的写入到 /etc/hosts.allow 文件中, 不允许的则放到 /etc/hosts.deny 文件中. 然后在文件中我们还可以使用一些**特殊的参数** :

```bash
ALL     : 代表全部的 program_name 或者 IP 的意思, 如 ALL:ALL:allow
LOCAL   : 代表本机的意思, 如  ALL:LOCAL:allow
UNKNOWN : 代表不知道的 IP/domain/服务 时
KNOWN   : 代表可解析的 IP/domain 信息时

## 所以我们来做个试验
## 140.160.0.0/16  以及  203.71.39.0/24 还有 203.71.38.123 可以进入到 rsync 服务
## 其他的 IP 全部拒绝
[root@localhost ~]# vim /etc/hosts.allow
rsync : 140.160.0.0/255.255.0.0   : allow
rsync : 203.71.39.0/255.255.255.0 : allow
rsync : 203.71.38.123             : allow
rsync : LOCAL                     : allow

[root@localhost ~]# vim /etc/hosts.deny
rsync : ALL : deny 
```

## TCP Wrappers特殊功能
我们现在仅仅只能做到拒绝或者允许某些操作, 那么我们如何在拒绝后记录下来 IP信息 或者直接发送给管理员呢? 这就需要用到 TCP Wrappers 软件才行, 所以需要确保我们安装了此软件.
```bash
## 查询是否安装了 tcp_wrappers 软件
[root@localhost ~]# rpm -q tcp_wrappers
tcp_wrappers-7.6-58.el6.x86_64


spawn (action) : 可以利用后续 shell 来进行额外的操作且具有变量的功能
		%h(hostname) %a(address) %d(daemon)
twist (action): 立即以后续的命令进行且执行完后终止该次连接的请求
```

### 实例
```bash
实验要求 :
	1. 利用 safe_finger 跟踪出对方主机的信息, 包含主机名 用户相关信息
	2. 然后将结果发送给 root 用户
	3. 在客户端上显示不可登录且信息已被记录的提示

[root@localhost ~]# vim /etc/hosts.deny
sshd : 192.168.1.11 : spawn (echo "security notice form host $(/bin/hostname)" ; \
                      echo ; /usr/shib/safe_finger @%h ) | \
                      /bin/mail -s "%d-%h security" root & \
                    : twist ( /bin/echo -e "\n\n WARNING connection not allowed.\n\n")
[root@localhost ~]# exit
logout

## 然后我们尝试登录时, 会提示登录失败, 使用虚拟机终端登录, 查看邮件
[root@localhost ~]# mail
Heirloom Mail version 12.4 7/29/08.  Type ? for help.
"/var/spool/mail/root": 5 messages
>   5 root                  Thu Mar 28 14:24  20/673   "sshd-192.168.1.11 security"

& 5   <== 输入邮件编号 5 就可以查看邮件内容
Message  5:
From root@localhost.localdomain  Thu Mar 28 14:24:11 2019
Return-Path: <root@localhost.localdomain>
X-Original-To: root
Delivered-To: root@localhost.localdomain
Date: Thu, 28 Mar 2019 14:24:11 +0800
To: root@localhost.localdomain
Subject: sshd-192.168.1.11 security
User-Agent: Heirloom mailx 12.4 7/29/08
Content-Type: text/plain; charset=us-ascii
From: root@localhost.localdomain (root)
Status: RO

security notice form host localhost.localdomain

& q   <== 退出邮件
```

# 系统开启的服务




