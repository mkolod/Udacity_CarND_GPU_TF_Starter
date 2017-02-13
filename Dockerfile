FROM nvidia/cuda:8.0-cudnn5-runtime-ubuntu16.04

MAINTAINER Marek Kolodziej <mkolod@gmail.com> 

# Partly borrowed from @joshuacook
# (https://github.com/udacity/CarND-Term1-Starter-Kit/blob/master/Dockerfile.gpu),
# but significantly expanded. 

# Pick up some TF dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        libcurl3-dev \
        libfreetype6-dev \
        libpng12-dev \
        libzmq3-dev \
        pkg-config \
	python \
        python3-dev \
        rsync \
        software-properties-common \
        unzip \
        libgtk2.0-0 \
        git \
	tcl-dev \
	tk-dev \	
        openjdk-8-jdk-headless \
        vim \
        nano \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ADD https://repo.continuum.io/miniconda/Miniconda3-4.2.12-Linux-x86_64.sh tmp/Miniconda3-4.2.12-Linux-x86_64.sh
RUN bash tmp/Miniconda3-4.2.12-Linux-x86_64.sh -b
ENV PATH $PATH:/root/miniconda3/bin/

COPY environment-gpu.yml  ./environment.yml
RUN conda env create -f=environment.yml --name carnd-term1 --debug -v -v

# cleanup tarballs and downloaded package files
RUN conda clean -tp -y

# Set up our notebook config.
COPY jupyter_notebook_config.py /root/.jupyter/

# Term 1 workdir
RUN mkdir /src
WORKDIR "/src"

# Make sure CUDNN is detected
ENV LD_LIBRARY_PATH /usr/local/cuda/lib64/:/usr/local/cuda/extras/CUPTI/lib64:$LD_LIBRARY_PATH
RUN export PYTHON_BIN_PATH=$(which python3)
ENV TENSORFLOW_VERSION 0.12.1
ENV CUDA_TOOLKIT_PATH /usr/local/cuda
ENV CUDA_HOME /usr/local/cuda
ENV TF_NEED_CUDA 1
# Support for most Kepler, Maxwell and Pascal GPUs
ENV TF_CUDA_COMPUTE_CAPABILITIES "3.2,3.5,5.0,5.2,6.0,6.1"
ENV TF_NEED_GCP 0
ENV TF_NEED_HDFS 0
ENV TF_NEED_OPENCL 0
RUN ln -s /usr/local/cuda/lib64/libcudnn.so.5 /usr/local/cuda/lib64/libcudnn.so

# Configure Bazel
ENV BAZELRC /root/.bazelrc
RUN echo "startup --batch" >> $BAZELRC && \
    echo "build --spawn_strategy=standalone --genrule_strategy=standalone" >> $BAZELRC

# Build Bazel
RUN BAZEL_VERSION=0.4.2 && \
    mkdir /bazel && cd /bazel && \
    curl -fSsL -O https://github.com/bazelbuild/bazel/releases/download/$BAZEL_VERSION/bazel-$BAZEL_VERSION-installer-linux-x86_64.sh && \
    curl -fSsL -o /bazel/LICENSE.txt https://raw.githubusercontent.com/bazelbuild/bazel/master/LICENSE.txt && \
    bash ./bazel-$BAZEL_VERSION-installer-linux-x86_64.sh && \
    rm -rf /bazel

# Build TensorFlow (can take about 10 minutes)
RUN cd / && git clone https://github.com/tensorflow/tensorflow.git && cd tensorflow && \
    git checkout r0.12 && tensorflow/tools/ci_build/builds/configured GPU && \
    bazel build -c opt --config=cuda tensorflow/tools/pip_package:build_pip_package && \
    bazel-bin/tensorflow/tools/pip_package/build_pip_package /tmp/pip && \
    pip --no-cache-dir install --upgrade /tmp/pip/tensorflow-*.whl && \
    rm -rf /tmp/pip && \
    rm -rf /root/.cache

# TensorBoard
EXPOSE 6006
# Jupyter
EXPOSE 8888
# Flask Server
EXPOSE 4567
