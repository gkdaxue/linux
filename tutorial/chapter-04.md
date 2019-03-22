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
```bash
## 比如把 rm 命令定义为 rm -i, 可以帮助我们在一定程度上防止误删文件. 会在删除之前要求我们确认
[root@localhost ~]# alias rm
alias rm='rm -i'
```

### 作业控制 前后台控制功能
我们可以把执行时间比较长的命令丢到后台去, 然后我们可以继续我们的任务, 这就是多任务的使用.

### 程序脚本
我们可以把很多命令写到一个文件中, 然后我们就可以通过执行这个脚本, 来简化我们的操作(自动化运行).

### 通配符
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

