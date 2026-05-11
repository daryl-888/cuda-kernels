/*
  1. In this chapter, we implemented a matrix multiplication kernel that has each 
  thread produce one output matrix element. In this question, you will implement 
  different matrix-matrix multiplication kernels and compare them. 
    a. Write a kernel that has each thread produce one output matrix row. 
  Fill in the execution configuration parameters for the design. 
    b. Write a kernel that has each thread to produce one output matrix column. 
  Fill in the execution configuration parameters for the design. 
    c. Analyze the pros and cons of each kernel design above.
*/
#include <cstdio>
//a

__global__ void MatrixMulRowKernel(float* M, float *N, 
                                   float* P, int width) {
  int row = blockIdx.x*blockDim.x+threadIdx.x;
  if((row < width)){
    for(int j = 0; j < width; ++j){
      float Pvalue = 0;
      for(int k = 0; k < width; ++k){
      // result[row][j] = sum(A[row][k] * B[k][j])
        Pvalue += M[row*width+k]*N[k*width+j];
      }
      P[row*width+j] = Pvalue;
    }
    
  }
                          
}

//b

__global__ void MatrixMulColKernel(float* M, float *N, 
                                   float* P, int width) {
  int col = blockIdx.x*blockDim.x+threadIdx.x;
  if((col < width)){
    for(int i = 0; i < width; ++i){
      float Pvalue = 0;
      for(int k = 0; k < width; ++k){
      //P[i][col] = sum over k of M[i][k] * N[k][col]
      //i is the row which varies, col is fixed and k is shared
        Pvalue += M[i*width+k]*N[k*width+col];
      }
      P[i*width + col] = Pvalue;
    }
    
  }
                          
}

//C
/*
GPU's love coalesced memory access.
Meaning threads reading sequential addresses instead of jumping around.

Row kernel: M not coalesced, N not coalesced
Col kernel: M not coalesced, N coalesced 

col kernel is better since it has coalesced N access

*/

int main()
{
  int width = 4;
  float M_h[] = {10, 20, 30,    40, 
                 10, 20, 30,    40, 
                 10, 20, 30,  40,
                 10, 20, 30,40}; 
  float N_h[] = {10, 20, 30, 40, 
                 10, 20, 30, 40, 
                 10, 20, 30,40,
                 10, 20, 30,40}; 
  float P_h[16];

  float *M_d, *N_d, *P_d;
  cudaMalloc((void**)&M_d,  16*sizeof(float));
  cudaMalloc((void**)&N_d,  16*sizeof(float));
  cudaMalloc((void**)&P_d,  16*sizeof(float));

  
  cudaMemcpy(M_d, M_h, 16*sizeof(float), cudaMemcpyHostToDevice);
  cudaMemcpy(N_d, N_h, 16*sizeof(float), cudaMemcpyHostToDevice);

  dim3 dimGrid(ceil(width/256.0), 1, 1); 
  dim3 dimBlock(256, 1, 1);
  MatrixMulRowKernel<<<dimGrid, dimBlock>>>(M_d, N_d, P_d, width);
  MatrixMulColKernel<<<dimGrid, dimBlock>>>(M_d, N_d, P_d, width);

  cudaMemcpy(P_h, P_d, 16*sizeof(float), cudaMemcpyDeviceToHost);

  for(int i = 0; i < width; ++i){
    for(int j = 0; j < width; ++j){
        printf("%.1f ", P_h[i*width+j]);
    }
    printf("\n");
}


    
  cudaFree(M_d);
  cudaFree(N_d);
  cudaFree(P_d);

  return 0;
}
