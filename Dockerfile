
# change number 9 to 8 or what version you want 
# linux version as well

ARG CUDA=9.0
#https://hub.docker.com/r/nvidia/cuda
#FROM nvidia/cuda:9.0-base-ubuntu16.04
FROM nvidia/cuda:9.0-devel-ubuntu16.04
# ARCH and CUDA are specified again because the FROM directive resets ARGs
# (but their default value is retained if set previously)
ARG ARCH
ARG CUDA
#ARG CUDNN_VERSION 7.4.2.24

ENV DEBIAN_FRONTEND noninteractive
LABEL maintainer "omelisra123@gmail.com"

RUN apt-get update && \
    apt-get -y install \
    build-essential \
    apt-utils \
    python3.5 \
    python3.5-dev \
    python3-pip \
    python3-tk \
    git \
    wget \
    unzip \
    cmake \
    build-essential \
    pkg-config \
    libatlas-base-dev \
    gfortran \
    libjasper-dev \
    libgtk2.0-dev \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libjasper-dev \
    libv4l-dev

RUN pip3 install --upgrade pip

RUN apt-get update

#check tensorflow-gpu version
#check keras version

#RUN pip3 install tensorflow-gpu==1.9.0
#RUN pip3 install keras

# Needed for string substitution 
SHELL ["/bin/bash", "-c"]
# Pick up some TF dependencies

ARG CUDNN=7.4.2.24
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        cuda-command-line-tools-${CUDA/./-} \
        cuda-cublas-${CUDA/./-} \
        cuda-cufft-${CUDA/./-} \
        cuda-curand-${CUDA/./-} \
        cuda-cusolver-${CUDA/./-} \
        cuda-cusparse-${CUDA/./-} \
        curl \
        libcudnn7=7.4.2.24-1+cuda9.0\
	libcudnn7-dev=7.4.2.24-1+cuda9.0 \
        libfreetype6-dev \
        libhdf5-serial-dev \
        libzmq3-dev \
        pkg-config \
        software-properties-common \
        unzip

RUN apt-mark hold libcudnn7 

RUN export PATH=/usr/local/cuda-9.0/bin${PATH:+:$PATH}
RUN export LD_LIBRARY_PATH=/usr/local/cuda-9.0/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
RUN export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda-9.0/lib64/

ENV LD_LIBRARY_PATH /usr/local/cuda/extras/CUPTI/lib64:$LD_LIBRARY_PATH

ARG USE_PYTHON_3_NOT_2
ARG _PY_SUFFIX=${USE_PYTHON_3_NOT_2:+3}
ARG PYTHON=python${_PY_SUFFIX}
ARG PIP=pip${_PY_SUFFIX}

# See http://bugs.python.org/issue19846
ENV LANG C.UTF-8

RUN apt-get update && apt-get install -y \
    ${PYTHON} \
    ${PYTHON}-pip

RUN ${PIP} --no-cache-dir install --upgrade \
    pip \
    setuptools

# Some TF tools expect a "python" binary
RUN ln -s $(which ${PYTHON}) /usr/local/bin/python 

# Options:
#   tensorflow
#   tensorflow-gpu
#   tf-nightly
#   tf-nightly-gpu
# Set --build-arg TF_PACKAGE_VERSION=1.11.0rc0 to install a specific version.
# Installs the latest version by default.

ARG TF_PACKAGE=tensorflow-gpu
ARG TF_PACKAGE_VERSION=1.9.0
RUN ${PIP} install ${TF_PACKAGE}${TF_PACKAGE_VERSION:+==${TF_PACKAGE_VERSION}}

#COPY bashrc /etc/bash.bashrc
#RUN chmod a+rwx /etc/bash.bashrc

RUN pip3 install keras==2.1.6
RUN pip3 install --upgrade pip

#check OPENCV_VERSION
ENV OPENCV_VERSION 3.4.2

RUN wget https://bootstrap.pypa.io/get-pip.py && \
    python3 get-pip.py && \
    rm get-pip.py && \
    pip3 install numpy && \
    wget https://github.com/opencv/opencv/archive/$OPENCV_VERSION.zip -O opencv3.zip && \
    unzip -q opencv3.zip && \
    mv /opencv-$OPENCV_VERSION /opencv && \
    rm opencv3.zip && \
    wget https://github.com/opencv/opencv_contrib/archive/$OPENCV_VERSION.zip -O opencv_contrib3.zip && \
    unzip -q opencv_contrib3.zip && \
    mv /opencv_contrib-$OPENCV_VERSION /opencv_contrib && \
    rm opencv_contrib3.zip && \
    mkdir /opencv/build && cd /opencv/build && \
    cmake -D CMAKE_BUILD_TYPE=RELEASE \
      -D BUILD_PYTHON_SUPPORT=ON \
      -D CMAKE_INSTALL_PREFIX=/usr/local \
      -D OPENCV_EXTRA_MODULES_PATH=/opencv_contrib/modules \
      -D BUILD_EXAMPLES=OFF \
      -D PYTHON_DEFAULT_EXECUTABLE=/usr/bin/python3 \
      -D BUILD_opencv_python3=ON \
      -D BUILD_opencv_python2=OFF \
      -D WITH_IPP=OFF \
      -D WITH_FFMPEG=ON \
      -D WITH_V4L=ON ..

RUN cd /opencv/build && \
    make -j$(nproc) && \
    make install && \
    ldconfig

RUN pip3 install opencv-python opencv-contrib-python
RUN pip3 install scipy scikit-learn scikit-image Pillow

#dlib==19.15.0
RUN wget http://dlib.net/files/dlib-19.15.tar.bz2
RUN tar xvf dlib-19.15.tar.bz2
RUN ls
RUN cd dlib-19.15 && \
    mkdir build && \
    cd build && \
    cmake .. && \
    cmake --build . --config Release && \
    make install && \
    ldconfig

RUN cd ..
RUN pkg-config --libs --cflags dlib-1
RUN cd dlib-19.15 && \
    python3 setup.py install

RUN apt-get install -qqy x11-apps
RUN apt-get -y install gedit

RUN mkdir /opt/pycharm
RUN cd /opt/pycharm
RUN wget https://download.jetbrains.com/python/pycharm-community-2019.1.tar.gz
RUN tar -xvzf pycharm-community-2019.1.tar.gz

RUN mv /pycharm-community-2019.1 /opt/pycharm/pycharm-community-2019.1

RUN echo "alias pycharm-cm='sh /opt/pycharm/pycharm-community-2019.1/bin/pycharm.sh'" >> /root/.bashrc
RUN source /root/.bashrc

RUN wget https://github.com/pytorch/pytorch
RUN pip3 install numpy pyyaml mkl mkl-include setuptools cmake cffi typing
RUN cd pytorch
RUN pip3 install torch torchvision