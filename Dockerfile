FROM ubuntu:21.04
MAINTAINER Maxime Arthaud <maxime.arthaud@nasa.gov>
ARG njobs=2
ARG build_type=Release

ENV TZ=America/Chicago

# Installs the following versions (note that it might be out of date):
# cmake 3.13.4
# gmp 6.1.2
# boost 1.67.0
# python 2.7.16
# sqlite 3.27.2
# tbb 10006
# llvm 9.0.1
# clang 9.0.1
# gcc 8.3.0

# Upgrade
RUN apt-get update
RUN apt-get upgrade -y

# Add ppa for llvm 9.0
RUN echo "deb http://apt.llvm.org/disco/ llvm-toolchain-disco-9 main" >> /etc/apt/sources.list

# Add llvm repository key
RUN apt-get install -y wget gnupg
RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add -

# Set the timezone so that apt-get(1) doesn't prompt for it.
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Refresh cache
RUN apt-get update

# Install all dependencies
RUN apt-get install -qq gcc g++ cmake libgmp-dev libboost-dev \
        libboost-filesystem-dev libboost-thread-dev libboost-test-dev python \
        libsqlite3-dev libtbb-dev libz-dev libedit-dev \
        llvm-9 llvm-9-dev llvm-9-tools clang-9

# Add ikos source code
RUN wget -P /tmp https://github.com/NASA-SW-VnV/ikos/releases/download/v3.0/ikos-3.0.tar.gz && \
    tar -C /tmp -zxf /tmp/ikos-3.0.tar.gz && \
    mkdir /tmp/ikos-3.0/build

# Build ikos
WORKDIR /tmp/ikos-3.0/build
ENV MAKEFLAGS "-j$njobs"
RUN cmake \
        -DCMAKE_INSTALL_PREFIX="/usr/local" \
        -DCMAKE_BUILD_TYPE="$build_type" \
        -DLLVM_CONFIG_EXECUTABLE="/usr/lib/llvm-9/bin/llvm-config" \
        ..
RUN make
RUN make install

# Run the tests
RUN make check

# Done
WORKDIR /
