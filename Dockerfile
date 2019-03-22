
# change number 9 to 8 or what version you want 
# linux version as well

FROM nvidia/cuda:9.0-base-ubuntu16.04

ENV DEBIAN_FRONTEND noninteractive
LABEL maintainer "omelisra123@gmail.com"

#check OPENCV_VERSION
ENV OPENCV_VERSION 3.4.2

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

RUN wget https://bootstrap.pypa.io/get-pip.py && \
    python3 get-pip.py && \
    rm get-pip.py && \
    pip3 install numpy \
    && \
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

RUN apt-get -y remove \
    python3-dev \
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

RUN apt-get clean && \
    rm -rf /opencv /opencv_contrib /var/lib/apt/lists/*

RUN apt-get update

#check tensorflow-gpu version
#check keras version

RUN pip3 install tensorflow-gpu
RUN pip3 install keras
RUN pip3 install opencv-python
RUN apt-get install -qqy x11-apps

COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

#how to transfer files to container
#docker cp foo.txt mycontainer:/foo.txt
#docker cp mycontainer:/foo.txt foo.txt
