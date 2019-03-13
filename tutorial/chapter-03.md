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

## 输出重定向符号

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
> 文件描述符 与 >/>> 之间没有空格
> 
> \>    :  表示清空写入的方式(清空原有文件内容,然后写入)
> 
> \>\>  :  表示追加写入的方式(附加在原有文件内容之后)

## 演示

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
```

home_dir_file 文件的处理方式为 :

> 1. 判断 home_dir_file 是否存在, 不存在则进行创建
> 
> 2. 我们使用的为 > , 表示为清空写入的意思, 清空原文件内容, 并把新内容写入, 查看
> 
> 3. 又使用了 >> 追加写入方式, 发现原内容没有被清空. 所以显示了我们添加的所有信息
