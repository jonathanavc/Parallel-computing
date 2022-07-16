#include <cuda_runtime.h>
#include <iostream>
#include "./metrictime.hpp"

#define block_dim 256

__global__ void mean_array(int *d_memory, double *d_resultados, int k, int m)
{ 
    int thread_id = blockIdx.x * blockDim.x + threadIdx.x;

    if (thread_id > m * 4) return;

    int array_id = thread_id / 4;
    int op_id = thread_id % 4;

    double resultado = 0;
    if (op_id == 0){
        for (int i = 0; i < k; i++){
            resultado += d_memory[array_id * k + i];
        }
        resultado = resultado / k;
    }
    else if (op_id == 1){
        resultado = d_memory[array_id * k];
         for (int i = 1; i < k; i++){
            if (d_memory[array_id * k + i] > resultado)
                resultado = d_memory[array_id * k + i];
        }
    }
    else if (op_id == 2){
        resultado = d_memory[array_id * k];
        for (int i = 1; i < k; i++){
            if (resultado > d_memory[array_id * k + i])
                resultado = d_memory[array_id * k + i];
        }
    }
    if (op_id == 3){
        double prom = 0;
        for (int i = 0; i < k; i++){
            prom += d_memory[array_id * k + i];
        }
        prom = prom / k;
        for (int i = 0; i < k; i++){
            float aux = d_memory[array_id * k + i] - prom;
            resultado += aux * aux;
        }
        resultado = resultado / k;
        resultado = sqrt(resultado);
        
    }
    d_resultados[array_id * 4 + op_id] = resultado;
}

int main(int argc, char const *argv[])
{
    if(argc != 3 ) {
        std::cout << "🤨🤨🤨" << std::endl;
        return 1; 
    }
    unsigned int m = atoi(argv[1]);
    unsigned int k = 2 << atoi(argv[2]);

    long long tamano = m * k;
    int * h_memory = (int *) malloc(m * k * sizeof(int));                // array del host
    double * h_resultados = (double *) malloc(m * 4 * sizeof(double));   // aquí se guardan los resultados
    int *d_memory;                                                      // array de la gpu, se copian el array del host
    double *d_resultados;                                               // aquí se guardan los resultados

    for (int i = 0; i < m; i++)
    {
        for (long long int j = 0; j < k; j++)
        {
            h_memory[i * k + j] = random()%(k + 1);
        }
    }

    cudaMalloc((void **)&d_memory, tamano * sizeof(int));       // robando memoria 🥷  🤑
    cudaMalloc((void **)&d_resultados, m * 4 * sizeof(double)); // robando memoria 🥷

    TIMERSTART(CUDA);

    cudaMemcpy(d_memory, h_memory, tamano * sizeof(int), cudaMemcpyHostToDevice);

    dim3 blkDim(block_dim, 1, 1);
    dim3 grdDim((m * 4 + block_dim - 1)/block_dim, 1, 1);
    mean_array<<<grdDim, blkDim>>>(d_memory, d_resultados, k, m);
    
    cudaDeviceSynchronize();

    cudaMemcpy(h_resultados, d_resultados, m * 4 * sizeof(double), cudaMemcpyDeviceToHost);

    TIMERSTOP(CUDA);
    /*
    for (long long i = 0; i < m; i++)
    {
        std::cout << "Mean: " << h_resultados[i * 4];
        std::cout << ", Max: " << h_resultados[i * 4 + 1];
        std::cout << ", Min: " << h_resultados[i * 4 + 2];
        std::cout << ", Desv: " << h_resultados[i * 4 + 3] << std::endl;
    }
    */
    cudaFree(d_resultados);
    cudaFree(d_memory);
    free(h_memory);
    free(h_resultados);
    return 0;
}