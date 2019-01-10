# Build_Tensorflow_GPU
Build the Tensorflow with GPU Support from the source.

## Description

I bought a new computing machine that has RTX2070 GPU in Jan 2019.
But the RTX20x0 series don't run on current tensorflow_gpu python
package because it was builded for CUDA9 and RTX20x0 only 
supports up-to-date CUDA10. So I have to build tensorflow 
from source code.

## Goal

To create the tensorflow_gpu package that supports RTX20x0.

## How to use it

1. Install the nvidia driver to your machine. CUDA is not needed because
 we'll use nvidia-docker2

2. Install the docker-ce, the docker-compose and the nvidia-docker2

3. Download TensorRT5 package from https://developer.nvidia.com/tensorrt

4. Modify Dockerfile. Change versions of libraries and options of tensorflow build configure.

5. Run docker-compose

~~~
$ cd Build_Tensorflow_GPU 
$ docker-compose build
~~~

That download build libraries, checkout TF sources from git, and build them.
The build process on the Dockerfile will be faild. But you don't need to 
worry about it.

I know this is agry workaround to call bazel build twice. But it works and
our goal is not to write a perfect Dockerfile. Our goal is to make the 
tensorflow_gpu package that supports CUDA10 and be optimized ... and 
make a lot of money by using it (:-p.

6. Enter the docer machine and run build command manually. And package it.

~~~
$ docker-compose run nivid /bin/bash
# cd ~/tensorflow
# bazel build //tensorflow/tools/pip_package:build_pip_package --config=opt
...
INFO: Elapsed time: 1843.411s, Critical Path: 168.01s
INFO: 3364 processes: 3364 local.
INFO: Build completed successfully, 4486 total actions 
# ./bazel-bin/tensorflow/tools/pip_package/build_pip_package /tmp/
~~~

don't exit from the bash now.

7. Copy the package form the docker-container to the Host machine.

~~~
$ docker ps 
... ... ... NAMES
... ... ... tensorflow_nvidia_run_67e67b06722a
$ docker cp tensorflow_nvidia_run_67e67b06722a:/tmp/tensorflow_pkg/tensorflow-1.13.0rc0-cp36-cp36m-linux_x86_64.whl ./   
~~~

8. Terminate the docker container.

bye.
