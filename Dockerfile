FROM nvidia/cuda:8.0-cudnn5-devel

MAINTAINER A Pink Giraffe <a.giraffe@pink.com>


ENV PYTHON_VERSION      3.5.1
ENV PYTHON_PIP_VERSION  8.0.3

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN apt-get purge -y python.*

# Pick up some TF dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        libfreetype6-dev \
        libpng12-dev \
        libzmq3-dev \
        pkg-config \
        python3 \
        python3-dev \
        rsync \
        software-properties-common \
        unzip \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN curl -O https://bootstrap.pypa.io/get-pip.py && \
        python3 get-pip.py && \
        rm get-pip.py

RUN pip --no-cache-dir install \
        ipykernel \
        jupyter \
        matplotlib \
        numpy \
        scipy \
        moviepy \
        && \
        python3 -m ipykernel.kernelspec


        ENV TENSORFLOW_VERSION 0.10.0

        # --- DO NOT EDIT OR DELETE BETWEEN THE LINES --- #
        # These lines will be edited automatically by parameterized_docker_build.sh. #
        # COPY _PIP_FILE_ /
        # RUN pip --no-cache-dir install /_PIP_FILE_
        # RUN rm -f /_PIP_FILE_

        # Install TensorFlow GPU version.
        RUN pip --no-cache-dir install \
            https://storage.googleapis.com/tensorflow/linux/gpu/tensorflow-0.10.0-cp34-cp34m-linux_x86_64.whl

        # --- ~ DO NOT EDIT OR DELETE BETWEEN THE LINES --- #

        # Set up our notebook config.
        COPY jupyter_notebook_config.py /root/.jupyter/

        # Copy sample notebooks.
        COPY notebooks /notebooks
        COPY srez_demo.py /notebooks/
        COPY srez_input.py /notebooks/
        COPY srez_main.py /notebooks/
        COPY srez_model.py /notebooks/
        COPY srez_train.py /notebooks/

        # Jupyter has issues with being run directly:
        #   https://github.com/ipython/ipython/issues/7062
        # We just add a little wrapper script.
        COPY run_jupyter.sh /

        # TensorBoard
        EXPOSE 6006
        # IPython
        EXPOSE 8888

        WORKDIR "/notebooks"

        CMD ["/run_jupyter.sh"]


# Remove all tmpfile and cleanup
RUN apt-get autoremove -y; apt-get clean -y
