FROM pytorch/pytorch:2.0.1-cuda11.7-cudnn8-runtime

ENV DEBIAN_FRONTEND=noninteractive

# Set the MKL_THREADING_LAYER environment variable to GNU
ENV MKL_THREADING_LAYER=GNU

RUN apt-get update && apt-get install -y git wget libgl1-mesa-glx libglib2.0-0 ffmpeg libx264-dev build-essential cmake

RUN useradd -m -u 1000 user

USER user

ENV HOME=/home/user \
	PATH=/home/user/.local/bin:$PATH \
    PYTHONPATH=$HOME/app \
	PYTHONUNBUFFERED=1 \
	GRADIO_ALLOW_FLAGGING=never \
	GRADIO_NUM_PORTS=1 \
	GRADIO_SERVER_NAME=0.0.0.0 \
	GRADIO_THEME=huggingface \
    GRADIO_SHARE=False \
	SYSTEM=spaces

# Set the working directory to the user's home directory
WORKDIR $HOME/app

RUN git clone -b dev https://github.com/allthingssecurity/dream/ $HOME/app 
    
RUN wget https://huggingface.co/camenduru/dreamtalk/resolve/main/damo/dreamtalk/checkpoints/denoising_network.pth -O $HOME/app/checkpoints/denoising_network.pth
RUN wget https://huggingface.co/camenduru/dreamtalk/resolve/main/damo/dreamtalk/checkpoints/renderer.pt -O $HOME/app/checkpoints/renderer.pt
    
# Install dependencies
RUN pip install --no-cache-dir urllib3==1.26.6 transformers==4.28.1 dlib yacs scipy scikit-image scikit-learn PyYAML Pillow numpy opencv-python imageio ffmpeg-python av moviepy gradio==4.18.0

COPY app.py .

# Set the environment variable to specify the GPU device
ENV CUDA_DEVICE_ORDER=PCI_BUS_ID
ENV CUDA_VISIBLE_DEVICES=0

# Run your app.py script
CMD ["python", "app.py"]