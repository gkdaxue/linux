在编写 shell 脚本时经常会用到需要判断的情况, 所以讲解一下

先讲解一下基础知识
    1. 可以 test 命令来判断之外,也可以使用 [](判断符号) 来进行数据的判断
    2. 两个等号(==)为判断(左右两边有空格), 一个等号(=)为变量的设置(左右不能有空格)
    3. # 号为注释, 后边的不会执行
    4. $? 表示的是上一条命令的执行结果 0 表示执行成功, 其他表示失败
    5. 条件1 && 条件2 : 条件1成立才会执行条件2
    6. 条件1 || 条件2 : 条件1不成立才会执行条件2

多重条件判断
    1. -a : (and)两个条件同时成立
    2. -o : (or) 两个条件任何一个成立

使用 [] 的注意事项
    1. 中括号内的每个组件都需要空格来分割
    2. 中括号内的变量最好用双引号包含起来
    3. 中括号内的常数,最好用单引号或双引号包含起来

比如定义一个变量为 name="www gkdaxue com",演示上面提到的事项, 请看案例
    --------------------------------   1 基础讲解   --------------------------------
    ## 定义一个变量,因为包含空格, 所以用引号包含起来, = 号左右没有空格
    [gkdaxue]# name='www gkdaxue com'

    ## 使用变量不用引号的情况, 报错,提示参数过多
    [gkdaxue]# [ ${name} == 'www gkdaxue com' ]
    -bash: [: too many arguments

    ## 相当于是这么操作的, 但是因为一个判断式仅能有两个数据的对比, 所以提示参数太多
    [gkdaxue]# [ www gkdaxue com == 'www gkdaxue com' ]
    -bash: [: too many arguments

    ## 使用引号包含起来, 可以使用
    [gkdaxue]# [ "${name}" == 'www gkdaxue com' ]

    ## 返回值是 0 说明两者是相等的
    [gkdaxue]# echo $?
    0
    
    
    ------------------------------   2 多重判断  -------------------------------
    ## -a : 表示两边都要满足条件
    [gkdaxue]# name='www gkdaxue com'
    
    ## 满足前边, 不满足后边
    [gkdaxue]# [ "${name}" == 'www gkdaxue com' -a "${name}" == 'www.gkdaxue.com' ]
    
    ## 所以上次命令执行失败, 返回非0(各个linux返回值可能不同,只要非0表示执行失败)
    [gkdaxue]# echo $?
    1
    
    ## 这个为啥是 0 呢, 因为表示的是上个命令执行, echo 成功执行, 所以是 0 
    [gkdaxue]# echo $?
    0
    
    ## 同理 -o : 只要满足一个即可,一个都不满足, 返回非 0 
    [gkdaxue]# name='www gkdaxue com'
    [gkdaxue]# [ "${name}" == 'www gkdaxue com' -o "${name}" == 'www.gkdaxue.com' ]
    [gkdaxue]# echo $?
    0
    
    ##  -o : 一个都不满足
    [gkdaxue]# [ "${name}" == 'www.gkdaxue.com' -o "${name}" == 'www.gkdaxue.com' ]
    [gkdaxue]# echo $?
    1
    
    
    ----------------------------   3 使用 && 和  ||  -------------------------------
    ## && 条件1执行成功, 执行条件 2
    [gkdaxue]# name='www gkdaxue com'
    
    ## 条件1 执行失败, 不执行条件2
    [gkdaxue]# [ "${name}" == 'www.gkdaxue.com' ] && echo 'equals'
    ## 条件1 执行成功, 执行条件2
    [gkdaxue]# [ "${name}" == 'www gkdaxue com' ] && echo 'equals'
    equals
    
    
    ## || 条件1执行失败, 执行条件2
    [gkdaxue]# name='www gkdaxue com'
    
    ## 条件1执行成功, 不执行条件2
    [gkdaxue]# [ "${name}" == 'www gkdaxue com' ] || echo 'no equals'
    # 条件1执行失败, 执行条件2
    [gkdaxue]# [ "${name}" == 'www.gkdaxue.com' ] || echo 'no equals'
    no equals
    
 



