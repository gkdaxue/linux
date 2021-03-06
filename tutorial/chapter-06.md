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
> vim [options] FILE_NAME

| 选项 | 作用 |
| :----: | ---- |
| +   | 打开文件并定位到最后一行 |
| +NUM | 打开文件并定位到 NUM 行 |
| +/PATTERN | 打开文件并定位到第一次被 PATTERN 匹配到的行的行首 |

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
| w | 移动到下一个单词的词首 |
| b | 移动到当前或前一个单词的词首 |
| e | 移动到当前或下一个单词的词尾 |
| <br> | 也可以和数字连用, 如 3w |
| ctrl + f \| Page Down | 屏幕向下移动一页 |
| ctrl + b \| Page Up | 屏幕向上移动一页 |
| ctrl + d | 屏幕向下移动半页 |
| ctrl + u | 屏幕向上移动半页 |
| Num + 空格 | 比如 30 + 空格, 表示向右移动30个字符 |
| H | 光标移动到此屏幕上第一行的第一个字符 |
| M | 光标移动到此屏幕中央那一行的第一个字符 |
| L | 光标移动到此屏幕上最后一行的第一个字符 |
| 0 \| Home键 | 移动到此行的第一个字符上(绝对行首) |
| ^ | 行首的第一个非空白字符 |
| $ \| End键 | 移动到此行的最后一个字符上(绝对行尾) |
| gg | 跳转到此文件的第一行 |
| G | 移动到此文件的最后一行 |
| NumG | 如20G, 表示跳转到 20 行 |
| Num + 回车 | 如 10 + 回车, 表示光标向下移动 10 行 |
| x | 向后删除一个字符 |
| X | 向前删除一个字符 |
| Numx| 向后删除 Num 个字符 |
| c0 \| c$ | 删除光标所在位置到 行首/行尾 内容并进入输入模式 |
| cc | 删除光标所在行并进入输入模式 |
| Numcc | 删除 Num 行并进入输入模式 |
| dd | 删除光标所在的一整行(删除之后下行会上移) |
| D | 删除光标所在行 (下行不上移, 此行显示为空白) |
| Numdd | 删除光标所在的向下 Num 行,如 20dd |
| d0 \| d$ | 删除光标所在位置到 行首/行尾 的内容 |
| d1G | 删除光标所在行到第一行的所有内容 |
| dG | 删除光标所在行到最后一行的所有内容 |
| d0 | 数字0, 表示删除光标所在位置到该行行首所有字符 |
| d$ \| shift + d | 表示删除光标所在位置到该行行尾所有字符 |
| y0 \| y$ | 复制光标所在位置到 行首/行尾 的内容 |
| yy | 复制光标所在的行 |
| Numyy | 复制光标所在的向下 Num 行, 如 20yy |
| y1G | 复制光标所在行到第一行的所有数据 |
| yG | 复制光标所在行到最后一样的所有数据 |
| y0 | 复制光标所在位置到该行行首的所有数据 | 
| y$ | 复制光标所在位置到该行行尾的所有数据 |
| p(小写) | 将复制的数据粘贴在 **光标的下一行(复制或删除整行)或光标所在字符的后面(复制或删非整行)** |
| P(大写) | 将复制的数据粘贴在 **光标的上一行(复制或删除整行)或光标所在字符的前面(复制或删非整行)** |
| u | 还原上一步的操作 |
| Numu | 还原最近 Num 次操作 |
| ctrl + r | 撤销最近一次撤销 |
| . | 重复前一个操作 |
| ZZ | 保存并退出 |

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
| **.** | 表示当前行 |
| $ | 表示最后一行 |
| +Num | 向下的 Num 行 |
| **:.,+Numd** | 删除从当前行以及往下 Num 行, 比如 :.,+5d 删除 从当前行和下 5 行, 共删除 6行 |
| :Line1,Line2d | 删除 Line1-Line2 行, 如 :10,20d 删除 10-20 行 |
| :Line1,Line2s/word1/word2/ | 从 Line1 到 Line2 行第一个 word1 字符替换为 word2 |
| :Line1,Line2s/word1/word2/i | 从 Line1 到 Line2 行第一个 word1 字符替换为 word2 并忽略大小写 |
| :Line1,Line2s/word1/word2/g | 将 Line1 到 Line2 行中所有的 word1 字符 替换为 word2 |
| :Line1,Line2s/word1/word2/gc | 将 Line1 到 Line2 行中所有的 word1 字符 替换为 word2 且在替换前给用户确认是否替换 |
| :1,$s/word1/word2/g | 将全文中的 word1 替换为 word2 |
| :%s/word1/word2/g | 将全文中的 word1 替换为 word2 |
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
| :NUM | 跳转到第 NUM 行 |
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
| :n | 切换到下一个文件 |
| :N | 切换到上一个文件 |
| :files | 列出目前这个 vim 打开的所有文件 |
| :first | 切换到第一个文件 |
| :last | 切换到最后一个文件 |
| :qa | 退出所有文件 |

#### 实例
```bash
[root@localhost ~]# vim man.config  man_test.txt 

## 查看一下打开了多少文件
:files
  1 %a   "man.config"                   line 1
  2 #    "man_test.txt"                 line 1

%a : 表示为 active, 当前正在打开的文件
#  : 上一个打开的文件

先回到 man.config 文件, 按 V 键使用行选择功能, 然后 y 复制, 
然后 :n 进入到下一个文件 man_test.txt 按 G 然后 按 p 即可.
```

### 多窗口功能
如果两个文件我们需要对比来比较其中的差异, 难道我们还需要来回跑到每个文件中来对比吗, 当然不需要.
> vim -o File1 ... : 水平显示多个窗口
> 
> vim -O File1 ... : 垂直显示多个窗口

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
| ctrl + w 然后再按 s | 水平拆分窗口(直接拆分原文件) |
| ctrl + w 然后再按 k | 跳转到上面一个窗口 |
| ctrl + w 然后在按 j | 跳转到下面一个窗口 |
| ctrl + w 然后在按 v | 垂直拆分窗口(直接差分原文件) |
| ctrl + w 然后再按 h | 跳转到左边窗口 |
| ctrl + w 然后再按 l(小写L) | 跳转到右边窗口 |
| :q | 退出当前窗口 |
| :qa | 退出所有窗口 |

## Vim 环境设置(\~/.vimrc)和记录文件(\~/.viminfo)
当我们编辑完一个文件后正常退出, 当我们第二次进入的时候发现光标还是停留在了我们上次修改完成后退出的地方. 这是因为 Vim 会主动将我们做过的行为记录下俩, 这个记录被保存在 ~/.viminfo 文件中.
如果我们想要我们每次查看不同文件都显示文件的行号, 难道每次都要先执行 :set nu 来操作吗, 当然不是这就需要用到我们所说的 vim 环境配置文件 ~/.vimrc, 我们可以在里面配置选项, 这样我们使用 vim 来查看文件就会使用 ~/.vimrc 的配置选项

| 选项 | 作用 |
| ---- | ---- |
| :set nu | 显示行号 |
| :set nonu | 不显示行号 |

## 实践出真知
### 修改主机名
```bash
## 我想修改我的主机名为 test.gkdaxue.com, 然后我们来实际操作一下
[root@localhost ~]# hostname
localhost.localdomain
## 查看当期的 etho 的 ip 地址
[root@localhost ~]# ifconfig eth0
eth0      Link encap:Ethernet  HWaddr 00:0C:29:27:50:34  
          inet addr:192.168.1.206  Bcast:192.168.1.255  Mask:255.255.255.0
          inet6 addr: fe80::20c:29ff:fe27:5034/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:55034 errors:0 dropped:0 overruns:0 frame:0
          TX packets:16050 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:31345487 (29.8 MiB)  TX bytes:1373488 (1.3 MiB)

## 编辑主机配置文件  /etc/sysconfig/network
[root@localhost ~]# vim /etc/sysconfig/network
NETWORKING=yes
HOSTNAME=test.gkdaxue.com       <== 修改为如下所示
[root@localhost ~]# echo '192.168.1.206   test.gkdaxue.com'  >> /etc/hosts

## 测试一下
[root@localhost ~]# ping -c 2 test.gkdaxue.com
PING test.gkdaxue.com (192.168.1.206) 56(84) bytes of data.
64 bytes from test.gkdaxue.com (192.168.1.206): icmp_seq=1 ttl=64 time=0.033 ms
64 bytes from test.gkdaxue.com (192.168.1.206): icmp_seq=2 ttl=64 time=0.031 ms

--- test.gkdaxue.com ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1007ms
rtt min/avg/max/mdev = 0.031/0.032/0.033/0.001 ms

## 最好的方式就是重启一下
[root@localhost ~]# reboot

## 重启完成后, 查看主机名已经变为  test.gkdaxue.com
[root@test ~]# hostname
test.gkdaxue.com
```

### 配置网卡信息
如果我这一台主机想要上网, 那么我们就必须为其设置合理的网络参数, 比如 IP/NETMASK/GATEWAY/DNS 等信息
```bash
我们先了解以下知识点 :
1. 网卡配置文存放在 /etc/sysconfig/network-scripts/ 目录下
2. CentOS6 : 网卡命名为 ifcfg-eth0, ifcfg-eth1 等等
3. CentOS7 : 网卡命名为 ifcfg-enoxxxxxxxx 其中 xxxxxxxx 表示为数字, 例如 ifcfg-eno16777736


## 因为我们当前系统为 CentOS6 , 所以自然我们的配置文件名为 ifcfg-eth0
## 以下 IP 信息应该根据自己的事情情况来设置.
[root@test ~]# vim /etc/sysconfig/network-scripts/ifcfg-eth0
DEVICE=eth0                  <== 设备文件名
HWADDR="00:0C:29:27:50:34"   <== 网卡 MAC 地址
TYPE=Ethernet                <== 网络的类型
ONBOOT=yes                   <== 开机是否启动 yes/no, 应设置为 yes 
BOOTPROTO=static             <== 获取 IP 的方式 static/dhcp
IPADDR=192.168.1.206         <== IP 地址
NETMASK=255.255.255.0        <== 子网掩码
GATEWAY=192.168.1.1          <== 网关
DNS1=192.168.1.1             <== DNS


## 设置完后, 我们可以重启我们的网络服务, 有两种方式
1. 重启所有的网卡  /etc/init.d/network restart
2. 重启特定的网卡  ifconfig eth0 down ; ifconfig eth0 up

## 重启完成后, 查看网卡的配置信息是否正确
[root@test ~]# /etc/init.d/network restart
```

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

### 词首 \< 和 词尾 \>
> **以一个字符开始 以一个字符结尾 中间只要不出现特殊字符 就认为是一个单词. 比如 ro88t.**

```bash
## 准备实验文件 word_test.txt
[root@localhost ~]# vim word_test.txt 
This is root user.
This is root.
The users is mroot.
rooter is cat name.
chroot is a command.
mrooter is not a word.

## root 出现在结尾
[root@localhost ~]# grep 'root\>' word_test.txt 
This is root user.
This is root.
The users is mroot.
chroot is a command.
[root@localhost ~]# grep 'root' word_test.txt 
This is root user.
This is root.
The users is mroot.
rooter is cat name.        <== 此行没有, 没有以 root 结尾
chroot is a command.
mrooter is not a word.	   <== 此行没有, 没有以 root 结尾

## root 出现在词首
[root@localhost ~]# grep '\<root' word_test.txt 
This is root user.
This is root.
rooter is cat name.

## 只想匹配 root 这个单词, 自行比较一下.
[root@localhost ~]# grep '\<root\>' word_test.txt 
This is root user.
This is root.
[root@localhost ~]# grep 'root' word_test.txt 
This is root user.
This is root.
The users is mroot.
rooter is cat name.
chroot is a command.
mrooter is not a word.
```

### 总结
| RE字符 | 含义 |
| :-----: | ----- |
| ^word | 以 word 开头的行 |
| word$ | 以 word 结尾的行(注意文件类型 Unix or DOS) |
| ^$ | 空白行 |
| . | 任意一个字符 |
| \ | 用来转义字符 |
| * | 前一个字符出现的次数为 0次或多次 |
| \\? | 前一个RE字符出现 0次或1次 |
| \\+ | 前一个RE字符出现至少 1 次 |
| \[ list \] | 匹配 list 中的字符 (无论里面有多少个字符, 只匹配一个) |
| \[ n1-n2 \] | 匹配字符范围 |
| [ ^list ] | 不在 list(可能是字符集合或者字符范文) 中的字符 |
| \\( \\) | 找出 组 字符串 或 后向引用 |
| \\\{n\\\} | 指定的字符出现 n 次 |
| \\\{n,m\\\} | 指定字符出现的次数为 n-m 次 |
| \\\{n,\\\} | 指定的字符出现的次数为 至少 n次 |
| \\< 或 \\b | 锚定词首, 其后面的任意字符必须作为单词首部出现 (词首) |
| \\> 或 \\b | 锚定词尾, 其前边的任意字符必须作为单词尾部出现 (词尾)|

## 扩展正则表达式
grep 默认仅支持 ` 基础正则表达式 `, 如果想要使用扩展正则表达式, 可以使用 ` grep -E ` 选项, 不过还是建议使用 egrep 命令.
> **grep -E = egrep**

| RE 符号 | 含义 |
| :----: | :-----: |
| + | 前一个RE字符出现 1次或1次以上 |
| ? | 前一个RE字符出现 0次或1次 |
| {m,n} | 匹配次数, 同基本正则表达式 不需要转义 |
| \| | 用 or 的方式找出数个字符 |
| ( ) | 找出 组 字符串 或 后向引用 不需要转义|
| ( )+ | 多个重复组的判断 |

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

### ()的后向引用
> \1 : 引用第一个括号中匹配到的内容, 然后还有 \2  \3 等等.
>
> & : 直接引用查找模式匹配到的字符串(Vim中使用较多)
```bash
## 我想要匹配前边为 l 开头 e 结尾中间两个字符, 然后后边为 前一个匹配到的字符后边加上r
## 如前边匹配到 love, 那么后边就要求是 lover, 即使满足 (l 开头 e 结尾中间两个字符) 也不行
[root@localhost ~]# vim test3.txt
He love his lover.
She like her lover.
He like his liker.
She love her liker.
[root@localhost ~]# grep 'l..e' test3.txt 
He love his lover.
She like her lover.
He like his liker.
She love her liker.
## 使用这种方式, 匹配的会有问题
[root@localhost ~]# grep 'l..e.*l..e' test3.txt 
He love his lover.
She like her lover.
He like his liker.
She love her liker.
## 前后要求匹配一致的
[root@localhost ~]# grep '\(l..e\).*\1' test3.txt
He love his lover.
He like his liker.
## 前后匹配一致并且加上 r 的
[root@localhost ~]# grep '\(l..e\).*\1r' test3.txt
He love his lover.
He like his liker.

## 行中存在一个数字且必须以该数字结尾的行
[root@localhost ~]# grep '\([0-9]\).*\1$' /etc/inittab 
#   5 - X11
```

## 相关命令(sed awk)
### sed命令
sed是一种流编编器，它是文本处理中非常中的工具，能够完美的配合正则表达式便用, 可以实现对数据的替换  删除  新增  选特定行等功能. 
**sed 默认不编辑原文件, 仅对模式空间中的数据进行处理, 处理完成后, 显示模式空间中的数据到屏幕.**

>   sed [ options ]  '动作'  [input-file]    

| 选项 | 作用 |
| ----- | ---- |
| -n  | 只有经过sed 特殊处理的那一行(或者动作)才会被列出来 |
| -e SCRIPT1 -e SCRIPT2 ...| 可以同时执行多个脚本 |
| -f FILE_NAME | 把 Script 保存到文件中, 然后读取文件进行修改 |
| -r | 支持扩展正则表达式 (默认仅支持基础正则表达式) |
| -i | 直接修改原文件 (谨慎使用) |

**动作几种形式:**
> 1. '[n1[,n2]]FUNCTION' : 必须用单引号 ' ' 包起来 (n1, n2 不一定会存在, 一般代表选择进行动作的行数)
>
> 2. Line_numFUNCTION : 精确匹配某行
>      
> 2. /RegExp/FUNCTION : 支持正则表达式 
>
> 3. /pattern1/,/pattern2/FUNCTION : 第一次被 parttern1 匹配到的行开始 到 第一次被 pattern2 匹配到的行结束
>
> 4. StartLine,+nFUNCTION : 从 StartLine 开始, 向后的 N 行
>
> sed 后边如果有超过两个以上的动作时, 每个动作前都要加上 -e 才行
> 
> $ 表示最后一行

| FUNCTION参数 | 含义 |
| :----: | ---- |
| a | 新增， a 的后面可以接字串，而这些字串会在新的一行出现(目前的下一行) |
| c | 取代， c 的后面可以接字串，这些字串可以取代 n1,n2 之间的行 |
| d | 删除， 因为是删除啊，所以 d 后面通常不接任何参数 |
| i | 插入， i 的后面可以接字串，而这些字串会在新的一行出现(目前的上一行) |
| p | 打印， 将选择的数据打印出来, 通常会和 sed -n 一起用 |
| s /pattern/string/ | 替换， 只替换每行中匹配到的第一个 |
| s /pattern/string/g | 替换， 替换行中所有匹配到的 |
| r FILE | 将 FILE 内容添加到符合条件的行 |
| w FILE | 将符合条件的行写入到 FILE 中 |
> 其中的 / 也可以用其他符号, 如 # 来替换, 这样我们遇到 / 就可以不用在进行转义了, 如 s#pattern#string#g


**修饰符 :**
比如我们使用 s 是后边跟上的 g 就是修饰符, 具体如下 :

| 修饰符 | 作用 |
| :--: | ---- |
| g  | 全局替换 |
| i | 忽略字符大小写 |

```bash
## 我们先使用 p 来打印以上几种动作的表示方式
[root@localhost ~]# sed -n '1,2p' /etc/passwd
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/bin:/sbin/nologin
[root@localhost ~]# sed -n '1p' /etc/passwd
root:x:0:0:root:/root:/bin/bash
[root@localhost ~]# sed -n '/^root/p' /etc/passwd
root:x:0:0:root:/root:/bin/bash
[root@localhost ~]# sed -n '/^root/,/^bin/p' /etc/passwd
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/bin:/sbin/nologin
[root@localhost ~]# sed -n '1,+1p' /etc/passwd
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/bin:/sbin/nologin


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


## s : 部分数据的替换工作 格式为 : s/被替换的字符/新字符/[g]
[root@localhost ~]# cat /etc/passwd | head -n 1
root:x:0:0:root:/root:/bin/bash
[root@localhost ~]# sed '1 s/root/ROOT/' /etc/passwd | head -n 1
ROOT:x:0:0:root:/root:/bin/bash
[root@localhost ~]# sed '1 s/root/ROOT/g' /etc/passwd | head -n 1
ROOT:x:0:0:ROOT:/ROOT:/bin/bash


## r FILE : 将文件内容添加到符合条件的行
[root@localhost ~]# cat /etc/issue
CentOS release 6.9 (Final)
Kernel \r on an \m

[root@localhost ~]# cat /etc/fstab 
.....
UUID=356ce5e4-c782-44cb-9447-1e7f0e04e7d1 /boot                   ext4    defaults        1 2
/dev/mapper/server-myhome /home                   ext4    defaults        1 2
UUID=fb2c6429-d1fa-4a77-a4db-d2bb899fb552 /tmp                    ext4    defaults        1 2
.....

[root@localhost ~]# sed '/^\//r /etc/issue' /etc/fstab
....
UUID=356ce5e4-c782-44cb-9447-1e7f0e04e7d1 /boot                   ext4    defaults        1 2
/dev/mapper/server-myhome /home                   ext4    defaults        1 2
## 以下三行是我们添加的
CentOS release 6.9 (Final)
Kernel \r on an \m

UUID=fb2c6429-d1fa-4a77-a4db-d2bb899fb552 /tmp                    ext4    defaults        1 2
.....

## w FILE : 将符合条件的行写入到 FILE 文件中
[root@localhost ~]# sed -n '/^\//w test.txt' /etc/fstab 
[root@localhost ~]# cat test.txt 
/dev/mapper/server-myhome /home                   ext4    defaults        1 2
```

#### 实例
```bash
## 练习题1
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

## 练习题2
1. 删除 /etc/grub.conf 文件中行首的空白符
   sed -r 's#^[[:space:]]+##g' /etc/grub.conf 
2. 替换 /etc/inittab 文件中 "id:5:initdefault:" 数字 5 -> 3, 如果是 3 则变成 5
   sed -r 's#(id:)[0-9](:initdefault:)#\13\2#g' /etc/inittab
3. 删除 /etc/inittab 文件中的空白行
   sed '/^$/d' /etc/initab
4. 删除 /etc/inittab 文件中开头的 # 号
   sed 's/^#//g' /etc/inittab
5. 删除 /etc/inittab 文件中以 # 开头后边跟上若干空白字符 行中的 #开头以及后边的空白字符
   sed -r 's/^#[[:space:]]+//g' /etc/inittab 
6. 删除 /etc/inittab 文件中以 空白字符后跟上#号的行中的 空白字符以及#号
   sed -r 's/^[[:space:]]+#//g' /etc/inittab 
7. 取出一个文件路径的目录名称
   echo '/etc/sysconfig/' | sed -r 's#^(/.*/)[^/]+/?#\1#g'
```

### printf命令
将数据进行格式化输出, 使数据更加的直观形象. 各个字段之间可以使用 Tab键或者空格分割开.
> printf 'FORMAT' 数据内容

| FROMAT | 作用 |
| :---: | ---- |
| \\n | 换行  |
| \\t | 水平的制表符(Tab) |
| %ns | n 为数字, s 表示 string , 即 n 个字符 |
| %ni | n 为数字, i 表示 integer, 即 n 个整数 |
| %N.nf | N和n都是数字, f 表示 float(浮点), 表示共需要N位数,但小数点保留n位小数 小数点也算一位. <br> 比如 %8.2f 为 xxxxx.xx 形式. 总共为8位, 小数点后保留2位小数 |

#### 实例
```bash
## 实验材料
[root@localhost ~]# sed -n '1,5p' /etc/passwd > printf_test.txt
[root@localhost ~]# cat printf_test.txt 
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin
adm:x:3:4:adm:/var/adm:/sbin/nologin
lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin

## 可以看到显示的效果不够直观
[root@localhost ~]# cat printf_test.txt | cut -d ':' -f 1,3,4 | sed 's/:/ /g'
root 0 0
bin 1 1
daemon 2 2
adm 3 4
lp 4 7

## 格式化后的效果
[root@localhost ~]# printf "%10s %10s %10s\n" $(cat printf_test.txt | cut -d ':' -f 1,3,4 | sed 's/:/ /g')
      root          0          0
       bin          1          1
    daemon          2          2
       adm          3          4
        lp          4          7

## 加上一个标题出来
[root@localhost ~]# printf '%10s %10s %10s \n' 'User' 'UID' 'GID' && printf "%10s %10s %10s\n" $(cat printf_test.txt | cut -d ':' -f 1,3,4 | sed 's/:/ /g')
      User        UID        GID 
      root          0          0
       bin          1          1
    daemon          2          2
       adm          3          4
        lp          4          7
```

### awk命令
sed 常常作用于一整行的处理, awk 则是比较倾向于将一行划分成多个字段来处理. 因此 awk 命令更适合处理小型的数据处理. **awk 主要处理每一行的字段内的数据, 而默认的字段分隔符为 空格和[Tab] 键.** awk 可以处理后续的文件或者接收前个命令的 STDOUT.
> ** awk [options] '[pattern] 条件判断 {动作1} ....' FILE_NAME**
> 
> **awk 后续所有动作必须只能使用单引号, 文字部分都要使用双引号.**

| 选项 | 作用 |
| :---: | ----- |
| -F 分隔符 | 用于指定输入的分隔符 (默认为 tab和空格) |


#### 实例
```bash
## 比如我想要实现 打印用户的 UID 和账户名 中间用空格分开显示 并按照升序方式排列出来
## -F 分割开后, 会把每部分分别赋值给 $1 $2 $3 ...... 变量
[root@localhost ~]# cat /etc/passwd | head -n 5
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin
adm:x:3:4:adm:/var/adm:/sbin/nologin
lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin
[root@localhost ~]# awk -F ':' '{print $3 "\t" $1}' /etc/passwd | sort -n
0	root
1	bin
2	daemon
3	adm
4	lp
5	sync
6	shutdown
7	halt
.....

## $0 代表处理的一整行数据
[root@localhost ~]# awk -F ':' '{print $0}' /etc/passwd | head -n 5
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin
adm:x:3:4:adm:/var/adm:/sbin/nologin
lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin
```
**awk 处理步骤:**
> 1. 读取第一行, 然后把第一行分别赋值给 $0, $1, $2..........
> 2. 依据条件类型的显示, 判断是否需要进行后续的操作
> 3. 做完所有的条件类型和动作
> 4. 判断是否还有后续行, 有则重复 1-3 步骤, 直到所有的数据都被读取完成.

**所以我们可以看出 : awk 是以行为处理的单位, 每次处理一行, 然后以字段作为最小的处理单位进行处理.**

#### awk 内置变量
| 变量 | 含义 |
| :---: | ----- |
| $0 | 代表处理的每行数据 |
| NF | 每一行($0)拥有的字段总数 |
| NR | 目前 awk 处理的是第几行数据 |
| FS | 输入字段分隔符, 默认为空格 |

```bash
## 使用 /etc/passwd 文件 显示目前在第几行 总共有多少个字段 用户名是什么
root@localhost ~]# awk -F ':' '{print NR "\t" NF "\t" $1}' /etc/passwd | head -n 5
1	7	root
2	7	bin
3	7	daemon
4	7	adm
5	7	lp
```

#### awk 的逻辑运算符
| 运算符 | 含义 |
| :---: | ----- |
| > | 大于 |
| < | 小于 |
| >= | 大于或等于 |
| <= | 小于或等于 |
| == | 等于 |
| != | 不等于 |

**pattern 有两种特殊的模式 :**
> BEGIN : 命令在处理文本之前执行
>
> END : 命令在处理文本之后执行

```bash
## 我们想要 UID 小于等于 5以下的用户 UID以及账号名
[root@localhost ~]# awk '{FS=":"} $3 <=5 {print $3 "\t" $1}' /etc/passwd
	root:x:0:0:root:/root:/bin/bash
1	bin
2	daemon
3	adm
4	lp
5	sync

## 结果我们发现, 第一行没有处理, 因为当我们读取第一行时, 默认还是使用空格分割的
## 定义的 FS 只能从 第二行开始生效. 这个时候我们就需要用到 BEGIN 了.
[root@localhost ~]# awk 'BEGIN {FS=":"} $3 <=5 {print $3 "\t" $1}' /etc/passwd
0	root     <== 第一行正常处理了
1	bin
2	daemon
3	adm
4	lp
5	sync

## 然后我们尝试使用 END 来操作一下
## 准备实验环境
[root@localhost ~]# sed -n '1,8p' /etc/passwd > passwd
[root@localhost ~]# sed -i '1i test:x:1000:1000' passwd
[root@localhost ~]# sed -i '1c account:password:uid:gid' passwd
[root@localhost ~]# cat passwd 
account:password:uid:gid
test:x:1000:1000
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin
adm:x:3:4:adm:/var/adm:/sbin/nologin
lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin
sync:x:5:0:sync:/sbin:/bin/sync
shutdown:x:6:0:shutdown:/sbin:/sbin/shutdown
halt:x:7:0:halt:/sbin:/sbin/halt

## 统计所有用户的 UID 和 GID 之和
[root@localhost ~]# awk -F ':' 'NR==1 {printf "%10s %10s %10s %10s\n", $1, $3, $4, "Num" } NR>=2 {total = $3 + $4 ; printf "%10s %10s %10s %10s\n", $1, $3, $4, total }' passwd 
   account        uid        gid        Num
      test       1000       1000       2000
      root          0          0          0
       bin          1          1          2
    daemon          2          2          4
       adm          3          4          7
        lp          4          7         11
      sync          5          0          5
  shutdown          6          0          6
      halt          7          0          7
[root@localhost ~]# awk 'BEGIN {FS=":"} NR==1 {printf "%10s %10s %10s %10s\n", $1, $3, $4, "Num" } NR>=2 {total = $3 + $4 ; printf "%10s %10s %10s %10s\n", $1, $3, $4, total }' passwd 
   account        uid        gid        Num
      test       1000       1000       2000
      root          0          0          0
       bin          1          1          2
    daemon          2          2          4
       adm          3          4          7
        lp          4          7         11
      sync          5          0          5
  shutdown          6          0          6
      halt          7          0          7
```

#### 总结
> 1. 所有 awk 的工作,即 {} 内的动作,如果需要有多个命令辅助时, 可以使用分号 ';' 间隔
> 2. 逻辑运算中, 需要用到 等于的情况, 要使用 '=='
> 3. 格式化时, printf 必须加上 '\\n' 才能换行
> 4. 与 bash 和 shell 中的变量不同, awk 中的变量前边不需要加上 $ 符号


### diff命令
主要用在比较两个文件的区别并且是**以行为单位来比较**的. 所以自然可以用来制作补丁文件.
```bash
## 实验环境
[root@localhost ~]# sed -n '1,3p' /etc/passwd > diff1.txt
[root@localhost ~]# sed -n '1,3p' /etc/passwd > diff2.txt
[root@localhost ~]# head diff1.txt diff2.txt 
==> diff1.txt <==
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin

==> diff2.txt <==
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin

## 未修改之前比较一下, 都一样
[root@localhost ~]# diff diff1.txt diff2.txt

## 然后修改 diff2.txt 文件
[root@localhost ~]# sed -i 's/root/ROOT/g' diff2.txt 
[root@localhost ~]# sed -i 's/daemon/DAEMON/' diff2.txt 
[root@localhost ~]# head diff1.txt diff2.txt 
==> diff1.txt <==
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin

==> diff2.txt <==
ROOT:x:0:0:ROOT:/ROOT:/bin/bash           <== 此行已经被改变
bin:x:1:1:bin:/bin:/sbin/nologin
DAEMON:x:2:2:daemon:/sbin:/sbin/nologin   <== 此行已经被改变

## 使用 diff 发现不同的部分
[root@localhost ~]# diff diff1.txt diff2.txt | tee diff.patch
1c1    <== 文件 1 (diff1.txt) 中的第 1 行 改为 文件 2 (diff2.txt) 中的第 1 行, 则两个文件相同
< root:x:0:0:root:/root:/bin/bash
---
> ROOT:x:0:0:ROOT:/ROOT:/bin/bash
3c3    <== 文件 1 (diff1.txt) 中的第 3 行 改为 文件 2 (diff2.txt) 中的第 3 行, 则两个文件相同
< daemon:x:2:2:daemon:/sbin:/sbin/nologin
---
> DAEMON:x:2:2:daemon:/sbin:/sbin/nologin


diff.patch 的文件内容如上所示, 然后这就可以作为一个补丁文件, 接下来我们会讲解
```

### patch命令 : 向文件打补丁
patch指令让用户利用设置修补文件的方式，修改，更新原始文件。倘若一次仅修改一个文件，可直接在指令列中下达指令依序执行。如果配合修补文件的方式则能一次修补大批文件，这也是Linux系统核心的升级方法之一。
> patch [  options ] -i Patch_File  patchfile

```bash
## 先查询该命令是否存在
[root@localhost ~]# which patch
/usr/bin/patch
## 如果不存在, 则可以使用如下命令安装, 前提是必须可以设置好 YUM 源, 根据 YUM 源决定是否需要联网
[root@localhost ~]# yum install patch -y

## 然后我们尝试安装补丁, 在比较差别
[root@localhost ~]# patch -i diff.patch diff1.txt 
patching file diff1.txt
[root@localhost ~]# diff diff1.txt diff2.txt

## 最后查看文件内容 
[root@localhost ~]# head diff1.txt diff2.txt 
==> diff1.txt <==
ROOT:x:0:0:ROOT:/ROOT:/bin/bash
bin:x:1:1:bin:/bin:/sbin/nologin
DAEMON:x:2:2:daemon:/sbin:/sbin/nologin

==> diff2.txt <==
ROOT:x:0:0:ROOT:/ROOT:/bin/bash
bin:x:1:1:bin:/bin:/sbin/nologin
DAEMON:x:2:2:daemon:/sbin:/sbin/nologin

## -R : 然后我们再把文件还原回去
[root@localhost ~]# patch -R -i diff.patch diff1.txt 
patching file diff1.txt
[root@localhost ~]# head diff1.txt diff2.txt 
==> diff1.txt <==
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin

==> diff2.txt <==
ROOT:x:0:0:ROOT:/ROOT:/bin/bash
bin:x:1:1:bin:/bin:/sbin/nologin
DAEMON:x:2:2:daemon:/sbin:/sbin/nologin
```

# shell script
shell script 就是纯文本文件, 让这个文件来帮我们一次执行多个命令 或者使用一些运算和逻辑判断来帮我们达到某些功能. 所以我们需要事先了解一下编写 shell script 的规则:
> 1. 命令的执行是从上往下, 从左往右开始执行的.
> 2. 命令 选项 参数之间至少要有一个空格, 多余的空格会被忽略.
> 3. 空白行也会被忽略, Tab键的空白也会作为空格来处理.
> 4. 以 # 开头的行不在第一行中表示注释会被忽略, 在第一行表示声明 shell 的作用.
> 5. 如果读取到一个 Enter, 就会尝试开始执行该行命令.
> 6. 如果一行的内容太多, 那么可以使用 \\[Enter] 来扩展为下一行.

**一般在编写 shell 脚本时应该包含以下的内容:**
> 1. 脚本的功能
> 2. 脚本的版本 作者信息
> 3. 用到的变量说明
> 4. 声明使用的 shell 
> 5. 各个部分的功能注释
> 6. 实际执行的脚本内容

**脚本执行的方式(脚本需要具有 rx 权限):**
> 绝对路径/相对路径执行
>
> 放到 PATH 环境变量中执行  
>
> 以 shell 进程执行, 如 bash FILE_NAME.sh

## 脚本练习

### Hello World
```bash
## 名称无所谓, 以 sh 为后缀名只是表示这是一个脚本仅此而已.
[root@localhost ~]# vim sh01.sh
#!/bin/bash
# bash test file              
echo 'Hello world!'

## "#" 在第一行表示声明的意思, 声明使用 /bin/bash 这个 shell. 在其余行表示注释不执行代码
## 建议在使用时设置好 PATH 环境变量, 防止命令不在 PATH 变量路径中, 就可以设置 PATH 变量或者手动指定命令的绝对路径也可.

## bash 方式执行
[root@localhost ~]# bash sh01.sh 
Hello world!

## 绝对路径/相对路径 执行
[root@localhost ~]# ./sh01.sh
-bash: ./sh01.sh: Permission denied   <== 为什么没有权限呢? 因为需要 rx 权限
[root@localhost ~]# chmod +x sh01.sh
[root@localhost ~]# ./sh01.sh 
Hello world!
```

### 人机交互
```bash
## 要求用户输入他的姓和名, 然后打印出来用户的名字
[root@localhost ~]# vim sh02.sh
#!/bin/bash
read -p 'first name : ' -t 10 first_name
read -p 'last name  : ' -t 10 last_name
echo "${first_name} ${last_name}" 
[root@localhost ~]# bash sh02.sh 
first name : zhang
last name  : san
zhang san
```

### 日志文件
```bash
## 创建 前一天 今天  明天 三个文件
## 比如今天是 20080808, 那么三个文件就是 20080807.log 20080808.log  20080809.log
[root@localhost ~]# vim sh03.sh
#!/bin/bash
date1=$(date -d '1 day ago' '+%Y%m%d') # 前一天的日期
date2=$(date '+%Y%m%d')                # 当前日期
date3=$(date -d '+1 day' '+%Y%m%d')    # 后一天日期

file1="${date1}.log"
file2="${date2}.log"
file3="${date3}.log"

touch ${file1} ${file2} ${file3}

[root@localhost ~]# bash sh03.sh
[root@localhost ~]# date
Mon Mar  4 14:13:43 CST 2019
[root@localhost ~]# ll
-rw-r--r--. 1 root root   0 Mar  4 14:13 20190303.log
-rw-r--r--. 1 root root   0 Mar  4 14:13 20190304.log
-rw-r--r--. 1 root root   0 Mar  4 14:13 20190305.log
```

### 加减乘除
```bash
## 我们之前学过了使用 declare 和 let 来定义变量的类型, 当变量定义成为整数时才能进行加减运算.
## bash shell 默认仅支持整数的计算, 我们也可以使用 $(( 计算式 )) 来进行数值的计算
## 默认为字符串
[root@localhost ~]# aa=5+6
[root@localhost ~]# echo $aa
5+6              <== 所以不是我们预想的 11
[root@localhost ~]# declare -i aa
[root@localhost ~]# aa=5+6
[root@localhost ~]# echo $aa
11               <== 显示正确的结果
[root@localhost ~]# let bb=5+6
[root@localhost ~]# echo $bb
11               <== 使用 let 也可以 


## 用户输入两个数值, 我们进行除法运算
[root@localhost ~]# vim sh04.sh
#!/bin/bash
read -p 'first number  : ' first_num
read -p 'second number : ' second_num
echo $(( $first_num/$second_num ))

[root@localhost ~]# bash sh04.sh
first number  : 13
second number : 3
4
```

## 不同脚本执行方式的区别
不同的脚本执行方式会造成不一样的结果, 可能会对 bash 的环境影响最大. 脚本执行方式除了我们之前说的方式外, 还有 source 和 . 方式来执行. 然后我们来分析一下不同执行方式之间的区别.

### 直接执行脚本
这种方式包含我们之前说的 ` 绝对/相对路径 ` ` . ` 以及 `放到 PATH 环境变量设置的目录中 ` 还有 `  bash `等方式来执行, 该脚本都会在子进程的 bash 内执行的. 并且子进程完成后, 子进程中的各项变量或操作将会被销毁而不会传回到父进程中.

```bash
## echo $$ : 表示输出当前的进程 ID
[root@localhost ~]# echo $$
14582      <== 当前进程的ID
[root@localhost ~]# vim sh002.sh 
#!/bin/bash
read -p 'first name : ' -t 10 first_name
read -p 'last name  : ' -t 10 last_name
echo "${first_name} ${last_name}"
echo $$
[root@localhost ~]# bash sh002.sh
first name : 111
last name  : 222
111 222
14587        <== 进程 ID 变了,变为了子进程的 ID       

## -u 如果使用未定义的变量, 则会提示错误
[root@localhost ~]# set -u
[root@localhost ~]# echo $first_name $last_name
-bash: first_name: unbound variable
```
当我们使用直接执行脚本来处理的话, 系统会给与一个新的 bash 来让我们操作, 我们所有的操作都是在子进程中进行, 子进程完后后数据被销毁, 也不会回传到父进程中. 所以自然不能输出.

### source 来操作脚本
```bash
[root@localhost ~]# source sh002.sh
first name : 111
last name  : 222
111 222
14582       <== 还是父进程的 ID 没有改变
[root@localhost ~]# echo $first_name $last_name
111 222
```
这种方式我们却可以获取到变量, 说明是在父进程中执行没有打开新的 shell, 所以我们修改完配置文件后, 为啥使用 source 加载后的设置会立即生效的原因.

## && 和 ||

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

## test命令的测试功能
如果我们想要监测某个文件或者文件相关的属性是, 那么我们就可以使用 test 命令, test 命令不会输出信息, 但是我们可以通过 $? 或 && 或 || 来显示结果.

| 符号 | 含义 |
| :----: | ---- |
| 文件类型判断 | <br> |
| -e | 判断文件是否存在 |
| -f | 是否是一个文件 |
| -d | 是否是一个目录 |
| -b | 是否是块设备 |
| -c | 是否是字符设备 |
| -s | 是否是 Socket 文件 |
| -l | 是否是链接文件 |
| 文件权限检测 | <br> |
| -r | 是否有可读权限 |
| -w | 是否有可写权限 |
| -x | 是否有可执行权限 |
| -u | 是否有 SUID 属性 |
| -g | 是否有 SGID 属性 |
| -k | 是否有 SBIT 属性 |
| -s | 是否非空白文件 |
| 数值逻辑判断, 如 test n1 -eq n2 | <br> |
| -eq | n1 n2 是否相等 |
| -ne | n1 n2 是否不相等 |
| -gt | n1 大于 n2 |
| -lt | n1 小于 n2 |
| -ge | n1 大于等于 n2 |
| -le | n1 小于等于 n2 |
| 字符串判断 | <br> |
| -z string | 判断字符串是否空字符串, 则为 true |
| str1 = str2 | str1 是否等于 str2, 相等则为 true (等号两边有空格) |
| str1 != str2 | str1 是否等于 str2, 不相等则为 true (等号两边有空格) |
| 多重条件判断 | <br> |
| -a | 两个条件同时满足 返回 true, 如 test -r file1 -a test -x file1 |
| -o | 满足任何一个条件 返回 true, 如 test -r file1 -o test -x file1 |
| ! | 非, 如 test ! -x file 当 file1不具有 x 权限时 返回 true | 
| 两个文件比较 test file1 -nt file2 | <br> |
| -nt | 判断 file1 是否比 file2 新 |
| -ot | 判断 file1 是否比 file2 旧 |
| -ef | 判断 file1 file2 是否为同一个文件 (是否指向同一个 inode) |

### 实例
```bash
## 查看 /home 下 是否存在 gkdaxue 用户的家目录
## test 执行结果不会显示任何信息, 但是我们可以通过 $? 来判断
[root@localhost ~]# ll /home
drwx------. 2 root root 16384 Mar  3 11:31 lost+found
[root@localhost ~]# test -e /home/gkdaxue
[root@localhost ~]# echo $?
1        <== 说明不存在


## 编写一个脚本, 
## 1. 让用户输入一个文件名, 判断用户是否输入文件名
## 2. 判断用户输入文件是否存在, 文件不存在则输出 'File Not Exists' 文件存在则判断是一个文件还是目录 
## 3. 如果是目录输出 'File is directory', 如果是文件则输出 'File is regular file'
## 4. 判断对这个文件的权限, 并输出权限信息.
[root@localhost ~]# useradd gkdaxue
[root@localhost ~]# passwd gkdaxue
Changing password for user gkdaxue.
New password: 
BAD PASSWORD: it is too short
BAD PASSWORD: is too simple
Retype new password: 
passwd: all authentication tokens updated successfully.
[root@localhost ~]# su - gkdaxue
[gkdaxue@localhost ~]$ mkdir test_dir
[gkdaxue@localhost ~]$ touch test_file
[gkdaxue@localhost ~]$ vim test_file.sh
#!/bin/bash
## 不要使用 root 用户来运行此文件, 否则可能会导致判断不准确
## 因为 root 在很多权限限制上面无效

## 提示用户输入文件名称
read -p 'Input File Name : ' file_name

## 判断用户是否输入文件名, 没有输入则提示并退出
test -z $file_name && echo 'Your Must Input File Name' && exit 0

## 判断文件是否存在, 不存在则提示并退出
test ! -e $file_name && echo 'File Not Exists' && exit 0

## 判断文件类型
test -f $file_name && echo "${file_name} is regulare file"
test -d $file_name && echo "${file_name} is directory"

## 判断文件的权限信息
test -r $file_name && echo 'readble'
test -w $file_name && echo 'writeable'
test -x $file_name && echo 'executable'


## 开始试验
[gkdaxue@localhost ~]$ ll
total 8
drwxrwxr-x. 2 gkdaxue gkdaxue 4096 Mar  5 14:08 test_dir
-rw-rw-r--. 1 gkdaxue gkdaxue    0 Mar  5 14:09 test_file
-rw-r--r--. 1 gkdaxue gkdaxue  754 Mar  5 14:07 test_file.sh
[gkdaxue@localhost ~]$ bash test_file.sh
Input File Name : 
Your Must Input File Name
[gkdaxue@localhost ~]$ bash test_file.sh
Input File Name : test
File Not Exists
[gkdaxue@localhost ~]$ bash test_file.sh 
Input File Name : test_dir
test_dir is directory
readble
writeable
executable
[gkdaxue@localhost ~]$ bash test_file.sh
Input File Name : test_file
test_file is regulare file
readble
writeable
```

## shell script 的默认变量
我们知道命令可以带参数, 脚本也可以提示我们输入参数, 那么如果我们想在脚本执行的时候跟上参数, 而不是提示输入参数, 那么是否可行呢? 当然可行啦. 格式如下
```bash
script_name     parm1   parm2  parm3  ...
    $0            $1     $2      $3      <== 我们可以在脚本中使用 $1 $2.... 来获取参数值

$# : 脚本后边有多少个参数
$@ : 所有的参数, 每个变量都是独立的(用双引号括起来的) "$1" "$2" "$3"
$* : 所有的参数, 为 $1#$2#$3... (#为分隔符,默认为空格)
$@ 和 $* 还是有点区别的, 所以记住 $@ 就好了
$0 : 脚本名称
$1 : 脚本后的第一个参数
....................
```

### 实例
```bash
## 编写一个脚本, 要求如下
## 1. 输出脚本的名称, 参数个数 
## 2. 参数个数必须大于等于2个, 否则提示错误
## 3. 先输出全部参数, 在输出第一个参数和第二个参数
[root@localhost ~]# vim test12.sh
#!/bin/bash
[ "$#" -lt 2 ] && echo 'You mush input more then 2 parameter' && exit 0
echo 'Script Name  : ' $0
echo 'Script Param : ' $@
echo 'Param 1      : ' $1
echo 'Param 2      : ' $2 

## 实验
[root@localhost ~]# bash test12.sh
You mush input more then 2 parameter
[root@localhost ~]# bash test12.sh one
You mush input more then 2 parameter
[root@localhost ~]# bash test12.sh one two
Script Name  :  test12.sh
Script Param :  one two
Param 1      :  one
Param 2      :  two 
```

### shift : 参数变量号码偏移
shift 后边可以跟上一个数字, 表示拿掉最前边的那么多个参数.
```bash
[root@localhost ~]# vim test13.sh
#!/bin/bash
echo 'Total Param : ' $#
echo 'Param       : ' $@
shift 1
echo 'Total Param : ' $#
echo 'Param       : ' $@
shift 1
echo 'Total Param : ' $#
echo 'Param       : ' $@
[root@localhost ~]# bash test13.sh one two three four five six server
Total Param :  7
Param       :  one two three four five six server
Total Param :  6
Param       :  two three four five six server
Total Param :  5
Param       :  three four five six server
```

## 条件判断式
### 判断符号 \[ \]

可以利用判断符号 ` [] ` 来进行数据的判断, 中括号的使用方法基本上和 test 一致. 使用此符号注意事项:
> 1. 中括号的两端都需要空格符来分割
> 2. 中括号内的变量最好都用双引号包含起来
> 3. 中括号内的常量最好都用单引号或双引号包含起来

```bash
## 使用 test 判断 $HOME 变量是否为空
[root@localhost ~]# echo $HOME
/root
[root@localhost ~]# test -z $HOME && echo 'not null'

## 使用 [] 来操作
[root@localhost ~]# [ -z "$HOME" ] && echo 'not null'

## 如果不用引号操作的后果
[root@localhost ~]# name='gkdaxue test user'
[root@localhost ~]# [ $name = "gkdaxue" ]
-bash: [: too many arguments    <== 相当于 gkdaxue test user = gkdaxue 导致的问题
[root@localhost ~]# [ "${name}" = 'gkdaxue' ] 
[root@localhost ~]# echo $?
1


## 练习题
## 让用户输入 y/Y/n/N 字符, 然后判断用户输入的是 y/Y/n/N 还是其他的
## 1. 用户输入 y/Y  输出 yes, 输入 n/N  则输出 no
## 2. 输入其他之外的字符, 则输出 error
[root@localhost ~]# vim test11.sh 
#!/bin/bash
read -p "Input Y/y/N/n : " input_char
[ "$input_char" == 'Y' -o "$input_char" == 'y' ] && echo 'Yes' && exit 0
[ "$input_char" == 'N' -o "$input_char" == 'n' ] && echo 'No'  && exit 0 
echo "error" && exit 0

## 实验
[root@localhost ~]# bash test11.sh
Input Y/y/N/n : y
Yes
[root@localhost ~]# bash test11.sh
Input Y/y/N/n : Y
Yes
[root@localhost ~]# bash test11.sh
Input Y/y/N/n : n
No
[root@localhost ~]# bash test11.sh
Input Y/y/N/n : N
No
[root@localhost ~]# bash test11.sh
Input Y/y/N/n : fadf
error
```

### 条件判断
如果我们想要判断执行一条命令, 我们可以使用 && 与 || , 但是如果我们想要执行一堆命令, 我们就可以使用 if...then 来帮忙了
```
## 注意事项
## 1. if 和 []  以及 [] 的两边各有一个空格

## 如果我有多个条件表达式要判断, 那么我们就可以使用如下两种方式(两个条件都满足):
1. [ 条件表达式1 -a 条件表达式2 ] 可以改为 [ 条件表达式1 ] && [ 条件表达式2 ]
2. [ 条件表达式1 && 条件表达式2 ]
当然还有 -o 以及 || 表示只要满足其一即可.
```

#### 单分支条件判断
```bash
## 相当于, 如果.... 就 ......
if [ 条件表达式 ]; then
   条件表达式成立时, 需要执行的一系列命令
fi


## 判断 /tmp 目录下是否存在 gkdaxue 文件, 不存在则创建
[root@localhost ~]# vim test14.sh
#!/bin/bash
DIR='/tmp/gkdaxue'
ls -ld $DIR
if [ ! -e "${DIR}" ]; then
  mkdir $DIR
  ls -ld  $DIR
fi

[root@localhost ~]# bash test14.sh
ls: cannot access /tmp/gkdaxue: No such file or directory
drwxr-xr-x. 2 root root 4096 Mar  5 19:25 /tmp/gkdaxue
```

#### 双分支条件判断
```bash
## 相当于如果 .....就 ....  否则 就.....
if [ 条件表达式 ]; then
   条件表达式成立时, 需要执行的一系列命令
else
   条件表达式不成立时, 需要执行的一系列命令
fi


## 如果用户 gkdaxue 不存在, 则创建这个用户, 存在则提示该用户已存在
[root@localhost ~]# vim test15.sh
#!/bin/bash
id gkdaxue
if [ $? -eq 0 ]; then
  echo 'gkdaxue is exists'
else
  useradd gkdaxue
  id gkdaxue
fi
[root@localhost ~]# bash test15.sh
id: gkdaxue: No such user         <== 说明此用不存在
uid=500(gkdaxue) gid=500(gkdaxue) groups=500(gkdaxue)
[root@localhost ~]# bash test15.sh
uid=500(gkdaxue) gid=500(gkdaxue) groups=500(gkdaxue)
gkdaxue is exists
```

#### 多分支条件判断
```bash
if [ 条件表达式1 ];then
   条件表达式1成立时, 需要执行的一系列命令
elfi [ 条件表达式2 ];then
   条件表达式2成立时, 需要执行的一系列命令
.....
else
   上诉条件都不成立时执行
fi

## 让用户输入 y/Y/n/N 中的一个, 
## 1. 输入 y/Y 输出 Yes
## 2. 输入 n/N 输出 No
## 3. 输入其他的, 则输出 Error
[root@localhost ~]# vim test16.sh
#!/bin/bash
read -p "Input Y/y/N/n : " input_char
if [ "${input_char}" == 'Y' ] || [ "${input_char}" == 'y' ];then
   echo 'Yes'
elif [ "${input_char}" == 'N' -o "${input_char}" == 'n' ];then
   echo 'No'
else
   echo 'Error'
fi

[root@localhost ~]# bash test16.sh
Input Y/y/N/n :  y
Yes
[root@localhost ~]# bash test16.sh
Input Y/y/N/n :  Y
Yes
[root@localhost ~]# bash test16.sh
Input Y/y/N/n :  n
No
[root@localhost ~]# bash test16.sh
Input Y/y/N/n :  N
No
[root@localhost ~]# bash test16.sh
Input Y/y/N/n :  
Error
```

### case...esac判断
case语句是在多个范围内匹配数据，若匹配成功则执行相关命令并结束整个条件测试；而如果数据不在所列出的范围内，则会去执行星号（*）中所定义的默认命令。
```bash
## 程序段最后的 ;; 表示该程序段的结束
## 变量可能是用户执行脚本后输入的 或者 是脚本的参数传递过来的($1.....)
case "$变量名" in
	模式1)
		代码块
		;;
	模式2)
		代码块
		;;
	......
	*)
		不符合以上所有匹配所执行的代码块
		;;
esac

## 判断用户输入的是 字母 数字 还是其他
[root@localhost ~]# vim test17.sh
#!/bin/bash
read -p '请输入一个字符 : ' input_char
case "${input_char}" in
     [a-z]|[A-Z])
	  echo '字母'
	  ;;
     [0-9])
	  echo '数字'
	  ;;
     *)
	  echo '其他的字符'
   	  ;;
esac

[root@localhost ~]# bash test17.sh
请输入一个字符 : a
字母
[root@localhost ~]# bash test17.sh
请输入一个字符 : 9
数字
[root@localhost ~]# bash test17.sh
请输入一个字符 : ^[[20~
其他的字符
[root@localhost ~]# bash test17.sh
请输入一个字符 : 555       <== 因为我们只判断一个字符, 所以不能匹配 被认为是其他
其他的字符
```

## 循环
我们之前讲了判断这些, 那么如果我想不断地执行某些代码, 到达设置的条件就不在执行, 那么就需要用到我们所说的循环.

### while..do..done
```bash
## 条件不满足退出循环
while [ 条件判断式 ]; do
	条件表达式满足时执行的代码
done

## 当用户输入 quit 后退出程序, 否则就打印输入的内容
[root@localhost ~]# vim test18.sh 
#!/bin/bash
input_char=''
while [ "${input_char}" != 'quit' ]; do
   read -p 'Input quit then exit this program : ' input_char
   echo "Your input ${input_char}"
done
echo 'Exists this program'

[root@localhost ~]# bash test18.sh 
Input quit then exit this program : hello
Your input hello
Input quit then exit this program : anything is ok
Your input anything is ok
Input quit then exit this program : bye
Your input bye
Input quit then exit this program : quit
Your input quit
Exists this program
```

### until..do..done
```bash
## 条件满足时退出程序
until [ 条件表达式 ]; do
	当条件表达式不满足时执行的代码块
done


## 当用户输入 quit 时 退出程序
[root@localhost ~]# vim test19.sh 
#!/bin/bash
input_char=''
until [ "${input_char}" == 'quit' ]; do
   read -p 'Input quit then exit this program : ' input_char
   echo "Your input ${input_char}"
done
echo 'Exists this program'

[root@localhost ~]# bash test19.sh 
Input quit then exit this program : hello
Your input hello
Input quit then exit this program : are you ok ?
Your input are you ok ?
Input quit then exit this program : quit
Your input quit
Exists this program
```

### for..do...done
```bash
## for 循环更偏向于已经知道要执行多少次循环代码, 而 while 和 until 则是符合条件则进行某些操作
for var in col1 col2 col3..; do
   代码块(我们可以 $var 来使用变量)
done

## 练习1 : 打印从 1-9 个数字
[root@localhost ~]# vim test20.sh
#!/bin/bash
# seq 为连续的意思, 从 1-9
for num in $(seq 1 9); do  
    echo $num
done

[root@localhost ~]# bash test20.sh 
1
2
3
4
5
6
7
8
9

## 练习2 : 打印系统中存在的所有用户
[root@localhost ~]# vim test21.sh 
#!/bin/bash
for users in $(cut -d ':' -f 1 /etc/passwd); do
    echo $users
done

[root@localhost ~]# bash test21.sh
root
bin
daemon
adm
lp
.....
```

此外, for 还有一种写法, 针对数值来进行操作.
```bash
for ((变量初始值; 条件; 步长)); do
	代码块
done

初始值 : 某个变量的值
条件   : 不满足这个条件, 则退出循环
步长   : 变量每次增加的数值

## 统计 1-20 数字相加的和
[root@localhost ~]# vim test22.sh
#!/bin/bash
s=0
for ((i=1; i<=20; i=i+1)); do
    s=$(( $s+$i ))
done
echo $s

[root@localhost ~]# bash test22.sh
210
```

## function(函数)
函数的作用是干嘛呢? 就是让我们自己定义一个命令 这个命令里面定义了一些常用的功能, 我们只要调用这个命令, 就可以使用自动执行函数中所有的命令.
> 因为 **shell script 的执行方式是由上而下, 从左到右**, 因此在 shell script中 定义函数一定在程序的最前边, 方便后边进行调用

```bash
function Function_Name(){
	函数的代码块, 调用这个函数, 就会执行这个程序中的所有代码块.
}


## 打印 一个九九乘法表
[root@localhost ~]# vim test23.sh 
#!/bin/bash
for ((i=1; i<=9; i=i+1)); do
    for ((j=1; j<=$i; j=j+1)); do
        printf "%2s * %2s = %2s  " ${j} ${i} $(( $j * $i ))
    done
    echo ''
done
[root@localhost ~]# bash test23.sh 
 1 *  1 =  1  
 1 *  2 =  2   2 *  2 =  4  
 1 *  3 =  3   2 *  3 =  6   3 *  3 =  9  
 1 *  4 =  4   2 *  4 =  8   3 *  4 = 12   4 *  4 = 16  
 1 *  5 =  5   2 *  5 = 10   3 *  5 = 15   4 *  5 = 20   5 *  5 = 25  
 1 *  6 =  6   2 *  6 = 12   3 *  6 = 18   4 *  6 = 24   5 *  6 = 30   6 *  6 = 36  
 1 *  7 =  7   2 *  7 = 14   3 *  7 = 21   4 *  7 = 28   5 *  7 = 35   6 *  7 = 42   7 *  7 = 49  
 1 *  8 =  8   2 *  8 = 16   3 *  8 = 24   4 *  8 = 32   5 *  8 = 40   6 *  8 = 48   7 *  8 = 56   8 *  8 = 64  
 1 *  9 =  9   2 *  9 = 18   3 *  9 = 27   4 *  9 = 36   5 *  9 = 45   6 *  9 = 54   7 *  9 = 63   8 *  9 = 72   9 *  9 = 81 

## 然后需求又变了, 打印两个九九乘法表, 那么你会怎么做? 在复制一遍? 这就需要用到我们说的 function 的功能
[root@localhost ~]# vim test24.sh 
#!/bin/bash
# 定义了一个 nine_nine 函数, 然后我们就可以重复来使用,而不用把代码重新复制一遍
function nine_nine(){
 for ((i=1; i<=9; i=i+1)); do
     for ((j=1; j<=$i; j=j+1)); do
         printf "%2s * %2s = %2s  " ${j} ${i} $(( $j * $i ))
     done
     echo ''
 done
}
nine_nine
echo '--------------------'
nine_nine

[root@localhost ~]# bash test24.sh 
 1 *  1 =  1  
 1 *  2 =  2   2 *  2 =  4  
 1 *  3 =  3   2 *  3 =  6   3 *  3 =  9  
 1 *  4 =  4   2 *  4 =  8   3 *  4 = 12   4 *  4 = 16  
 1 *  5 =  5   2 *  5 = 10   3 *  5 = 15   4 *  5 = 20   5 *  5 = 25  
 1 *  6 =  6   2 *  6 = 12   3 *  6 = 18   4 *  6 = 24   5 *  6 = 30   6 *  6 = 36  
 1 *  7 =  7   2 *  7 = 14   3 *  7 = 21   4 *  7 = 28   5 *  7 = 35   6 *  7 = 42   7 *  7 = 49  
 1 *  8 =  8   2 *  8 = 16   3 *  8 = 24   4 *  8 = 32   5 *  8 = 40   6 *  8 = 48   7 *  8 = 56   8 *  8 = 64  
 1 *  9 =  9   2 *  9 = 18   3 *  9 = 27   4 *  9 = 36   5 *  9 = 45   6 *  9 = 54   7 *  9 = 63   8 *  9 = 72   9 *  9 = 81
--------------------
 1 *  1 =  1  
 1 *  2 =  2   2 *  2 =  4  
 1 *  3 =  3   2 *  3 =  6   3 *  3 =  9  
 1 *  4 =  4   2 *  4 =  8   3 *  4 = 12   4 *  4 = 16  
 1 *  5 =  5   2 *  5 = 10   3 *  5 = 15   4 *  5 = 20   5 *  5 = 25  
 1 *  6 =  6   2 *  6 = 12   3 *  6 = 18   4 *  6 = 24   5 *  6 = 30   6 *  6 = 36  
 1 *  7 =  7   2 *  7 = 14   3 *  7 = 21   4 *  7 = 28   5 *  7 = 35   6 *  7 = 42   7 *  7 = 49  
 1 *  8 =  8   2 *  8 = 16   3 *  8 = 24   4 *  8 = 32   5 *  8 = 40   6 *  8 = 48   7 *  8 = 56   8 *  8 = 64  
 1 *  9 =  9   2 *  9 = 18   3 *  9 = 27   4 *  9 = 36   5 *  9 = 45   6 *  9 = 54   7 *  9 = 63   8 *  9 = 72   9 *  9 = 81
```

其实 function 也是拥有内置变量的, 它的变量和 shell script 类似, 函数名称 $0, 后续参数 $1 $2.....,  但是在函数中的 $0 和 $1 与 shell script 中的是不同的.

```bash
[root@localhost ~]# vim test25.sh
#!/bin/bash
function test_param(){
    echo '$1 is ' $1  # 注意这个 $1 到底代表谁
}

case "$1" in
    'one')
	test_param 1
        ;;
     'two')
        test_param 2
        ;;
     'three')
        test_parm
        ;;
esac

[root@localhost ~]# bash test25.sh one
$1 is  1
[root@localhost ~]# bash test25.sh tow  # <== 为啥没有输出内容, 想一下
[root@localhost ~]# bash test25.sh two
$1 is  2
[root@localhost ~]# bash test25.sh three
$1 is 

## 所以使用函数时, 一定要注意 $1 $2 $0 的意思
```

# exit
exit 可以用来退出脚本, 也可以用来定义退出是返回的状态码, 如果脚本没有明确的定义状态码, 那么最后执行的一条命令的状态码即为脚本的退出状态码
```bash
[root@localhost ~]# vim test26.sh 
#!/bin/bash
echo 'test'
[root@localhost ~]# bash test26.sh
test
[root@localhost ~]# echo $?
0      <== 没有定义退出状态码, 所以退出码就是最后一条命令执行的状态码(0或非0的数字)


[root@localhost ~]# vim test27.sh
#!/bin/bash
echo 'test'
exit 26
[root@localhost ~]# bash test27.sh
test
[root@localhost ~]# echo $?
26    <== 输出的就是我们自己定义的状态码, 类似于 http 中的状态码 200 301 404 502 等
```

# shell 中如何进行算术运算
我们之前说过, 在 shell 中数据的类型都是字符, 那么我们如何进行数值的运算呢? 今天我们来总结一下
```bash
[root@localhost ~]# A=3
[root@localhost ~]# B=6
[root@localhost ~]# echo $A+$B
3+6       <== 并不是我们想要的结果 9

## 第一种方式 : let
users=`grep '^gkdaxue' /etc/shadow`
if [ -z "${users}" ]; then
   echo "${users} not exists"
   exit 0
fi

## 第二种方式 : $[算术运算表达式]
[root@localhost ~]# D=$[$A+$B]
[root@localhost ~]# echo $D
9

## 第三种方式 : $((算术运算表达式))
[root@localhost ~]# F=$(($A+$B))
[root@localhost ~]# echo $F
9

## 第四种方法 : expr 算术运算表达式
## 表达式中各操作数及运算符之间要有空格, 而且还要使用命令引用
[root@localhost ~]# G=`expr $A + $B`
[root@localhost ~]# echo $G
9
```


