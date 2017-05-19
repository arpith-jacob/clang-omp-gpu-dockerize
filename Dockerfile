FROM nvidia/cuda:8.0-devel-ubuntu16.04
MAINTAINER Arpith Jacob <arpith@gmail.com>

RUN apt-get update && apt-get install -y --no-install-recommends \
            ca-certificates \
            python \
            build-essential \
            git \
            cmake \
            ninja-build

ADD . /opt/ibm

RUN mkdir -p /opt/ibm/sources && \
    mkdir -p /opt/ibm/build-base && \
    mkdir -p /opt/ibm/clang-base && \
    cd /opt/ibm/sources && \
    git clone https://github.com/clang-ykt/llvm && \
    cd /opt/ibm/sources/llvm/tools && git clone https://github.com/clang-ykt/clang && \
    cd /opt/ibm/sources/llvm/projects && git clone https://github.com/clang-ykt/openmp && \
    cd /opt/ibm/build-base && \
    cmake  -DCMAKE_BUILD_TYPE=RELEASE \
    -DCMAKE_INSTALL_PREFIX=/opt/ibm/clang-base \
    -DLLVM_ENABLE_BACKTRACES=ON \
    -DLLVM_ENABLE_WERROR=OFF \
    -DBUILD_SHARED_LIBS=OFF \
    -DLLVM_ENABLE_RTTI=ON \
    -G \
    Ninja \
    ../sources/llvm && \
    ninja

RUN mkdir -p /opt/ibm/build-ykt && \
    mkdir -p /opt/ibm/clang-ykt && \
    cd /opt/ibm/build-ykt && \
    cmake  -DCMAKE_BUILD_TYPE=RELEASE \
    -DCMAKE_INSTALL_PREFIX=/opt/ibm/clang-ykt \
    -DLLVM_ENABLE_BACKTRACES=ON \
    -DLLVM_ENABLE_WERROR=OFF \
    -DBUILD_SHARED_LIBS=OFF \
    -DLLVM_ENABLE_RTTI=ON \
    -DCMAKE_C_COMPILER=/opt/ibm/build-base/bin/clang \
    -DCMAKE_CXX_COMPILER=/opt/ibm/build-base/bin/clang++ \
    -DLIBOMPTARGET_NVPTX_ENABLE_BCLIB=true \
    -DLIBOMPTARGET_NVPTX_CUDA_COMPILER=/opt/ibm/build-base/bin/clang \
    -DLIBOMPTARGET_NVPTX_BC_LINKER=/opt/ibm/build-base/bin/llvm-link \
    -G \
    Ninja \
    ../sources/llvm && \
    ninja

# Compiler is built in /opt/ibm/clang-ykt/bin/
