# Vim编辑器
在 Linux 系统中, 大部分的配置文件都是以 Ascll 的存文本形式存在, 那么编辑这些配置文件就需要用到我们之前说的 nano 之类的编辑软件, 但是我们为什么一定要学习 Vim 编辑器呢?
> 1. 所有的 Linux 系统都会内置 vi 文本编辑器, 其他的编辑器不一定存在
> 2. 很多的软件的编辑接口也会调用 vi 来编辑配置文件(crontab, visudo 等)
> 3. Vim 具有程序编辑的能力, 程序简单, 编辑速度相当快.

vim 共分为 3 种模式, 分别是 命令模式(Command mode), 输入模式(Insert mode) 和 末行模式(Last line mode), 默认进入 vim 为 命令模式.
> 命令模式 : 控制光标上下左右移动，可对文本进行复制、粘贴、删除和查找等工作(默认)
>
> 输入模式 : 进行正常的文本输入操作, 也叫编辑模式
> 
> 末行模式 : 保存或退出文档，以及设置编辑环境

![vim_three_mode](https://github.com/gkdaxue/linux/raw/master/image/chapter_A6_0001.png)

在每次运行Vim编辑器时，默认进入命令模式，此时需要先切换到输入模式后再进行文档编写工作，而每次在编写完文档后需要先返回命令模式，然后再进入末行模式，执行文档的保存或退出操作。在Vim中，无法直接从输入模式切换到末行模式。有的时候会看到 vi , 那么 vi 和 vim 什么关系呢? vim 可以看做 vi 的升级版本功能更强大. 
> vim FILE_NAME

```bash
## 默认进入命令模式
[root@localhost ~]# vim vim_test.txt
▌   <== 光标在这里跳动
~
~   <== ~ 表示没有任何东西, 所以显示 ~
~
~                                                                           
"vim_test.txt"  [New File]                                  0,0-1         All
   文件名        这是一个新建的文件

## 然后按下 i o a 任何一个按键, 进入输入模式
gkdaxue  <== 光标在这里跳动, 然后输入 gkdaxue
~
~
~                                                                                                                  
-- INSERT --                                               0,1           All
   表明现在是编辑模式

## 那么如何保存呢? 先按 ESC 退回到命令模式, 发现最下边的 INSET 那行不见了
## 然后我们按下 Shift + " : 键所在的位置". 输入 : 变成如下所示
gkdaxue
~
~
~                                                                         
:  <== 这是我们在命令模式下输入的 : 显示在最后一行, 进入了末行模式, 我们可以在里面输入内容

## 接下来我们在末行模式中输入 wq! ,显示如下, 输入完成敲回车, 在查看文件内容
:wq!
[root@localhost ~]# cat vim_test.txt 
gkdaxue
[root@localhost ~]# vim vim_test.txt
gkdaxue
~
~
~                                                                         
"vim_test.txt" 1L, 8C                                      1,1           All
  文件名       因为不是新创建的文件, 所以没有 New File 
1L : 有1行
8C : 8个字符

## 经过上面简单的尝试, 我们已经学会了最简单的 Vim 操作. 接下来自行尝试修改文件内容并保存.
```
![use_vim](https://github.com/gkdaxue/linux/raw/master/image/chapter_A6_0002_use_vim.gif)

## 命令模式常用按键
Num 表示数字的意思, 不是单词, 也不是字符串.

| 按键 | 作用 |
| ---- | ---- |
| h \| ←  | 光标向左移动一个字符 |
| j \| ↓ | 光标向下移动一个字符 |
| k \| ↑ | 光标向上移动一个字符 |
| l \| → | 光标向右移动一个字符 |
| <br /> | 也可以和数字连用, 比如 30j 表示向下移动30 行 |
| ctrl + f \| Page Down | 屏幕向下移动一页 |
| ctrl + b \| Page Up | 屏幕向上移动一页 |
| ctrl + d | 屏幕向下移动半页 |
| ctrl + u | 屏幕向上移动半页 |
| Num + 空格 | 比如 30 + 空格, 表示向右移动30个字符 |
| H | 光标移动到此屏幕上第一行的第一个字符 |
| M | 光标移动到此屏幕中央那一行的第一个字符 |
| L | 光标移动到此屏幕上最后一行的第一个字符 |
| 0 \| Home键 | 移动到此行的第一个字符上 |
| $ \| End键 | 移动到此行的最后一个字符上 |
| gg | 跳转到此文件的第一行 |
| G | 移动到此文件的最后一行 |
| NumG | 如20G, 表示跳转到 20 行 |
| Num + 回车 | 如 10 + 回车, 表示光标向下移动 10 行 |
| x | 向后删除一个字符 |
| X | 向前删除一个字符 |
| Numx| 向后删除 Num 个字符 |
| dd | 删除光标所在的一整行 |
| Numdd | 删除光标所在的向下 Num 行,如 20dd |
| d1G | 删除光标所在行到第一行的所有内容 |
| dG | 删除光标所在行到最后一行的所有内容 |
| d0 | 数字0, 表示删除光标所在位置到该行行首所有字符 |
| d$ \| shift + d | 表示删除光标所在位置到该行行尾所有字符 |
| yy | 复制光标所在的行 |
| Numyy | 复制光标所在的向下 Num 行, 如 20yy |
| y1G | 复制光标所在行到第一行的所有数据 |
| yG | 复制光标所在行到最后一样的所有数据 |
| y0 | 复制光标所在位置到该行行首的所有数据 | 
| y$ | 复制光标所在位置到该行行尾的所有数据 |
| p | 将复制的数据粘贴在光标的下一行 |
| P | 将复制的数据粘贴在光标的上一行 |
| u | 还原上一步的操作 |
| . | 重复前一个操作 |

**以下为 命令模式 进入到编辑模式的按键说明 :**

| 按键 | 作用 |
| ---- | ---- |
| i | 当前光标所在处插入 |
| I | 大写(i), 光标所在行的第一个非空格处插入 |
| a | 光标所在的下一个字符处开始插入 |
| A | 光标所在行的最后一个字符处插入 |
| o | 光标所在行的插入新的一行 |
| O | 大小字母 o, 光标所在行的上一行插入新的一行 |
| r word| 替换光标所在位置的那个字符一次, 把光标所在的位置的字符串替换为 word |
| R | 进入到连续替换模式, 一直到按 ESC 键退出 |

## 末行模式常用按键 
想要进入末行模式, 可以按 :  /   ?  这三个中的任意一个, 每个都有不同的作用. 搜索时也可以使用正则来匹配, 比如 ^word (以word开头) , word$(以word结尾) 等下一部分讲解.

| 按键 | 作用 |
| ---- | ---- |
| /word | 往下寻找一个叫做 word 的字符串 |
| ?word | 往上寻找一个叫做 word 的字符串 |
| <br /> | n 重复前一个查找的工作 |
| <br /> | N 反向执行前一个查找的操作 | 
| :Line1,Line2s/word1/word2/ | 从 Line1 到 Line2 行第一个 word1 字符替换为 word2 |
| :Line1,Line2s/word1/word2/g | 将 Line1 到 Line2 行中所有的 word1 字符 替换为 word2 |
| :Line1,Line2s/word1/word2/gc | 将 Line1 到 Line2 行中所有的 word1 字符 替换为 word2 且在替换前给用户确认是否替换 |
| :w | 保存数据 |
| :w! | 强制保存数据(能不能写入要看用户对该文件的权限) |
| :q | 退出 vim |
| :q! | 强制退出 vim, 不保存已经修改的数据 |
| :wq | 保存并退出 |
| :wq! | 强制保存并退出 |
| ZZ | 文件没有改动,则退出, 如果文件被改动, 则保存后退出 |
| :w FILE_NAME | 将编辑的数据另存为 FILE_NAME 文件 |
| :r FILE_NAME | 读取 FILE_NAME 的内容并追加到光标所在行的后面 |
| :Num1,Num2 w FILE_NAME | 将 Num1 到 Num2 行的内容保存为 FILE_NAME 文件 |
| :! Command | 暂时离开 Vim 环境到命令行模式下执行 Command 命令并显示结果 |
| :set nu | 显示行号 |
| :set nonu | 不显示行号 |

**还有一些变形模式, 如下:**
> 1. :5,$s/word1/word2/g : 从第 5 行到最后一样把所有的 word1 替换成 word2
> 2. :%s/word1/word2/g : 把全文中的 word1 替换成 word2
> 3. 也可以吧 / 替换成其他符号防止出现和word中重复的符号, 比如 %s#word1#word2#g
> 4. :,8s/word1/word2/g : 把当前行到第 8 行的中所有的 word1 替换成 word2
> 5. :4,9s/^#// : 把 4-9行的开头 # 替换为空
> 6. :5,10s/.\*/#&/ : 把 5-10行前加入 # 符号(.\* 整行  & 引用查找的内容 )
> 7. :1,3 w FILE_NAME : 把 1-3行内容写入到 FILE_NAME 中
> 8. :r FILE : 读取文件到当前行后
> 9. :5 r FILE : 读取文件到第 5 行后

## 实例
### 测试数据
```bash
[root@localhost ~]# cp /etc/man.config .
```
### 实验需求
```bash
01. 设置显示行号
02. 移动到 58 行, 然后在向右移动 40 个字符,看到的双引号中的内容
03. 移动到第一行, 然后向下查找 bzip2 它在第几行
04. 将 50 - 100 行中 man 变为 MAN 并且让用户确认是否修改
05. 修改完成后, 突然不想修改了, 有哪些方法
06. 复制 65 -73 行内容并粘贴在最后一行之后
07. 删除 21 -42 行
08. 将文件另存为 man.test.config
09. 到 27 行删除 15 个字符, 第一个字符是什么
10. 跑到第一行, 在第一行的上面写上一行文字, 'gkdaxue'
```

### 参考答案
```bash
01. :set nu
02. 50G ; 40 + 空格 , 内容为 /dir/bin/foo
03. gg ; /bzip2 在 137 行
04. :50,100s/man/MAN/gc
05. 可以一直按 u 返回初始状态 或者 直接 :q! 在重新打开
06. 65G ; 7yy ; G ; p 
07. 21G ; 22dd 
08. :w man.test.config
09. 27G ; 15x ; 结果为小写字母 o
10. gg ; O ; 输入 gkdaxue 即可 ; 按 esc
```

## Vim 的保存文件
当我们使用 vim 编辑文件时, vim 会在被编辑的文件目录下新建一个叫做 .FILE_NAME.swp 的缓存文件用来记录用户对本文件进行到了什么操作, 当出现意外情况时, 可以根据此文件来进行救援的功能. **没有意外情况此文件在操作完源文件后会被删除**.
> vim 的工作被不正常中断时, 导致缓存文件不能通过正常流程被删除, 所以就不会消失而是保存了下来.

```bash
## 第一个终端 进入 vim 界面后, 然后在第一行之上添加一行文字, gkdaxue , 然后在打开一个新的终端
[root@localhost ~]# vim man.config


## 第二个终端 然后我们退出此终端, 在重新打开终端, 会发现和之前进入的不太一样.
[root@localhost ~]# ll -a
total 48
drwxr-xr-x.  2 root root 12288 Mar 15 07:11 .
dr-xr-xr-x. 30 root root  4096 Mar 12 10:26 ..
-rw-------.  1 root root   248 Mar 15 07:05 .bash_history
-rw-r--r--.  1 root root    18 Mar 15 07:03 .bash_logout
-rw-r--r--.  1 root root   176 Mar 15 07:03 .bash_profile
-rw-r--r--.  1 root root   124 Mar 15 07:03 .bashrc
-rw-r--r--.  1 root root  4940 Mar 15 07:11 man.config
-rw-r--r--.  1 root root  4096 Mar 15 07:11 .man.config.swp   <== 非正常操作, 此文件保留
-rw-------.  1 root root   623 Mar 15 07:11 .viminfo
[root@localhost ~]# vim man.config 
E325: ATTENTION    <== 错误代码
Found a swap file by the name ".man.config.swp"                <== 提示有一个 swap 文件
          owned by: root   dated: Fri Mar 15 07:14:36 2019
         file name: ~root/man.config                           <== 缓存文件属于哪个文件
          modified: YES
         user name: root   host name: localhost.localdomain
        process ID: 23740
While opening file "man.config"
             dated: Fri Mar 15 07:11:04 2019
可能发生错误的原因以及处理方案
(1) Another program may be editing the same file.  If this is the case,
    be careful not to end up with two different instances of the same
    file when making changes.  Quit, or continue with caution.

(2) An edit session for this file crashed.
    If this is the case, use ":recover" or "vim -r man.config"
    to recover the changes (see ":help recovery").
    If you did this already, delete the swap file ".man.config.swp"
    to avoid this message.

Swap file ".man.config.swp" already exists!
[O]pen Read-Only, (E)dit anyway, (R)ecover, (D)elete it, (Q)uit, (A)bort:    <== 在此处等待我们输入

[O]pen Read-Only : 以只读方式打开此文件
(E)dit anyway    : 正常的方式打开此文件, 不载入缓存文件内容(打开的为文件内容)
(R)ecover        : 加载缓存文件的内容, 用来继续之前非正常中断的工作
(D)elete it      : 删除缓存文件
(Q)uit           : 离开 vim , 不进行任何操作
(A)bort          : 忽略这个编辑行为

## 接下里我们输入 D ,也就是删除缓存文件, 会发现我们之前编辑的 gkdaxue 文字没有了. 一切都正常了
```

> 当你使用 R 命令也就是加载缓存文件的内容时, 即使你正常操作完成退出后, 此缓存文件也不会消失并且你每次打开源文件还是有提示, 所以确定此缓存文件没用时, 可以手动删除此文件就不会在出现此提示工作.

## Vim 的功能
### 块选择(Visual Block)
**如果我们想使用块选择的功能, 那么我们必须要回到命令模式下才可以使用块选择的功能.**

```bash
## 实验文件 根据 man.config 而来, 自己利用 vim 来制作这么一个文件
[root@localhost ~]# cat man.config 
MANPATH_MAP	/bin			    /usr/share/man
MANPATH_MAP	/sbin			    /usr/share/man
MANPATH_MAP	/usr/bin		    /usr/share/man
MANPATH_MAP	/usr/sbin		    /usr/share/man
MANPATH_MAP	/usr/X11R6/bin		/usr/X11R6/man
MANPATH_MAP	/usr/bin/X11		/usr/X11R6/man
MANPATH_MAP	/usr/bin/mh		    /usr/share/man
```

| 选项 | 作用 |
| ----- | ----- |
| v | 字符选择, 会将光标经过的地方反白选择 |
| V | 行选择, 会将光标经过的行反白选择 |
| Ctrl + v | 块选择, 可以用长方形的方式选择数据 |
| y | 复制反白的地方 |
| d | 删除反白的地方 |

#### 实例
```
## 我们按下 v 时, 显示如下
-- VISUAL --               <== 说明是字符选择

## 我们按下 V 是, 显示如下
-- VISUAL LINE --          <== 说明是行选择

## 我们按下 ctrl + v 时, 显示如下
-- VISUAL BLOCK --         <== 块选择的功能


## 我们现在的任务, 复制 1 -3 行的 MANPATH_MAP 放到对应行的后面
## 我们分析复制的是每行的前一部分, 所以需要使用块功能
[root@localhost ~]# vim man.config
按下 Ctrl + v ,最后一行显示如下 
-- VISUAL BLOCK --, 然后选中 1 -3 行的 MANPATH_MAP, 按下 y 键 然后按 $ 键 在按 p 键即可.

## 然后我们再把文件另存问 man_test.txt, 为下节内容做铺垫, 然后此文件不保存, 强制退出.
:w man_test.txt
:q!
```
![visual_block](https://github.com/gkdaxue/linux/raw/master/image/chapter_A6_0003_visual_block.gif)

### 多文件编辑
如果我们想办 man.config 文件的前三行粘贴到 man_test.txt 文件中, 那么我们应该怎么操作呢? 这个时候就要用到我们所说的多文件编辑功能

| 按键 | 作用 |
| ---- | ---- |
| :n | 编辑下一个文件 |
| :N | 编辑上一个文件 |
| :files | 列出目前这个 vim 打开的所有文件 |

#### 实例
```bash
[root@localhost ~]# vim man.config  man_test.txt 

## 查看一下打开了多少文件
:files
  1 %a   "man.config"                   line 1
  2 #    "man_test.txt"                 line 1

先回到 man.config 文件, 按 V 键使用行选择功能, 然后 y 复制, 
然后 :n 进入到下一个文件 man_test.txt 按 G 然后 按 p 即可.
```

### 多窗口功能
如果两个文件我们需要对比来比较其中的差异, 难道我们还需要来回跑到每个文件中来对比吗, 当然不需要.
```bash
[root@localhost ~]# vim man.config
MANPATH_MAP     /bin                    /usr/share/man
MANPATH_MAP     /sbin                   /usr/share/man
MANPATH_MAP     /usr/bin                /usr/share/man
MANPATH_MAP     /usr/sbin               /usr/share/man
MANPATH_MAP     /usr/X11R6/bin          /usr/X11R6/man
MANPATH_MAP     /usr/bin/X11            /usr/X11R6/man
MANPATH_MAP     /usr/bin/mh             /usr/share/man
~                                                                           
~                                                                           
"man.config" 7L, 268C                                     1,1           All

## 然后执行 :sp man_test.txt
:sp man_test.txt

## 变成了如下所示 
MANPATH_MAP	/bin			    /usr/share/manMANPATH_MAP
MANPATH_MAP	/sbin			    /usr/share/manMANPATH_MAP
MANPATH_MAP	/usr/bin		    /usr/share/manMANPATH_MAP
MANPATH_MAP	/usr/sbin		    /usr/share/man
MANPATH_MAP	/usr/X11R6/bin		/usr/X11R6/man
MANPATH_MAP	/usr/bin/X11		/usr/X11R6/man
MANPATH_MAP	/usr/bin/mh		    /usr/share/man
MANPATH_MAP	/bin			    /usr/share/man
MANPATH_MAP	/sbin			    /usr/share/man
MANPATH_MAP	/usr/bin		    /usr/share/man
~
~
~
man_test.txt                                              8,1            All
MANPATH_MAP     /bin                    /usr/share/man
MANPATH_MAP     /sbin                   /usr/share/man
MANPATH_MAP     /usr/bin                /usr/share/man
MANPATH_MAP     /usr/sbin               /usr/share/man
MANPATH_MAP     /usr/X11R6/bin          /usr/X11R6/man
MANPATH_MAP     /usr/bin/X11            /usr/X11R6/man
MANPATH_MAP     /usr/bin/mh             /usr/share/man
~
~
~                                                                                      
man.config                                             1,1            All
"man_test.txt" 10L, 407C
```

| 选项 | 作用 |
| ---- | ---- |
| :sp [FILE_ANME] | FILE_NAME 可以省略, 如果省略表示两个窗口为同一个文件的内容 |
| ctrl + w 然后在按 j | 跳转到下面一个窗口 |
| ctrl + w 然后再按 k | 跳转到上面一个窗口 |
| :q | 退出当前窗口 |

## Vim 环境设置(\~/.vimrc)和记录文件(\~/.viminfo)
当我们编辑完一个文件后正常退出, 当我们第二次进入的时候发现光标还是停留在了我们上次修改完成后退出的地方. 这是因为 Vim 会主动将我们做过的行为记录下俩, 这个记录被保存在 ~/.viminfo 文件中.
如果我们想要我们每次查看不同文件都显示文件的行号, 难道每次都要先执行 :set nu 来操作吗, 当然不是这就需要用到我们所说的 vim 环境配置文件 ~/.vimrc, 我们可以在里面配置选项, 这样我们使用 vim 来查看文件就会使用 ~/.vimrc 的配置选项

| 选项 | 作用 |
| ---- | ---- |
| :set nu | 显示行号 |
| :set nonu | 不显示行号 |

# 正则表达式
正则表达式(Regular Expression)是通过一些特殊的字符排列, 用于查找 替换 删除一行或者多行文字字符串. 是一种字符串处理的标准依据. 它 **以行为单位** 来进行字符串的处理行为. 比如 vim, grep, awk, sed 等都支持正则表达式. 正则表达式 和 bash 的 globing 是两种不同的东西.

> 正则表达式的字符串表示方式可以依照不同的严谨度分为 ` 基础正则表达式 ` 和 ` 扩展正则表达式 ` 

## 基础正则表达式
既然正则表达式是处理字符串的一种方式, 那么语序肯定会到结果有影响, 所以就会造成数据选取结果的区别. 比如 
> LANG=C : 0 - 9 A - Z a -z 这种编码顺序
>  
> LANG=zh_CN : 0 - 9 a A b B c C .... z Z 这种编码顺序.

所以使用正则表达式时, 一定要特别注意语序的区别, 否则可能会造成结果的不同. 所以**我们所有的实验结果都是基于 LANG=C 来进行的**.

还记得我们之前在介绍 globing 时讲的一些特殊符号(专用字符集合), 我们在这里先复习一下.

| 字符 | 含义 |
| --- | ----- |
| \[\:alnum\:\] | 任意数字或字母 ( a-z A-Z 0-9 )               |
| \[\:alpha\:\] | 任意大小写字母  ( a-z A-Z )                   |
| \[\:digit\:\] | 任意数字, 相当于 0-9, 注意是 0-9 而不是 \[0-9\] |
| \[\:lower\:\] | 任意小写字母  a-z                        |
| \[\:upper\:\] | 任意大写字母  A-Z                        |
| \[\:space\:\] | 空格                                 |
| \[\:punct\:\] | 标点符号                               |
| \[\:blank\:\] | 空格键 和 tab键                        |

### 实验环境
```bash
## 实验准备工作
## 1. export LANG=C   避免语系的影响
## 2. alias grep='grep --color=auto ' 
## 3. 安装了 unix2dos 和  dos2unix
## 4. 实验文件 https://github.com/gkdaxue/linux/raw/master/tutorial_document/regular_express.txt
## 5. 转换为 dos 格式
[root@localhost ~]# export LANG=C
[root@localhost ~]# alias grep='grep --color=auto '
[root@localhost ~]# yum install -y unix2dos  dos2unix wget
[root@localhost ~]# wget https://github.com/gkdaxue/linux/raw/master/tutorial_document/regular_express.txt
[root@localhost ~]# file regular_express.txt 
regular_express.txt: ASCII English text
[root@localhost ~]# unix2dos regular_express.txt 
unix2dos: converting file regular_express.txt to DOS format ...
[root@localhost ~]# file regular_express.txt 
regular_express.txt: ASCII English text, with CRLF line terminators
```

### grep常规用法
```
## 从文件中找到 the 字符并显示行号
[root@localhost ~]# grep -n 'the' regular_express.txt 
8:I can't finish the test.
12:the symbol '*' is represented as start.
15:You are the best is mean you are the no. 1.
16:The world <Happy> is the same with "glad".
18:google is the best tools for search keyword.

## 从文件中找到 the 字符(不区分大小写)并显示行号
[root@localhost ~]# grep -in 'the' regular_express.txt 
8:I can't finish the test.
9:Oh! The soup taste good.                               <== 大写的 The 也被找了出来
12:the symbol '*' is represented as start.
14:The gd software is a library for drafting programs.   <== 大写的 The 也被找了出来
15:You are the best is mean you are the no. 1.
16:The world <Happy> is the same with "glad".
18:google is the best tools for search keyword.

## 如果想要查找没有 the 字符的行并显示行号, 则使用如下所示
[root@localhost ~]# grep -vn 'the' regular_express.txt 
1:"Open Source" is a good mechanism to develop programs.
2:apple is my favorite food.
3:Football game is not use feet only.
4:this dress doesn't fit me.
5:However, this dress is about $ 3183 dollars.
6:GNU is free air not free beer.
7:Her hair is very beauty.
9:Oh! The soup taste good.
10:motorcycle is cheap than car.
11:This window is clear.
13:Oh!	My god!
14:The gd software is a library for drafting programs.
17:I like dog.
19:goooooogle yes!
20:go! go! Let's go.
21:# I am VBird
22: 
```

### 利用 \[ ] 来查找字符集合
**[ ] 里面不论有多少字符, 它都只代表 '一个' 字符**

```
## 现在查找 test 和 tast 字符出现的位置
[root@localhost ~]# grep -n 't[ae]st' regular_express.txt 
8:I can't finish the test.
9:Oh! The soup taste good.


## 利用 [^] 反选来查找字符
## 如果我们想要查找 'oo' 字符时
[root@localhost ~]# grep -n 'oo' regular_express.txt 
1:"Open Source" is a good mechanism to develop programs.
2:apple is my favorite food.
3:Football game is not use feet only.
9:Oh! The soup taste good.
18:google is the best tools for search keyword.
19:goooooogle yes!

## oo 的前边不能有 g 的存在
[root@localhost ~]# grep -n '[^g]oo' regular_express.txt 
2:apple is my favorite food.
3:Football game is not use feet only.
18:google is the best tools for search keyword.      <== 此行虽然有 google不符合但是 tools 符合, 所以显示
19:goooooogle yes!

## oo 前边不能有小写字符 , - 表示连续编码 比如 a-z  A-Z  0-9 等
[root@localhost ~]# grep -n '[^a-z]oo' regular_express.txt 
3:Football game is not use feet only.
## 还有如下实现方式
[root@localhost ~]# grep -n '[^[:lower:]]oo' regular_express.txt 
3:Football game is not use feet only.
```

### 行首 ^ 与 行尾 $ 字符
```
## ^ 注意放在 [] 中 和 放在 [] 之外的含义不同, 自己体会总结
## 查询含有 the 字符的行并显示行号
[root@localhost ~]# grep -n 'the' regular_express.txt 
8:I can't finish the test.
12:the symbol '*' is represented as start.
15:You are the best is mean you are the no. 1.
16:The world <Happy> is the same with "glad".
18:google is the best tools for search keyword.

## 查找以 the 开头的行并显示行号
[root@localhost ~]# grep -n '^the' regular_express.txt 
12:the symbol '*' is represented as start.

## 以小写字符开头的行并显示行号
[root@localhost ~]# grep -n '^[a-z]' regular_express.txt 
2:apple is my favorite food.
4:this dress doesn't fit me.
10:motorcycle is cheap than car.
12:the symbol '*' is represented as start.
18:google is the best tools for search keyword.
19:goooooogle yes!
20:go! go! Let's go.

## 不想要开头是英文字母(无论大小写)并显示行号
[root@localhost ~]# grep -n '^[^a-zA-Z]' regular_express.txt 
1:"Open Source" is a good mechanism to develop programs.
21:# I am VBird
```

### 任意一个字符 . 和重复字符 *
```
## 以 . 结尾的行并显示行号, . 有特殊意义,所以需要使用 \ 来转义 稍后讲解
## 那么执行一下命令为啥找不到匹配的数据呢? 因为我们这个文件是从 unix -> dos 所以不是以 . 结尾的
## Linux 下仅有 LF($) 断行符号, DOS 下则是 (^M$) 断行符号, 导致不能正确识别
## 所有有的时候查找不到数据一定要仔细想一下原因
[root@localhost ~]# grep -n '\.$' regular_express.txt 
[root@localhost ~]# file regular_express.txt
regular_express.txt: ASCII English text, with CRLF line terminators
[root@localhost ~]# cat -A regular_express.txt | head -n 5
"Open Source" is a good mechanism to develop programs.^M$ 
apple is my favorite food.^M$
Football game is not use feet only.^M$
this dress doesn't fit me.^M$
However, this dress is about $ 3183 dollars.^M$
[root@localhost ~]# cp regular_express.txt regular_express.txt.unix
[root@localhost ~]# dos2unix regular_express.txt.unix 
dos2unix: converting file regular_express.txt.unix to UNIX format ...
## 转化为 unix 可以成功的找到匹配数据
[root@localhost ~]# grep -n '\.$' regular_express.txt.unix 
1:"Open Source" is a good mechanism to develop programs.
2:apple is my favorite food.
3:Football game is not use feet only.
4:this dress doesn't fit me.
5:However, this dress is about $ 3183 dollars.
6:GNU is free air not free beer.
7:Her hair is very beauty.
8:I can't finish the test.
9:Oh! The soup taste good.
10:motorcycle is cheap than car.
11:This window is clear.
12:the symbol '*' is represented as start.
14:The gd software is a library for drafting programs.
15:You are the best is mean you are the no. 1.
16:The world <Happy> is the same with "glad".
17:I like dog.
18:google is the best tools for search keyword.
20:go! go! Let's go.
[root@localhost ~]# cat -A regular_express.txt.unix | head -n 5
"Open Source" is a good mechanism to develop programs.$ 
apple is my favorite food.$
Football game is not use feet only.$
this dress doesn't fit me.$
However, this dress is about $ 3183 dollars.$

## 在重复看一下两者的区别  ^$ 表示为空白行
[root@localhost ~]# grep -n '^$' regular_express.txt
[root@localhost ~]# grep -n '^$' regular_express.txt.unix 
22:


## 我们以前看 /etc/man.config 文件发现里面有很多以 # 开头的行, 如果我们只想看不以 # 开头的行应该怎么处理呢?
[root@localhost ~]# grep -vn '^#' /etc/man.config  | head -n 5
34:FHS
43:MANPATH	/usr/man
44:MANPATH	/usr/share/man
45:MANPATH	/usr/local/man
46:MANPATH	/usr/local/share/man


## 查找 以g开头 d结尾的四个字符
[root@localhost ~]# grep -n 'g..d' regular_express.txt
1:"Open Source" is a good mechanism to develop programs.
9:Oh! The soup taste good.
16:The world <Happy> is the same with "glad".

## 至少两个 o 以上的字符, 想一下为什么是 ooo*
[root@localhost ~]# grep -n 'ooo*' regular_express.txt
1:"Open Source" is a good mechanism to develop programs.
2:apple is my favorite food.
3:Football game is not use feet only.
9:Oh! The soup taste good.
18:google is the best tools for search keyword.
19:goooooogle yes!

## 字符开头和结尾都是 g 并且两个 g 之间至少存在一个 o
[root@localhost ~]# grep -n 'goo*g' regular_express.txt
18:google is the best tools for search keyword.
19:goooooogle yes!

## 字符开头和结尾都是 g 中间字符可有可无
[root@localhost ~]# grep -n 'g.*g' regular_express.txt
1:"Open Source" is a good mechanism to develop programs.
14:The gd software is a library for drafting programs.
18:google is the best tools for search keyword.
19:goooooogle yes!
20:go! go! Let's go.
```

### 限定范围的字符 {}
我们从上边可以知道, ` . ` 可以表示任意一个字符 * 可以表示字符出现 0次或多次, 但是我就想要字符出现指定的次数, 这个时候就要用到 {} 符号了, 但是 {} 和 bash 中的 {} 冲突了, 所以我们就要使用转义字符来转义才行.
> 请回忆一下 bash 中 {} 的作用是什么 ?

```bash
## 我想要匹配 /etc/passwd 中查找 o 字符出现 2 次的字符
[root@localhost ~]# grep -n 'o\{2\}' /etc/passwd
1:root:x:0:0:root:/root:/bin/bash
5:lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin
9:mail:x:8:12:mail:/var/spool/mail:/sbin/nologin
10:uucp:x:10:14:uucp:/var/spool/uucp:/sbin/nologin
11:operator:x:11:0:operator:/root:/sbin/nologin
29:postfix:x:89:89::/var/spool/postfix:/sbin/nologin

## 在 regular_express.txt 中 g 后边跟了 2-5个 o 的字符
[root@localhost ~]# grep -n 'go\{2,5\}' regular_express.txt
1:"Open Source" is a good mechanism to develop programs.
9:Oh! The soup taste good.
18:google is the best tools for search keyword.
19:goooooogle yes!

## 在 regular_express.txt 中 g 后边跟了 2-5个 0  然后在跟了一个 g 的字符
[root@localhost ~]# grep -n 'go\{2,5\}g' regular_express.txt
18:google is the best tools for search keyword.
```

### 总结
| RE字符 | 含义 |
| :-----: | ----- |
| ^word | 以 word 开头的行 |
| word$ | 以 word 结尾的行(注意文件类型 Unix or DOS) |
| . | 任意一个字符 |
| \ | 用来转义字符 |
| * | 前一个字符出现的次数为 0次或多次 |
| \[ list \] | 匹配 list 中的字符 (无论里面有多少个字符, 只匹配一个) |
| \[ n1-n2 \] | 匹配字符范围 |
| [ ^list ] | 不在 list(可能是字符集合或者字符范文) 中的字符 |
| \\\{n\\\} | 指定的字符出现 n 次 |
| \\\{n,m\\\} | 指定字符出现的次数为 n-m 次 |
| \\\{n,\\\} | 指定的字符出现的次数为 至少 n次 |

## 扩展正则表达式
grep 默认仅支持 ` 基础正则表达式 `, 如果想要使用扩展正则表达式, 可以使用 ` grep -E ` 选项, 不过还是建议使用 egrep 命令.

| RE 符号 | 含义 |
| :----: | :-----: |
| + | 前一个RE字符出现 1次或1次以上 |
| \? | 前一个RE字符出现 0次或1次 |
| \| | 用 or 的方式找出数个字符 |
| () | 找出 组 字符串 |
| ()+ | 多个重复组的判断 |

```bash
## 准备实验环境
[root@localhost ~]# alias egrep='egrep --color=auto'
[root@localhost ~]# rm -rf regular_express.txt
[root@localhost ~]# mv regular_express.txt.unix regular_express.txt
[root@localhost ~]# file regular_express.txt 
regular_express.txt: ASCII English text    <== 确保你的不是 DOS 换行符


## 去掉 空白行 和 以 # 开头的行(两种方式)
[root@localhost ~]# grep -v '^$' /etc/man.config | grep -v '^#'
FHS
MANPATH	/usr/man
MANPATH	/usr/share/man
MANPATH	/usr/local/man
MANPATH	/usr/local/share/man
...........
## 也可以使用 grep -Ev '^$|^#' /etc/man.config
[root@localhost ~]# egrep -v '^$|^#' /etc/man.config
FHS
MANPATH	/usr/man
MANPATH	/usr/share/man
MANPATH	/usr/local/man
MANPATH	/usr/local/share/man
...........

## 查找 以 g 开头 以 d 结尾 o 出现一次或以上
[root@localhost ~]# grep -n 'go\{1,\}d' regular_express.txt 
1:"Open Source" is a good mechanism to develop programs.
9:Oh! The soup taste good.
13:Oh!	My god!
[root@localhost ~]# egrep -n '\go+\d' regular_express.txt 
1:"Open Source" is a good mechanism to develop programs.
9:Oh! The soup taste good.
13:Oh!	My god!

## 查找 以 g 开头 以 d 结尾 o 出现 0 次或 1次
[root@localhost ~]# egrep -n 'go?d' regular_express.txt 
13:Oh!	My god!
14:The gd software is a library for drafting programs.

## 查找 gd good dog 出现的行数
[root@localhost ~]# egrep -n 'gd|good|dog' regular_express.txt 
1:"Open Source" is a good mechanism to develop programs.
9:Oh! The soup taste good.
14:The gd software is a library for drafting programs.
17:I like dog.

## 查找 glad 或者 good 出现的行数
[root@localhost ~]# egrep -n 'g(la|oo)d' regular_express.txt 
1:"Open Source" is a good mechanism to develop programs.
9:Oh! The soup taste good.
16:The world <Happy> is the same with "glad".
```

## 相关命令(sed awk)
### sed命令
sed是一种流编编器，它是文本处理中非常中的工具，能够完美的配合正则表达式便用, 可以实现对数据的替换  删除  新增  选特定行等功能. **在一般 sed 的用法中，所有来自 STDIN 的数据一般都会被显示到屏幕上.**
>   sed [ options ]  '动作'  [input-file]    

| 选项 | 作用 |
| ----- | ---- |
| -n  | 只有经过sed 特殊处理的那一行(或者动作)才会被列出来 |
| -e | 直接在指令列模式上进行 sed 的动作编辑 |
| -f FILE_NAME | 直接将 sed 的动作写到一个文件中 |
| -r | 支持扩展正则表达式 (默认仅支持基础正则表达式) |
| -i | 直接修改读取的文件内容，而不是由屏幕输出 (谨慎使用) |

**动作:**
> '[n1[,n2]]function' : 必须用单引号 ' ' 包起来
>
> n1, n2 不一定会存在, 一般代表选择进行动作的行数. 比如 '10,20[动作行为]' 

| function参数 | 含义 |
| :----: | ---- |
| a | 新增， a 的后面可以接字串，而这些字串会在新的一行出现(目前的下一行) |
| c | 取代， c 的后面可以接字串，这些字串可以取代 n1,n2 之间的行 |
| d | 删除， 因为是删除啊，所以 d 后面通常不接任何参数 |
| i | 插入， i 的后面可以接字串，而这些字串会在新的一行出现(目前的上一行) |
| p | 打印， 将选择的数据打印出来, 通常会和 sed -n 一起用 |
| s | 替换， 直接进行替换的工作 |

```bash
## 准备环境, 除了 -f 会影响到源文件, 其他操作不会影响到源文件
[root@localhost ~]# head -n 3 /etc/passwd > passwd 
[root@localhost ~]# cat passwd 
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin

## i 新增一行,在指定行之上添加
[root@localhost ~]# sed '2i gkdaxue test line' passwd
root:x:0:0:root:/root:/bin/bash
gkdaxue test line                   <== 多了此行 在指定行的上面添加
bin:x:1:1:bin:/bin:/sbin/nologin    <== 指定行
daemon:x:2:2:daemon:/sbin:/sbin/nologin
## 如果新增多行, 每一行必须要使用反斜杠 \ 来进行新行的添加
[root@localhost ~]# cat passwd | sed '2i test1 \
> test2 \
> test3 '
root:x:0:0:root:/root:/bin/bash
test1 
test2 
test3 
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin
[root@localhost ~]# cat passwd 
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin


## a : 新增一行 执行行的下面新增一行
[root@localhost ~]# sed '2a gkdaxue test line' passwd
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/bin:/sbin/nologin    <== 指定行
gkdaxue test line					<== 多了此行 在指定行的下面添加
daemon:x:2:2:daemon:/sbin:/sbin/nologin


## d : 删除指定的行, $ 表示最后一行的意思
[root@localhost ~]# sed '2,$d' passwd 
root:x:0:0:root:/root:/bin/bash


## i : 直接修改源文件内容  谨慎使用
[root@localhost ~]# sed -i '2i gkdaxue test1' passwd
[root@localhost ~]# sed -i '2a gkdaxue test2' passwd
[root@localhost ~]# cat passwd 
root:x:0:0:root:/root:/bin/bash
gkdaxue test1        <== 体会一下为什么会是这样的结果
gkdaxue test2        <== 体会一下为什么会是这样的结果
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin


## c : 整行的替换
[root@localhost ~]# sed '2,3c only 4 lines' passwd 
root:x:0:0:root:/root:/bin/bash
only 4 lines         <== 替换 2 3 行的内容为 only 4 lines
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin


## p : 打印的操作, 通常和 -n 连用
## 之前想获取文件的 10-20行, 就使用 head 和 tail 来操作, 使用 sed 更直接
[root@localhost ~]# cat -n /etc/passwd | sed  -n '10,20p'
    10	uucp:x:10:14:uucp:/var/spool/uucp:/sbin/nologin
    11	operator:x:11:0:operator:/root:/sbin/nologin
    12	games:x:12:100:games:/usr/games:/sbin/nologin
    13	gopher:x:13:30:gopher:/var/gopher:/sbin/nologin
    14	ftp:x:14:50:FTP User:/var/ftp:/sbin/nologin
    15	nobody:x:99:99:Nobody:/:/sbin/nologin
    16	dbus:x:81:81:System message bus:/:/sbin/nologin
    17	usbmuxd:x:113:113:usbmuxd user:/:/sbin/nologin
    18	rpc:x:32:32:Rpcbind Daemon:/var/lib/rpcbind:/sbin/nologin
    19	rtkit:x:499:499:RealtimeKit:/proc:/sbin/nologin
    20	avahi-autoipd:x:170:170:Avahi IPv4LL Stack:/var/lib/avahi-autoipd:/sbin/nologin


## s : 部分数据的替换工作
## 格式为 s/被替换的字符/新字符/g
[root@localhost ~]# sed '1,$s/bin/BIN/g' passwd
root:x:0:0:root:/root:/BIN/bash
gkdaxue test1
gkdaxue test2
BIN:x:1:1:BIN:/BIN:/sBIN/nologin
daemon:x:2:2:daemon:/sBIN:/sBIN/nologin
```

#### 实例
```bash
## 获取本机的 IP 地址, IP 地址为 192.168.1.206 我们如何获取
## ifconfig 查看启用的网卡信息, 以后讲解
[root@localhost ~]# ifconfig eth0
eth0      Link encap:Ethernet  HWaddr 00:0C:29:27:50:34  
          inet addr:192.168.1.206  Bcast:192.168.1.255  Mask:255.255.255.0
          inet6 addr: fe80::20c:29ff:fe27:5034/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:5493 errors:0 dropped:0 overruns:0 frame:0
          TX packets:2809 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:497815 (486.1 KiB)  TX bytes:310615 (303.3 KiB)
[root@localhost ~]# ifconfig eth0 | grep 'inet addr'
          inet addr:192.168.1.206  Bcast:192.168.1.255  Mask:255.255.255.0
[root@localhost ~]# ifconfig eth0 | grep 'inet addr' | sed 's/^.* inet addr://g'
192.168.1.206  Bcast:192.168.1.255  Mask:255.255.255.0
[root@localhost ~]# ifconfig eth0 | grep 'inet addr' | sed 's/^.* inet addr://g' | sed 's/  Bcast.*$//g'
192.168.1.206
```

### awk命令
sed 常常作用于一整行的处理, awk 则是比较倾向于讲一行分成多个字段来处理. 因此 awk 命令更适合处理小型的数据处理.



### diff命令









# shell script

| 符号 | 作用 |
| ---- | ---- |
| com1 && com2 | 若 cmd1 执行完毕且正确执行($?=0), 则开始执行 cmd2 <br> 若 cmd1 执行完毕且为错误($?≠0), 则 cmd2 不执行 |
| com1 \|\| com2 | 若 cmd1 执行完毕且正确执行($?=0), 则不执行 cmd2 <br> 若 cmd1 执行完毕且为错误($?≠0), 则执行 cmd2  |

```bash
## linux 的命令是从左往右执行的.
## 没有 /tmp/abc, 所以没有执行 && 后边的操作
[root@localhost ~]# ls /tmp/abc && touch /tmp/abc/gkdaxue
ls: cannot access /tmp/abc: No such file or directory   <== 因为没有这个目录, 所以没有执行创建文件的操作
[root@localhost ~]# mkdir /tmp/abc
[root@localhost ~]# ls /tmp/abc && touch /tmp/abc/gkdaxue
[root@localhost ~]# ls /tmp/abc
gkdaxue


## 然后测试 ||
[root@localhost ~]# rm -rf /tmp/abc/
[root@localhost ~]# ls /tmp/abc || mkdir /tmp/abc
ls: cannot access /tmp/abc: No such file or directory   <== 虽然报错了, 但是已经成功创建了 abc 文件夹
[root@localhost ~]# ll /tmp/abc
total 0
```
**练习题:**
ls 判断 /tmp/gkdaxue 文件夹是否存在, 存在输出 'exists' 否则输出 'not exists'
```bash
ls /tmp/gkdaxue && echo 'exists' || echo 'not exists'

假设我们不小心写成了如下所示, 会有什么影响 ?
ls /tmp/gkdaxue || echo 'not exists' && echo 'exists'
1. 当/tmp/gkdaxue 不存在, 则 $? != 0
2. 那么执行 echo 'exists' 则 $? = 0
3. 又执行了 echo 'exists'

## 如果判断式有三个, 那么 && 与 || 的顺序通常如下所示, 一定如下所示:
command1 && command2 || command3
```

