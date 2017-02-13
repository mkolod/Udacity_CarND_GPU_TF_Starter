## Udacity_CarND_GPU_TF_Starter
GPU-enabled starter kit (Term 1)

This is a slight modification of the original [Starter Kit](https://github.com/udacity/CarND-Term1-Starter-Kit), with an emphasis on optimized NVIDIA CUDA-enabled GPU experience.

This build includes optimized GPU code for TensorFlow for Kepler, Maxwell and Pascal architectures. This is different from the existing TF GPU Docker container, which does not include Pascal binaries and results in a JIT lag at application start time. This change and some others should enable short app start times and better runtime performance, especially on Pascal GPUs.

## Building the container
1. Install the [nvidia-docker plugin](https://github.com/NVIDIA/nvidia-docker).
2. Test that nvidia-docker works: 
   ```nvidia-docker run --rm nvidia/cuda nvidia-smi```
3. Run the build:
   ```nvidia-docker build -t udacity_carnd_gpu_tf_starter .```
