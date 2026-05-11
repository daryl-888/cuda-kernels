#include <cstdio>
__global__
void vecAddKernel(float* A, float* B, float* C, int n){
    int i = threadIdx.x + blockIdx.x * blockDim.x;
    if(i<n){
        C[i] = A[i] + B[i];
    }
}


void vectAdd(float* A, float* B, float* C, int n){
    float *A_d, *B_d, *C_d;
    int size = n * sizeof(float);

    cudaMalloc((void**) &A_d, size);
    cudaMalloc((void**) &B_d, size);
    cudaMalloc((void**) &C_d, size);

    cudaMemcpy(A_d, A, size, cudaMemcpyHostToDevice);
    cudaMemcpy(B_d, B, size, cudaMemcpyHostToDevice);

    vecAddKernel<<<ceil(n/256.0), 256>>>(A_d,B_d,C_d,n);

    cudaMemcpy(C, C_d, size, cudaMemcpyDeviceToHost);

    cudaFree(A_d);
    cudaFree(B_d);
    cudaFree(C_d);


}

int main(){

  int n = 16;
  float A[] = {10, 20, 30,    40, 
                 10, 20, 30,    40, 
                 10, 20, 30,  40,
                 10, 20, 30,40}; 
  float B[] = {10, 20, 30, 40, 
                 10, 20, 30, 40, 
                 10, 20, 30,40,
                 10, 20, 30,40};

  float C[16];

  vectAdd(A,B,C,n);
  
  for(int j = 0; j < n; ++j){
    printf("%.1f ", C[j]);
}
    
  return 0;
}