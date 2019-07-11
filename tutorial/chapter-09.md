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

### 