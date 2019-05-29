# Linux 磁盘与文件系统管理
## 硬盘组成与分区复习
**硬盘的组成 :**
> 1. 圆形的盘片(记录数据的部分)
> 2. 机械手臂以及机械手臂上的磁头(可读写盘片上的数据)
> 3. 主轴马达可以带动盘片旋转, 让机械手臂的磁头在盘片上读写数据

**盘片的物理组成 :**
> 1. 扇区(Sector)为最小的物理存储单位, 每个扇区 512bytes
> 2. 将扇区组成一个圆,那就是柱面(Cylinder), 柱面是分区(partition)的最小单位
> 3. 第一个扇区最重要, 包含Master Boot Record (MBR, 硬盘主引导记录) 及分区表 (partition table)
> ```bash
> MBR 446bytes
> partition table共64bytes, 每个分区需要占用 16bytes
> ```

**各种接口的磁盘在Linux中的文件名:**
> /dev/sd[a-p][1-15] : SCSI, SATA, USB 等接口
>
> /dev/hd[a-d][1-63] : IDE 接口的磁盘文件名
>
> /dev/vd[a-p] : Virtio 接口

    **磁盘分区**就是指定分区的起始与结束柱面. 指定分区的柱面范围被记录第一个扇区的分区表中. 但是分区表仅仅只有 64bytes, 一个分区要占用 16bytes, 因此最多只能记录四条分区的信息, 这四条记录我们称之为 **主分区或者扩展分区**, 可以在扩展分区上划分出来逻辑分区, (逻辑分区的大小最大为扩展分区的大小) **只有逻辑分区和主分区可以被格式化.**

**分区知识复习 :**
> 1. 主分区与扩展分区最多可以有4个(硬盘限制)
> 2. 扩展分区最多只能有一个 (操作系统的限制)
> 3. 逻辑分区是由扩展分区划分出来的, 逻辑分区的编号从 5 开始.
> 4. 能够被格式化的只有逻辑分区和主分区, 扩展分区无法格式化

    磁盘分区后还需要进行格式化操作后操作系统才可以使用这个分区, 那么为什么需要格式化呢? 这是因为每个操作系统所设置的 文件属性/权限 不同, 为了存放这些文件所需的数据, 因为就需要将分区进行格式化, 使之能够成为被操作系统所使用的文件系统格式.

    操作系统的文件除了有文件的实际内容之外, 还有很多的属性, 比如文件权限/文件属性(所有者, 所有组 时间等), 文件系统通常会把这两部分的数据分别存放在不同的块里面, 权限和属性放到 inode 中, 实际数据则被存放在 data block 中. 然后还有一个 超级块(super block) 来记录整个文件系统的整体信息. 包含inode 和 block 的总量 使用量 剩余量 等等. 每个 inode 和 block 都有编号.
> super block : 记录此文件系统的整体信息. 包含 inode/block 的总量, 使用量, 剩余量以及文件系统的格式与相关信息等
>
> inode : 记录文件的属性, 一个文件占用一个 inode, 同时记录此文件的数据所在的 block 号码
> 
> block : 实际记录文件的内容, 如果文件很大, 则会占用多个 block

    文件系统会在格式化的时候, 先格式化出 inode 和 block 块, 除非重新格式化(或者使用resize2fs等命令) 否则 inode 和 block 固定后就不会在变动. 并且 inode/block 都有编号, 每个文件都会有一个 inode, inode内则存放了数据的属性信息和 block 号码, 所以只要找到该文件的 inode 号, 我们就可以找到 block 的位置, 就能够读取该文件的数据内容. 这种数据访问的方法我们称之为 ` 索引式文件系统 `.  
> 文件系统的最前面有一个启动扇区(boot sector), 这个启动扇区可以安装引导装载程序, 如此一来, 我们就可以将不同的引导装载程序安装到文件系统的最前面, 而不是覆盖硬盘上的唯一MBR, 这样我们才能实现多重引导的环境, 也就是多操作系统的功能.

那么我们来想象一个问题, 如果我们有一个1T的硬盘, 然后划分成两个分区, 一个分区500G左右, 那么所有的 inode 和 block 的数量会很大, 所以将所有的 inode 和 block 放置在一起是不明智的决定, 其实在格式化的时候是区分多个块组(block group)的, 每个块组都有独立的 inode/block/`super block` 系统. 分组之后比较好管理. 如下图所示

![partition_disk](https://github.com/gkdaxue/linux/raw/master/image/chapter_A7_0001.png)

### data block
data block 是实际放置文件内容的地方, **block 的大小有 1KB  2KB  4KB 三种大小**, 在格式化时 block 的大小就固定了. 并且每个 block 都有编号方便 inode 来记录. 由于 block 的大小会影响到文件系统能够支持的最大单一文件容量和最大磁盘容量.
> 原则上, block 的大小和数量在格式化完成后就不能在改变(除非重新格式化)
>
> **block 的大小有 1KB  2KB  4KB 三种大小**
>
> 每个 block 内只能放置一个文件的数据. (每个block仅能容纳一个文件的数据)
>
> 如果文件的大小大于 block 的大小, 那么会占用多个 block 块
>
> 如果文件的大小小于 block 的大小, 那么 block 剩余的空间也无法被利用(磁盘空间会浪费)

| block 大小 | 1kb | 2kb | 4kb |
| -------- | ---- | ----| ---- |
| 最大单一文件 | 16GB | 256GB | 2TB |
| 最大文件系统总容量 | 2TB | 8TB | 16TB |

#### 磁盘空间浪费
文件系统使用 4kb 的 block, 并且有 10000 个文件, 每个文件的大小为 50 bytes, 那么磁盘浪费了多少容量 ?
> 1KB = 1024bytes
>
> 1MB = 1024KB

```bash
总文件占用的磁盘容量 : ( 50 * 10000 ) / 1024 = 488.28KB
浪费的磁盘容量 : ( 4 * 1024 - 50 ) * 10000 / 1024 / 1024 = 38.58MB

但是如果 block 的大小太小, 大型文件将会占用更多数量的 block, 而 inode 也需要记录更多的 block 号码, 读写性能变差.

总文件仅仅只占用了 488.28KB, 浪费了 38.58MB, 所以突出了划分 block 大小的重要性.
```

### inode table
inode 的内容主要记录文件的属性以及该文件实际数据存在 block 号码. inode 记录的文件数据至少包含下面几个方面 : 
> 该文件的访问权限 ( read/write/excute )
>
> 该文件爱你的所有者 所有组 ( owner/group )
>
> 该文件的大小
>
> 该文件的创建时间(ctime), 最后一次读取时间(atime), 最近修改的时间(mtime)
>
> 该文件的真实内容指向 ( pointer )

**inode 的数量和大小在格式化时就已经固定了**, inode 的特点如下 :
> 1. **每个 inode 的大小为 128bytes 或 256bytes **
> 2. **inode 记录一个 block 的号码需要 4bytes**
> 3. 每个文件仅会占用一个inode, 所以我们可以通过判断 inode 号码来确认不同文件名是不是同一个文件.
> 4. 文件系统能够创建文件的数量与inode的数量有关
> 5. 系统读取文件时,需要先找到 inode, 然后在分析权限, 权限符合才开始读取 block 的内容

    我们现在来分析一下, 一个 inode 的大小只有 128bytes, 记录一个 block 需要 4bytes, 我们按照 block 为 4KB 计算,  那么我们计算一个 inode 最大记录的文件大小为 ( 128 / 4) \* 4KB = 128KB, **一个文件只有一个 inode**, 最大也只有 128 KB, 难道我们的文件最大只能 128KB ? 当然不是.
> inode 记录 block 的号码的区域划分为 ` 12个直接 `  ` 一个间接 `  ` 一个双间接 ` ` 一个三间接 `  记录区. 

![inode_record_block](https://github.com/gkdaxue/linux/raw/master/image/chapter_A7_0002.png)

    最左边的为 inode本身(128bytes), 里面有 12 个可以直接指向 block 号码的指针, 这 12 个记录能够直接取得 block 号码. 间接的意思是在拿一个 block 块作为记录 block 号码的记录区, 如果文件太大, 会利用间接的 block 来记录. 那么这样的 inode 最大单一文件限制是多少呢? 我们用 block 为 1KB 来计算.

> 12个直接 : 12 * 1KB = 12KB
>
> 一个间接 : ( 1KB / 4bytes ) \* 1KB = 256KB
>
> 一个双间接 : 256 \* 256 \* 1KB = 256²KB
>
> 一个三间接 : 256 \* 256 \* 256 \* 1KB = 256³KB
>
> block 为 1KB, 单一文件总大小为 12直接 + 一个间接 + 一个双间接 + 一个三间接 = 16GB 和之前所说的吻合.

### block bitmap
我们在添加文件时, 总会用到 block 来记录文件的实际内容, 那么系统如何知道应该使用哪个空的 block 来记录呢, 这就需要用到 block bitmap 的帮助了, 从 block bitmap 中可以知道哪些 block 是空的, 这样我们就可以使用空的 block 来存放文件的数据. 同理, 当删除文件时, 那么原本文件占用的 block 就要被释放, 也应该从 block bitmap 中删除对应 block 块已经被使用的信息, 恢复为未被使用.

### inode bitmap
inode bitmap 的作用和 block bitmap 的作用类似, 只不过 inode bitmap 记录的是 inode 的使用情况.

### File System Descripition
描述每个 block group 开始和结束的 block 号码, 以及说明每个区段的(super block, block bitmap, inode bitmap, data block) 分别位于哪一个 block 号码之间.

### Super block
Super block 是记录整个文件系统相关信息的地方, 一般它的大小为 1024bytes, 可以通过 dumpe2fs命令来查看. 它记录的信息包含:
> 1. block 与 inode 的使用量
> 2. 未使用/已使用  block inode 的数量
> 3. block 与 inode 的大小 (block 有 1KB 2KB 4KB 三种, inode 为 128bytes  256bytes  )
> 4. 文件系统的挂载时间, 最后一次写入数据的时间等
> 5. 文件系统是否挂载的标志位 valid bit 数值,  已挂载 valid bit 为 0, 未挂载 valid bit 为 1.

**注意 :**
> 每个block group 都可能含有 super block, 但是我们也说了, 一个文件系统已经仅有一个super block, 那么到底是怎么回事呢? 事实上除了第一个 block group 内还有 super block之外, 后续的 block group中不一定含有 super block, 如果含有 super block, 则是作为第一个 block group 中 super block 的备份. 这样可以在 super block 损坏时, 进行救援工作, 恢复数据.

### dumpe2fs命令
显示 ext2/ext3/ext4 文件系统信息
> dumpe2fs [ options ] 设备文件名

| 选项 | 作用 |
|---- |----|
| -h | 仅列出 super block 的数据 |

#### 实例
```bash
## block 大小为 1KB 2KB  4KB 时, 会有不同的情况, 这里只要了解即可, 不需要深入了解
[root@localhost ~]# dumpe2fs /dev/sda5 | head -n 100
dumpe2fs 1.41.12 (17-May-2010)
Filesystem volume name:   <none>  <== 文件系统的名称
Last mounted on:          /       <== 最后一次挂载的位置
Filesystem UUID:          64af9fff-884d-4cf2-afe6-ba3f7869cf35  <== 文件系统 UUID
Filesystem magic number:  0xEF53
Filesystem revision #:    1 (dynamic)
Filesystem features:      has_journal ext_attr resize_inode dir_index filetype extra_isize
Filesystem flags:         signed_directory_hash 
Default mount options:    user_xattr acl  <== 默认挂载的参数
Filesystem state:         clean           <== 文件系统的状态
Errors behavior:          Continue
Filesystem OS type:       Linux
Inode count:              128000  <== inode 的总数
Block count:              512000  <== block 的总数
Reserved block count:     25600
Free blocks:              418217  <== 未使用 block 的数量
Free inodes:              120712  <== 未使用 inode 的数量
First block:              0
Block size:               4096    <== block 块的大小为 4K = 4096 bytes 
Fragment size:            4096
Reserved GDT blocks:      124
Blocks per group:         32768
Fragments per group:      32768
Inodes per group:         8000
Inode blocks per group:   500
Flex block group size:    16
Filesystem created:       Sun Mar  3 11:31:46 2019
Last mount time:          Sun Mar  3 14:41:55 2019
Last write time:          Sun Mar  3 11:42:41 2019
Mount count:              5
Maximum mount count:      -1
Last checked:             Sun Mar  3 11:31:46 2019
Check interval:           0 (<none>)
Lifetime writes:          499 MB
Reserved blocks uid:      0 (user root)
Reserved blocks gid:      0 (group root)
First inode:              11
Inode size:	              256       <== inode 的大小为 256bytes
Required extra isize:     28
Desired extra isize:      28
Journal inode:            8
Default directory hash:   half_md4
Directory Hash Seed:      409e41ee-f377-4270-a43f-7bac33b58f58
Journal backup:           inode blocks
Journal features:         journal_incompat_revoke
Journal size:             32M
Journal length:           8192
Journal sequence:         0x00000245
Journal start:            1


Group 0: (Blocks 0-32767) [ITABLE_ZEROED] <== 第一个 block group 的起始 结束号码
  Checksum 0x5744, unused inodes 604
  Primary superblock at 0, Group descriptors at 1-1  <== 超级块在 0 号 block
  Reserved GDT blocks at 2-125
  Block bitmap at 126 (+126), Inode bitmap at 142 (+142)
  Inode table at 158-657 (+158)                       <== inode table 所在的 block
  23671 free blocks, 608 free inodes, 888 directories, 604 unused inodes
  Free blocks: 9097-32767                              <== 未使用的 block 号码
  Free inodes: 7367, 7392, 7394, 7396-8000             <== 未使用的 inode 号码
Group 1: (Blocks 32768-65535) [ITABLE_ZEROED]
  Checksum 0x488b, unused inodes 7991
  Backup superblock at 32768, Group descriptors at 32769-32769 <== super block 备份在 32768
  Reserved GDT blocks at 32770-32893
  Block bitmap at 127 (+4294934655), Inode bitmap at 143 (+4294934671)
  Inode table at 658-1157 (+4294935186)
  6191 free blocks, 7991 free inodes, 9 directories, 7991 unused inodes
  Free blocks: 32904-32919, 33164-33175, 33220-33255, 33268-33271, 33520-33523, 33529, 33531-33540, 33568-33569, 33711, 33918-34387, 34438-34463, 34482-34593, 34600-34602, 34607-34608, 34612-34639, 34720-34793, 34796-34799, 35239, 35285-35540, 35542-35638, 35640-35724, 35735-35811, 35823, 35834-35839, 35869-35871, 35880-35887, 35890-35891, 35896, 35898, 35900-36386, 36427-36436, 36498-36527, 36530-37173, 37184-37553, 37614-37615, 37619-37736, 37743, 37769-37821, 37871, 37880-37962, 37984-37998, 38023, 38032-38034, 38055, 38060-38062, 38064-38071, 38076, 38098-38103, 38138-38139, 38183, 38230, 38251, 38275, 38297-38298, 38312, 38329, 38526-38527, 38564-38575, 38607-38610, 38614-38615, 38638-38639, 38643-38647, 38669-38765, 38811-38812, 38820-38822, 38906-39291, 39296-39327, 39340, 39470-39495, 39504-39519, 39538-39552, 39568-39684, 39693, 39696-39929, 39939-39974, 40005-40018, 40020-40023, 40216-40233, 40236-40239, 40289-40529, 40536-40571, 40770-40824, 40828-40831, 40960-41221, 41224-41340, 41732-41757, 42022-42035, 42040-42047, 42080-42087, 42694-42707, 42709-42721, 42732-42790, 42792-42860, 42893-42897, 42904-42911, 42913-42930, 42932-42978, 42998-43002, 43006-43137, 43664-43673, 43676-43678, 43726-43768, 43904-43909, 43912-43922, 44000-44031, 44096-44151, 44176-44177, 44200-44252, 45482-45501, 45664-45677, 45680-45699, 46368-46379, 49866-49887, 49936-49985, 50192-50214, 50216-50238, 50240-50284, 50286-50338, 50340-50346, 50348-50385, 50490-50497, 50502-50509, 50514-50515, 50522, 50524-50525, 50846-50847, 50880-50888, 50908-50917, 50922-51012, 51049-51055, 51088-51191, 51431-51439, 51445-51450, 51496-51501, 51577-51581, 51670-51672, 51679-51680, 51692, 51694-51697, 51699-51702
  Free inodes: 8010-16000
Group 2: (Blocks 65536-98303) [ITABLE_ZEROED]
  Checksum 0xbd46, unused inodes 7995
  Block bitmap at 128 (+4294901888), Inode bitmap at 144 (+4294901904)
  Inode table at 1158-1657 (+4294902918)
  158 free blocks, 7995 free inodes, 5 directories, 7995 unused inodes
  Free blocks: 88576-88589, 91248-91259, 91288-91295, 91654-91659, 91692-91693, 91704-91706, 91811-91822, 92264-92286, 92442-92505, 92521-92534
  Free inodes: 16006-24000
Group 3: (Blocks 98304-131071) [ITABLE_ZEROED]
  Checksum 0x70e7, unused inodes 7998
  Backup superblock at 98304, Group descriptors at 98305-98305
  Reserved GDT blocks at 98306-98429
  Block bitmap at 129 (+4294869121), Inode bitmap at 145 (+4294869137)
  Inode table at 1658-2157 (+4294870650)
  15697 free blocks, 7998 free inodes, 2 directories, 7998 unused inodes
  Free blocks: 102428-102431, 102495, 104318-104319, 105750-105767, 105981-105983, 107134-107135, 107546-107548, 109055, 109059-109074, 109076-109567, 113110-113111, 113185-113191, 115925-116224, 116226-131071
  Free inodes: 24003-32000
......................
```

## 和目录树之间的关联
在之前的讲解中. 我们知道了每个文件(不论是一般文件或者目录)都会占用一个 inode 并且可以根据文件内容的大小来分配多个 block 给该文件使用. 那么目录和文件是如何记录数据的呢?
### 目录
我们新建一个目录时, 系统会分配一个 inode 与 至少一个 block 块给该目录, 其中 inode 记录的是该目录的相关权限和属性并记录分配到的 block 号码, 而 block 则是记录了该目录下的文件名与该文件名占用的 inode 号码数据. 那么我们来查看一下 /root 下文件所占用的 inode 号码.
```bash
[root@localhost ~]# ll -i
total 104
inode   <== 此列出现的就是文件的 inode 号码
7249 -rw-------. 1 root root  1638 Mar  3 11:42 anaconda-ks.cfg
 149 drwxr-xr-x. 2 root root  4096 Mar  3 14:42 Desktop
 168 drwxr-xr-x. 2 root root  4096 Mar  3 14:42 Documents
 151 drwxr-xr-x. 2 root root  4096 Mar  3 14:42 Downloads
  18 -rw-r--r--. 1 root root 50698 Mar  3 11:42 install.log
  30 -rw-r--r--. 1 root root 10031 Mar  3 11:39 install.log.syslog
 175 drwxr-xr-x. 2 root root  4096 Mar  3 14:42 Music
 178 drwxr-xr-x. 2 root root  4096 Mar  3 14:42 Pictures
 162 drwxr-xr-x. 2 root root  4096 Mar  3 14:42 Public
 155 drwxr-xr-x. 2 root root  4096 Mar  3 14:42 Templates
 180 drwxr-xr-x. 2 root root  4096 Mar  3 14:42 Videos

## 我们也可以使用 stat 命令来查看单一文件的信息
[root@localhost ~]# stat anaconda-ks.cfg 
  File: `anaconda-ks.cfg'
  Size: 1638      	Blocks: 8    IO Block: 4096   regular file
Device: 805h/2053d	Inode: 7249 <== inode 号码       Links: 1
Access: (0600/-rw-------)  Uid: (    0/    root)   Gid: (    0/    root)
Access: 2019-03-03 11:42:05.698998407 +0800
Modify: 2019-03-03 11:42:06.168998405 +0800
Change: 2019-03-03 11:42:22.232998400 +0800

## 我的 block size 为 4k 的, 所以每个目录基本上都是 4k 的整数倍, /boot 为独立的分区, 大小为 1k, 所以为 1024bytes.
[root@localhost ~]# ll -d / /bin /boot
dr-xr-xr-x. 25 root root 4096 Mar  3 14:41 /
dr-xr-xr-x.  2 root root 4096 Mar  3 12:27 /bin
dr-xr-xr-x.  5 root root 1024 Mar  3 11:41 /boot
```

### 文件
当我们新建一个文件时, 会分配一个 inode 和 若干数量的 block 给该文件. 那么问题来了, 假设我的 block 大小为 4KB, 我要新建一个 100KB 大小的文件, 那么需要多少块 block ?
> 100 / 4 = 25 ? 这是正确的 block 块数量吗, 其实不对, 应该是 26, 因为只有 12直接, 需要单独使用一个块,作为间接来使用. 所以为 26 块.

### 目录树的读取
   inode 不记录文件名, 文件名被记录在 block 当中, 并且 新增/删除/重命名文件名 和目录的 w 权限有关. 因为文件名是记录在 block 块当中的, 因此我们读取某个文件时, 肯定会经过目录的 inode 和 block , 然后才能找到待读取文件的 inode, 然后才能读取到正确的 block 内的数据.
   目录树是从根目录开始读取的. 系统通过挂载的信息可以找到挂载点的 inode 号码, (通常一个文件系统的最顶层的 inode 号码会由 2 号开始), 这样就可以得到根目录下的 inode 内容, 然后在通过 inode 读取 block 内的文件名, 然后逐层的找到正确的数据. 下面我们以 gkdaxue 用户的身份来读取 /etc/passwd 这个文件为例来说明.
```bash
[root@localhost ~]# ll -di / /etc /etc/passwd
    2 dr-xr-xr-x.  25 root root  4096 Mar  3 14:41 /
32002 drwxr-xr-x. 118 root root 12288 Mar  3 15:05 /etc
 7395 -rw-r--r--.   1 root root  1617 Mar  3 15:04 /etc/passwd
```
> 1. 通过挂载点信息找到根目录的 inode 的号码为 2 且可以让我们读取根目录下 block 的内容( r-x 权限), 通过 block 的内容, 取得 etc 文件的 inode 号码(32002)
> 2. 读取 etc 的 inode(32002) 信息, 拥有(r-x) 权限, 可以读取 etc 的 block 内容, 找到 passwd文件的 inode (7395)
> 3. 读取 passwd文件的 inode, 只有(r--)权限, 因此可以读取 passwd block 的内容, 通过找到对应的 block 块, 我们就可以得到文件内容.

### 新建 文件/目录 步骤
> 1. 先确定用户对于想要操作的目录是否具有 wx 权限, 如果有才能添加
> 2. 先根据 inode bitmap 找到没有使用的 inode 号码, 并把新文件 权限/属性 写入
> 3. 在根据 block bitmap 找到没有使用的 block 号码, 并将实际数据写入到 block 中, 更新 inode 的 block指向数据
> 4. 将刚才写入的 inode 和 block 数据同步更新到 inode bitmap 和 block bitmap, 并更新 super block 的内容

### 日志文件系统
   一般我们将 inode table 与 data block 称为数据存放区域, 至于其他的例如 super block, block bitmap, inode bitmpa 称为 metadata(元数据), 因为这些信息是经常变动的, 每次 增加/删除/编辑 时都会发生变化都有可能会影响到这三个部分的数据, 所以被称为 metadata.

   我们知道了新建 文件/目录 时, 系统做了哪些操作, 但是天有不测风云, 在处理到第3步骤时系统突然断电了, 那么就会产生数据不一致的情况, 这就突出了 日志文件系统(Journaling file system) 的重要性. 万一数据的记录过程中发生了问题, 我们就可以检查日志记录块内容就可以快速的修复文件系统.

#### 操作步骤
在文件系统中划分出来一个块, 用来记录写入或者修改文件的步骤.
> 1. 预备: 当系统要写入一个文件的时候, 会在日志块中记录某个文件准备写入的信息
> 2. 实际写入: 开始写入文件的权限和数据, 开始更新 metadata数据
> 3. 结束: 完成数据和metadata的更新后, 在日志块中完成该文件的记录.

### 文件系统的优化操作
   所有的数据只有加载到内存后CPU才能对该数据进行处理, 但是如果是一个很大的文件的话, 在编辑的过程中又要频繁的写入到磁盘中, 但是磁盘的写入速度要比内存慢的多, 因此效率真的很低, 所以就有了优化的操作. Linux 通过一个称为异步处理(asynchronously)的方式.
>    系统加载一个文件到内存后, 如果该文件没有被修改过, 那么在内存中的文件数据就会被设置为 clean 的, 如果被修改过, 那么会被设置为 Dirty, 此时所有的操作还是在内存中执行并没有写入到硬盘中, 然后系统会不定时的把内存中的 Dirty 的数据写回到磁盘中, 以保持磁盘和内存数据的一致性. 所以这就是为什么有的时候我们关机的时候要执行 sync 命令.

系统常用的优化操作:
> 1. 系统会将常用的文件数据放置在主存储器的缓冲区, 加速文件系统的 读/写.
> 2. Linux 上的物理内存有的时候会被用光, 这是正常现象, 可以加速系统系统
> 3. 可以手动执行 sync 命令来强制把内存中的设置为 Dirty 的文件回写到磁盘上
> 4. 正常关机时, 关机命令会主动调用 sync 命令将数据写回到磁盘中.

### 挂载点(mount point)的意义
每个文件系统都有独立的 inode, block, super block 等信息, 这些文件系统要关联到目录树才能被我们使用. **将文件系统与目录树结合的操作我们称之为挂载.** 挂载点一定是目录并且该目录作为访问该文件系统的入口. 根目录的上层(/..) 是它自己.

### 虚拟文件系统 VFS
我们的 Linux 系统支持很多的文件系统, 如下所示, 但是那么多文件系统, 内核又是怎么识别和管理这些文件系统的呢? 其实整个 Linux 系统都是通过 Virtual File System(虚拟文件系统) 的内核功能来读取文件系统. 省去我们需要自行设置读取文件系统的定义.

```bash
[root@localhost ~]# ls -l /lib/modules/2.6.32-696.el6.x86_64/kernel/fs/
total 132
drwxr-xr-x. 2 root root  4096 Mar  3 11:37 autofs4
drwxr-xr-x. 2 root root  4096 Mar  3 11:37 btrfs
drwxr-xr-x. 2 root root  4096 Mar  3 11:37 cachefiles
drwxr-xr-x. 2 root root  4096 Mar  3 11:37 cifs
drwxr-xr-x. 2 root root  4096 Mar  3 11:37 configfs
drwxr-xr-x. 2 root root  4096 Mar  3 11:37 cramfs
drwxr-xr-x. 2 root root  4096 Mar  3 11:37 dlm
drwxr-xr-x. 2 root root  4096 Mar  3 11:37 ecryptfs
drwxr-xr-x. 2 root root  4096 Mar  3 11:37 exportfs
drwxr-xr-x. 2 root root  4096 Mar  3 11:37 ext2
drwxr-xr-x. 2 root root  4096 Mar  3 11:37 ext3
drwxr-xr-x. 2 root root  4096 Mar  3 11:37 ext4
drwxr-xr-x. 2 root root  4096 Mar  3 11:37 fat
drwxr-xr-x. 2 root root  4096 Mar  3 11:37 fscache
drwxr-xr-x. 2 root root  4096 Mar  3 11:37 fuse
drwxr-xr-x. 2 root root  4096 Mar  3 11:37 gfs2
drwxr-xr-x. 2 root root  4096 Mar  3 11:37 jbd
drwxr-xr-x. 2 root root  4096 Mar  3 11:37 jbd2
drwxr-xr-x. 2 root root  4096 Mar  3 11:37 jffs2
drwxr-xr-x. 2 root root  4096 Mar  3 11:37 lockd
-rwxr--r--. 1 root root 19944 Mar 22  2017 mbcache.ko
drwxr-xr-x. 2 root root  4096 Mar  3 11:37 nfs
drwxr-xr-x. 2 root root  4096 Mar  3 11:37 nfs_common
drwxr-xr-x. 2 root root  4096 Mar  3 11:37 nfsd
drwxr-xr-x. 2 root root  4096 Mar  3 11:37 nls
drwxr-xr-x. 2 root root  4096 Mar  3 11:37 squashfs
drwxr-xr-x. 2 root root  4096 Mar  3 11:37 ubifs
drwxr-xr-x. 2 root root  4096 Mar  3 11:37 udf
drwxr-xr-x. 2 root root  4096 Mar  3 11:37 xfs
```

![VFS](https://github.com/gkdaxue/linux/raw/master/image/chapter_A7_0003.png)

## 磁盘的分区 格式化 检验 和挂载
### df命令
报告文件系统磁盘空间使用情况
> df [ options ] [ FILE ]....

| 选项 | 作用 |
| ---- | ---- |
| -a | 列出所有的文件系统, 包含 /proc 等 |
| -h | 人性化显示大小(KB, MB, GB) |
| -T | 列出文件系统的类型 |
| -i | 以 inode 的数量来显示 |

#### 实例
```bash
## 默认将所有的显示出来(不包含特殊内存内的文件以及 swap), 都以 1KB 的容量列出来.
[root@localhost ~]# df
Filesystem                1K-blocks    Used Available Use% Mounted on
/dev/sda5                   1983056  310756   1569900  17% /
tmpfs                      	 502056     224    501832   1% /dev/shm
/dev/sda1                  	 194241   35163    148838  20% /boot
/dev/mapper/server-myhome	4904448   10052   4638604   1% /home
/dev/sda8                    991512    1420    938892   1% /tmp
/dev/sda3                   3966144 3070696    690648  82% /usr
/dev/sda6                   1983056   88104   1792552   5% /var
/dev/sr0                    3878870 3878870         0 100% /media/CentOS_6.9_Final

## -T 显示出来文件系统类型 ( Type 列) 
[root@localhost ~]# df -T 
Filesystem           		Type    1K-blocks    Used Available Use% Mounted on
/dev/sda5            		ext4      1983056  310756   1569900  17% /
tmpfs                		tmpfs      502056     224    501832   1% /dev/shm
/dev/sda1            		ext4       194241   35163    148838  20% /boot
/dev/mapper/server-myhome	ext4      4904448   10052   4638604   1% /home
/dev/sda8            		ext4       991512    1420    938892   1% /tmp
/dev/sda3            		ext4      3966144 3070696    690648  82% /usr
/dev/sda6            		ext4      1983056   88120   1792536   5% /var
/dev/sr0             		iso9660   3878870 3878870         0 100% /media/CentOS_6.9_Final

## -h 人性化显示容量大小
[root@localhost ~]# df -h
Filesystem            		Size  Used Avail Use% Mounted on
/dev/sda5             		1.9G  304M  1.5G  17% /
tmpfs                 		491M  224K  491M   1% /dev/shm
/dev/sda1             		190M   35M  146M  20% /boot
/dev/mapper/server-myhome	4.7G  9.9M  4.5G   1% /home
/dev/sda8             		969M  1.4M  917M   1% /tmp
/dev/sda3             		3.8G  3.0G  675M  82% /usr
/dev/sda6             		1.9G   87M  1.8G   5% /var
/dev/sr0              		3.7G  3.7G     0 100% /media/CentOS_6.9_Final

## -a 显示所有的文件系统
[root@localhost ~]# df -a
                           说明下面得到数字单位为1kb              挂载点
Filesystem           		1K-blocks    Used Available Use% Mounted on
/dev/sda5              		  1983056  310756   1569900  17% /
proc                                0       0         0    - /proc   <== 内存内的文件系统
sysfs                        		0       0         0    - /sys
devpts                       		0       0         0    - /dev/pts
tmpfs                   	   502056     224    501832   1% /dev/shm
/dev/sda1               	   194241   35163    148838  20% /boot
/dev/mapper/server-myhome     4904448   10052   4638604   1% /home
/dev/sda8                      991512    1420    938892   1% /tmp
/dev/sda3                     3966144 3070696    690648  82% /usr
/dev/sda6                     1983056   88120   1792536   5% /var
none                                0       0         0    - /proc/sys/fs/binfmt_misc
/dev/sr0                      3878870 3878870         0 100% /media/CentOS_6.9_Final

## -i
[root@localhost ~]# df -ai
代表该文件是在哪个分区
Filesystem           		Inodes IUsed  IFree IUse% Mounted on
/dev/sda5            		128000  7413 120587    6% /
proc                      		0     0      0     - /proc
sysfs                     		0     0      0     - /sys
devpts                    		0     0      0     - /dev/pts
tmpfs                	   125514     5 125509    1% /dev/shm
/dev/sda1                   51200    38  51162    1% /boot
/dev/mapper/server-myhome  320000    22 319978    1% /home
/dev/sda8                   64000    75  63925    1% /tmp
/dev/sda3                  256000 92185 163815   37% /usr
/dev/sda6                  128000  3067 124933    3% /var
none                            0     0      0     - /proc/sys/fs/binfmt_misc
/dev/sr0                        0     0      0     - /media/CentOS_6.9_Final
```

### du命令
显示目录或者文件的大小, 默认情况下是以 KB 输出的.
> du [ options ] FILE_NAME

| 选项 | 作用 |
| ---- | ----- |
| -s | 列出总量, 而不是每个目录的大小 |
| -m | 以 MB 大小显示 |
| -a | 显示所有的文件和目录大小, 默认只显示目录 | 
| -h | 人性化显示大小 |

#### 实例
```bash
## 可以使用 * 通配符来代表每个目录
[root@localhost ~]# du
4	./Desktop
4	./Documents
4	./Videos
4	./Music
4	./Downloads
4	./Public
4	./Templates
4	./Pictures
108	.     <== 默认显示所有文件夹的

[root@localhost ~]# du -a
56	./install.log
4	./Desktop
4	./Documents
4	./Videos
4	./anaconda-ks.cfg
4	./Music
4	./Downloads
4	./Public
4	./Templates
12	./install.log.syslog
4	./Pictures
108	.

[root@localhost ~]# du -s .
108	.
```

### ln命令
我们以前讲 ls -l 命令的时候, 回忆一下第二字段是什么意思? 然后我们发现了问题, 文件基本上都是 1, 文件夹都是 2 , 然后我们现在来分析一下.
> ln [ options ] 源文件 目标文件

| 选项 | 作用 |
| --- | ----|
| -s | 创建一个符号连接, 不加默认为硬链接 |
| -f | 如果目标文件, 则删除目标文件在创建 | 

```bash
[root@localhost ~]# ls -l
total 104
-rw-------. 1 root root  1638 Mar  3 11:42 anaconda-ks.cfg
drwxr-xr-x. 2 root root  4096 Mar  3 14:42 Desktop
drwxr-xr-x. 2 root root  4096 Mar  3 14:42 Documents
drwxr-xr-x. 2 root root  4096 Mar  3 14:42 Downloads
-rw-r--r--. 1 root root 50698 Mar  3 11:42 install.log

## 发现他们的 inode 的号码一致, 所以表示 Desktop 和 Desktop/.  是同一个文件. 所以为 2
[root@localhost ~]# ls -lid Desktop/ Desktop/.
149 drwxr-xr-x. 2 root root 4096 Mar  3 14:42 Desktop/
149 drwxr-xr-x. 2 root root 4096 Mar  3 14:42 Desktop/.
...............
```

**在 Linux 下面的链接文件分为两种, 一种是类似 Windows 中快捷方式功能的文件 称为符号链接(symbolic link), 还有一种就是通过文件系统的 inode 链接来产生新文件名, 而不是产生新文件. 称为硬链接(hard link).**

然后我们来复习一下之前所说的知识点 :
> 1. 每个文件都会占用一个 inode, 文件内容由 inode 的记录来指向
> 2. 想要读取文件, 必须经过该目录记录的文件名来找到正确的 inode 才可以读取.
> 3. 文件名只和目录有关, 但是文件内容则和 inode 有关.

#### 硬链接(hard link)
hard link 只是在某个目录下新建一个 **文件名连接到某 inode 号码的关联记录** 而已.

```bash
## ln 默认创建硬链接
[root@localhost ~]# ll -i anaconda-ks.cfg 
7249 -rw-------. 1 root root 1638 Mar  3 11:42 anaconda-ks.cfg        <== 链接数为 1
[root@localhost ~]# ln anaconda-ks.cfg  anaconda-ks.cfg.hard

## 它们的 inode 一样, 所以是同一个文件.
[root@localhost ~]# ll -i anaconda-ks.cfg* 
7249 -rw-------. 2 root root 1638 Mar  3 11:42 anaconda-ks.cfg        <== 链接数为 2
7249 -rw-------. 2 root root 1638 Mar  3 11:42 anaconda-ks.cfg.hard

在当前目录下新建了一个文件名叫做 anaconda-ks.cfg.hard 链接到 inode 号码 为 7249 的关联记录
所以删除这两个任何一个文件, inode 和 block 都存在, 都可以正常访问到文件内容.

anaconda-ks.cfg      ->  7249  --> 文件内容
anaconda-ks.cfg.hard ->  7249  --> 文件内容 
```
**缺点 :**
> 1. 不能跨文件系统(因为指向 inode, 在别的文件系统中相同的 inode 可能指向的是别的文件, 指向错误)
> 2. 不能链接到目录

```bash
[root@localhost ~]# ln .  directory_hard
ln: `.': hard link not allowed for directory
```

#### 符号链接(symbolic link, 软连接)
符号链接是在创建一个独立的文件, 而这个文件能够让数据的读取指向它连接的那个文件的文件名, 因为只是利用文件来作文指向的操作, 所以删除源文件时, 符号连接会找不到文件.
```bash
[root@localhost ~]# ll -i anaconda-ks.cfg*
7249 -rw-------. 2 root root 1638 Mar  3 11:42 anaconda-ks.cfg
7249 -rw-------. 2 root root 1638 Mar  3 11:42 anaconda-ks.cfg.hard
  24 lrwxrwxrwx. 1 root root   15 Mar  8 00:30 anaconda-ks.cfg.soft -> anaconda-ks.cfg

anaconda-ks.cfg.soft   不一样的 inode, 所以是不同文件
它的大小 15bytes 怎么来的呢? 他箭头的右边的文件名长度为 15bytes(anaconda-ks.cfg)

anaconda-ks.cfg.soft --> anaconda-ks.cfg --> 找到 inode 7249 --> 读取文件内容

## -f 的作用
[root@localhost ~]# ln -s anaconda-ks.cfg anaconda-ks.cfg.soft
ln: creating symbolic link `anaconda-ks.cfg.soft': File exists
[root@localhost ~]# ln -sf anaconda-ks.cfg anaconda-ks.cfg.soft 

## 删除源文件, 尝试访问 不能访问
[root@localhost ~]# cat anaconda-ks.cfg.soft  | head -n 3
# Kickstart file automatically generated by anaconda.

#version=DEVEL
[root@localhost ~]# rm -rf anaconda-ks.cfg
[root@localhost ~]# cat anaconda-ks.cfg.soft  | head -n 3
cat: anaconda-ks.cfg.soft: No such file or directory

## 还原
[root@localhost ~]# mv anaconda-ks.cfg.hard anaconda-ks.cfg
```

### 总结
如果我们想要在系统中新增一块硬盘, 需要哪些步骤呢?
> 1. 对磁盘分区, 建立可用的分区
> 2. 格式化分区, 建立可用的文件系统
> 3. 对文件系统进行检验
> 4. 创建挂载点(mount point), 然后挂载上来, 设置挂载参数(开机启动 读写 acl 等) 设置对应配置文件

# 磁盘分区
磁盘分区有两个格式:
> MBR：MBR分区表(即主引导记录) 所支持的最大卷 2T，最多4个主分区或3个主分区加一个扩展分区
>  
> GPT：GPT（即GUID分区表）。是未来磁盘分区的主要形式, 每个磁盘最多支持128个分区。支持大于2T的分区，最大卷可达18EB。

**稍后会添加两块硬盘 : /dev/sdb 做 MBR 分区, /dev/sdc 做 GPT 分区.**

## fdisk命令
新建/修改/删除 磁盘分区的操作, 分区是针对整个磁盘的, 而不是针对某个分区.
**fdisk 命令无法处理大于 2TB 以上的磁盘分区, 大于2TB的硬盘, 我们可以使用 parted 命令, 稍后讲解**

> fdisk -l [ DEVICE ]  : 查看磁盘分区
>
> fdisk DEVICE : 新建/修改/删除  磁盘分区

| 选项 | 作用 |
| ---- | ---- |
| -l  | 如果 DEVICES 存在, 则列出 DEVICES 的磁盘分区, 否则就列出系统所有的设备分区 |

```bash
## 查询当前目录下所有分区信息, 没有 DEVICE 
[root@localhost ~]# fdisk -l

Disk /dev/sda: 42.9 GB, 42949672960 bytes
255 heads, 63 sectors/track, 5221 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x000bbc41

   Device Boot      Start         End      Blocks   Id  System
/dev/sda1   *           1          26      204800   83  Linux
/dev/sda2              26         664     5120000   8e  Linux LVM
/dev/sda3             664        1173     4096000   83  Linux
/dev/sda4            1173        5222    32521216    5  Extended
/dev/sda5            1174        1429     2048000   83  Linux
/dev/sda6            1429        1684     2048000   83  Linux
/dev/sda7            1684        1811     1024000   82  Linux swap / Solaris
/dev/sda8            1812        1939     1024000   83  Linux


Disk /dev/mapper/server-myhome: 5238 MB, 5238685696 bytes
255 heads, 63 sectors/track, 636 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x00000000


## 只列出 /dev/sda 磁盘下的分区信息, 有 DEVICE
[root@localhost ~]# fdisk -l /dev/sda

Disk /dev/sda: 42.9 GB, 42949672960 bytes				<== 磁盘的文件名和容量, 字节数
255 heads, 63 sectors/track, 5221 cylinders             <== 磁头 扇区  柱面个数   
Units = cylinders of 16065 * 512 = 8225280 bytes        <== 每个柱面的大小
					  255 * 63 * 512 = 8225280 bytes 
      硬盘的容量 = 柱面数 * 磁头数 * 扇区数 * 512bytes(Sector Size) 第一章讲的内容
	  硬盘的容量 = 柱面数 * 每个柱面大小
Sector size (logical/physical): 512 bytes / 512 bytes   <== 扇区的大小      
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x000bbc41                             <== 磁盘标识

设备文件名 启动标识  开始位置      结束位置  分区块的大小(1kb) 分区ID  分区类型
   Device Boot      Start         End      Blocks           Id   System
/dev/sda1   *           1          26      204800           83   Linux
/dev/sda2              26         664     5120000           8e   Linux LVM
/dev/sda3             664        1173     4096000           83   Linux
/dev/sda4            1173        5222    32521216            5   Extended
/dev/sda5            1174        1429     2048000           83   Linux
/dev/sda6            1429        1684     2048000           83   Linux
/dev/sda7            1684        1811     1024000           82   Linux swap / Solaris
/dev/sda8            1812        1939     1024000           83   Linux
```

然后我们现在开始新增两块磁盘, 防止操作失误损坏到系统盘, 先把系统关机, 添加完成后开启系统 步骤如下 :

![create_new_disk](https://github.com/gkdaxue/linux/raw/master/image/chapter_A7_0004_create_new_disk.gif)

添加完成后, 然后我们来复习之前所说的关于设备文件命名的问题, 我现在新增的一块硬盘, 使用的 scsi接口 形式, 那么它在系统中会被如何命名呢? (/dev/sdb, /dev/sdc)
```bash
[root@localhost ~]# fdisk -l /dev/sdb

Disk /dev/sdb: 42.9 GB, 42949672960 bytes
255 heads, 63 sectors/track, 5221 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x00000000

## 会进入到 fdisk 命令的界面.
[root@localhost ~]# fdisk /dev/sdb
Device contains neither a valid DOS partition table, nor Sun, SGI or OSF disklabel
Building a new DOS disklabel with disk identifier 0xdedc2b2e.
Changes will remain in memory only, until you decide to write them.
After that, of course, the previous content won't be recoverable.

Warning: invalid flag 0x0000 of partition table 4 will be corrected by w(rite)

WARNING: DOS-compatible mode is deprecated. It's strongly recommended to
         switch off the mode (command 'c') and change display units to
         sectors (command 'u').
 
Command (m for help): ▊                <== 等待你的输入操作

## 然后输入 m 命令, 查看帮助信息
Command (m for help): m
Command action
   a   toggle a bootable flag
   b   edit bsd disklabel
   c   toggle the dos compatibility flag
   d   delete a partition                         <== 删除一个分区
   l   list known partition types                 <== 列出已知分区类型
   m   print this menu
   n   add a new partition                        <== 新增一个分区
   o   create a new empty DOS partition table
   p   print the partition table                  <== 显示分区表
   q   quit without saving changes                <== 不写入分区表, 直接退出  不保存任何修改
   s   create a new empty Sun disklabel
   t   change a partition's system id             <== 改变一个分区的系统ID，就是改变分区类型
   u   change display/entry units
   v   verify the partition table
   w   write table to disk and exit               <== 写入分区表并退出
   x   extra functionality (experts only)

Command (m for help): l    <== 列出分区类型 和上面分区 id 相对应

 0  Empty           24  NEC DOS         81  Minix / old Lin bf  Solaris        
 1  FAT12           39  Plan 9          82  Linux swap / So c1  DRDOS/sec (FAT-
 2  XENIX root      3c  PartitionMagic  83  Linux           c4  DRDOS/sec (FAT-
 3  XENIX usr       40  Venix 80286     84  OS/2 hidden C:  c6  DRDOS/sec (FAT-
 4  FAT16 <32M      41  PPC PReP Boot   85  Linux extended  c7  Syrinx         
 5  Extended        42  SFS             86  NTFS volume set da  Non-FS data    
 6  FAT16           4d  QNX4.x          87  NTFS volume set db  CP/M / CTOS / .
 7  HPFS/NTFS       4e  QNX4.x 2nd part 88  Linux plaintext de  Dell Utility   
 8  AIX             4f  QNX4.x 3rd part 8e  Linux LVM       df  BootIt         
 9  AIX bootable    50  OnTrack DM      93  Amoeba          e1  DOS access     
 a  OS/2 Boot Manag 51  OnTrack DM6 Aux 94  Amoeba BBT      e3  DOS R/O        
 b  W95 FAT32       52  CP/M            9f  BSD/OS          e4  SpeedStor      
 c  W95 FAT32 (LBA) 53  OnTrack DM6 Aux a0  IBM Thinkpad hi eb  BeOS fs        
 e  W95 FAT16 (LBA) 54  OnTrackDM6      a5  FreeBSD         ee  GPT            
 f  W95 Ext'd (LBA) 55  EZ-Drive        a6  OpenBSD         ef  EFI (FAT-12/16/
10  OPUS            56  Golden Bow      a7  NeXTSTEP        f0  Linux/PA-RISC b
11  Hidden FAT12    5c  Priam Edisk     a8  Darwin UFS      f1  SpeedStor      
12  Compaq diagnost 61  SpeedStor       a9  NetBSD          f4  SpeedStor      
14  Hidden FAT16 <3 63  GNU HURD or Sys ab  Darwin boot     f2  DOS secondary  
16  Hidden FAT16    64  Novell Netware  af  HFS / HFS+      fb  VMware VMFS    
17  Hidden HPFS/NTF 65  Novell Netware  b7  BSDI fs         fc  VMware VMKCORE 
18  AST SmartSleep  70  DiskSecure Mult b8  BSDI swap       fd  Linux raid auto
1b  Hidden W95 FAT3 75  PC/IX           bb  Boot Wizard hid fe  LANstep        
1c  Hidden W95 FAT3 80  Old Minix       be  Solaris boot    ff  BBT            
1e  Hidden W95 FAT1

Command (m for help): q

[root@localhost ~]# 
```

### 增加磁盘分区(/dev/sdb)
```bash
[root@localhost ~]# fdisk /dev/sdb
Command (m for help): n
Command action
   e   extended                     <== 扩展分区
   p   primary partition (1-4)      <== 主分区
e
Partition number (1-4): 1           <== 分区的编号, 可以自定义 (复习一下之前所说的分区编号知识)
First cylinder (1-5221, default 1):     
Using default value 1
Last cylinder, +cylinders or +size{K,M,G} (1-5221, default 5221): +2G    <== 分区大小

Command (m for help): p

Disk /dev/sdb: 42.9 GB, 42949672960 bytes
255 heads, 63 sectors/track, 5221 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x60e98ef6

   Device Boot      Start         End      Blocks   Id  System
/dev/sdb1               1         262     2104483+   5  Extended   <== 这是一个扩展分区

## 在新建一个分区, 发现只有逻辑分区和主分区了, 因为扩展分区只能有一个
Command (m for help): n    
Command action
   l   logical (5 or over)
   p   primary partition (1-4)
p
Partition number (1-4): 1    <== 如果我们设定分区编号为1, 提示已经存在
Partition 1 is already defined.  Delete it before re-adding it.

## 回想一下, 如果是逻辑分区, 那么编号从多少开始.
Command (m for help): n
Command action
   l   logical (5 or over)
   p   primary partition (1-4)
l
First cylinder (1-262, default 1): 
Using default value 1
Last cylinder, +cylinders or +size{K,M,G} (1-262, default 262): +2G

Command (m for help): p

Disk /dev/sdb: 42.9 GB, 42949672960 bytes
255 heads, 63 sectors/track, 5221 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x60e98ef6

   Device Boot      Start         End      Blocks   Id  System
/dev/sdb1               1         262     2104483+   5  Extended
/dev/sdb5               1         262     2104452   83  Linux      <== 逻辑分区编号 从 5 开始

## 我们还没有写入磁盘分区表中, 接下来做删除分区的实验.
```

### 删除磁盘分区(/dev/sdb)
接上一步, 我们现在有一个扩展分区和逻辑分区, 突然发现我们弄错了, 那么我们现在操作一下, 先删除错误分区, 在新建正确的分区.
> 三个主分区每个分区大小为 5G, 然后一个逻辑分区的大小为5G.

```bash
## 我使用 d 命令删除了分区编号为 1 的分区, 但是为什么 p 显示所有的分区都没有了? 请复习一下我们之前的知识
## 逻辑分区是在扩展分区的基础上划分的, 结果你把扩展分区删除了, 所以结果你懂的
 
Command (m for help): d      <== 表示要删除分区
Partition number (1-5): 1    <== 输入要删除的分区编号

Command (m for help): p

Disk /dev/sdb: 42.9 GB, 42949672960 bytes
255 heads, 63 sectors/track, 5221 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x60e98ef6

   Device Boot      Start         End      Blocks   Id  System

## 新建正确的主分区信息, 以下这些重复三次
Command (m for help): n
Command action
   e   extended
   p   primary partition (1-4)
p
Partition number (1-4): 1     <== 除了此处不一样
First cylinder (1-5221, default 1): 
Using default value 1
Last cylinder, +cylinders or +size{K,M,G} (1-5221, default 5221): +5G

## 新建扩展分区
Command (m for help): n
Command action
   e   extended
   p   primary partition (1-4)
e
Selected partition 4
First cylinder (1963-5221, default 1963): 
Using default value 1963
Last cylinder, +cylinders or +size{K,M,G} (1963-5221, default 5221):     <== 直接回车, 想一下为什么要分配全部的空间
Using default value 5221

Command (m for help): p

Disk /dev/sdb: 42.9 GB, 42949672960 bytes
255 heads, 63 sectors/track, 5221 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x60e98ef6

   Device Boot      Start         End      Blocks   Id  System
/dev/sdb1               1         654     5253223+  83  Linux
/dev/sdb2             655        1308     5253255   83  Linux
/dev/sdb3            1309        1962     5253255   83  Linux
/dev/sdb4            1963        5221    26177917+   5  Extended

## 新建逻辑分区, 没有指定分区编号的功能
Command (m for help): n
First cylinder (1963-5221, default 1963): 
Using default value 1963
Last cylinder, +cylinders or +size{K,M,G} (1963-5221, default 5221): +5G

Command (m for help): p

Disk /dev/sdb: 42.9 GB, 42949672960 bytes
255 heads, 63 sectors/track, 5221 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x60e98ef6

   Device Boot      Start         End      Blocks   Id  System
/dev/sdb1               1         654     5253223+  83  Linux
/dev/sdb2             655        1308     5253255   83  Linux
/dev/sdb3            1309        1962     5253255   83  Linux
/dev/sdb4            1963        5221    26177917+   5  Extended
/dev/sdb5            1963        2616     5253223+  83  Linux

Command (m for help): w     <== 想一下 w 和  q 的区别, 一定要使用 w
The partition table has been altered!

Calling ioctl() to re-read partition table.
Syncing disks.
[root@localhost ~]# partprobe   # <== 强制内核重新加载一次分区表, 一般敲两次.

## 查看一下分区文件
[root@localhost ~]# ll /dev/sdb*
brw-rw----. 1 root disk 8, 16 Mar 10 08:22 /dev/sdb
brw-rw----. 1 root disk 8, 17 Mar 10 08:22 /dev/sdb1
brw-rw----. 1 root disk 8, 18 Mar 10 08:22 /dev/sdb2
brw-rw----. 1 root disk 8, 19 Mar 10 08:22 /dev/sdb3
brw-rw----. 1 root disk 8, 20 Mar 10 08:22 /dev/sdb4
brw-rw----. 1 root disk 8, 21 Mar 10 08:22 /dev/sdb5
```
### 总结
> 1. 1-4 号分区编号有剩余且没有扩展分区, 那么会有 Primary/Extended 选项存在
> 2. 1-4 号分区编号有剩余且有扩展分区, 那么会出现 Primary/Logical 选项存在且 Primary 可以手动指明主分区编号
> 3. 1-4 号分区编号无剩余且有扩展分区, 那么只有 Logical 选项, 不让指定分区编号

## gdisk命令
如果硬盘的大小大于 2T, 那么无法使用 MBR 格式的分区, 只能使用 GPT, 然后我们使用 gdisk 命令来创建 GPT 分区类型. **使用此方式, 我们必须先安装一下 gdisk 软件才可以使用此种方式.** 选项和 fdisk 命令一致.

### 安装软件
```bash
## 安装一下 gdisk 软件
[root@localhost ~]# yum install -y gdisk
Loaded plugins: fastestmirror, refresh-packagekit, security
Setting up Install Process
Loading mirror speeds from cached hostfile
 * base: mirrors.aliyun.com
 * extras: mirrors.aliyun.com
 * updates: mirrors.aliyun.com
Resolving Dependencies
--> Running transaction check
---> Package gdisk.x86_64 0:0.8.10-1.el6 will be installed
--> Finished Dependency Resolution

Dependencies Resolved

============================================================================
 Package         Arch         Version         Repository                   Size
============================================================================
Installing:
 gdisk           x86_64       0.8.10-1.el6    base                         167 k

Transaction Summary
============================================================================
Install       1 Package(s)

Total download size: 167 k
Installed size: 619 k
Downloading Packages:
gdisk-0.8.10-1.el6.x86_64.rpm                           | 167 kB     00:00
Running rpm_check_debug
Running Transaction Test
Transaction Test Succeeded
Running Transaction
  Installing : gdisk-0.8.10-1.el6.x86_64               1/1 
  Verifying  : gdisk-0.8.10-1.el6.x86_64               1/1 

Installed:
  gdisk.x86_64 0:0.8.10-1.el6        

Complete!
```

### 创建GPT分区(/dev/sdc)
```bash
[root@localhost ~]# gdisk /dev/sdc
GPT fdisk (gdisk) version 0.8.10

Partition table scan:
  MBR: not present
  BSD: not present
  APM: not present
  GPT: not present

Creating new GPT entries.

Command (? for help): ?      <== 输入 ? 查看 帮助信息, 发现和之前的差不多
b	back up GPT data to a file
c	change a partition's name
d	delete a partition
i	show detailed information on a partition
l	list known partition types
n	add a new partition
o	create a new empty GUID partition table (GPT)
p	print the partition table
q	quit without saving changes
r	recovery and transformation options (experts only)
s	sort partitions
t	change a partition's type code
v	verify disk
w	write table to disk and exit
x	extra functionality (experts only)
?	print this menu

## 创建一个 100M 和 1G 的分区
Command (? for help): n
Partition number (1-128, default 1):      <== 并没有提示我们说是创建主分区还是扩展分区的问题并且数字是 1-128
First sector (34-41943006, default = 2048) or {+-}size{KMGTP}: 
Last sector (2048-41943006, default = 41943006) or {+-}size{KMGTP}: +100M
Current type is 'Linux filesystem'
Hex code or GUID (L to show codes, Enter = 8300): 
Changed type of partition to 'Linux filesystem'

Command (? for help): n
Partition number (2-128, default 2): 
First sector (34-41943006, default = 206848) or {+-}size{KMGTP}: 
Last sector (206848-41943006, default = 41943006) or {+-}size{KMGTP}: +1G
Current type is 'Linux filesystem'
Hex code or GUID (L to show codes, Enter = 8300): 
Changed type of partition to 'Linux filesystem'

Command (? for help): p
Disk /dev/sdc: 41943040 sectors, 20.0 GiB
Logical sector size: 512 bytes
Disk identifier (GUID): 3F4B1051-12CF-438F-B53E-0F0FC87D4266
Partition table holds up to 128 entries
First usable sector is 34, last usable sector is 41943006
Partitions will be aligned on 2048-sector boundaries
Total free space is 39641021 sectors (18.9 GiB)

Number  Start (sector)    End (sector)  Size       Code  Name
   1            2048          206847   100.0 MiB   8300  Linux filesystem
   2          206848         2303999   1024.0 MiB  8300  Linux filesystem
Command (? for help): w

Final checks complete. About to write GPT data. THIS WILL OVERWRITE EXISTING
PARTITIONS!!

Do you want to proceed? (Y/N): 
OK; writing new GUID partition table (GPT) to /dev/sdc.
The operation has completed successfully.
```
### 查看磁盘分区
```bash
[root@localhost ~]# gdisk -l /dev/sdc
GPT fdisk (gdisk) version 0.8.10

Partition table scan:
  MBR: protective
  BSD: not present
  APM: not present
  GPT: present

Found valid GPT with protective MBR; using GPT.
Disk /dev/sdc: 41943040 sectors, 20.0 GiB
Logical sector size: 512 bytes
Disk identifier (GUID): 3F4B1051-12CF-438F-B53E-0F0FC87D4266
Partition table holds up to 128 entries
First usable sector is 34, last usable sector is 41943006
Partitions will be aligned on 2048-sector boundaries
Total free space is 39641021 sectors (18.9 GiB)

Number  Start (sector)    End (sector)  Size       Code  Name
   1            2048          206847   100.0 MiB   8300  Linux filesystem
   2          206848         2303999   1024.0 MiB  8300  Linux filesystem
```

## parted命令
fdisk 命令无法支持高于 2TB 以上的分区, 这个时候就需要使用 parted 命令来处理. parted 命令可以使用一行命令来完成分区, 是一个非常好用的命令.
> parted DEVICE_NAME [命令 [参数]]

```bash
新增分区    	: mkpart { primary | logical | extended } 文件系统格式 开始 结束
打印分区信息	: print
删除分区     : rm [partition] 
```

### 实例
```bash
## 打印分区表信息
[root@localhost ~]# parted /dev/sdb print
Model: VMware, VMware Virtual S (scsi)
Disk /dev/sdb: 42.9GB
Sector size (logical/physical): 512B/512B
Partition Table: msdos    <== msdos 的格式

分区号码 开始柱面 结束柱面 大小    分区类型   文件系统类型
Number  Start   End     Size    Type      File system  Flags
 1      32.3kB  5379MB  5379MB  primary   ext3
 2      5379MB  10.8GB  5379MB  primary   ext3
 3      10.8GB  16.1GB  5379MB  primary
 4      16.1GB  42.9GB  26.8GB  extended 
 5      16.1GB  21.5GB  5379MB  logical

你能从上面看出来, 我们的硬盘还有多少空间未被使用的吗? 剩余的空间都被分配给了扩展分区, 所以我们就可以得出
剩余容量 : 扩展分区容量 - 已经分配的 /dev/sdb5 的容量, 所以大概还有 20G 左右容量

## 因为我们主分区+扩展分区已经4个了, 所以只有创建一个逻辑分区了, 确保 /dev/sdb 无挂载信息
[root@localhost ~]# df -hT | grep sdb
[root@localhost ~]# parted /dev/sdb mkpart logical ext2 21.5GB 26.5GB
Information: You may need to update /etc/fstab.   <== 因为新增了分区, 提示可能需要更新此文件

[root@localhost ~]# parted /dev/sdb print
Model: VMware, VMware Virtual S (scsi)
Disk /dev/sdb: 42.9GB
Sector size (logical/physical): 512B/512B
Partition Table: msdos

Number  Start   End     Size    Type      File system  Flags
 1      32.3kB  5379MB  5379MB  primary   ext3
 2      5379MB  10.8GB  5379MB  primary   ext3
 3      10.8GB  16.1GB  5379MB  primary
 4      16.1GB  42.9GB  26.8GB  extended
 5      16.1GB  21.5GB  5379MB  logical
 6      21.5GB  26.5GB  4982MB  logical    <== 我们刚才创建的文件

## 然后我们再删除刚才创建的分区
[root@localhost ~]# parted /dev/sdb rm 6
Information: You may need to update /etc/fstab.                           

[root@localhost ~]# parted /dev/sdb print
Model: VMware, VMware Virtual S (scsi)
Disk /dev/sdb: 42.9GB
Sector size (logical/physical): 512B/512B
Partition Table: msdos

Number  Start   End     Size    Type      File system  Flags
 1      32.3kB  5379MB  5379MB  primary   ext3
 2      5379MB  10.8GB  5379MB  primary   ext3
 3      10.8GB  16.1GB  5379MB  primary
 4      16.1GB  42.9GB  26.8GB  extended
 5      16.1GB  21.5GB  5379MB  logical
```

## lsblk命令
显示块设备信息.
> lsblk [ options ] [ device ]

| 选项 | 作用 |
| :---: | ----- |
| -d | 仅列出磁盘本身, 不列出分区数据 |
| -f | 同时列出磁盘的文件系统信息 |
| -m | 同事显示该设备在 /dev/ 下面的权限信息 |
| -t | 列出该设备的详细信息 |

```bash
## 不理解的内容, 可以忽略即可, 只是为了做实验, 以后会讲解
[root@localhost ~]# mkdir /tmp/mount_test1
[root@localhost ~]# mkfs.ext4 -L 'gkdaxue' /dev/sdc1
[root@localhost ~]# mount /dev/sdc1 /tmp/mount_test1/

## 列出磁盘的分区数据
[root@localhost ~]# lsblk /dev/sdc
名称   主设备号:次设备号   是否为可卸载设备   容量   是否为只读设备  类型   挂载点 
NAME     MAJ:MIN         RM               SIZE   RO            TYPE   MOUNTPOINT
sdc      8:32            0                20G    0             disk 
├─sdc1   8:33            0                100M   0             part /tmp/mount_test1
└─sdc2   8:34            0                1G     0             part 

## 只显示磁盘本身
[root@localhost ~]# lsblk -d /dev/sdc
NAME MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
sdc    8:32   0  20G  0 disk 

## 列出块设备的文件系统信息
[root@localhost ~]# lsblk -f /dev/sdc
NAME   FSTYPE LABEL   UUID                                 MOUNTPOINT
sdc                                                        
├─sdc1 ext4   gkdaxue 55969e98-43fc-4bd2-b050-9e1b382e8892 /tmp/mount_test1
└─sdc2   

## 列出权限信息
[root@localhost ~]# lsblk -m /dev/sdc
NAME    SIZE OWNER GROUP MODE
sdc      20G root  disk  brw-rw----
├─sdc1  100M root  disk  brw-rw----
└─sdc2    1G root  disk  brw-rw----

## 列出磁盘的详细数据
[root@localhost ~]# lsblk -t /dev/sdc
NAME   ALIGNMENT MIN-IO OPT-IO PHY-SEC LOG-SEC ROTA SCHED RQ-SIZE   RA
sdc            0    512      0     512     512    1 cfq       128  128
├─sdc1         0    512      0     512     512    1 cfq       128  128
└─sdc2         0    512      0     512     512    1 cfq       128  128
```

## blkid命令
blkid命令对查询设备上所采用文件系统类型进行查询。blkid主要用来对系统的块设备（包括交换分区）所使用的文件系统类型、LABEL、UUID等信息进行查询。要使用这个命令必须安装e2fsprogs软件包。

```bash
[root@localhost ~]# blkid
/dev/sda1: UUID="356ce5e4-c782-44cb-9447-1e7f0e04e7d1" TYPE="ext4" 
/dev/sda2: UUID="QiqoY2-Wmng-l4uw-EnNi-QcrR-hiCk-Us7Atn" TYPE="LVM2_member" 
/dev/sda3: UUID="33659ce2-7c20-4143-9d2b-4e5b39fe5310" TYPE="ext4" 
/dev/sda5: UUID="64af9fff-884d-4cf2-afe6-ba3f7869cf35" TYPE="ext4" 
/dev/sda6: UUID="8c2f0179-2787-43c8-8c8b-16456ebc1f57" TYPE="ext4" 
/dev/sda7: UUID="79c4a924-5436-4163-a624-4785f47a424d" TYPE="swap" 
/dev/sda8: UUID="fb2c6429-d1fa-4a77-a4db-d2bb899fb552" TYPE="ext4" 
/dev/mapper/server-myhome: UUID="e9b85403-804d-4bca-bbe7-8222ad01e0ff" TYPE="ext4" 
/dev/sdc1: LABEL="gkdaxue" UUID="55969e98-43fc-4bd2-b050-9e1b382e8892" TYPE="ext4" 

## 查看特定设备的信息
[root@localhost ~]# blkid /dev/sdc1
/dev/sdc1: LABEL="gkdaxue" UUID="55969e98-43fc-4bd2-b050-9e1b382e8892" TYPE="ext4" 
```

## 磁盘格式化 : mkfs 命令
mkfs (即make file system) 可以进行分区的格式化操作. 它是一个综合的命令, 所以可以用来创建多种文件系统, 如果分区里面已经存在数据, 那么格式化是会删除该分区上的所有数据, 特别注意.
> mkfs -t 文件系统格式 设备文件名

| 选项 | 作用 |
| ----- | ----- |
| -t 文件系统格式 | 只有系统支持的文件系统才会生效 |

```bash
## 使用命令补全形式, 会发现有下面这些, 其实 mkfs -t 文件系统格式 就是调用下面对应类型工作
## mkfs -t ext3 /dev/sdb1  =  mkfs.ext3  /dev/sdb1
[root@localhost ~]# mkfs
mkfs          mkfs.cramfs   mkfs.ext2     mkfs.ext3     mkfs.ext4     mkfs.ext4dev  mkfs.msdos    mkfs.vfat

## mkfs 其实可以设置很多值, 但是我们没有设置, 所以使用系统默认值来格式化.
[root@localhost ~]# mkfs -t ext3 /dev/sdb1
mke2fs 1.41.12 (17-May-2010)
Filesystem label=               <== 分区的名称
OS type: Linux                  <== 操作系统类型 
Block size=4096 (log=2)         <== Block 的大小 4KB
Fragment size=4096 (log=2)
Stride=0 blocks, Stripe width=0 blocks
328656 inodes, 1313305 blocks   <== inode 和 block 的数量
65665 blocks (5.00%) reserved for the super user
First data block=0
Maximum filesystem blocks=1346371584
41 block groups                <== 多少个 block group
32768 blocks per group, 32768 fragments per group
8016 inodes per group
Superblock backups stored on blocks: 
	32768, 98304, 163840, 229376, 294912, 819200, 884736

Writing inode tables: done                            
Creating journal (32768 blocks): done   <== ext3 是日志文件系统
Writing superblocks and filesystem accounting information: done

This filesystem will be automatically checked every 39 mounts or
180 days, whichever comes first.  Use tune2fs -c or -i to override.

## 完全使用系统默认值来格式化
[root@localhost ~]# mkfs /dev/sdb2
mke2fs 1.41.12 (17-May-2010)
Filesystem label=
OS type: Linux
Block size=4096 (log=2)
Fragment size=4096 (log=2)
Stride=0 blocks, Stripe width=0 blocks
328656 inodes, 1313313 blocks
65665 blocks (5.00%) reserved for the super user
First data block=0
Maximum filesystem blocks=1346371584
41 block groups
32768 blocks per group, 32768 fragments per group
8016 inodes per group
Superblock backups stored on blocks: 
	32768, 98304, 163840, 229376, 294912, 819200, 884736

							  <== ext2 不是日志文件系统
Writing inode tables: done                            
Writing superblocks and filesystem accounting information: done

This filesystem will be automatically checked every 23 mounts or
180 days, whichever comes first.  Use tune2fs -c or -i to override.


## 创建分区点并查看分区类型, 以后讲解, 现在只是演示, 知道即可.
[root@localhost ~]# mkdir /test_mount_point{1,2,3,4}
[root@localhost ~]# mount /dev/sdb1 /test_mount_point1
[root@localhost ~]# mount /dev/sdb2 /test_mount_point2
[root@localhost ~]# df -hT | grep 'sdb'
/dev/sdb1            ext3   5.0G  139M  4.6G   3% /test_mount_point1   <== 自己设定的文件系统格式
/dev/sdb2            ext2   5.0G   11M  4.7G   1% /test_mount_point2   <== 系统默认的文件系统格式
```

## mke2fs命令
创建 ext2/ext3/ext4 系列文件系统, 不能创建除此之外的文件系统. 以下这些选项也可以在 mkfs 命令中使用一样的效果.

| 选项 | 作用 |
| ---- | ----- |
| -L LABLE_NAME | 设置卷标名称, e2label 命令会讲解 |
| -b BLOCK_SIZE | 设置 block 块的大小, 支持 1024, 2048, 4096 bytes 三种 |
| -j | 如果不加, 系统默认格式化为 ext2 格式, 加上之后会格式化为 ext3 格式 |
| -i INODE_SIZE | 每多少容量给予一个 inode |
| -c | 检查磁盘错误, 进行快速读取测试 |
| -c -c | 测试读写 | 

### 实验
我们使用 /dev/sdb2 开始做实验.
> 1. Volume Name : gkdaxue_logical
> 2. Block Size : 2048 bytes
> 3. Inode Size : 8192 bytes
> 4. File System : ext3

```bash
## 省略部分信息, 保留关键信息
[root@localhost ~]# dumpe2fs -h /dev/sdb2
Filesystem volume name:   <none>          <== 卷标为空的
Block count:              1313313         <== block 的总数
Block size:               4096            <== block 的大小 4KB 
[root@localhost ~]# df -hT /dev/sdb2
Filesystem     Type  Size  Used Avail Use% Mounted on
/dev/sdb2      ext2  5.0G   11M  4.7G   1% /test_mount_point2

## 之前挂载了, 先卸载才能操作
[root@localhost ~]# umount /dev/sdb2
[root@localhost ~]# mke2fs -j -L 'gkdaxue_logical' -b 2048 -i 8192 /dev/sdb2
[root@localhost ~]# df -hT /dev/sdb2
Filesystem     Type  Size  Used Avail Use% Mounted on
/dev/sdb2      ext3  4.9G   76M  4.6G   2% /test_mount_point2   <== 变为 ext3 了
[root@localhost ~]# dumpe2fs -h /dev/sdb2
dumpe2fs 1.41.12 (17-May-2010)
Filesystem volume name:   gkdaxue_logical  <== 卷标为gkdaxue_logical
Block count:              2626626          <== block 的总数
Block size:               2048             <== block 的大小 2KB
```

## fsck命令
文件系统运行时会有硬盘和内存数据不同步的情况发生, 因此可能导致系统出现各种问题, 所以这个时候就需要使用到我们所说的 fsck (file system check) 命令来检查和修复文件系统. fsck 也是一个综合的命令
> file [ options ] DEVICE_NAME

| 选项 | 作用 |
| ----- | ----- |
| -t 文件系统 | 指定文件系统, 通常不需要这个选项(系统会根据 super block 自动分区文件系统) |
| -A | 依据 /etc/fstab 的内容, 将需要的设备扫描一遍, 通常开机过程中会执行此命令 |
| -a | 自动修改有问题的扇区 |
| -C | 使用一个直方图来显示当前的进度 |
| -f | 强制检查 |

**注意事项 : **
> 1. 通常只有 root 且文件系统有问题时才会使用此命令, 否则正常情况下使用此命令, 可能会导致系统出现问题.
> 2. 执行 fsck 命令时, 分区不能被挂载在系统上, 必须提前先卸载, 才能执行此命令
> 3. 其实我们执行 fsck 命令, 就是在调用 e2fsck 这个软件, 所以可以使用 man e2fsck 来获取帮助

### 实例
```bash
## fsck 也是一个综合的命令, 有多种形式和之前 mkfs 一样
[root@localhost ~]# fsck
fsck          fsck.cramfs   fsck.ext2     fsck.ext3     fsck.ext4     fsck.ext4dev  fsck.msdos    fsck.vfat     

## fsck 之前没有卸载出现的情况
[root@localhost ~]# fsck -C -t ext3 -f /dev/sdb2
fsck from util-linux-ng 2.17.2
e2fsck 1.41.12 (17-May-2010)
/dev/sdb2 is mounted.                 <== 已经被挂载, 没有卸载
e2fsck: Cannot continue, aborting.

## 之前已经挂载, 需要先移除
[root@localhost ~]# umount /dev/sdb2
[root@localhost ~]# fsck -C -t ext3 -f /dev/sdb2
fsck from util-linux-ng 2.17.2
e2fsck 1.41.12 (17-May-2010)
Pass 1: Checking inodes, blocks, and sizes
Pass 2: Checking directory structure                                           
Pass 3: Checking directory connectivity
Pass 4: Checking reference counts
Pass 5: Checking group summary information
gkdaxue_logical: 11/656880 files (0.0% non-contiguous), 120951/2626626 blocks  
```

## e2fsck命令
检查 ext2/ext3/ext4 文件系统
> e2fsck [ options ] DEVICE_NAME

| 选项 | 作用 |
| ----- | ---- |
| -y | 自动回答 yes |
| -f | 强制修复 |

### 实例
```bash
[root@localhost ~]# e2fsck -y -f /dev/sdb2
e2fsck 1.41.12 (17-May-2010)
Pass 1: Checking inodes, blocks, and sizes
Pass 2: Checking directory structure
Pass 3: Checking directory connectivity
Pass 4: Checking reference counts
Pass 5: Checking group summary information
gkdaxue_logical: 11/656880 files (0.0% non-contiguous), 120951/2626626 blocks
```

## e2label命令
更改 ext系列 的Label, 我们挂载分区也可以使用 Label Name的方式(稍后讲解), 那么使用卷标有什么优缺点呢?
> 1. 系统通过 Label 来挂载, 无论磁盘插在什么接口上面, 磁盘文件名如何变化都不会受到影响
> 2. 如果有 Label 重复的, 那么可能会导致系统出现问题.

**语法:**
> e2label device [ new-label ]

```bash
## 查看卷标名
[root@localhost ~]# e2label /dev/sdb2
gkdaxue_logical
[root@localhost ~]# dumpe2fs -h /dev/sdb2
dumpe2fs 1.41.12 (17-May-2010)
Filesystem volume name:   gkdaxue_logical  <== 卷标为gkdaxue_logical

## 然后更改卷标名
[root@localhost ~]# e2label /dev/sdb2 'gkdaxue_test'
[root@localhost ~]# e2label /dev/sdb2
gkdaxue_test
[root@localhost ~]# dumpe2fs -h /dev/sdb2
dumpe2fs 1.41.12 (17-May-2010)
Filesystem volume name:   gkdaxue_test
.......
```

## tune2fs命令
调整ext2/ext3/ext4文件系统上的可调文件系统参数.
> tune2fs -jlL DEVICE_NAME

| 选项 | 作用 |
| ---- | ---- |
| -l | 类似于 dumpe2fs -h命令, 读取super block 的内容 |
| -j | 将 ext2 文件系统格式转换为 ext3 格式 |
| -L "Volume_Name" | 类似于 e2label, 可修改文件系统的 Label |

```bash
[root@localhost ~]# mount /dev/sdb2 /test_mount_point2
[root@localhost ~]# df -hT /dev/sdb2
Filesystem     Type  Size  Used Avail Use% Mounted on
/dev/sdb2      ext3  5.0G   11M  4.7G   1% /test_mount_point2

## 我们将 /dev/sdb2 格式化为 ext2 格式, 格式化的前提是必须先卸载此分区(稍后讲解)
[root@localhost ~]# umount /dev/sdb2
[root@localhost ~]# mkfs.ext2 /dev/sdb2
[root@localhost ~]# mount /dev/sdb2 /test_mount_point2
[root@localhost ~]# df -hT /dev/sdb2
Filesystem     Type  Size  Used Avail Use% Mounted on
/dev/sdb2      ext2  5.0G   11M  4.7G   1% /test_mount_point2

## -L 更改卷标名
[root@localhost ~]# e2label /dev/sdb2
gkdaxue_test
[root@localhost ~]# tune2fs -L 'gkdaxue_logical' /dev/sdb2
tune2fs 1.41.12 (17-May-2010)
[root@localhost ~]# e2label /dev/sdb2
gkdaxue_logical

## -l 读取super block 的内容
[root@localhost ~]# tune2fs -l /dev/sdb2 | head -n 5
tune2fs 1.41.12 (17-May-2010)
Filesystem volume name:   gkdaxue_logical
Last mounted on:          <not available>
Filesystem UUID:          bf5957d5-734a-4fe1-853a-9ad9e21c36e6
Filesystem magic number:  0xEF53

## -j : 将 ext2 转换为 ext3 文件系统格式
[root@localhost ~]# df -hT /dev/sdb2
Filesystem     Type  Size  Used Avail Use% Mounted on
/dev/sdb2      ext2  5.0G   11M  4.7G   1% /test_mount_point2
[root@localhost ~]# umount /dev/sdb2
[root@localhost ~]# tune2fs -j /dev/sdb2
[root@localhost ~]# mount /dev/sdb2 /test_mount_point2
[root@localhost ~]# df -hT /dev/sdb2
Filesystem     Type  Size  Used Avail Use% Mounted on
/dev/sdb2      ext3  5.0G  139M  4.6G   3% /test_mount_point2
```

## 磁盘挂载与卸载
我们之前就简单的介绍过挂载点的概念, 挂载点必须是目录, 而这个目录是进入这个文件系统的入口, 我们可以通过这个目录来访问到文件系统里面的文件.
> 1. 单一目录文件系统不应该被重复挂载到不同的挂载点中
> 2. 单一目录不应该挂载多个文件系统
> 3. 理论上挂载点应该是空的, 如果不是空的, 挂载后, 挂载点原来的文件内容将暂时不可见, 卸载后可见.

### 磁盘挂载
> mount [ options ] 设备文件名  挂载点
>
> mount -a
>
> mount : 显示系统中已经挂载的文件系统, 不显示卷标

| 选项 | 作用 |
| ---- | ----- |
| -a | 根据 /etc/fstab 文件将未挂载的磁盘挂载到系统中 |
| -l | 显示目前挂载的信息, 并包含Label 命令, 默认不显示 Label 名称 |
| -t 文件系统 | 以指定的文件系统挂载, 默认不需要, 系统会自动识别 |
| -L 卷标名 | 可以利用文件系统的卷标名称来挂载 |
| -n | 不把实际挂载情况写入 /etc/mtab 中 |
| -o 额外选项 | 挂载时加上一些额外的参数 (多个选项之间用 " , " 分割) |

**挂载额外参数 : **
```bash
ro, rw       : 挂载文件系统成为 只读ro(read only) 或 可读写rw(read write)
async, sync  : 此文件系统使用 同步写入(sync) 或者 异步(async) 内存机制
auto, noauto : 是否允许此分区被 mount -a 自动挂载 (auto 自动挂载)
dev, nodev   : 是否允许此分区上可创建设备文件 (dev 允许)
suid, nosuid : 是否允许此分区含有 SUID/SGID 的文件格式
exec, noexec : 是否允许此分区上拥有可执行 binary 文件
user, nouser : 是否允许此分区让任何用户执行 mount (一般来说, 只有 root 可以进行mount操作, 如果为 user, 则普通用户也可以)
defaults     : 默认值为 rw, suid, dev, exec, auto, nouser, async
remount      : 重新挂载 (在系统出错或者重新更新参数时用的比较多)
```

#### 实例
```bash
## 查看 /dev/sdb{1,2} 的文件系统
[root@localhost ~]# df -hT /dev/sdb{1,2}
Filesystem     Type  Size  Used Avail Use% Mounted on
/dev/sdb1      ext3  5.0G  139M  4.6G   3% /test_mount_point1
/dev/sdb2      ext3  4.9G   76M  4.6G   2% /test_mount_point2

## 我们将 /dev/sdb2 格式化为 ext2 格式, 格式化的前提是必须先卸载此分区(稍后讲解)
[root@localhost ~]# umount /dev/sdb2
[root@localhost ~]# umount /dev/sdb1
[root@localhost ~]# mkfs.ext2 /dev/sdb2
[root@localhost ~]# e2label /dev/sdb2 'gkdaxue_test'
[root@localhost ~]# e2label /dev/sdb2
gkdaxue_test

## 现在 sdb1 为 ext3  sdb2 为 ext2, 现在挂载
[root@localhost ~]# mount /dev/sdb1 /test_mount_point1
[root@localhost ~]# mount /dev/sdb2 /test_mount_point2
[root@localhost ~]# df -hT /dev/sdb{1,2}
Filesystem     Type  Size  Used Avail Use% Mounted on
/dev/sdb1      ext3  5.0G  139M  4.6G   3% /test_mount_point1
/dev/sdb2      ext2  5.0G   11M  4.7G   1% /test_mount_point2

## 为什么我们连 -t 文件系统都没有写, 系统就能帮我们正确挂载呢? 
## 因为系统会去分析 super block 来测试挂载, 挂载成功, 就使用此文件系统挂载. 但是我们又如何查看系统支持哪些文件系统呢?
/etc/filesystems : 系统指定的测试挂载文件系统类型
/proc/filesystems : Linux 已经加载的文件系统类型
/lib/modules/$(uanme -r)/kernel/fs : 系统支持的文件系统类型
[root@localhost ~]# cat /etc/filesystems
ext4
ext3
ext2
nodev proc
nodev devpts
iso9660
vfat
hfs
hfsplus
[root@localhost ~]# cat /proc/filesystems 
.....
nodev	inotifyfs
nodev	devpts
nodev	ramfs
nodev	hugetlbfs
	    iso9660     <== 光盘的挂载格式
nodev	pstore
nodev	mqueue
nodev	selinuxfs
nodev	drm
	    ext4     
nodev	autofs
	    ext3
	    ext2
[root@localhost ~]# ls /lib/modules/$(uname -r)/kernel/fs
autofs4     cifs      dlm       ext2  fat      gfs2  jffs2       nfs         nls       udf
btrfs       configfs  ecryptfs  ext3  fscache  jbd   lockd       nfs_common  squashfs  xfs
cachefiles  cramfs    exportfs  ext4  fuse     jbd2  mbcache.ko  nfsd        ubifs

## -l 同时显示已挂载文件系统的卷标
[root@localhost ~]# mount | grep sdb
/dev/sdb1 on /test_mount_point1 type ext3 (rw)
/dev/sdb2 on /test_mount_point2 type ext2 (rw)
[root@localhost ~]# mount -l | grep sdb
/dev/sdb1 on /test_mount_point1 type ext3 (rw)
/dev/sdb2 on /test_mount_point2 type ext2 (rw) [gkdaxue_test]  <== 卷标显示出来了

## 尝试挂载光盘(确保你的虚拟机中 CD/DVD 选项勾选了 已连接 和启动时连接并选择了对应的ISO )
[root@localhost ~]# mkdir /media/cdrom
[root@localhost ~]# mount -t iso9660 /dev/cdrom /media/cdrom/  # = mount /dev/cdrom /media/cdrom
mount: block device /dev/sr0 is write-protected, mounting read-only <== 只读挂载的
[root@localhost ~]# df -hT | grep /media/cdrom
/dev/sr0             iso9660  3.7G  3.7G     0 100% /media/cdrom    <== 空间使用率 100%
[root@localhost ~]# mount -l | grep /media/cdrom
/dev/sr0 on /media/cdrom type iso9660 (ro) [CentOS_6.9_Final]       <== ro  只读
```

### 磁盘重新挂载
当我们进入当用户维护模式时, 根目录通常被系统挂载为只读, 所以这个时候我们就需要重新挂载根目录.
```bash
[root@localhost ~]# mount -o remount,rw,auto  /
```

### 磁盘卸载
我们之前已经挂载了文件系统, 那么我们如何将它卸载呢, 这就需要用到我们所说的 umount 命令了.
> umount [ options ] { DEVICE_NAME | Mount_Point }

| 选项 | 作用 |
| ---- | ----|
| -f | 强制卸载 |
| -n | 不更新 /etc/mtab 的情况下卸载 |

#### 实例
```bash
[root@localhost ~]# mount | tail -n 3
/dev/sdb1 on /test_mount_point1 type ext3 (rw)
/dev/sdb2 on /test_mount_point2 type ext2 (rw)
/dev/sr0 on /media/cdrom type iso9660 (ro)
 
[root@localhost ~]# umount /dev/sdb1                   # <== DEVICE_NAME
[root@localhost ~]# umount /test_mount_point2          # <== Mount_Point

[root@localhost ~]# mount | tail -n 3
/dev/sda6 on /var type ext4 (rw)
none on /proc/sys/fs/binfmt_misc type binfmt_misc (rw)
/dev/sr0 on /media/cdrom type iso9660 (ro)

## 然后我们现在有可能会遇到的一种情况.
[root@localhost ~]# cd /media/cdrom/
[root@localhost cdrom]# umount /dev/cdrom
umount: /media/cdrom: device is busy.     <== 他告诉我设备正忙, 不能卸载, 为什么呢
        (In some cases useful info about processes that use
         the device is found by lsof(8) or fuser(1))

## 因为你已经在挂载点里面了, 相当于已经进入该磁盘了, 所以离开挂载点就好了
[root@localhost ~]# umount /dev/cdrom
[root@localhost ~]# mount | tail -n 3
/dev/sda3 on /usr type ext4 (rw)
/dev/sda6 on /var type ext4 (rw)
none on /proc/sys/fs/binfmt_misc type binfmt_misc (rw)
```

## 开机自动挂载
手动的去进行 mount 很不人性化, 并且在系统重启时, 我们又需要自己一个一个的手动去挂载太麻烦了, 那么能不能让系统在开机的时候自动挂载呢, 接下来我们讲解一下开机挂载 /etc/fstab 文件. 
```bash
[root@localhost ~]# cat /etc/fstab 

#
# /etc/fstab
# Created by anaconda on Sun Mar  3 11:33:34 2019
#
# Accessible filesystems, by reference, are maintained under '/dev/disk'
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info
#
磁盘设备文件名/Label Name/UUID             挂载点(mount point)      文件系统  文件系统参数   
UUID=64af9fff-884d-4cf2-afe6-ba3f7869cf35 /                       ext4    defaults        1 1
UUID=356ce5e4-c782-44cb-9447-1e7f0e04e7d1 /boot                   ext4    defaults        1 2
/dev/mapper/server-myhome /home                                   ext4    defaults        1 2
UUID=fb2c6429-d1fa-4a77-a4db-d2bb899fb552 /tmp                    ext4    defaults        1 2
UUID=33659ce2-7c20-4143-9d2b-4e5b39fe5310 /usr                    ext4    defaults        1 2
UUID=8c2f0179-2787-43c8-8c8b-16456ebc1f57 /var                    ext4    defaults        1 2
UUID=79c4a924-5436-4163-a624-4785f47a424d swap                    swap    defaults        0 0
tmpfs                                     /dev/shm                tmpfs   defaults        0 0
devpts                                    /dev/pts                devpts  gid=5,mode=620  0 0
sysfs                                     /sys                    sysfs   defaults        0 0
proc                                      /proc                   proc    defaults        0 0

## 我们可以发现该文件可以分为 6 列, 每列含义如下:
1. 可以填写磁盘设备文件名, UUID(super block中), 或者 Label Name (如果使用Label Name 请确认必须存在且不重复)
   	[root@localhost ~]# tune2fs -l /dev/sda5
   	Filesystem UUID:          64af9fff-884d-4cf2-afe6-ba3f7869cf35
2. 挂载点(挂载点必须是目录)
3. 磁盘分区的文件系统(例如 ext3, ext4, xfs, iso9660, swap等)
4. 文件系统参数, 我们之前手动挂载的时候使用的 mount -o 后边跟的选项, 稍后在详细介绍一下
   [gkdaxue@localhost ~]$ mount /dev/sdb1 /test_mount_point1
   mount: only root can do that   <== 非 root 用户不可以挂载
5. 能否被 dump 命令备份 ( 0 不要做 dump 备份, 1 表示每天进行 dump操作)
6. 是否以 fsck 检验扇区 ( 0 不要检验, 1 表示最早检验(只有根目录设置为1), 2 在1之后被检验 )
```

**文件系统参数 :**

| 选项 | 作用 |
| ---- | ---- |
| async(异步) / sync(同步) | 磁盘是否以异步方式运行, 默认为 async 性能较好 |
| auto(自动) / noatuo(非自动) | 使用 mount -a 时是否会被主动测试挂载 默认为 auto |
| rw(读写) / ro(只读) | 设置磁盘是否可读写 |
| exec(可执行) / noexec(不可执行) | 再次文件系统内是否可以进行 '执行' 的工作 |
| user / nouser | 是否允许用户使用 mount 命令来挂载. 默认只有 root 可以 |
| suid / nosuid  | 表示此文件系统是否允许 SUID 的存在 |
| dev / nodev | 是否允许此磁盘上创建设备文件 |
| usrquota | 启动文件系统时, 支持磁盘配额模式 |
| grpquota | 启动文件系统时, 支持对群组磁盘配额模式 |
| defaults | 具有 rw, suid, dev, exec, auto, nouser, async等参数, 一般情况下使用 defaults 即可. | 

其实 /etc/fstab 文件就是我们可以利用 mount 命令来进行挂载的, 将所有的参数写入这个文件即可. 不过讲解一下系统挂载的一些限制 :
> 1. 根目录(/) 必须挂载的, 且必须第一个挂载
> 2. 所有的挂载点同一时间只能挂载一次
> 3. 所有分区同一时间内只能挂载一次
> 4. 如果想要进行卸载, 必须先离开挂载点之外的地方, 才可以卸载

### 实验
我们想在想要把我们的 /dev/sdb2 开机自动挂载到 /test_mount_point2, 应该如何处理
```bash
## 在以下文件中最后新增一行
[root@localhost ~]# vim /etc/fstab
/dev/sdb2  /test_mount_point2  ext3 defaults 0 0

## 使用 mount -a 测试挂载
[root@localhost ~]# mount -a
```

> /etc/fstab 是开机时的配置文件, 实际文件系统的挂载是记录到 /etc/mtab 和 /proc/mounts 文件中, 每当我们改动文件系统的挂载时, 也会同时改动这两个文件.

## 特殊设备 loop 挂载 以及 swap(内存交换空间)的构建
比如当初在划分磁盘分区的时候, 只划分了一个根分区并分配了全部的空间, 已经没有多余的空间来进行额外的分区, 但是呢 你又发现了你的内存太小了, 所以想要使用 swap 交换分区来缓解内存的压力. 那么该如何操作呢? 
> 安装的时候一定要分的两个分区, 根目录 和 swap 分区, swap 就是在应付物理内存不足的情况下扩展内存的功能.

当内存不足时, 会把内存中暂时用不到的程序和数据放到 swap 中去, 然后多余出来的内存就可以给其他的程序使用, 不会因为内存不足, 导致其他程序异常结束服务终止.

> 因为我买的云主机为 1核 1G内存 1M 40GB 配置, 然后安装了很多的软件, 经常因为内存不足而导致服务异常结束, 那么我就可以使用如下方式来增加一个 swap, 缓解内存压力.

使用文件构造 swap 的步骤 :
> 1. 分出一个区或者文件给系统作为 swap (有可能需要修改分区的ID)
> 2. 格式化 "mkswap 设备文件名", 可以格式化该分区成为 swap 格式
> 3. 启用该 swap 设备, 方法为 swapon 设备文件名
> 4. 通过 free 命令来查看
> 5. 根据需要, 判断是否需要开机启动等.

```bash
## 从 /dev/sdb2 中制作一个 2G 的空的大文件
[root@localhost ~]# mount /dev/sdb2 /test_mount_point2
[root@localhost ~]# dd if=/dev/zero of=/test_mount_point2/swap_file bs=1024M count=2
2+0 records in
2+0 records out
2147483648 bytes (2.1 GB) copied, 26.9022 s, 79.8 MB/s
[root@localhost ~]# ll -h /test_mount_point2/swap_file 
-rw-r--r--. 1 root root 2.0G Mar 11 07:09 /test_mount_point2/swap_file

## 格式化成为 swap 格式
[root@localhost ~]# mkswap /test_mount_point2/swap_file 
mkswap: /test_mount_point2/swap_file: warning: don't erase bootbits sectors
        on whole disk. Use -f to force.
Setting up swapspace version 1, size = 2097148 KiB
no label, UUID=834e97fc-1fb2-446a-9b26-f15aa4380fc6

## 查看一下内存
[root@localhost ~]# free
             total       used       free     shared    buffers     cached
Mem:       1004112     165060     839052          0       3892      28764
-/+ buffers/cache:     132404     871708
Swap:      1023996      20804    1003192

## 开启 /test_mount_point2/swap_file swap 
[root@localhost ~]# swapon /test_mount_point2/swap_file 
[root@localhost ~]# free
             total       used       free     shared    buffers     cached
Mem:       1004112     168160     835952          0       5464      28952
-/+ buffers/cache:     133744     870368
Swap:      3121144      20784    3100360    <== 发现此项数值变大

## 关闭 /test_mount_point2/swap_file swap
[root@localhost ~]# swapoff /test_mount_point2/swap_file 
[root@localhost ~]# free
             total       used       free     shared    buffers     cached
Mem:       1004112     166920     837192          0       5480      28956
-/+ buffers/cache:     132484     871628
Swap:      1023996      20784    1003212

## 剩下的根据需要, 是不是需要开机启动等操作.
```

### swapon/swapoff 命令
> swapon/swapoff 设备文件名

启用或禁用 swap 设备

# 文件与文件系统的打包和压缩
在 Linux 下扩展名仅仅只是为了给我们提示让我们可以知道使用什么方式来操作仅此而已. 在 Linux 中压缩文件的扩展名大多为 \*.tar, \*.tar.gz, \*.tgz, \*.gz, \*.bz2, \*.zip, 因为支持的压缩命令非常多, 所以需要使用特定的命令来 压缩/解压缩.

**压缩比 : 压缩前与压缩后的文件所占用的磁盘空间大小** 

## gzip命令
压缩或者解压缩文件, gzip 所建的压缩文件为 \*.gz 的文件名并且 gzip 压缩的文件可以在 Windows系统中被 Winrar 解压缩. **在 压缩/解压缩 时默认会删除原文件**.
> gzip [ options ] FILE_NAME
>
> zcat 文件名.gz

| 选项 | 作用 |
| ---- | ---- |
| -v | 显示压缩比的信息 |
| -# | # 可以是1-9的数字, 表示压缩等级, 默认为6|
| -d | 解压缩文件, 也可以使用 gunzip |
| -c | 把 解压/压缩 后的文件输出到标准输出设备 |

### 实例
```bash
[root@localhost ~]# cd /tmp && mkdir test_zip && cd test_zip
[root@localhost test_zip]# cp /etc/fstab  .
[root@localhost test_zip]# ll
total 4
-rw-r--r--. 1 root root 1165 Mar 11 13:31 fstab

## 创建压缩文件, 默认创建完成后删除源文件
[root@localhost test_zip]# gzip -v fstab 
fstab:	 59.8% -- replaced with fstab.gz
[root@localhost test_zip]# ll
total 4
-rw-r--r--. 1 root root 500 Mar 11 13:31 fstab.gz   <== *.gz 压缩文件

## zcat 读取压缩文件的内容
[root@localhost test_zip]# zcat fstab.gz 

#
# /etc/fstab
# Created by anaconda on Sun Mar  3 11:33:34 2019
#
# Accessible filesystems, by reference, are maintained under '/dev/disk'
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info
#
UUID=64af9fff-884d-4cf2-afe6-ba3f7869cf35 /                       ext4    defaults        1 1
UUID=356ce5e4-c782-44cb-9447-1e7f0e04e7d1 /boot                   ext4    defaults        1 2
/dev/mapper/server-myhome /home                                   ext4    defaults        1 2
UUID=fb2c6429-d1fa-4a77-a4db-d2bb899fb552 /tmp                    ext4    defaults        1 2
UUID=33659ce2-7c20-4143-9d2b-4e5b39fe5310 /usr                    ext4    defaults        1 2
UUID=8c2f0179-2787-43c8-8c8b-16456ebc1f57 /var                    ext4    defaults        1 2
UUID=79c4a924-5436-4163-a624-4785f47a424d swap                    swap    defaults        0 0
tmpfs                                     /dev/shm                tmpfs   defaults        0 0
devpts                                    /dev/pts                devpts  gid=5,mode=620  0 0
sysfs                                     /sys                    sysfs   defaults        0 0
proc                                      /proc                   proc    defaults        0 0

## 尝试解压缩, 也可以使用 gunzip fstab.gz 命令
[root@localhost test_zip]# gzip -d fstab.gz 
[root@localhost test_zip]# ll
total 4
-rw-r--r--. 1 root root 1165 Mar 11 13:31 fstab

## 设置压缩等级并保留源文件
[root@localhost test_zip]# gzip -9 -v -c fstab > fstab.gz
fstab:	 60.0%
[root@localhost test_zip]# ll
total 8
-rw-r--r--. 1 root root 1165 Mar 11 13:31 fstab
-rw-r--r--. 1 root root  498 Mar 11 13:42 fstab.gz

## 文件已经存在, 会询问是否覆盖处理
[root@localhost test_zip]# gunzip fstab.gz
gzip: fstab already exists; do you wish to overwrite (y or n)? y
[root@localhost test_zip]# ll
total 4
-rw-r--r--. 1 root root 1165 Mar 11 13:42 fstab

## 尝试压缩目录, 发现不能压缩目录
[root@localhost test_zip]# mkdir gkdaxue
[root@localhost test_zip]# gzip gkdaxue/
gzip: gkdaxue/ is a directory -- ignored
```

## bzip2命令
压缩/解压缩 文件, 文件名以 bz2为后缀, 默认也是不保留源文件
> bzip2 [ options ] 文件名
>
> bzcat 文件名.bz2

| 选项 | 作用 |
| ---- | ----- |
| -c | 将压缩过程中产生的数据删除到屏幕上 |
| -d | 解压缩文件 |
| -k | 保留源文件 |
| -v | 显示压缩比 |
| -# | 压缩等级, 1-9的数字 |

### 实例
```bash
[root@localhost test_zip]# bzip2 fstab 
[root@localhost test_zip]# ll
total 4
-rw-r--r--. 1 root root 544 Mar 11 13:42 fstab.bz2
[root@localhost test_zip]# bzcat fstab.bz2 

#
# /etc/fstab
# Created by anaconda on Sun Mar  3 11:33:34 2019
#
# Accessible filesystems, by reference, are maintained under '/dev/disk'
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info
#
UUID=64af9fff-884d-4cf2-afe6-ba3f7869cf35 /                       ext4    defaults        1 1
UUID=356ce5e4-c782-44cb-9447-1e7f0e04e7d1 /boot                   ext4    defaults        1 2
/dev/mapper/server-myhome /home                                   ext4    defaults        1 2
UUID=fb2c6429-d1fa-4a77-a4db-d2bb899fb552 /tmp                    ext4    defaults        1 2
UUID=33659ce2-7c20-4143-9d2b-4e5b39fe5310 /usr                    ext4    defaults        1 2
UUID=8c2f0179-2787-43c8-8c8b-16456ebc1f57 /var                    ext4    defaults        1 2
UUID=79c4a924-5436-4163-a624-4785f47a424d swap                    swap    defaults        0 0
tmpfs                   				  /dev/shm                tmpfs   defaults        0 0
devpts                  				  /dev/pts                devpts  gid=5,mode=620  0 0
sysfs                   				  /sys                    sysfs   defaults        0 0
proc                    				  /proc                   proc    defaults        0 0

## 解压缩, 也可以使用 bunzip2 fstab.bz2 命令
[root@localhost test_zip]# bzip2 -d fstab.bz2 
[root@localhost test_zip]# bzip2 -9 -k fstab 
[root@localhost test_zip]# ll
total 8
-rw-r--r--. 1 root root 1165 Mar 11 13:42 fstab
-rw-r--r--. 1 root root  544 Mar 11 13:42 fstab.bz2

## 也不能压缩目录
[root@localhost test_zip]# bzip2 gkdaxue
bzip2: Input file gkdaxue is a directory.
```

## tar命令
我们上面的命令仅仅只能针对单一的文件来压缩, tar 可以将多个目录或者文件打包成一个大文件. 然后使用 gzip/bzip2 来将该文件进行压缩.
> tar [ options ] [FILE]

| 选项 | 作用 |
| ---- | ---- |
| -c | 创建压缩文件 |
| -x | 解开压缩文件 |
| -t | 查看压缩包内的文件名 |
| -C DIR_NAME | 解压到指定 DIR_NAME 目录 | 
| -z | 通过 gzip 压缩或解压 |
| -j | 通过 bzip2 压缩或解压 |
| -v | 显示压缩或解压过程 |
| -f FILE_NAME | 被处理(压缩/解压缩)的文件名, 必须放到参数的最后一位 |
| -p | 保留原始的权限和属性, 常用于备份重要的配置文件 |
| -P(大写) | 文件名使用绝对名称，不移除文件名称前的 " / "号 |
| --exclude=FILE_NAME | 打包时不包含 FILE_NAME 目录|

### 实例
```bash
## 尝试压缩文件  -v 会显示大量的参数, 所以省略, -f 选项跟上文件名
[root@localhost ~]# tar -czvf ./etc.tar.gz /etc/
......
[root@localhost ~]# ll
total 10724
-rw-r--r--. 1 root root 10979368 Mar 12 09:47 etc.tar.gz


## 开始解压文件, 使用对应的方式解压  gzip 方式
[root@localhost ~]# tar -xzvf etc.tar.gz etc
.....
[root@localhost ~]# ll
total 10736
drwxr-xr-x. 118 root root    12288 Mar 12 05:51 etc
-rw-r--r--.   1 root root 10979368 Mar 12 09:47 etc.tar.gz


## 查看压缩文件的内容 
[root@localhost ~]# tar -ztvf etc.tar.gz  | head -n 5
drwxr-xr-x root/root         0 2019-03-12 05:51 etc/
-rw------- root/root       232 2017-03-23 05:59 etc/autofs_ldap_auth.conf
-rw-r--r-- root/root     13641 2017-03-23 05:59 etc/autofs.conf
-rw-r--r-- root/root      1057 2017-03-23 02:12 etc/sysctl.conf
drwxr-xr-x root/root         0 2019-03-03 11:37 etc/ipa/


## 我们发现使用 tar 命令不会删除源文件
```

### 解压文件中单一文件的方法, 比如 shadow 文件
```bash
[root@localhost ~]# tar -ztf etc.tar.gz  | grep shadow
etc/gshadow-
etc/gshadow
etc/shadow-
etc/shadow
[root@localhost ~]# rm -rf etc
[root@localhost ~]# tar -zxvf etc.tar.gz etc/shadow
etc/shadow
[root@localhost ~]# ll -R etc
etc:
total 4
----------. 1 root root 1091 Mar 12 05:51 shadow
[root@localhost ~]# rm -rf *
```

### 打包某目录(排除某些文件或目录)
```bash
## 不排除打包, 做个对比
[root@localhost ~]# tar -czf etc.tar.gz2 /etc
[root@localhost ~]# tar -tvf etc.tar.gz2 | grep shadow
---------- root/root       672 2019-03-12 05:46 etc/gshadow-
---------- root/root       689 2019-03-12 05:51 etc/gshadow
---------- root/root      1056 2019-03-12 05:46 etc/shadow-
---------- root/root      1091 2019-03-12 05:51 etc/shadow


## 排除带 shadow 字符串的文件
[root@localhost ~]# ll /etc/*shadow*
----------. 1 root root  689 Mar 12 05:51 /etc/gshadow
----------. 1 root root  672 Mar 12 05:46 /etc/gshadow-
----------. 1 root root 1091 Mar 12 05:51 /etc/shadow
----------. 1 root root 1056 Mar 12 05:46 /etc/shadow-
[root@localhost ~]# tar -czf etc.tar.gz --exclude=/etc/*shadow* /etc
[root@localhost ~]# ll
total 10720
-rw-r--r--. 1 root root 10974401 Mar 12 10:17 etc.tar.gz
## 没有找到记录
[root@localhost ~]# tar -ztvf etc.tar.gz  | grep "*shadow*"
[root@localhost ~]#
```

## dump命令(完整备份工具)
这个东西我们在之前挂载的时候提到过, 这个命令除了能够针对整个文件系统备份外还能针对目录来备份.
> dump [ options ] 待备份数据
>
> dump -W

| 选项 | 作用 |
| ----- | ---- |
| -S | 仅列出待备份数据需要多少磁盘空间 |
| -u | 将此次备份的时间记录到 /etc/dumpdates 文件中 |
| -v | 显示备份过程 |
| -j | 使用 bzip2 来对数据进行压缩, 默认压缩等级为 2 |
| -LEVEl | 从 0-9 10个级别 |
| -W | 列出 /etc/fstab 里面设置过 dump 的分区是否备份过 |
| -f FILE |  将备份写入到 FILE 文件 |

**LEVEl :**
> 0 : 完整备份
> 
> 1 : 在 level 0 的基础上差异化备份
>
> 2 : 在 level 1 的基础上差异化备份
>
> ...... 直到 9

### 备份单一文件系统
可以使用 0-9 个 level 来备份, 备份时还可以使用挂载点或者是设备文件名来进行备份.
```bash
## 如果你的系统中没有安装 dump , 你需要自己手动安装
[root@locahost ~]# yum insall -y dump

## 待备份数据
[root@localhost ~]# df -hT /dev/sda1
Filesystem     Type  Size  Used Avail Use% Mounted on
/dev/sda1      ext4  190M   35M  146M  20% /boot

## 查看如果备份需要多大空间, 
[root@localhost ~]# dump -S /dev/sda1
34552832    <== 单位为 bytes  大概 33M

## 完整备份并把时间记录到 /etc/dumpdates 文件中, 备份文件名为 boot.dump 可以使用  /boot 或者 /dev/sda1 都可以
[root@localhost ~]# dump -0uf boot.dump /boot
  DUMP: Date of this level 0 dump: Tue Mar 12 11:24:30 2019
  DUMP: Dumping /dev/sda1 (/boot) to boot.dump
  DUMP: Label: none
  DUMP: Writing 10 Kilobyte records
  DUMP: mapping (Pass I) [regular files]
  DUMP: mapping (Pass II) [directories]
  DUMP: estimated 33743 blocks.
  DUMP: Volume 1 started with block 1 at: Tue Mar 12 11:24:30 2019
  DUMP: dumping (Pass III) [directories]
  DUMP: dumping (Pass IV) [regular files]
  DUMP: Closing boot.dump
  DUMP: Volume 1 completed at: Tue Mar 12 11:24:31 2019
  DUMP: Volume 1 33850 blocks (33.06MB)
  DUMP: Volume 1 took 0:00:01
  DUMP: Volume 1 transfer rate: 33850 kB/s
  DUMP: 33850 blocks (33.06MB) on 1 volume(s)
  DUMP: finished in 1 seconds, throughput 33850 kBytes/sec
  DUMP: Date of this level 0 dump: Tue Mar 12 11:24:30 2019
  DUMP: Date this dump completed:  Tue Mar 12 11:24:31 2019
  DUMP: Average transfer rate: 33850 kB/s
  DUMP: DUMP IS DONE
[root@localhost ~]# ll boot.dump  /etc/dumpdates 
-rw-r--r--. 1 root root 34662400 Mar 12 11:24 boot.dump
-rw-rw-r--. 1 root disk       43 Mar 12 11:24 /etc/dumpdates
[root@localhost ~]# cat /etc/dumpdates 
文件系统   备份等级    备份时间
/dev/sda1 0          Tue Mar 12 11:24:30 2019 +0800

## -W 列出 /etc/fsab 文件中设置 dump 的文件是否备份过
[root@localhost ~]# dump -W
Last dump(s) done (Dump '>' file systems):
> /dev/sda5	(     /)                 Last dump: never
  /dev/sda1	( /boot)                 Last dump: Level 0, Date Tue Mar 12 11:24:30 2019
> /dev/mapper/server-myhome	( /home) Last dump: never
> /dev/sda8	(  /tmp)                 Last dump: never
> /dev/sda3	(  /usr)                 Last dump: never
> /dev/sda6	(  /var)                 Last dump: never

## 体验差异化备份
[root@localhost ~]# dd if=/dev/zero of=/boot/test.img count=1 bs=1M
1+0 records in
1+0 records out
1048576 bytes (1.0 MB) copied, 0.00257376 s, 407 MB/s
[root@localhost ~]# ll /boot/test.img 
-rw-r--r--. 1 root root 1048576 Mar 12 11:32 /boot/test.img
[root@localhost ~]# dump -1uf boot.dump.1 /boot
  DUMP: Date of this level 1 dump: Tue Mar 12 11:41:28 2019
  DUMP: Date of last level 0 dump: Tue Mar 12 11:24:30 2019
  DUMP: Dumping /dev/sda1 (/boot) to boot.dump.1
  DUMP: Label: none
  DUMP: Writing 10 Kilobyte records
  DUMP: mapping (Pass I) [regular files]
  DUMP: mapping (Pass II) [directories]
  DUMP: estimated 1055 blocks.
  DUMP: Volume 1 started with block 1 at: Tue Mar 12 11:41:28 2019
  DUMP: dumping (Pass III) [directories]
  DUMP: dumping (Pass IV) [regular files]
  DUMP: Closing boot.dump.1
  DUMP: Volume 1 completed at: Tue Mar 12 11:41:28 2019
  DUMP: Volume 1 1060 blocks (1.04MB)
  DUMP: 1060 blocks (1.04MB) on 1 volume(s)
  DUMP: finished in less than a second
  DUMP: Date of this level 1 dump: Tue Mar 12 11:41:28 2019
  DUMP: Date this dump completed:  Tue Mar 12 11:41:28 2019
  DUMP: Average transfer rate: 0 kB/s
  DUMP: DUMP IS DONE
[root@localhost ~]# ll 
total 34912
-rw-r--r--. 1 root root 34662400 Mar 12 11:24 boot.dump
-rw-r--r--. 1 root root  1085440 Mar 12 11:41 boot.dump.1    <== 仅仅只有 1M 多点的备份文件
[root@localhost ~]# cat /etc/dumpdates 
/dev/sda1 0 Tue Mar 12 11:24:30 2019 +0800
/dev/sda1 1 Tue Mar 12 11:41:28 2019 +0800
[root@localhost ~]# dump -W
Last dump(s) done (Dump '>' file systems):
> /dev/sda5	(     /)                 Last dump: never
  /dev/sda1	( /boot)                 Last dump: Level 1, Date Tue Mar 12 11:41:28 2019
> /dev/mapper/server-myhome	( /home) Last dump: never
> /dev/sda8	(  /tmp)                 Last dump: never
> /dev/sda3	(  /usr)                 Last dump: never
> /dev/sda6	(  /var)                 Last dump: never
```

## 备份目录
> 1. 所有的备份数据必须要在该目录下面
> 2. 仅能使用level 0 , 即完整备份, 不支持差异化备份
> 3. 不支持 -u 选项

```bash
## 此命令中的 f 选项不能和之前的短选项合用, 否则报错
[root@localhost ~]# dump -0j -f /root/etc.dump.bz2 /etc
  DUMP: Date of this level 0 dump: Thu Mar 14 06:21:51 2019
  DUMP: Dumping /dev/sda5 (/ (dir etc)) to /root/etc.dump.bz2
  DUMP: Label: none
  DUMP: Writing 10 Kilobyte records
  DUMP: Compressing output at compression level 2 (bzlib)
  DUMP: mapping (Pass I) [regular files]
  DUMP: mapping (Pass II) [directories]
  DUMP: estimated 43111 blocks.
  DUMP: Volume 1 started with block 1 at: Thu Mar 14 06:21:51 2019
  DUMP: dumping (Pass III) [directories]
  DUMP: dumping (Pass IV) [regular files]
  DUMP: Closing /root/etc.dump.bz2
  DUMP: Volume 1 completed at: Thu Mar 14 06:21:59 2019
  DUMP: Volume 1 took 0:00:08
  DUMP: Volume 1 transfer rate: 1675 kB/s
  DUMP: Volume 1 48190kB uncompressed, 13404kB compressed, 3.596:1
  DUMP: 48190 blocks (47.06MB) on 1 volume(s)
  DUMP: finished in 8 seconds, throughput 6023 kBytes/sec
  DUMP: Date of this level 0 dump: Thu Mar 14 06:21:51 2019
  DUMP: Date this dump completed:  Thu Mar 14 06:21:59 2019
  DUMP: Average transfer rate: 1675 kB/s
  DUMP: Wrote 48190kB uncompressed, 13404kB compressed, 3.596:1
  DUMP: DUMP IS DONE
```

## restore命令
我们前边已经学习了如何备份数据了, 那么如果想要恢复数据就要用到我们所说的 restore 命令了.
> restore [ options ] [ -f DUMP_FILE ] [ -h ]
>
> restore [ options ] [ -f DUMP_FILE ] [ -D 挂载点 ]

| 选项 | 作用 |
| --- | ---- |
| -t | 查看备份文件内容 |
| -C | 将dump文件和实际文件系统作比较, 列出 **在dump 内有记录且和目前文件系统不一样的文件 **| 
| -i | 交互模式, 可以还原部分文件 用在目录的还原 |
| -r | 还原整个文件系统, 用在文件系统的还原 |
| -h | 查看完整备份数据中的 inode 和 数据系统的 lable 等信息 |
| -f DUMP_FILE | 要处理的 dump 文件 |
| -D Mount_Point| 可以和 -C 搭配, 找出后面接的挂载点与dump内有不同的文件 |

### 实例
```bash
## 查看 dump 文件的内容
[root@localhost ~]# restore -t -f /root/boot.dump 
Dump   date: Thu Mar 14 05:42:13 2019  <==备份的日期
Dumped from: the epoch
Level 0 dump of /boot on localhost.localdomain:/dev/sda1  <== level 的级别以及备份的文件系统
Label: none
         2	.
        11	./lost+found
        12	./grub
        24	./grub/grub.conf
        13	./grub/splash.xpm.gz
        25	./grub/menu.lst
......
[root@localhost ~]# restore -t -f /root/etc.dump.bz2
Dump tape is compressed.                <== 说明数据有被压缩
Dump   date: Thu Mar 14 06:21:51 2019
Dumped from: the epoch
Level 0 dump of / (dir etc) on localhost.localdomain:/dev/sda5  <== 目录
Label: none
         2	.
     32002	./etc
        17	./etc/modprobe.d
        21	./etc/modprobe.d/anaconda.conf
       672	./etc/modprobe.d/dist-alsa.conf
       673	./etc/modprobe.d/dist-oss.conf
.....


## -C : 比较 dump 和实际文件系统
[root@localhost ~]# restore -C -f /root/boot.dump
Dump   date: Thu Mar 14 05:42:13 2019
Dumped from: the epoch
Level 0 dump of /boot on localhost.localdomain:/dev/sda1
Label: none
filesys = /boot
## 先把 /boot 的文件重命名, 导致接下来会出现不一致的情况
[root@localhost ~]# mv /boot/config-2.6.32-696.el6.x86_64 /boot/config-2.6.32-696.el6.x86_64-back
[root@localhost ~]# restore -C -f /root/boot.dump
Dump   date: Thu Mar 14 05:42:13 2019
Dumped from: the epoch
Level 0 dump of /boot on localhost.localdomain:/dev/sda1
Label: none
filesys = /boot
restore: unable to stat ./config-2.6.32-696.el6.x86_64: No such file or directory  <== 能看出来不一致
Some files were modified!  1 compare errors


## 还原文件系统全部文件,  必须事先跳转到想要恢复文件系统的目录
[root@localhost ~]# cd /boot/
[root@localhost boot]# restore -r -f /root/boot.dump 
restore: ./lost+found: File exists
restore: ./grub: File exists
restore: ./efi: File exists
restore: ./efi/EFI: File exists
restore: ./efi/EFI/redhat: File exists
restore: cannot create symbolic link ./grub/menu.lst->./grub.conf: File exists
[root@localhost boot]# ll
total 35371
-rw-r--r--. 1 root root   108164 Mar 22  2017 config-2.6.32-696.el6.x86_64    <== 已经重新出现
-rw-r--r--. 1 root root   108164 Mar 22  2017 config-2.6.32-696.el6.x86_64-back
drwxr-xr-x. 3 root root     1024 Mar  3 11:39 efi
drwxr-xr-x. 2 root root     1024 Mar  3 11:42 grub
-rw-------. 1 root root 26669464 Mar  3 11:41 initramfs-2.6.32-696.el6.x86_64.img
drwx------. 2 root root    12288 Mar  3 11:31 lost+found
-rw-------. 1 root root    94336 Mar 14 06:57 restoresymtable
-rw-r--r--. 1 root root   215634 Mar 22  2017 symvers-2.6.32-696.el6.x86_64.gz
-rw-r--r--. 1 root root  2622364 Mar 22  2017 System.map-2.6.32-696.el6.x86_64
-rw-r--r--. 1 root root  1048576 Mar 12 11:32 test.img
-rw-r--r--. 1 root root  1048576 Mar 14 05:44 testing.img
-rwxr-xr-x. 1 root root  4274992 Mar 22  2017 vmlinuz-2.6.32-696.el6.x86_64
## 然后在还原 level 1 level2  level3 ...  逐一还原即可.

## 还原文件系统部分文件
[root@localhost boot]# rm -rf config-2.6.32-696.el6.x86_64
[root@localhost boot]# restore -i -f /root/boot.dump
restore >
## 现在已经进入 restore 环境

restore > help
Available commands are:
	ls [arg] - list directory         查看备份中的文件
	cd arg - change directory         跳转到目录中
	pwd - print current directory     显示当前路径
	add [arg] - add `arg' to list of files to be extracted   将文件加入到提取列表中
	delete [arg] - delete `arg' from list of files to be extracted  从提前列表中删除某个文件
	extract - extract requested files      开始提取
	setmodes - set modes of requested directories
	quit - immediately exit program       退出 
	what - list dump header information
	verbose - toggle verbose flag (useful with ``ls'')
	prompt - toggle the prompt display
	help or `?' - print this list
If no `arg' is supplied, the current directory is used
restore > add config-2.6.32-696.el6.x86_64    ## <== 提取此文件
restore > extract                             ## 开始提取
You have not read any volumes yet.
Unless you know which volume your file(s) are on you should start
with the last volume and work towards the first.
Specify next volume # (none if no more volumes): 1  ## 输入 1
set owner/mode for '.'? [yn] n     ## 不设置
restore > quit    ## 退出
[root@localhost boot]# ll 
total 35371
-rw-r--r--. 1 root root   108164 Mar 22  2017 config-2.6.32-696.el6.x86_64  ## <== 已经成功提取出来
-rw-r--r--. 1 root root   108164 Mar 22  2017 config-2.6.32-696.el6.x86_64-back
drwxr-xr-x. 3 root root     1024 Mar  3 11:39 efi
drwxr-xr-x. 2 root root     1024 Mar  3 11:42 grub
-rw-------. 1 root root 26669464 Mar  3 11:41 initramfs-2.6.32-696.el6.x86_64.img
drwx------. 2 root root    12288 Mar  3 11:31 lost+found
-rw-------. 1 root root    94336 Mar 14 06:57 restoresymtable
-rw-r--r--. 1 root root   215634 Mar 22  2017 symvers-2.6.32-696.el6.x86_64.gz
-rw-r--r--. 1 root root  2622364 Mar 22  2017 System.map-2.6.32-696.el6.x86_64
-rw-r--r--. 1 root root  1048576 Mar 12 11:32 test.img
-rw-r--r--. 1 root root  1048576 Mar 14 05:44 testing.img
-rwxr-xr-x. 1 root root  4274992 Mar 22  2017 vmlinuz-2.6.32-696.el6.x86_64

## 还原实验环境
[root@localhost boot]# rm -rf config-2.6.32-696.el6.x86_64-back 
```

##   