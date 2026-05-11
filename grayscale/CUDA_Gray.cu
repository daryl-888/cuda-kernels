#include <cstdio>
#include <cmath>
#define CHANNELS 3
__global__
void colortoGrayscaleConvertion(unsigned char * Pout, 
        unsigned char * Pin, int width, int height) {
    int col = blockIdx.x*blockDim.x + threadIdx.x;
    int row = blockIdx.y*blockDim.y + threadIdx.y;
    if(col < width && row < height){
        //Get 1D offset for the grayscale image
        int grayOffset = row*width + col;
        //One can think of the RGB image having CHANNEL
        //times more columns than the gray scale image
        int rgbOffset = grayOffset*CHANNELS;
        unsigned char r = Pin[rgbOffset    ]; //Red value
        unsigned char g = Pin[rgbOffset + 1]; //Green value
        unsigned char b = Pin[rgbOffset + 2]; //Blue value
        //Perform the rescaling and store it
        //We multiply by floating point constants
        Pout[grayOffset] = (unsigned char)(0.21f*r + 0.71f*g + 0.07f*b);
    }
}

void ImgMan(unsigned char * In_h, unsigned char * Out_h,int width, int height, int size){
    unsigned char *In_d, *Out_d;

    cudaMalloc((unsigned char **)&In_d,  size);
    cudaMalloc((unsigned char **)&Out_d, size/3);

    cudaMemcpy(In_d, In_h, size, cudaMemcpyHostToDevice);
    

    dim3 dimGrid(ceil(width/16.0), ceil(height/16.0), 1);
    dim3 dimBlock(16,16, 1);
    colortoGrayscaleConvertion<<<dimGrid, dimBlock>>>(Out_d, In_d, width, height);

    cudaMemcpy(Out_h, Out_d, size/3, cudaMemcpyDeviceToHost);
    
    cudaFree(In_d);
    cudaFree(Out_d);
}

void ReadImage(unsigned char ** ImgData, int * width, int * height){
    FILE *f = fopen("C:/Users/dpapl/Practice/Grayscale test/sample_1920x1280.ppm", "rb");

    fscanf(f, "P6\n%d %d\n255\n", width, height);
    
    *ImgData = (unsigned char *)malloc((*width) * (*height) * 3);

    fread(*ImgData, 1, (*width) * (*height) * 3, f);

    fclose(f);


}

void WriteImage(unsigned char *pixOut, int width, int height){
    FILE *fptr = fopen("output.pgm", "wb");

    if(fptr == nullptr){
        printf("Error");
        return;
    }

    fprintf(fptr, "P5\n%d %d\n255\n", width, height);
    fwrite(pixOut, 1, width * height, fptr);
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
pixOut = (unsigned char *)malloc(width * height);

int size = width*height*3;
ImgMan(ImgData,pixOut ,width, height, size);
//obtain values from ImgMan & output

WriteImage(pixOut, width, height);




}