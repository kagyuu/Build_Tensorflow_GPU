FROM nvidia/cuda:10.0-cudnn7-devel-ubuntu18.04

WORKDIR /root/
RUN apt-get update && apt-get -y dist-upgrade
RUN apt-get -y install curl wget vim htop git swig build-essential 

# Don't ask timezone when you install expect that depends on tzdata.
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get -y install expect

# Install Bazel
# https://docs.bazel.build/versions/master/install-ubuntu.html
RUN apt-get -y install openjdk-8-jdk
RUN echo "deb [arch=amd64] http://storage.googleapis.com/bazel-apt stable jdk1.8" | tee /etc/apt/sources.list.d/bazel.list
RUN curl https://bazel.build/bazel-release.pub.gpg | apt-key add -
RUN apt-get update && apt-get -y install bazel

# Download Tensorflow
RUN git clone https://github.com/tensorflow/tensorflow
RUN cd tensorflow && git checkout r1.13

# cf. Build from Source 
# https://www.tensorflow.org/install/source#install_tensorflow_python_dependencies
RUN apt-get -y install python3 python3-dev python3-pip
RUN /usr/bin/pip3 install -U six numpy wheel mock h5py
RUN /usr/bin/pip3 install -U keras_applications==1.0.6 --no-deps
RUN /usr/bin/pip3 install -U keras_preprocessing==1.0.5 --no-deps

# TensorRT
# https://developer.nvidia.com/tensorrt
COPY nv-tensorrt-repo-ubuntu1804-cuda10.0-trt5.0.2.6-ga-20181009_1-1_amd64.deb /tmp
RUN dpkg -i /tmp/nv-tensorrt-repo-ubuntu1804-cuda10.0-trt5.0.2.6-ga-20181009_1-1_amd64.deb
RUN apt-key add /var/nv-tensorrt-repo-cuda10.0-trt5.0.2.6-ga-20181009/7fa2af80.pub
RUN apt-get update && apt-get -y install tensorrt python3-libnvinfer-dev uff-converter-tf

# Build Tensorflow
WORKDIR /root/tensorflow/
ENV TMP=/tmp
RUN expect -c " \
  set timeout 10; \
  spawn ./configure; \
  expect \"Please specify the location of python.\"; send \"/usr/bin/python3\r\"; \
  expect \"Please input the desired Python library path to use\"; send \"\r\"; \
  expect \"XLA JIT support?\";            send \"n\r\"; \
  expect \"OpenCL SYCL support?\";        send \"n\r\"; \
  expect \"ROCm support?\";               send \"n\r\"; \
  expect \"CUDA support?\";               send \"y\r\"; \
  expect \"CUDA SDK version\";            send \"\r\"; \
  expect \"where CUDA 10.0 toolkit\";     send \"\r\"; \
  expect \"the cuDNN version\";           send \"\r\"; \
  expect \"where cuDNN 7 library\";       send \"\r\"; \
  expect \"TensorRT support?\";           send \"y\r\"; \
  expect \"where TensorRT is installed\"; send \"\r\"; \
  expect \"installed NCCL version\";      send \"\r\"; \
  expect \"Cuda compute capabilities\";   send \"7.5\r\"; \
  expect \"use clang as CUDA compiler\";  send \"\r\"; \
  expect \"which gcc should be used\";    send \"\r\"; \
  expect \"MPI support?\";                send \"\r\"; \
  expect \"optimization flags\";          send \"\r\"; \
  expect \"Android builds?\";             send \"\r\"; \
  expect eof; \
"
# The following command will be failed by missing cuda librry.
# You shoud retry in login shell, "docker-compose run nvidia /bin/bash".
RUN bazel build //tensorflow/tools/pip_package:build_pip_package --config=opt; exit 0
