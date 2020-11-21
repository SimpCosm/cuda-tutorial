#include <stdio.h>

__global__ void hello_from_gpu()
{
    printf( "\"Hello, world!\", says the GPU.\n" );
}

void hello_from_cpu()
{
    printf( "\"Hello, world!\", says the CPU.\n" );
}

// host code entrance
int main( int argc, char **argv )
{
    hello_from_cpu();
    hello_from_gpu <<< 2, 4>>>();
    cudaDeviceReset();
    return 0;
}

