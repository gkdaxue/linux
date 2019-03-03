# 安装实验环境

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
