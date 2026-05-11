#include <cstdio>
#include <cstdlib>
#define BLUR_SIZE 3
__global__
void blurKernel(unsigned char * out, unsigned char * in, int w, int h) {
    int col = blockIdx.x*blockDim.x + threadIdx.x;
    int row = blockIdx.y*blockDim.y + threadIdx.y;
    if(col < w && row < h){
      int rVal = 0, gVal = 0, bVal = 0;
      int pixels = 0;

      for (int blurRow = -BLUR_SIZE; blurRow <= BLUR_SIZE; ++blurRow) {
        for (int blurCol = -BLUR_SIZE; blurCol <= BLUR_SIZE; ++blurCol) {
          int curRow = row + blurRow;
          int curCol = col + blurCol;
          if (curRow >= 0 && curRow < h && curCol >= 0 && curCol < w) {
            int idx = (curRow * w + curCol) * 3;
            rVal += in[idx + 0];
            gVal += in[idx + 1];
            bVal += in[idx + 2];
            ++pixels;
        }
    }
}

  int outIdx = (row * w + col) * 3;
  out[outIdx + 0] = (unsigned char)((float)rVal / pixels);
  out[outIdx + 1] = (unsigned char)((float)gVal / pixels);
  out[outIdx + 2] = (unsigned char)((float)bVal / pixels);

    }
}



void ImgMan(unsigned char * In_h, unsigned char * Out_h,int width, int height, int size){
    unsigned char *In_d, *Out_d;

    cudaError_t err = cudaMalloc((unsigned char **)&In_d,  size);
    cudaError_t err2 = cudaMalloc((unsigned char **)&Out_d, size);

    if (err != cudaSuccess) 
    { printf("%s in %s at line %d \n", cudaGetErrorString(err), __FILE__, __LINE__); exit(EXIT_FAILURE);}

     if (err2 != cudaSuccess) 
    { printf("%s in %s at line %d \n", cudaGetErrorString(err2), __FILE__, __LINE__); exit(EXIT_FAILURE);}


    cudaError_t err3 = cudaMemcpy(In_d, In_h, size, cudaMemcpyHostToDevice);
     if (err3 != cudaSuccess) 
    { printf("%s in %s at line %d \n", cudaGetErrorString(err3), __FILE__, __LINE__); exit(EXIT_FAILURE);}

    dim3 dimGrid((width + 15) / 16, (height + 15) / 16, 1);
    dim3 dimBlock(16,16, 1);
    blurKernel<<<dimGrid, dimBlock>>>(Out_d, In_d, width, height);
    cudaError_t errKernel = cudaGetLastError();
    if (errKernel != cudaSuccess) {
      printf("%s in %s at line %d\n", cudaGetErrorString(errKernel), __FILE__, __LINE__);
      exit(EXIT_FAILURE);
    }   

    cudaError_t err4 = cudaMemcpy(Out_h, Out_d, size, cudaMemcpyDeviceToHost);
     if (err4 != cudaSuccess) 
    { printf("%s in %s at line %d \n", cudaGetErrorString(err4), __FILE__, __LINE__); exit(EXIT_FAILURE);}

    cudaFree(In_d);
    cudaFree(Out_d);
}

void ReadImage(unsigned char ** ImgData, int * width, int * height){
    FILE *f = fopen("sample_1920x1280.ppm", "rb");

    fscanf(f, "P6\n%d %d\n255\n", width, height);
    
    *ImgData = (unsigned char *)malloc((*width) * (*height) * 3);

    fread(*ImgData, 1, (*width) * (*height) * 3, f);

    fclose(f);


}

void WriteImage(unsigned char *pixOut, int width, int height){
    FILE *fptr = fopen("output.ppm", "wb");

    if(fptr == nullptr){
        printf("Error");
        return;
    }

    fprintf(fptr, "P6\n%d %d\n255\n", width, height);
    fwrite(pixOut, 1, width * height * 3, fptr);
    fclose(fptr);

    printf("File creation successful");
    return;
}

int main(){
unsigned char *ImgData;
int width;
int height;

unsigned char *pixOut;

//call ReadImage and get values
ReadImage(&ImgData, &width, &height);
//send values to ImgMan
pixOut = (unsigned char *)malloc(width * height * 3);

int size = width*height*3;
ImgMan(ImgData,pixOut ,width, height, size);
//obtain values from ImgMan & output

WriteImage(pixOut, width, height);




}