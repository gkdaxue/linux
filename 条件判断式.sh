在编写 shell 脚本时经常会用到需要判断的情况, 所以讲解一下

先讲解一下基础知识
    1. 可以 test 命令来判断之外,也可以使用 [](判断符号) 来进行数据的判断
    2. 两个等号(==)为判断(左右两边有空格), 一个等号(=)为变量的设置(左右不能有空格)

使用 [] 的注意事项
    1. 中括号内的每个组件都需要空格来分割
    2. 中括号内的变量最好用双引号包含起来
    3. 中括号内的常数,最好用单引号或双引号包含起来

比如定义一个变量为 name="www gkdaxue com",判断时没有用引号包含起来.请看案例
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


