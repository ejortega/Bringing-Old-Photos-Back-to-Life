FROM nvidia/cuda:13.2.1-base-ubuntu24.04

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

ENV DEBIAN_FRONTEND=noninteractive \
  UV_LINK_MODE=copy \
  UV_PROJECT_ENVIRONMENT=/app/.venv

RUN apt update && apt install -yq \
  git bzip2 wget unzip cmake build-essential \
  libgl1 libglib2.0-0 libgtk2.0-0 \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-install-project

COPY . /app

RUN git clone --depth=1 https://github.com/vacancy/Synchronized-BatchNorm-PyTorch /tmp/sbn && \
  cp -rf /tmp/sbn/sync_batchnorm Face_Enhancement/models/networks/ && \
  cp -rf /tmp/sbn/sync_batchnorm Global/detection_models/ && \
  rm -rf /tmp/sbn

RUN cd Face_Detection && \
  wget http://dlib.net/files/shape_predictor_68_face_landmarks.dat.bz2 && \
  bzip2 -d shape_predictor_68_face_landmarks.dat.bz2

RUN cd Face_Enhancement && \
  wget https://github.com/microsoft/Bringing-Old-Photos-Back-to-Life/releases/download/v1.0/face_checkpoints.zip && \
  unzip face_checkpoints.zip && \
  rm -f face_checkpoints.zip

RUN cd Global && \
  wget https://github.com/microsoft/Bringing-Old-Photos-Back-to-Life/releases/download/v1.0/global_checkpoints.zip && \
  unzip global_checkpoints.zip && \
  rm -f global_checkpoints.zip

ENTRYPOINT ["uv", "run", "python", "run.py"]
CMD ["--help"]
