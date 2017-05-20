FROM nvidia/cuda:8.0-devel-ubuntu16.04
MAINTAINER Arpith Jacob <arpith@gmail.com>

RUN apt-get update && apt-get install -y --no-install-recommends \
            ca-certificates \
            python \
            build-essential \
            git \
            cmake \
            ninja-build

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
    -DOPENMP_NVPTX_COMPUTE_CAPABILITY=37 \
    -DLIBOMPTARGET_NVPTX_ENABLE_BCLIB=true \
    -G \
    Ninja \
    ../sources/llvm && \
    ninja

# Compiler is built in /opt/ibm/clang-ykt/bin/
