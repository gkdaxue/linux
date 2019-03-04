# 安装实验环境

## 实验环境

- Window7  64 位

- VMwave Workstation 12 64位

- CentOS 6.9 64位

> 如果你的电脑为32位, 那么你只能使用VMware 10 Workstation或之前的版本, 此后版本不支持 32 位.

## VMwave Workstation 12

    自行百度下载, 然后傻瓜式安装即可, 然后百度对应版本的序列号, 激活即可或者免费使用一个月后在激活.  主要的重点在于虚拟机的创建工作.

### 创建虚拟机

    使用虚拟机的主要优点就是可以快速的模拟出我们需要的设备(比如 添加一块硬盘, 添加一个网卡等等), 而不需要我们实际的去购买这些硬件设备, 操作简单, 所以推荐使用.

#### 注意事项

1. 硬件兼容性选择对应安装的 VMwave Wordstation 相同版本, 如下图所示 : 

   ![硬件兼容性](https://github.com/gkdaxue/linux/raw/master/image/chapter_A1_001.png)

2. 选择操作系统时, 一定要选择 **`稍后安装操作系统`** 

   ![安装操作系统](https://github.com/gkdaxue/linux/raw/master/image/chapter_A1_002.png)

   >     如果在此步骤选择了下载的镜像文件, 有可能会被部署为 `精简模式的操作系统`, 很多软件都不会被安装, 这对于我们新手来说, 会导致平时学习中会遇到很多的问题.

3. 选择操作系统以及操作系统的版本信息

   ![操作系统以及版本](https://github.com/gkdaxue/linux/raw/master/image/chapter_A1_003.png)

   >     一定要选择和你下载的镜像匹配的 `操作系统以及版本信息` , 比如我下载的是 CentOS 6.9 64 位, 那么我就可以如上图一样选择对应信息.

4. 内存的选择

   ![内存的选择](https://github.com/gkdaxue/linux/raw/master/image/chapter_A1_004.png)

   > 一般来说是物理内存的两倍, 但是设置为 1024M 也没多大问题, 毕竟是测试, 实际工作中根据具体情况来处理

5. 网络类型

   ![网络类型](https://github.com/gkdaxue/linux/raw/master/image/chapter_A1_005.png)

   > 桥接模式  : 相当于在物理主机与虚拟机网卡之间架设了一座桥梁，可以通过物理主机的网卡访问外网
   > 
   > NAT模式 : 让VM虚拟机的网络服务发挥路由器的作用，可以通过物理主机访问外网，对应物理网卡是VMnet8
   > 
   > 仅主机模式 : 仅让虚拟机与物理机通信不能访问外网，对应的物理网卡是VMnet1

6. 磁盘大小( 40G )

   ![磁盘大小](https://github.com/gkdaxue/linux/raw/master/image/chapter_A1_006.png)

7. 选择下载的镜像

   ![选择镜像](https://github.com/gkdaxue/linux/raw/master/image/chapter_A1_007.png)

   > 因为我们之前选择的是 `稍后安装操作系统`, 所以在此处选择对应的镜像文件.

#### 完整安装过程

   完整安装过程如下图所示 :

![创建虚拟机](https://github.com/gkdaxue/linux/raw/master/image/chapter_A1_000.gif)

### 安装操作系统 (CentOS 6.9 64位)

![开启虚拟机](https://github.com/gkdaxue/linux/raw/master/image/chapter_A1_008.png)

---

![安装操作系统](https://github.com/gkdaxue/linux/raw/master/image/chapter_A1_009.png)

---

![跳过检查](https://github.com/gkdaxue/linux/raw/master/image/chapter_A1_010.png)

---

![安装引导界面](https://github.com/gkdaxue/linux/raw/master/image/chapter_A1_011.png)

---

![选择语言](https://github.com/gkdaxue/linux/raw/master/image/chapter_A1_012.png)

---

![选择键盘](https://github.com/gkdaxue/linux/raw/master/image/chapter_A1_013.png)

---

![设备类型](https://github.com/gkdaxue/linux/raw/master/image/chapter_A1_014.png)

---

![删除数据](https://github.com/gkdaxue/linux/raw/master/image/chapter_A1_015.png)

---

![设置主机名](https://github.com/gkdaxue/linux/raw/master/image/chapter_A1_016.png)

---

![选择时区](https://github.com/gkdaxue/linux/raw/master/image/chapter_A1_017.png)

---

![设置root密码](https://github.com/gkdaxue/linux/raw/master/image/chapter_A1_018.png)

---

![选择自定义分区](https://github.com/gkdaxue/linux/raw/master/image/chapter_A1_019.png)

---

#### 自定义磁盘分区

    准备使用自定义分区, 来让我们熟悉前一章节的内容, 主分区, 扩展分区和逻辑分区等等. 

**为了方便计算和记忆, 我们设定  1G = 1000M**

| 目录信息  | 占据空间          |
| ----- | ------------- |
| /     | 2GB           |
| /boot | 200MB         |
| /usr  | 4GB           |
| /var  | 2GB           |
| /tmp  | 1GB           |
| swap  | 1GB           |
| /home | 5GB ( LVM模式 ) |

##### 创建普通分区

![创建普通分区](https://github.com/gkdaxue/linux/raw/master/image/chapter_A1_020.png)

> 如 /, /boot, /usr, /var, /tmp这些
> 
> 选中 /dev/sda (想一下磁盘命名规则, 为啥是/dev/sda ? ) , 然后点击 `Create` 按钮 , 选择 `Standard Partition (标准分区)`  然后点击 'Create' 按钮,  创建以上几个分区, 都是这个步骤. 然后写入不同的 `Mount Point` 以及 `Size` 即可.

![创建普通分区](https://github.com/gkdaxue/linux/raw/master/image/chapter_A1_021.png)

> ext4 : Linux使用的文件系统类型
> 
> physical volumn(LVM) : 弹性调整文件系统大小的一种机制
> 
> software RAID : 不同RAID的级别效果不同
> 
> swap : 内存交换空间 (**不需要挂载点**)

![创建普通分区](https://github.com/gkdaxue/linux/raw/master/image/chapter_A1_022.png)
![创建普通分区](https://github.com/gkdaxue/linux/raw/master/image/chapter_A1_023.png)
![创建普通分区](https://github.com/gkdaxue/linux/raw/master/image/chapter_A1_024.png)
![创建普通分区](https://github.com/gkdaxue/linux/raw/master/image/chapter_A1_025.png)

##### 创建 swap

> 其他内容类似, 只是在弹框的选择不同而已, File System Type 为 `swap` (只能下拉选), 无 `Mount Point(挂载点)`
> 
> 有些教程中, 会提到 `swap的大小为物理内存的2倍`, 一般会是这样, 不过还是要看具体需求.

![创建swap](https://github.com/gkdaxue/linux/raw/master/image/chapter_A1_026.png)

##### 创建 LVM

>  因为 /home 要求为 lvm 模式, 所以需要先创建 lvm
> 
> 和刚才创建 swap 类型, 不过不是 swap, 需要选择 `physical volume (LVM)` 这个, 然后选择输入大小, 点击 `OK` 按钮即可

![创建lvm](https://github.com/gkdaxue/linux/raw/master/image/chapter_A1_027.png)

##### 创建 /home

> 先选择自己创建的 lvm, 然后点击 `Create` 按钮, 选择 `LVM Volume Group` 后点击 `Create` 按钮, 在按图中设置即可, 因为涉及到后面的内容, 所以只要做出来就可以.

![创建home](https://github.com/gkdaxue/linux/raw/master/image/chapter_A1_028.png)
![创建home](https://github.com/gkdaxue/linux/raw/master/image/chapter_A1_029.png)
![创建home](https://github.com/gkdaxue/linux/raw/master/image/chapter_A1_030.png)

![创建home](https://github.com/gkdaxue/linux/raw/master/image/chapter_A1_031.png)

##### 全部创建完成截图

> 已经全部创建完成, 确认无误,  点击`Next` 按钮, 如果有不同, 请修改后再点击 `Next` 按钮

![创建home](https://github.com/gkdaxue/linux/raw/master/image/chapter_A1_032.png)

>     我们发现, 系统已经帮我们自己创建了 主分区, 扩展分区和逻辑分区. 并且把所有的可用空间都分给了扩展分区, 然后我们就可以再此基础上划分出来逻辑分区. 可以复习一下分区设备文件的命名规则.

#### 格式化并写入硬盘

![写入硬盘](https://github.com/gkdaxue/linux/raw/master/image/chapter_A1_033.png)
![写入硬盘](https://github.com/gkdaxue/linux/raw/master/image/chapter_A1_034.png)
![写入硬盘](https://github.com/gkdaxue/linux/raw/master/image/chapter_A1_035.png)

#### 其他操作

> 选择需要安装的软件信息, 等待安装完成,  然后点击 'Reboot' 按钮, 等待系统重新启动完成, 然后设置即可.

![其他操作](https://github.com/gkdaxue/linux/raw/master/image/chapter_A1_036.png)
![其他操作](https://github.com/gkdaxue/linux/raw/master/image/chapter_A1_037.png)
![其他操作](https://github.com/gkdaxue/linux/raw/master/image/chapter_A1_038.gif)

> 到此, 我们的操作系统就安装完成了, 就可以正常登录使用了, 有兴趣的同学, 可以自己登录摸索一番.

### 快照的使用

>      快照的主要作用是备份系统, 这是VMwave 自带的一个功能, 在真正服务器上是没有这个功能, 如果我们之前备份了一个快照, 然后不小心执行了 `rm -rf /*` 这个爆炸性的命令, 系统就会挂了, 那么我们就可以通过快照功能来还原系统, 而不必重新安装系统.

![快照操作](https://github.com/gkdaxue/linux/raw/master/image/chapter_A1_039.png)
![快照操作](https://github.com/gkdaxue/linux/raw/master/image/chapter_A1_040.png)

# 终端以及终端分类

> 用户和主机交互必然会用到的设备
> 
>       终端就是处理计算机主机输入输出的一套设备，它用来显示主机运算的输出，并且接受主机要求的输入，典型的终端包括显示器键盘套件，打印机打字机套件等。

## 物理终端

在本地就直接关联了物理设备, 比如VGA口啊，PS/2口啊，串口等( /dev/console )

> **/dev/console** 变量可以表示焦点终端，不管你在哪里往 ***/dev/console*** 里写东西，这些东西总会出现在系统当前的焦点终端上！
> 
> **/dev/console**其实就是一个全局变量，指代当前的焦点终端，如果当前的焦点是 ***/dev/tty4*** ，那么 ***/dev/console*** 指的就是 **/dev/tty4**  (这一切都是由内核来维护的)

## 虚拟终端(本地终端)

附加在物理终端之上的用软件方式虚拟实现的终端 Ctrl+Alt+F\[1-6\] ( **/dev/tty1~/dev/tty63** )

> 可以在这些终端之间切换，每切换到一个终端，该终端就是当前的 `焦点终端`
> 
> `/dev/tty` 叫做自己的全局变量，无论你在哪个终端下工作，当你往/dev/tty里写东西的时候，它总是会马上出现在你的眼前。

## 图形终端

附加在物理终端之上的用软件方式虚拟实现的终端,会额外提供桌面环境 ( **/dev/pts/\[0,...\]** )

## 模拟终端

图形界面下打开的命令行接口或者基于SSH和telnet协议等远程打开的界面 ( **/dev/pts/\[0,...\]** )

## 总结

     每一个终端必须绑定一个用户，只有登录成功的用户方可在这个终端上操作计算机，所以首先要做的就是登录。输入用户名和密码，如果输入正确，则会给你一个Bash(或者别的Shell)让你操作计算机，如果输入不正确，则让你继续输入或进行其他操作. 

# 交互式接口

     `启动终端后, 在终端设备附加一个交互式应用程序`, 这样我们就可以通过终端, 来执行我们的操作. 

## 分类

Graphical User Interface : 图形用户界面 (GUI), 例如 X protocol, GNOME, Window Manage, Desktop等.

Command Line Interface : 命令行界面 (CLI  或者叫 终端界面\[ terminal, console \] ), 例如 sh, csh, tcsh, ksh, Bash 等,

>      Shell(也称为终端或壳)是一个命令行工具。充当的是人与内核（硬件）之间的翻译官，用户把一些命令“告诉”终端，它就会调用相应的程序服务去完成某些工作。现在许多主流Linux系统默认使用的终端是`Bash（Bourne-Again Shell` 解释器. 

所以我们看下图, 体会一下 Shell 的作用,  是否有了一些新的理解和体会.

![shell的位置](https://github.com/gkdaxue/linux/raw/master/image/chapter_03.png)

## CUI 与 CLI 的切换

     交互式界面有 `GUI` 以及 `CLI` 这两种方式, 那么它们之前应该怎么进行切换呢? 

>      命令行模式 : 也被称为终端界面( terminal 或 console ), Linux 默认会提供6个 terminal 来让用户登录使用, 切换的的方式为`Ctrl + Alt + F[1-6]` 的组合按钮. 并分别命名为 `tty[1-6]` . 这就是我们所说的 `虚拟终端(本地终端)`
> 
>      图形界面 : `Ctrl + Alt + F7` (但是在VMwave中, 却是 `Ctrl + Alt + F1`) `图形终端`

     在 Linux 默认登录模式中, 主要有两种, 一种是 `纯文本界面(runlevel 3)` 的登录环境, 还有一种就是 `图形化的登录环境(runlevel 5)` , 我们安装时, 没有更改, 所以默认是图形化界面登录.

### 命令行登录系统

     那么我们如何使用终端界面来登录呢? 这就需要用到我们之前说的 `Ctrl + Alt + F[1-6]` 了,  例如我们刚才按了 `Ctrl + Alt + F2` 就打开了一个纯文本界面来登录, 显示如下:

```
CentOS release 6.9 (Final)
Kernel 2.6.32-696.el6.x86_64 on an x86_64
localhost login: root
Passwd:    <= 输入用户名, 敲回车才会显示此行, 并且输入密码时, 不显示出来
[root@localhost ~]#
```

> CentOS release 6.9 (Final) : Linux 发行的名称(CentOS) 和 版本(6.9)
> 
> Kernel 2.6.32-696.el6.x86\_64 on an x86\_64 : 内核版本以及硬件信息
> 
> localhost login : 
> 
>         localhost : 主机名(因为我们的主机名为 localhost.localdomain, 通常只取第一个小数点前的字母)
>     
>         login : 后边可以输入用户名, 敲击回车即可输入密码
> 
> Passwd : 只有输入用户名并敲回车才会显示, `输入的密码不会显示` , 所以输入完密码, 敲击回车即可
> 
> \[root@localhost ~\]# :   PS1 命令提示符( prompt ).  以后讲解, 现在了解即可.
> 
>         root : 登录的用户名
>     
>         localhost : 主机名
>     
>         ~ : 是一个变量, 表示用户的家目录, 比如 root 的家目录为 /root
>     
>         # : root的命令提示符为 # , 一般用户的命令提示符为 $ 

注销登录, 离开系统, 使用 `exit` 命令即可:

> \[root@localhost ~\]# exit \

### Bash (Bourne-Again Shell)

     我们在之前说过 shell 可以称为终端, 并且现在许多主流Linux系统默认使用的终端是`Bash (Bourne-Again Shell)` 解释器. 那么Bash 到底有哪些优点呢, 让主流的 Linux 都选择了它, 主要如下:

> 1. 通过上下方向键来调取过往执行过的Linux命令
> 
> 2. 命令或参数仅需输入前几位就可以用Tab键补全
> 
> 3. 具有强大的批处理脚本
> 
> 4. 具有实用的环境变量功能

我们会在以后的实验中, 体会到我们说的这些优点. 以下内容初学者知道就好

```Shell
## 查看当前系统中默认的 Shell
[root@localhost ~]# echo $SHELL
/bin/bash

## 查看系统中所有的 Shell
[root@localhost ~]# cat /etc/shells 
/bin/sh
/bin/bash
/sbin/nologin
/bin/dash
/bin/tcsh
/bin/csh
```



### PS1 : 命令提示符( prompt )

这里只要先了解即可, 以后可以来深入理解一下.

```
[root@localhost ~]# echo $PS1   # echo 输出变量的意思
[\u@\h \W]\$
```

| 符号  | 含义                       |
| --- |:------------------------ |
| \h  | 显示简写主机名                  |
| \u  | 显示当前用户名                  |
| \d  | 显示日期,格式为"星期 月 日"         |
| \t  | 24小时制, 格式为"HH:MM:SS"     |
| \T  | 12小时制, 格式为"HH:MM:SS"     |
| \A  | 24小时制, 格式为"HH:MM"        |
| \u  | 显示当前用户名                  |
| \w  | 显示当前所在目录的完整名称            |
| \W  | 显示最后一次所在的目录              |
| \#  | 执行的第几个命令                 |
| \$  | 命令提示符, root (#), 普通用户($) |

所以这里我们就可以自己理解一下 `[root@localhost ~]#` 是什么意思了

### 总结

     Shell 是一个命令行的交互式接口, 也可以称之为终端, 因为是依附在终端上的一个程序而已, Shell 充当的是 人与内核之间的翻译官，用户把一些命令“告诉”终端，它就会调用相应的程序服务去完成某些工作.

     在服务器上, 一般是不会给系统安装上图形化界面(是的, 图形化界面不是必选项), 所以一般都是通过 命令行界面(终端界面) 来操作我们的系统. 接下来我们学习一些基本的操作.
