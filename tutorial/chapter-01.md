# 安装CentOS 6.9

## 实验环境

- Window7  64 位

- VMwave Workstation 12

- CentOS 6.9 64位

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

6. 磁盘大小( 40G )

   ![磁盘大小](https://github.com/gkdaxue/linux/raw/master/image/chapter_A1_006.png)

7. 选择下载的镜像

   ![选择镜像](https://github.com/gkdaxue/linux/raw/master/image/chapter_A1_007.png)

   > 因为我们之前选择的是 `稍后安装操作系统`, 所以在此处选择对应的镜像文件.

#### 完整安装过程

   完整安装过程如下图所示 :

![创建虚拟机](https://github.com/gkdaxue/linux/raw/master/image/chapter_A1_000.gif)

### 安装操作系统


