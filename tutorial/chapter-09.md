# 软件安装
## 源码安装(Tarball)
Linux 系统上真正识别的可执行文件是二进制文件. 但是一个文件能不能执行还是要看是否拥有 ` 执行(x) 的权限 ` , 但是我们的 shell 脚本也不是二进制文件, 那么脚本为什么能运行呢?  其实最终执行的还是调用了一些已经编译好的二进制程序来执行的.

```bash
## 如 /bin/bash 是一个可执行的二进制文件 executable
[root@localhost ~]# file /bin/bash
/bin/bash: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), ....

## 如果是我们自己编写的 shell 脚本, 则会提示 Bourne-Again shell
## 因为我们声明了 #!/bin/bash , 所以显示为 Bourne-Again shell script
[root@localhost ~]# file /etc/init.d/network 
/etc/init.d/network: Bourne-Again shell script text executable
```

那么存在了一个问题, 既然 Linux 系统识别的是二进制文件, 但是我们又不能直接用二进制来写程序, 所以我们写出来的基本都是文本文件, 我们称之为源代码. 然后使用编译工具来编译成二进制的可执行文件.
```bash
                       函数库      
                         ↓ 
源代码(纯文本文件) → 编译程序编译 →  二进制程序

但是二进制程序是否可以执行还是要看是否拥有执行权限.
如果在程序当中引用了其他的外部子程序或函数, 那么就要在编译的过程中把该函数库加进去. 否则会导致不能正常使用程序.

运行二进制程序 →→ 程序执行中 →→ 最终执行的结果
                    ↓  ↑
                    ↓  ↑
                 外部函数库
```

我们知道了源代码就是一些程序代码的纯文本文件, 厂商一般都会把他们打包压缩(可以节省带宽)来供用户下载, 一般文件名为 tar.gz 或者 tar.bz2 等, 我们解压文件一般会看到下面这些文件
```bash
程序源代码
检测程序 ( 可能是 configure 或者 config 等文件名 )
软件安装的说明 ( INSTALL 或者 README 文件 )
```
那么我们取得了源代码, 我们又该如何安装使用呢? 一般需要经过以下这些步骤
```bash
1. 访问官方网站, 取得源代码
2. 把压缩文件解压缩
3. 以 gcc 来编译生成目标文件 (目标文件都是以 .o 的扩展名形式存在的.)
   目标文件是一种中间文件或者临时文件，gcc 一般不会保留目标文件，可执行文件生成完成后就自动删除了
4. 以 gcc 来进行函数库 主程序 子程序的连接 生成二进制文件
5. 把二进制文件以及配置文件安装到自己的服务器上面

第 3 和 第 4 步 我们可以通过 make 这个命令来简化它. 这就需要你的系统上存在 gcc 以及 make 这两个软件.
```

### gcc命令
```bash
-c  源文件             : 只编译源文件，而不进行链接，因此，对于链接中的错误是无法发现的
-o [outfile] [infile] :
                       [infile] 表示输入文件（也即要处理的文件），它可以是源文件，也可以是汇编文件或者是目标文件；
                       [outfile] 表示输出文件（也即处理的结果），它可以是预处理文件、目标文件、可执行文件等
-l                    : 加入某个函数库
-m                    : 指的是 libm.so 或 libm.a 这个函数库文件
-L Lib_PATH           : 函数库的搜索目录
```

### 传统编译安装步骤演示
```bash
## 需要先联网并且配置好 yum 仓库来安装 gcc 软件
[root@localhost ~]# yum install gcc -y
```

#### 单一程序的编译
```bash
[root@localhost ~]# vim hello.c
#include <stdio.h>
int main(void)
{
    printf("Hello Wolrd\n");
    return 0;
}

[root@localhost ~]# ll
-rw-r--r--. 1 root root 80 Apr 27 03:59 hello.c

## 编译 hello.c 文件, gcc 编译不加任何参数, 则会生成 a.out 这个文件名
[root@localhost ~]# gcc hello.c 
[root@localhost ~]# ll
total 12
-rwxr-xr-x. 1 root root 6465 Apr 27 03:41 a.out     <== 发现生成了 a.out 文件
-rw-r--r--. 1 root root   81 Apr 27 03:39 hello.c

## 测试 a.out 文件
[root@localhost ~]# ./a.out  
Hello Wolrd

## 然后我们来生成目标文件 gcc -c 
[root@localhost ~]# gcc -c hello.c 
[root@localhost ~]# ll
total 16
-rwxr-xr-x. 1 root root 6465 Apr 27 03:41 a.out
-rw-r--r-x. 1 root root   81 Apr 27 03:39 hello.c
-rw-r--r--. 1 root root 1504 Apr 27 03:45 hello.o  <== 会生成 hello.o 文件

## gcc -o 选项生成二进制文件
[root@localhost ~]# gcc -o hello hello.o
[root@localhost ~]# ll
total 32
-rwxr-xr-x. 1 root root 6465 Apr 27 04:09 a.out
-rwxr-xr-x. 1 root root 6465 Apr 27 04:09 hello    <== 生成的可执行文件
-rw-r--r--. 1 root root   81 Apr 27 04:05 hello.c
-rw-r--r--. 1 root root 1504 Apr 27 04:08 hello.o

## 执行 hello 文件
[root@localhost ~]# ./hello 
Hello Wolrd

## 然后我们来对比一下这两个文件
[root@localhost ~]# file a.out hello.o hello
a.out:   ELF 64-bit LSB executable, x86-64, version 1 (SYSV), dynamically linked (uses shared libs), for GNU/Linux 2.6.18, not stripped
hello.o: ELF 64-bit LSB relocatable, x86-64, version 1 (SYSV), not stripped
hello:   ELF 64-bit LSB executable, x86-64, version 1 (SYSV), dynamically linked (uses shared libs), for GNU/Linux 2.6.18, not stripped


## 也许你觉得我们直接一步就能完成了, 为什么还要先生成目标文件在制作可执行文件呢, 是否多次一举? 请看另外一个案例.
```

#### 主程序和子程序链接编译
```bash
## self_func 只有一个函数 func_a, 没有 func_b 函数
[root@localhost ~]# vim self_func.c
#include <stdio.h>
void func_a(){
    printf("FUNC_A\n");
}
[root@localhost ~]# vim main.c 
#include <stdio.h>
int main(void)
{
    func_a();
    func_b(); 
    return 0;
}

## -c 只编译源文件，而不进行链接，因此，对于链接中的错误是无法发现的, 所以没有报错
[root@localhost ~]# gcc -c main.c self_func.c
[root@localhost ~]# rm -rf main.o self_func.o

## 但是如果我们直接使用 gcc 命令则会提示错误
[root@localhost ~]# gcc main.c self_func.c
/tmp/ccQPLF8J.o: In function `main':
main.c:(.text+0x14): undefined reference to `func_b'
collect2: ld returned 1 exit status

## 然后我们就修改 main.c 文件显示如下
[root@localhost ~]# vim main.c
#include <stdio.h>
int main(void)
{
    func_a();
    printf("main func\n");
    return 0;
}

[root@localhost ~]# ll
-rw-r--r--. 1 root root 93 Apr 27 04:45 main.c
-rw-r--r--. 1 root root 60 Apr 27 03:59 self_func.c

## 先生成目标文件 main.o 以及 self_func.o 
[root@localhost ~]# gcc -c self_func.c main.c
[root@localhost ~]# ll
-rw-r--r--. 1 root root   93 Apr 27 04:45 main.c
-rw-r--r--. 1 root root 1560 Apr 27 04:47 main.o
-rw-r--r--. 1 root root   60 Apr 27 03:59 self_func.c
-rw-r--r--. 1 root root 1496 Apr 27 04:47 self_func.o

## 然后生成可执行文件 main
[root@localhost ~]# gcc -o main main.o self_func.o
[root@localhost ~]# ll main
-rwxr-xr-x. 1 root root 6611 Apr 27 04:48 main
[root@localhost ~]# ./main
FUNC_A
main func


## 我们在主程序里面调用了另外一个子程序是很常见的写法. 这样我们可以模块化的管理操作. 
```

#### 调用外部函数库
```bash
## sin 属于 libm.so 这个函数库中
[root@localhost ~]# vim sin.c 
#include <stdio.h>
#include <math.h>
int main(void)
{
    float value;
    value = sin ( 3.14/2 );
    printf("%f\n", value);
}
[root@localhost ~]# gcc sin.c -lm -L /usr/lib64
[root@localhost ~]# ./a.out 
1.000000


## Linux 默认将函数库放在 /lib 和 /usr/lib 当中, 所以如果你的函数库在这个下面, 你可以不使用 -L 参数
## 但是你的函数库不在这个目录下, 就要使用 -L 来指定路径
```

### make命令 和 configure
从以上的实验步骤, 我们知道了直接使用 gcc 来编译的困难程度. 所以一般我们会使用 make 命令来操作. 源代码文件一般会有一个检测程序 ( configure ) 来检测用户的环境是否满足安装软件的条件(因为不同版本的内核系统调用 功能不同), 如果检测通过后, 会生成一个 makefile 的规则文件. 然后 make 命令根据 makefile 文件来编译软件. 所以检测步骤一定要成功(言外之意:你的系统一定要满足安装软件的条件, 比如操作系统 依赖库 编译软件等等).  
```bash
源代码 --> configure检测程序 --> 检测通过会生成 makefile 文件, 不通过则需要检查问题, 直到通过检测

make 命令根据 makefile 文件来调用 gcc命令以及函数库 驱动 编译器等 最终生成可执行的二进制文件 
```

比如我有很多个文件, 然后需要编译成一个二进制的文件, 然后过了一段时间, 我们需要升级这个软件, 我们难道又要从头到尾手动的编译执行一遍吗? 那估计是要疯了. 所以就诞生了 makefile 文件的方式.

我们把这些编译的流程写到一个文件中, 然后执行 make 命令就会自动帮助我们编译运行, 并且 make 还会去主动的判断每个目标文件相关的源文件并直接编译. 最后进行链接的操作. 如果我们更改了某些源码文件, 则 make 还会主动判断哪一个源码与相关的目标文件有更新过, 并仅仅只是更新该文件, 可以大大节省编译的时间. 所以 make 的好处如下:
```bash
1. 简化编译时所需要执行的命令
2. 编译完成后, 修改了部分源代码, 则 make 仅会针对被修改了文件进行编译 其他目标文件不会被更改
3. 可以依照相关性来更新执行文件
```

#### makefile的语法和变量
##### makefile的语法
```bash
目标(target) : 目标文件1 目标文件2 ....
<Tab键>	  gcc -o 执行文件名称  目标文件1  目标文件2 ....

1. 在 makefile 当中的 # 表示批注的意思
2. <Tab键> 需要在命令行的第一个字符 (如 gcc这个编译命令)
3. 目标(target) 与 目标文件之间需要用 " : " 隔开 
```

比如我现在有 4 个文件, 功能如下所示 :
```bash
[root@localhost ~]# ll
total 16
-rw-r--r--. 1 500 500 184 Sep  4  2015 cos_value.c   <== 计算用户输入角度的 cos 值
-rw-r--r--. 1 500 500 101 Jun  9  2009 haha.c        <== 输出信息
-rw-r--r--. 1 500 500 291 Jun  9  2009 main.c        <== 让用户输入以及调用其他子程序的主程序
-rw-r--r--. 1 500 500 186 Sep  4  2015 sin_value.c   <== 计算用户输入角度的 sin 值
[root@localhost ~]# cat cos_value.c  
#include <stdio.h>
#include <math.h>
#define pi 3.14159
float angle;

void cos_value(void)
{
	float value;
	value = cos ( angle / 180. * pi );
	printf ("The Cos is: %5.2f\n",value);
}

[root@localhost ~]# cat sin_value.c 
#include <stdio.h>
#include <math.h>
#define pi 3.14159
float angle;

void sin_value(void)
{
	float value;
	value = sin ( angle / 180. * pi );
	printf ("\nThe Sin is: %5.2f\n",value);
}

[root@localhost ~]# cat haha.c 
#include <stdio.h>
int haha(char name[15])
{
	printf ("\nHi, Dear %s, nice to meet you.", name);
}

[root@localhost ~]# cat main.c
#include <stdio.h>
#define pi 3.14159
char name[15];
float angle;

int main(void)
{
	printf ("Please input your name: ");
	scanf  ("%s", &name );
	printf ("Please enter the degree angle (ex> 90): " );
	scanf  ("%f", &angle );
	haha( name );
	sin_value( angle );
	cos_value( angle );
}


## 然后我们开始制作 makefile 文件
[root@localhost ~]# vim makefile
main : main.o cos_value.o haha.o sin_value.o
        gcc -lm -o main main.o cos_value.o haha.o sin_value.o

## 默认执行 main 的目标
[root@localhost ~]# make
cc    -c -o main.o main.c
cc    -c -o cos_value.o cos_value.c
cc    -c -o haha.o haha.c
cc    -c -o sin_value.o sin_value.c
gcc -lm -o main main.o cos_value.o haha.o sin_value.o
[root@localhost ~]# ./main 
Please input your name: gkdaxue
Please enter the degree angle (ex> 90): 30

Hi, Dear gkdaxue, nice to meet you.
The Sin is:  0.50
The Cos is:  0.87
[root@localhost ~]# ll
total 44
-rw-r--r--. 1  500  500  184 Sep  4  2015 cos_value.c
-rw-r--r--. 1 root root 1760 Apr 27 06:20 cos_value.o
-rw-r--r--. 1  500  500   99 Apr 27 06:23 haha.c
-rw-r--r--. 1 root root 1536 Apr 27 06:20 haha.o
-rwxr-xr-x. 1 root root 7897 Apr 27 06:20 main
-rw-r--r--. 1  500  500  287 Apr 27 06:22 main.c
-rw-r--r--. 1 root root 2224 Apr 27 06:20 main.o
-rw-r--r--. 1 root root  100 Apr 27 06:20 makefile
-rw-r--r--. 1  500  500  186 Sep  4  2015 sin_value.c
-rw-r--r--. 1 root root 1760 Apr 27 06:20 sin_value.o

## 新增一个目标 clean 清除生成的  *.o 文件
[root@localhost ~]# vim makefile
main : main.o cos_value.o haha.o sin_value.o
        gcc -lm -o main main.o cos_value.o haha.o sin_value.o
clean :
        rm -f main.o cos_value.o sin_value.o haha.o

[root@localhost ~]# make clean
rm -f main.o cos_value.o sin_value.o haha.o

[root@localhost ~]# ll
total 28
-rw-r--r--. 1  500  500  184 Sep  4  2015 cos_value.c
-rw-r--r--. 1  500  500   99 Apr 27 06:23 haha.c
-rwxr-xr-x. 1 root root 7897 Apr 27 06:20 main
-rw-r--r--. 1  500  500  287 Apr 27 06:22 main.c
-rw-r--r--. 1 root root  153 Apr 27 06:27 makefile
-rw-r--r--. 1  500  500  186 Sep  4  2015 sin_value.c

## 我们来验证一下修改了部分源代码, 只会修改对应的 .o 文件
[root@localhost ~]# make main
cc    -c -o main.o main.c
cc    -c -o cos_value.o cos_value.c
cc    -c -o haha.o haha.c
cc    -c -o sin_value.o sin_value.c
gcc -lm -o main main.o cos_value.o haha.o sin_value.o

[root@localhost ~]# ll *.o
-rw-r--r--. 1 root root 1760 Apr 27 06:28 cos_value.o
-rw-r--r--. 1 root root 1536 Apr 27 06:28 haha.o
-rw-r--r--. 1 root root 2224 Apr 27 06:28 main.o
-rw-r--r--. 1 root root 1760 Apr 27 06:28 sin_value.o

## 修改 haha.c 的内容如下所示
[root@localhost ~]# vim haha.c
#include <stdio.h>
int haha(char name[15])
{
	printf ("\nHi, Dear %s, I love you ", name);
}

## 只更新了 haha.o
[root@localhost ~]# make
cc    -c -o haha.o haha.c
gcc -lm -o main main.o cos_value.o haha.o sin_value.o

[root@localhost ~]# ll *.o
-rw-r--r--. 1 root root 1760 Apr 27 06:28 cos_value.o
-rw-r--r--. 1 root root 1528 Apr 27 06:32 haha.o         <== 只更新了 haha.o
-rw-r--r--. 1 root root 2224 Apr 27 06:28 main.o
-rw-r--r--. 1 root root 1760 Apr 27 06:28 sin_value.o

[root@localhost ~]# ./main 
Please input your name: gkdaxue
Please enter the degree angle (ex> 90): 30

Hi, Dear gkdaxue, I love you     <== 已经变了
The Sin is:  0.50
The Cos is:  0.87

## 所以有的时候虽然 shell script 也能帮助我们完成我们想要的, 但是对于编译程序来说, make 更合适不是吗?
```

##### makefile的变量
然后我们再来看一下 makefile 这个文件, 发现里面的重复数据太多了, 那么我们是否可以使用变量来替换呢?
```bash
[root@localhost ~]# cat makefile 
main : main.o cos_value.o haha.o sin_value.o
	gcc -lm -o main main.o cos_value.o haha.o sin_value.o
clean :
	rm -f main.o cos_value.o sin_value.o haha.o

## 变量的语法规则
1. 变量和变量内容使用 '=' 隔开, 并且 '=' 两边可以有空格(和 shell script 不同)
2. 变量左边不可以有 Tab 键
3. 变量和变量内容在 '=' 两边不能具有 ':'
4. 变量尽量使用大写字母
5. ${变量} 或 $(变量) 来使用变量


[root@localhost ~]# vim makefile
LIBS = -lm
OBJS = main.o cos_value.o haha.o sin_value.o
main : ${OBJS}
	gcc ${LIBS} -o main ${OBJS}
clean :
	rm -f ${OBJS} 


## 那么问题来了, 我们既可以使用 shell 中环境变量, 也可以使用在 makefile 文件中定义变量 还有脚本后也可以跟上变量
## 那么变量的优先级是什么?
1. make 命令行跟上的环境变量优先级最高
2. makefile 指定的环境变量为第二优先级
3. shell 原本的环境变量为第三优先级
4. $@ 可以表示当前的目标
```

### Tarball安装的基本步骤
```bash
1. 下载对应软件的源代码
2. 解压源代码并查看 INSTALL/README 文件, 查看如何安装此软件
3. ./configure 或 ./config (用来检查系统环境是否满足安装条件), 如果满足则会生成 makefile 文件
4. 如果之前编译失败, 需要使用 make clean 删除目标文件, 如果没有编译过, 可以忽略此步骤
5. 执行 make 命令, 根据 makefile 文件的配置生成可执行的文件
6. 执行 make install命令, 则是将对应的数据移动到默认的位置中, 完成安装的操作.

## 如果上一步的执行失败会导致后续的步骤无法执行, 所以一定要确保每一步骤都要执行成功.
```

### 静态和动态函数库
#### 静态函数库
```bash
1. 库文件扩展名为 .a
2. 这类函数库会被直接编译到执行程序中, 所以生成的可执行程序比较大
3. 可以独立执行, 不需要读取外部的函数库
4. 一旦静态函数库改变，程序就需要重新编译
```

#### 动态函数库
```bash
1. 库文件扩展名为 .so
2. 在编译时程序中只保存对函数库的指向（程序编译仅对其做简单的引用）并没有整合到可执行程序中
   当执行程序时, 用到函数库时才会去读取函数库来使用, 所以可执行程序较小
3. 不能被独立执行, 必须要保证函数库的目录以及文件都存在无误
4. 升级函数库时无需对整个程序重新编译, 如果程序执行时函数库出现问题，则程序将不能正确运行
```

那么问题来了, 我们知道了动态函数库是使用到对应的函数库时, 才会从硬盘上去读取该函数库, 无形之中拖慢了程序的运行速度. 所以就出现了 ldconfig 命令,  不让它直接从硬盘上读取, 做成类似缓存的效果加载到内存中, 这样就可以提升读取的速度.
```bash
1. 在 /etc/ld.so.conf 文件中写下想要放入高速缓存的动态链接库所在目录(是目录)
2. 利用 ldconfig 命令将 /etc/ld.so.conf 的数据读入到缓存中
3. 同时也将数据记录一份在 /etc/ld.so.cache 文件中

[root@localhost ~]# cat /etc/ld.so.conf
include ld.so.conf.d/*.conf
```

### ldconfig命令
> ldconfig [ options ]

| 选项 | 作用 |
| :---: | --- |
| -f conf | conf 指文件名, 使用指定的文件来替代 /etc/ld.so.conf 文件 |
| -C cache | cache 指文件, 使用指定的文件作为缓存文件, 不使用 /etc/ld.so.cache 文件 |
| -p | 列出目前函数库数据内容(默认为 /etc/ld.so.cache中的内容) |

```bash
[root@localhost ~]# ldconfig
[root@localhost ~]# ldconfig -p
750 libs found in cache `/etc/ld.so.cache'
	libz.so.1 (libc6,x86-64) => /lib64/libz.so.1
	libxul.so (libc6,x86-64) => /usr/lib64/xulrunner/libxul.so
	libxtables.so.4 (libc6,x86-64) => /lib64/libxtables.so.4
	libxslt.so.1 (libc6,x86-64) => /usr/lib64/libxslt.so.1
	libxshmfence.so.1 (libc6,x86-64) => /usr/lib64/libxshmfence.so.1
	libxpcom.so (libc6,x86-64) => /usr/lib64/xulrunner/libxpcom.so
	libxml2.so.2 (libc6,x86-64) => /usr/lib64/libxml2.so.2
	libxmlrpc_util.so.3 (libc6,x86-64) => /usr/lib64/libxmlrpc_util.so.3
	libxmlrpc_server_cgi.so.3 (libc6,x86-64) => /usr/lib64/libxmlrpc_server_cgi.so.3
	libxmlrpc_server_abyss.so.3 (libc6,x86-64) => /usr/lib64/libxmlrpc_server_abyss.so.3
	libxmlrpc_server.so.3 (libc6,x86-64) => /usr/lib64/libxmlrpc_server.so.3
	libxmlrpc_client.so.3 (libc6,x86-64) => /usr/lib64/libxmlrpc_client.so.3
	libxmlrpc_abyss.so.3 (libc6,x86-64) => /usr/lib64/libxmlrpc_abyss.so.3
	libxmlrpc.so.3 (libc6,x86-64) => /usr/lib64/libxmlrpc.so.3
	......
```

### ldd命令 : 打印共享库依赖项
> ldd [ options ]  FILE

| 选项 | 作用 |
| :---: | ---- |
| -v | 列出所有内容信息 |
| -d | 重新将数据有丢失的 link 点显示出来 |
| -r | 将 ELF 有关的错误内容显示出来 |

```bash
## 查看 /usr/bin/passwd 的函数依赖库
[root@localhost ~]# ldd /usr/bin/passwd 
	linux-vdso.so.1 =>  (0x00007ffd2bedd000)
	libuser.so.1 => /usr/lib64/libuser.so.1 (0x00007f7d81eb3000)
	libcrypt.so.1 => /lib64/libcrypt.so.1 (0x00007f7d81c7c000)
	libgobject-2.0.so.0 => /lib64/libgobject-2.0.so.0 (0x00007f7d81a2f000)
	libgmodule-2.0.so.0 => /lib64/libgmodule-2.0.so.0 (0x00007f7d8182c000)
	libgthread-2.0.so.0 => /lib64/libgthread-2.0.so.0 (0x00007f7d81628000)
	librt.so.1 => /lib64/librt.so.1 (0x00007f7d8141f000)
	libglib-2.0.so.0 => /lib64/libglib-2.0.so.0 (0x00007f7d81108000)
	libpopt.so.0 => /lib64/libpopt.so.0 (0x00007f7d80eff000)
	libpam_misc.so.0 => /lib64/libpam_misc.so.0 (0x00007f7d80cfa000)
	libaudit.so.1 => /lib64/libaudit.so.1 (0x00007f7d80ad6000)
	libselinux.so.1 => /lib64/libselinux.so.1 (0x00007f7d808b7000)
	libpthread.so.0 => /lib64/libpthread.so.0 (0x00007f7d80699000)
	libc.so.6 => /lib64/libc.so.6 (0x00007f7d80305000)
	libpam.so.0 => /lib64/libpam.so.0 (0x00007f7d800f7000)        <== 用到了 pam 的模块
	libfreebl3.so => /lib64/libfreebl3.so (0x00007f7d7fef3000)
	libdl.so.2 => /lib64/libdl.so.2 (0x00007f7d7fcef000)
	/lib64/ld-linux-x86-64.so.2 (0x00000036acc00000)

## -v 查看 /lib/libc.so.6 的相关函数库
[root@localhost ~]# ldd -v /lib64/libc.so.6
	/lib64/ld-linux-x86-64.so.2 (0x00000036acc00000)
	linux-vdso.so.1 =>  (0x00007ffcd7943000)

	Version information:
	/lib64/libc.so.6:
		ld-linux-x86-64.so.2 (GLIBC_PRIVATE) => /lib64/ld-linux-x86-64.so.2
		ld-linux-x86-64.so.2 (GLIBC_2.3) => /lib64/ld-linux-x86-64.so.2
```

## 二进制安装软件
### RPM功能
在RPM（RedHat Package Manager 红帽软件包管理器）公布之前，要想在Linux系统中安装软件只能采取源码包的方式安装。早期在Linux系统中安装程序是一件非常困难、耗费耐心的事情，而且大多数的服务程序仅仅提供源代码，需要运维人员自行编译代码并解决许多的软件依赖关系，因此要安装好一个服务程序，运维人员需要具备丰富知识、高超的技能，甚至良好的耐心。而且在安装、升级、卸载服务程序时还要考虑到其他程序、库的依赖关系，所以在进行校验、安装、卸载、查询、升级等管理软件操作时难度都非常大。

RPM机制则为解决这些问题而设计的。RPM会建立统一的数据库文件，详细记录软件信息并能够自动分析依赖关系。目前RPM的优势已经被公众所认可，使用范围也已不局限在红帽系统中了。RPM 的优点如下 :
```bash
1. RPM 内含已经编译过的程序和配置文件, 可以免除编译的过程
2. RPM 安装之前回去检查依赖信息, 可避免被安装却无法使用
3. RPM 会保留软件包的 版本/名称/说明/文件 等信息, 让用户可以了解该软件
4. RPM 使用数据库(/var/lib/rpm/)记录 RPM 文件的相关参数, 便于 升级/查询/卸载

例如只有先安装 openssl 才能安装 openssh 软件, 所以要先自己手动安装 openssl 在安装 openssh
```

|  说明 | 命令 |
| ----- | ----- |
| 安装软件 |	rpm -ivh filename.rpm |
| 升级软件 |	rpm -Uvh filename.rpm |
| 卸载软件 |	rpm -e filename.rpm  |
| 查询软件描述信息 |	rpm -qpi filename.rpm |
| 列出软件文件信息 |	rpm -qpl filename.rpm |
| 查询文件属于哪个RPM |	rpm -qf filename |
| 查看该软件的设置文件 | rpm -qc filename |

```bash
## 先在虚拟机设置中 CD/DVD栏目中点击 在设备状态中把已连接勾选保存后, 再来操作
[root@localhost ~]# mkdir /media/cdrom
[root@localhost ~]# mount /dev/cdrom /media/cdrom
mount: /dev/sr0 is write-protected, mounting read-only
[root@localhost ~]# cd /media/cdrom/Packages/
[root@localhost Packages]# ls | grep httpd
httpd-2.4.6-17.el7.x86_64.rpm
httpd-devel-2.4.6-17.el7.x86_64.rpm
httpd-manual-2.4.6-17.el7.noarch.rpm
httpd-tools-2.4.6-17.el7.x86_64.rpm
libmicrohttpd-0.9.33-2.el7.i686.rpm
libmicrohttpd-0.9.33-2.el7.x86_64.rpm
 
 
## 接下来尝试安装 httpd, 提示错误, 因为需要安装依赖包
[root@localhost Packages]# rpm -ivh httpd-2.4.6-17.el7.x86_64.rpm 
warning: httpd-2.4.6-17.el7.x86_64.rpm: Header V3 RSA/SHA256 Signature, key ID fd431d51: NOKEY
error: Failed dependencies:
	httpd-tools = 2.4.6-17.el7 is needed by httpd-2.4.6-17.el7.x86_64
 
 
## 先来安装依赖包之后, 正常安装
[root@localhost Packages]# rpm -ivh httpd-tools-2.4.6-17.el7.x86_64.rpm 
warning: httpd-tools-2.4.6-17.el7.x86_64.rpm: Header V3 RSA/SHA256 Signature, key ID fd431d51: NOKEY
Preparing...                          ################################# [100%]
Updating / installing...
   1:httpd-tools-2.4.6-17.el7         ################################# [100%]
[root@localhost Packages]# rpm -ivh httpd-2.4.6-17.el7.x86_64.rpm 
warning: httpd-2.4.6-17.el7.x86_64.rpm: Header V3 RSA/SHA256 Signature, key ID fd431d51: NOKEY
Preparing...                          ################################# [100%]
Updating / installing...
   1:httpd-2.4.6-17.el7               ################################# [100%]
 

[root@localhost ~]# rpm -qa httpd
httpd-2.2.15-59.el6.centos.x86_64

[root@localhost ~]# rpm -qi httpd
Name        : httpd                        Relocations: (not relocatable)
Version     : 2.2.15                            Vendor: CentOS
Release     : 59.el6.centos                 Build Date: Wed 22 Mar 2017 02:53:40 PM CST
Install Date: Sun 03 Mar 2019 11:37:42 AM CST      Build Host: c1bm.rdu2.centos.org
Group       : System Environment/Daemons    Source RPM: httpd-2.2.15-59.el6.centos.src.rpm
Size        : 3137746                          License: ASL 2.0
Signature   : RSA/SHA1, Thu 23 Mar 2017 11:02:13 PM CST, Key ID 0946fca2c105b9de
Packager    : CentOS BuildSystem <http://bugs.centos.org>
URL         : http://httpd.apache.org/
Summary     : Apache HTTP Server
Description :
The Apache HTTP Server is a powerful, efficient, and extensible
web server.

[root@localhost ~]# rpm -qc httpd
/etc/httpd/conf.d/welcome.conf
/etc/httpd/conf/httpd.conf
/etc/httpd/conf/magic
..............

[root@localhost ~]# rpm -qf /etc/httpd/conf/httpd.conf 
httpd-2.2.15-59.el6.centos.x86_64
```

### YUM功能
尽管RPM能够帮助用户查询软件相关的依赖关系，但问题还是要运维人员自己来解决，而有些大型软件可能与数十个程序都有依赖关系，Yum软件仓库便是为了进一步降低软件安装难度和复杂度而设计的技术。Yum软件仓库可以根据用户的要求分析出所需软件包及其相关的依赖关系，然后自动从服务器下载软件包并安装到系统.
> yum [ options ] [ command ] [package ...]

```bash
## options  ( 命令行的优先级高于 yum 配置文件的优先级 )
-y                       : 自动回答'yes'
-q                       : 静默模式
--disablerepo=repoidglob : 临时禁用此处指定的repo
--enablerepo=repoidglob  : 临时启用此处指定的repo
--noplugins              : 禁用所有插件
--installroot=PATH       : 将软件安装在 PATH 中而不使用默认路径


## command
01. repolist [ all | enabled(默认) | disabled ]              : 显示仓库列表(默认显示所有启用的)
02. list     [ all(默认) | available | updates | installed ] : 显示程序包
03. remove    package1 [package2 ...]                       : 卸载程序包
04. install   package1 [package2 ...]                       : 安装程序包
05. reinstall package1 [package2 ...]                       : 重新安装程序包
06. update    package1 [package2 ...]                       : 升级软件包
07. info      package1 [package2 ...]                       : 查看程序包信息
08. provides  FILE_NAME                                     : 查看文件属于哪个软件包
09. search    string1                                       : 搜索软件名/描述的关键字
10. clean     { package | headers | all }                   : 清除本地缓存
11. makecache                                               : 构建缓存    
12. deplist   package1 [package2] [...]                     : 显示软件包的依赖关系

## 查询是否安装了 yum 客户端
[root@localhost ~]# rpm -qa yum
yum-3.2.29-81.el6.centos.noarch
```

| 常用综合命令 |	作用 |
| ----- | ------ |
| yum repolist all | 显示所有的仓库列表 |
| yum list all |	列出仓库中所有软件包 |
| yum info 软件包名称	| 查看软件包信息 |
| yum install | 软件包名称	安装软件包 |
| yum reinstall | 软件包名称	重新安装软件包 |
| yum search 软件包名称 | 搜索软件名/描述的关键字 |
| yum update 软件包名称	 | 升级软件包 |
| yum remove 软件包名称 |	移除软件包 |
| yum clean all |	清除所有仓库缓存 |
| yum check-update	| 检查可更新的软件包 |
| yum grouplist	 | 查看系统中已经安装的软件包组 |
| yum groupinstall 软件包组	 | 安装指定的软件包组 |
| yum groupremove 软件包组	| 移除指定的软件包组 |
| yum groupinfo 软件包组 |	查询指定的软件包组信息 |
| yum provides FILE_NAME | 查看 FILE_NAME 是哪个软件包提供的 |

#### YUM配置文件
> /etc/yum.conf           : 为所有仓库提供公共配置
>
> /etc/yum.repos.d/*.repo : 为仓库的私有配置文件

#### YUM仓库配置文件模板
```bash
[repositoryID] ：Yum软件仓库唯一标识符，避免与其他仓库冲突。
name=Some name for this repository：Yum软件仓库的名称描述，易于识别仓库用处。
baseurl=file:///media/cdrom：包括FTP（ftp://..）、HTTP（http://..）、（file:///..）三种方式
enabled=1：设置此源是否可用；1为可用，0为禁用。
gpgcheck=0：设置此源是否校验文件；1为校验，0为不校验。
gpgkey=file:///media/cdrom/RPM-GPG-KEY-redhat-release：如开启校验，请指定公钥文件位置
```

#### 创建本地 YUM 源
```bash 
## 那么我们就来使用光盘来自己创建一个本地 YUM 源
## 1. 创建挂载目录, 挂载光盘
[root@localhost ~]# mkdir -p /media/cdrom
[root@localhost ~]# mount /dev/cdrom /media/cdrom
mount: block device /dev/sr0 is write-protected, mounting read-only

## 2. 在/etc/yum.repos.d/目录中创建后缀名为 repo 的文件, 文件名可随意
[root@localhost ~]# vim /etc/yum.repos.d/gkdaxue.repo
[gkdaxue]
name=gkdaxue
baseurl=file:///media/cdrom
enabled=1
gpgcheck=0
 
## 3. 在 /etc/fstab 文件中新增一行, 永久生效
[root@localhost ~]# vim /etc/fstab 
/dev/cdrom /media/cdrom iso9660 defaults 0 0
 
## 4. 使用 yum install httpd -y 检查Yum仓库是否可用, 出现 Complete 说明配置完成
[root@localhost ~]# yum install httpd
Loaded plugins: langpacks, product-id, subscription-manager
This system is not registered to Red Hat Subscription Management. You can use subscription-manager to register.
Resolving Dependencies
--> Running transaction check
---> Package httpd.x86_64 0:2.4.6-17.el7 will be installed
--> Processing Dependency: httpd-tools = 2.4.6-17.el7 for package: httpd-2.4.6-17.el7.x86_64
--> Running transaction check
---> Package httpd-tools.x86_64 0:2.4.6-17.el7 will be installed
--> Finished Dependency Resolution
gkdaxue/group_gz                                                    | 134 kB  00:00:00     
 
Dependencies Resolved
 
===========================================================================================
 Package                Arch              Version                 Repository          Size
===========================================================================================
Installing:
 httpd                  x86_64            2.4.6-17.el7            gkdaxue            1.2 M
Installing for dependencies:
 httpd-tools            x86_64            2.4.6-17.el7            gkdaxue             77 k
 
Transaction Summary
===========================================================================================
Install  1 Package (+1 Dependent package)
 
Total download size: 1.2 M
Installed size: 3.8 M
Is this ok [y/d/N]: y         <== 需要自己手动输入 y 确认安装
Downloading packages:
-------------------------------------------------------------------------------------------
Total                                                       60 MB/s | 1.2 MB  00:00:00     
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
  Installing : httpd-tools-2.4.6-17.el7.x86_64                                         1/2 
  Installing : httpd-2.4.6-17.el7.x86_64                                               2/2 
gkdaxue/productid                                                   | 1.6 kB  00:00:00     
  Verifying  : httpd-tools-2.4.6-17.el7.x86_64                                         1/2 
  Verifying  : httpd-2.4.6-17.el7.x86_64                                               2/2 
 
Installed:
  httpd.x86_64 0:2.4.6-17.el7                                                              
 
Dependency Installed:
  httpd-tools.x86_64 0:2.4.6-17.el7                                                        
 
Complete!
```

#### 显示仓库列表
```bash
## 默认显示所有已经启用的仓库
[root@localhost ~]# yum repolist   # = yum repolist enabled
repo id                               repo name                                         status
base                                  CentOS-6 - Base                                   6,713
extras                                CentOS-6 - Extras                                    46
gkdaxue                               gkdaxue                                           6,706
updates                               CentOS-6 - Updates                                  534
repolist: 13,999

## 显示所有的, 包含 启用和未启用 的仓库
[root@localhost ~]# yum repolist all
repo id                             repo name                                   status
C6.0-base                           CentOS-6.0 - Base                           disabled
C6.0-centosplus                     CentOS-6.0 - CentOSPlus                     disabled
..............
centosplus                          CentOS-6 - Plus                             disabled
contrib                             CentOS-6 - Contrib                          disabled
extras                              CentOS-6 - Extras                           enabled:    46
fasttrack                           CentOS-6 - fasttrack                        disabled
gkdaxue                             gkdaxue                                     enabled: 6,706
updates                             CentOS-6 - Updates                          enabled:   534
repolist: 13,999

## 比如我们现在的 gkdauxe 这个仓库在启用这, 然后我们使用命令行来将其关闭
[root@localhost ~]# yum repolist all | grep gkdaxue
gkdaxue                      gkdaxue                              enabled: 6,706
[root@localhost ~]# yum --disablerepo gkdaxue repolist all | grep gkdaxue
gkdaxue                      gkdaxue                              disabled
[root@localhost ~]# yum --enablerepo gkdaxue repolist all | grep gkdaxue
gkdaxue                      gkdaxue                              enabled: 6,706


## yum命令行选项 : 命令行的优先级高于 yum 配置文件的优先级
```

#### 显示程序包
```bash
## 查看所有的软件包
[root@localhost ~]# yum list | head     ## = yum list all | head
Loaded plugins: fastestmirror, refresh-packagekit, security
Loading mirror speeds from cached hostfile
 * base: mirrors.huaweicloud.com
 * extras: mirrors.cn99.com
 * updates: mirrors.cn99.com
Installed Packages
ConsoleKit.x86_64                  0.4.1-6.el6         @anaconda-CentOS-201703281317.x86_64/6.9
ConsoleKit-libs.x86_64             0.4.1-6.el6         @anaconda-CentOS-201703281317.x86_64/6.9
ConsoleKit-x11.x86_64              0.4.1-6.el6         @anaconda-CentOS-201703281317.x86_64/6.9
DeviceKit-power.x86_64             014-3.el6           @anaconda-CentOS-201703281317.x86_64/6.9


## 查看所有已经安装的包
[root@localhost ~]# yum list installed | head 
Loaded plugins: fastestmirror, refresh-packagekit, security
Installed Packages
ConsoleKit.x86_64       0.4.1-6.el6     @anaconda-CentOS-201703281317.x86_64/6.9
ConsoleKit-libs.x86_64  0.4.1-6.el6     @anaconda-CentOS-201703281317.x86_64/6.9
ConsoleKit-x11.x86_64   0.4.1-6.el6     @anaconda-CentOS-201703281317.x86_64/6.9
DeviceKit-power.x86_64  014-3.el6       @anaconda-CentOS-201703281317.x86_64/6.9
GConf2.x86_64           2.28.0-7.el6    @anaconda-CentOS-201703281317.x86_64/6.9
GConf2-gtk.x86_64       2.28.0-7.el6    @anaconda-CentOS-201703281317.x86_64/6.9
MAKEDEV.x86_64          3.24-6.el6      @anaconda-CentOS-201703281317.x86_64/6.9
ModemManager.x86_64     0.4.0-5.git20100628.el6
```

#### 查看程序包信息
```bash
[root@localhost ~]# yum info httpd
Loaded plugins: fastestmirror, refresh-packagekit, security
Loading mirror speeds from cached hostfile
 * base: mirrors.huaweicloud.com
 * extras: mirrors.cn99.com
 * updates: mirrors.cn99.com
Installed Packages
Name        : httpd
Arch        : x86_64
Version     : 2.2.15
Release     : 69.el6.centos
Size        : 3.0 M
Repo        : installed
From repo   : base                      <== 来源于那个仓库
Summary     : Apache HTTP Server        <== 概述
URL         : http://httpd.apache.org/
License     : ASL 2.0
Description : The Apache HTTP Server is a powerful, efficient, and extensible
            : web server.
```

#### 查看文件属于哪个软件包
```bash
[root@localhost ~]# yum provides /bin/ls
Loaded plugins: fastestmirror, refresh-packagekit, security
Loading mirror speeds from cached hostfile
 * base: mirrors.huaweicloud.com
 * extras: mirrors.cn99.com
 * updates: mirrors.cn99.com
coreutils-8.4-47.el6.x86_64 : A set of basic GNU tools commonly used in shell scripts
Repo        : base
Matched from:
Filename    : /bin/ls

coreutils-8.4-46.el6.x86_64 : A set of basic GNU tools commonly used in shell scripts
Repo        : gkdaxue
Matched from:
Filename    : /bin/ls

coreutils-8.4-46.el6.x86_64 : A set of basic GNU tools commonly used in shell scripts
Repo        : installed
Matched from:
Other       : Provides-match: /bin/ls
```

#### 根据关键字搜索包名
```bash
[root@localhost ~]# yum search httpd
Loaded plugins: fastestmirror, refresh-packagekit, security
Loading mirror speeds from cached hostfile
 * base: mirrors.huaweicloud.com
 * extras: mirrors.cn99.com
 * updates: mirrors.cn99.com
===================================== N/S Matched: httpd =====================================
libmicrohttpd-devel.i686 : Development files for libmicrohttpd
libmicrohttpd-devel.x86_64 : Development files for libmicrohttpd
libmicrohttpd-doc.noarch : Documentation for libmicrohttpd
httpd.x86_64 : Apache HTTP Server
httpd-devel.i686 : Development interfaces for the Apache HTTP server
httpd-devel.x86_64 : Development interfaces for the Apache HTTP server
httpd-manual.noarch : Documentation for the Apache HTTP server
httpd-tools.x86_64 : Tools for use with the Apache HTTP Server
libmicrohttpd.i686 : Lightweight library for embedding a webserver in applications
libmicrohttpd.x86_64 : Lightweight library for embedding a webserver in applications
mod_auth_mellon.x86_64 : A SAML 2.0 authentication module for the Apache Httpd Server
mod_dav_svn.x86_64 : Apache httpd module for Subversion server
mod_dnssd.x86_64 : An Apache HTTPD module which adds Zeroconf support

  Name and summary matches only, use "search all" for everything.
```

#### 清除本地缓存
```bash
packages : 将已下载的软件文件删除
headers  : 将下载的软件文件头删除
all      : 将所有容器数据都删除

[root@localhost ~]# yum clean all
Loaded plugins: fastestmirror, refresh-packagekit, security
Cleaning repos: base extras gkdaxue updates
Cleaning up Everything
Cleaning up list of fastest mirrors
```

#### 构建缓存
```bash
[root@localhost ~]# yum makecache
Loaded plugins: fastestmirror, refresh-packagekit, security
Determining fastest mirrors
 * base: mirrors.aliyun.com
 * extras: mirrors.163.com
 * updates: mirrors.cn99.com
base                                                                   | 3.7 kB     00:00     
base/group_gz                                                          | 242 kB     00:00     
base/filelists_db                                                      | 6.4 MB     00:01     
base/primary_db                                                        | 4.7 MB     00:00     
base/other_db                                                          | 2.8 MB     00:00     
extras                                                                 | 3.4 kB     00:00     
extras/filelists_db                                                    |  24 kB     00:00     
extras/prestodelta                                                     | 2.2 kB     00:00     
extras/primary_db                                                      |  29 kB     00:00     
extras/other_db                                                        |  14 kB     00:00     
gkdaxue                                                                | 4.0 kB     00:00 ... 
gkdaxue/group_gz                                                       | 226 kB     00:00 ... 
gkdaxue/filelists_db                                                   | 6.3 MB     00:00 ... 
gkdaxue/primary_db                                                     | 4.7 MB     00:00 ... 
gkdaxue/other_db                                                       | 2.7 MB     00:00 ... 
updates                                                                | 3.4 kB     00:00     
updates/filelists_db                                                   | 3.6 MB     00:01     
updates/prestodelta                                                    | 180 kB     00:00     
updates/primary_db                                                     | 5.1 MB     00:01     
updates/other_db                                                       | 251 kB     00:00     
Metadata Cache Created
```

#### 显示软件包的依赖关系
```bash
[root@localhost ~]# yum deplist httpd
Loaded plugins: fastestmirror, refresh-packagekit, security
Finding dependencies: 
Loading mirror speeds from cached hostfile
 * base: mirrors.aliyun.com
 * extras: mirrors.163.com
 * updates: mirrors.cn99.com
package: httpd.x86_64 2.2.15-69.el6.centos
  dependency: libc.so.6(GLIBC_2.4)(64bit)
   provider: glibc.x86_64 2.12-1.209.el6
   provider: glibc.x86_64 2.12-1.212.el6
   provider: glibc.x86_64 2.12-1.212.el6_10.3
  dependency: libz.so.1()(64bit)
   provider: zlib.x86_64 1.2.3-29.el6
   ...............
```

### createrepo命令 : 构建自己的 YUM 源
> createrepo [options] <directory>

```bash
## 我们现在自己尝试一下 YUM 源, 了解一下原理
## 操作之前, 先使用 VMwave 虚拟机创建一个快照, 因为我们要删除其他的仓库, 如果要还原比较麻烦
## 所以直接创建一个快照, 然后其他的仓库, 做完实验在还原快照就好了

## 1. 安装 createrepo  软件
[root@localhost ~]# yum remove httpd -y
[root@localhost ~]# yum install createrepo  -y

## 2. 自己创建一个 /yum/repo 目录用来存放软件
[root@localhost ~]# mkdir -p /yum/repo
[root@localhost ~]# cp /media/cdrom/Packages/httpd-2.2.15-59.el6.centos.x86_64.rpm  /yum/repo
cp /media/cdrom/Packages/httpd-tools-2.2.15-59.el6.centos.x86_64.rpm /yum/repo/
[root@localhost ~]# ll /yum/repo/
total 900
-r--r--r--. 1 root root 854072 Apr 28 08:51 httpd-2.2.15-59.el6.centos.x86_64.rpm
-r--r--r--. 1 root root  81180 Apr 28 09:32 httpd-tools-2.2.15-59.el6.centos.x86_64.rpm

## 3. 使用createrepo命令, 开始创建 repodata 系列文件
[root@localhost ~]# createrepo /yum/repo
Spawning worker 0 with 2 pkgs
Workers Finished
Gathering worker results

Saving Primary metadata
Saving file lists metadata
Saving other metadata
Generating sqlite DBs
Sqlite DBs complete
[root@localhost ~]# ll /yum/repo/
total 920
-r--r--r--. 1 root root 854072 Apr 28 08:51 httpd-2.2.15-59.el6.centos.x86_64.rpm
-r--r--r--. 1 root root  81180 Apr 28 09:32 httpd-tools-2.2.15-59.el6.centos.x86_64.rpm
drwxr-xr-x. 2 root root   4096 Apr 28 08:52 repodata

## 4. 修改 gkdaxue.repo 文件
[root@localhost ~]# vim /etc/yum.repos.d/gkdaxue.repo 
[gkdaxue]
name=gkdaxue
baseurl=file:///yum/repo          # <== 主要修改此行即可
enabled=1
gpgcheck=0

## 5. 删除其他的仓库, 只保留 gkdaxue 这个仓库          
[root@localhost ~]# rm -rf /etc/yum.repos.d/CentOS-*
[root@localhost ~]# ll /etc/yum.repos.d/
total 4
-rw-r--r--. 1 root root 69 Apr 28 08:53 gkdaxue.repo

## 6. 清除缓存, 然后重建缓存并安装文件
[root@localhost ~]# yum clean all
Loaded plugins: fastestmirror, refresh-packagekit, security
Cleaning repos: gkdaxue
Cleaning up Everything
Cleaning up list of fastest mirrors
[root@localhost ~]# yum makecache
Loaded plugins: fastestmirror, refresh-packagekit, security
Determining fastest mirrors
gkdaxue                                            | 4.0 kB     00:00 ... 
gkdaxue/group_gz                                   | 226 kB     00:00 ... 
gkdaxue/filelists_db                               | 6.3 MB     00:00 ... 
gkdaxue/primary_db                                 | 4.7 MB     00:00 ... 
gkdaxue/other_db                                   | 2.7 MB     00:00 ... 
Metadata Cache Created

## 7. 尝试安装 httpd 这个软件
[root@localhost ~]# yum install httpd -y
[root@localhost ~]# yum install httpd -y
Loaded plugins: fastestmirror, refresh-packagekit, security
Setting up Install Process
Loading mirror speeds from cached hostfile
Resolving Dependencies
--> Running transaction check
---> Package httpd.x86_64 0:2.2.15-59.el6.centos will be installed
--> Processing Dependency: httpd-tools = 2.2.15-59.el6.centos for package: httpd-2.2.15-59.el6.centos.x86_64
--> Finished Dependency Resolution
Error: Package: httpd-2.2.15-59.el6.centos.x86_64 (gkdaxue)
           Requires: httpd-tools = 2.2.15-59.el6.centos                 <== 要求的版本
           Installed: httpd-tools-2.2.15-69.el6.centos.x86_64 (@base)   <== 我们已经安装了这个版本
               httpd-tools = 2.2.15-69.el6.centos
           Available: httpd-tools-2.2.15-59.el6.centos.x86_64 (gkdaxue) <== 可用的版本  
                    httpd-tools = 2.2.15-59.el6.centos
 You could try using --skip-broken to work around the problem
 You could try running: rpm -Va --nofiles --nodigest
## 很明显我们的版本有点老了, 所以卸掉吧, 然后就可以重新安装了
[root@localhost ~]# yum remove httpd-tools
[root@localhost ~]# yum install httpd -y
[root@localhost ~]# yum info httpd httpd-tools
Loaded plugins: fastestmirror, refresh-packagekit, security
Loading mirror speeds from cached hostfile
Installed Packages
Name        : httpd
Arch        : x86_64
Version     : 2.2.15
Release     : 59.el6.centos
Size        : 3.0 M
Repo        : installed
From repo   : gkdaxue             <== 来源于这个仓库
Summary     : Apache HTTP Server
URL         : http://httpd.apache.org/
License     : ASL 2.0
Description : The Apache HTTP Server is a powerful, efficient, and extensible
            : web server.

Name        : httpd-tools
Arch        : x86_64
Version     : 2.2.15
Release     : 59.el6.centos
Size        : 138 k
Repo        : installed
From repo   : gkdaxue             <== 来源于这个仓库
Summary     : Tools for use with the Apache HTTP Server
URL         : http://httpd.apache.org/
License     : ASL 2.0
Description : The httpd-tools package contains tools which can be used with
            : the Apache HTTP Server.


## 还原环境, 使用 VMwave 的快照功能就好了.
```

## 软件的正确性
我们安装或者下载了一个软件, 那么如何确保我们的软件是正确没有被篡改? 我就遇到过一个系统被黑了, 把 netstat 等命令都被重新编译了, 所以你使用这些命令根本看不出来你的系统有任何的问题, 但是事实却是系统被黑了. 所以这个时候我们就需要来检验软件的正确性.
每个文件都有独特的指纹数据, 所以被篡改过后, 有些信息肯定会改变, 所以我们就可以使用 md5/sha1 来校验.

### md5sum命令/sha1sum命令 : 查看文件的指纹信息
```bash
## 生成两个文件, 仅仅只有一个空格只差
[root@localhost ~]# echo 'gkdaxue'  > gkdaxue.txt
[root@localhost ~]# echo 'gkdaxue ' > gkdaxue2.txt

[root@localhost ~]# md5sum gkdaxue*
67512949b143c49a7712a3061a336800  gkdaxue2.txt
544bfed48fd44346a4b27f17458172be  gkdaxue.txt

[root@localhost ~]# sha1sum gkdaxue*
9d5d315e3b1097e2539177fec44899e65627ae82  gkdaxue2.txt
02348c428dba9ef481a68409aac7f9685be442ae  gkdaxue.txt
``` 

