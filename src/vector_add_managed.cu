#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <assert.h>
#include <cuda.h>
#include <cuda_runtime.h>

#define N 10000000
#define MAX_ERR 1e-6

__global__ void vector_add(float *out, float *a, float *b, int n) {
    int tid = blockIdx.x * blockDim.x + threadIdx.x;
    
    // Handling arbitrary vector size
    if (tid < n){
        out[tid] = a[tid] + b[tid];
    }
}

int main(){
    // Allocate managed memory
    float *x, *y, *z;
    cudaMallocManaged((void**)&x, sizeof(float) * N);
    cudaMallocManaged((void**)&y, sizeof(float) * N);
    cudaMallocManaged((void**)&z, sizeof(float) * N);

    // Initialize host arrays
    for(int i = 0; i < N; i++){
        x[i] = 1.0f;
        y[i] = 2.0f;
    }

    // Executing kernel 
    int block_size = 256;
    int grid_size = ((N + block_size - 1) / block_size);
    vector_add<<<grid_size,block_size>>>(z, x, y, N);
    
    // 同步 Device 保证结果能正确访问
    cudaDeviceSynchronize();
  
    // Verification
    for(int i = 0; i < N; i++){
        assert(fabs(z[i] - x[i] - y[i]) < MAX_ERR);
    }

    printf("PASSED\n");

    // Deallocate managed memory
    cudaFree(x);
    cudaFree(y);
    cudaFree(z);

    return 0;
}
