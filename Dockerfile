FROM nvidia/cuda-ppc64le:8.0-cudnn6-devel-ubuntu16.04
MAINTAINER Arpith Jacob <arpith@gmail.com>

RUN apt-get -y update && \
    apt-get -y install curl iputils-ping unzip && \
    apt-get clean && \
    curl -H 'Cache-Control: no-cache' \
        https://raw.githubusercontent.com/nimbix/image-common/master/install-nimbix.sh \
        | bash

# Expose port 22 for local JARVICE emulation in docker
EXPOSE 22

RUN apt-get update && apt-get install -y --no-install-recommends \
            ca-certificates \
            libelf1 libelf-dev \
            libffi6 libffi-dev \
            python \
            build-essential \
            git \
            cmake \
            ninja-build && \
            apt-get clean

RUN mkdir -p /opt/ibm/sources && \
    mkdir -p /opt/ibm/build && \
    mkdir -p /opt/ibm/clang-ykt && \
    cd /opt/ibm/sources && \
    git clone https://github.com/clang-ykt/llvm && \
    cd /opt/ibm/sources/llvm/tools && git clone https://github.com/clang-ykt/clang && \
    cd /opt/ibm/sources/llvm/projects && git clone https://github.com/clang-ykt/openmp && \
    cd /opt/ibm/build && \
    cmake  -DCMAKE_BUILD_TYPE=RELEASE \
    -DCMAKE_INSTALL_PREFIX=/opt/ibm/clang-ykt \
    -DLLVM_ENABLE_BACKTRACES=ON \
    -DLLVM_ENABLE_WERROR=OFF \
    -DBUILD_SHARED_LIBS=OFF \
    -DLLVM_ENABLE_RTTI=ON \
    -DCMAKE_C_FLAGS='-DOPENMP_NVPTX_COMPUTE_CAPABILITY=37' \
    -DCMAKE_CXX_FLAGS='-DOPENMP_NVPTX_COMPUTE_CAPABILITY=37' \
    -DLIBOMPTARGET_NVPTX_COMPUTE_CAPABILITY=37 \
    -DLIBOMPTARGET_NVPTX_ENABLE_BCLIB=true \
    -G \
    Ninja \
    ../sources/llvm && \
    ninja

ENV LD_LIBRARY_PATH=/opt/ibm/clang-ykt/lib:/usr/local/cuda/lib64/stubs:$LD_LIBRARY_PATH
ENV LIBRARY_PATH=/opt/ibm/clang-ykt/lib:/usr/local/cuda-8.0/lib64:/usr/lib/nvidia-361:$LIBRARY_PATH
ENV PATH=/opt/ibm/clang-ykt/bin:/usr/local/cuda/bin:$PATH

# Compiler is built in /opt/ibm/clang-ykt/bin/
