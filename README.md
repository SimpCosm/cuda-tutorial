# cuda-tutorial

## 环境配置

系统选用的是腾讯云GPU服务器，安装有Tesla P40，系统为Ubuntu CentOS 8，按量计费。

- 确认系统识别到GPU
```bash
# lspci  | grep NVIDIA
00:08.0 3D controller: NVIDIA Corporation GP102GL [Tesla P40] (rev a1)
```

- 安装installer
```bash
$ wget https://developer.download.nvidia.com/compute/cuda/11.1.0/local_installers/cuda-repo-rhel8-11-1-local-11.1.0_455.23.05-1.x86_64.rpm
$ sudo rpm -i cuda-repo-rhel8-11-1-local-11.1.0_455.23.05-1.x86_64.rpm
$ sudo dnf clean all
```

- 安装显卡驱动
```bash
sudo dnf -y module install nvidia-driver:latest-dkms
```

- 安装CUDA Toolkit
```bash
sudo dnf -y install cuda
```

- 配置环境变量
在 `.bashrc` 中添加下列变量，然后执行 `source .bashrc`
```bash
export PATH=/usr/local/cuda/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH
export CUDA_HOME=/usr/local/cuda
```

- 安装成功效果

```bash
[root@VM-0-11-centos ~]# nvcc --version
nvcc: NVIDIA (R) Cuda compiler driver
Copyright (c) 2005-2020 NVIDIA Corporation
Built on Tue_Sep_15_19:10:02_PDT_2020
Cuda compilation tools, release 11.1, V11.1.74
Build cuda_11.1.TC455_06.29069683_0
[root@VM-0-11-centos ~]# nvidia-smi
Sun Sep 27 14:39:07 2020
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 455.23.05    Driver Version: 455.23.05    CUDA Version: 11.1     |
|-------------------------------+----------------------+----------------------+
| GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|                               |                      |               MIG M. |
|===============================+======================+======================|
|   0  Tesla P40           On   | 00000000:00:08.0 Off |                    0 |
| N/A   25C    P8     9W / 250W |      0MiB / 22919MiB |      0%      Default |
|                               |                      |                  N/A |
+-------------------------------+----------------------+----------------------+

+-----------------------------------------------------------------------------+
| Processes:                                                                  |
|  GPU   GI   CI        PID   Type   Process name                  GPU Memory |
|        ID   ID                                                   Usage      |
|=============================================================================|
|  No running processes found                                                 |
+-----------------------------------------------------------------------------+
```

更多安装细节，可以参考[CUDA官方教程](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html)

## Hello World

不妨先写一个cuda C 程序，命名为`hello.cu`，用它来输出字符串 `Hello World` 

```c hello.cu
#include <stdio.h>

__global__ void hello_from_gpu()
{
    printf( "\"Hello, world!\", says the GPU.\n" );
}

void hello_from_cpu()
{
    printf( "\"Hello, world!\", says the CPU.\n" );
}

// host code entrance
int main( int argc, char **argv )
{
    hello_from_cpu();
    hello_from_gpu <<< 2, 4>>>();
    cudaDeviceReset();
    return 0;
}
```
在linux终端下使用以下命令进行编译hello.cu，然后执行程序得到

```
$ nvcc hello.cu -o hello
$./hello
"Hello, world!", says the CPU.
"Hello, world!", says the GPU.
"Hello, world!", says the GPU.
"Hello, world!", says the GPU.
"Hello, world!", says the GPU.
"Hello, world!", says the GPU.
"Hello, world!", says the GPU.
"Hello, world!", says the GPU.
"Hello, world!", says the GPU.
```
在上面的代码中，`cudaDeviceReset`表示重置当前线程所关联过的当前设备的所有资源；修饰符__global__告诉编译器这是一个内核函数，它将从CPU中调用，然后在GPU上执行，在CPU上通过下面的代码启动内核函数
```
hello_from_gpu <<< 2, 4>>>();
```
> 三重尖号意味着从主线程到端代码的调用。2 和4分别表示有2个块区域和4个线程，后续会作相关介绍。


## CUDA 编程模型

关于 CUDA 编程模型等更多相关内容，可以参考我总结的[博客](http://houmin.cc/posts/5004f8e5)

## 参考资料

- https://github.com/puttsk/cuda-tutorial
