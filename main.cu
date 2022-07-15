#include <cuda_runtime.h>
#include <iostream>
// vo eri bueno🤨🤨🤨🤨🤨🤨🤨
// asi era la wea o no ? con .cu? .culia

// static int block_dim = 128; // hebras por

__global__ void mean_array(int *d_memory, double *d_resultados, int k)
{ // esta wea es cudaaaaaaaaaaaa se  pera 1 seg 😶‍🌫️😶‍🌫️😶‍🌫️😶‍🌫️😶‍🌫️😶‍🌫️😶‍🌫️😶‍🌫️
    int id_array = blockIdx.x;
    int id_thread = threadIdx.x;

    double resultado = 0;
    if (id_thread == 0)
    {
        for (int i = 0; i < k; i++)
        {
            resultado += d_memory[id_array * k + i];
        }
        resultado = resultado / k;
    }
    else if (id_thread == 1)
    {
    }
    else if (id_thread == 2)
    {
    }
    else if (id_thread == 3)
    {
    }
    switch (id_thread)
    {
    case (0):
        for (int i = 0; i < k; i++)
        {
            resultado += d_memory[id_array * k + i];
        }
        resultado = resultado / k;
        break;
    case (1):
        resultado = d_memory[id_array * k];
        for (int i = 1; i < k; i++)
        {
            if (d_memory[id_array * k + i] > resultado)
                resultado = d_memory[id_array * k + i];
        }
        break;
    case (2):
        resultado = d_memory[id_array * k];
        for (int i = 1; i < k; i++)
        {
            if (resultado > d_memory[id_array * k + i])
                resultado = d_memory[id_array * k + i];
        }
        break;
    case (3):
        for (int i = 0; i < k; i++)
        {
            float aux = d_memory[id_array * k + i] - d_resultados[id_array * 4];
            resultado += aux * aux;
        }
        resultado = resultado / k;
        resultado = sqrt(resultado);
        break;
    }
    d_resultados[id_array * 4 + id_thread] = resultado;
}

int main()
{
    int m = 10;
    int k = 10000;

    int tamano = m * k;
    int h_memory[m * k];        // array del host
    double h_resultados[m * 4]; // aquí se guardan los resultados
    int *d_memory;              // array de la gpu, se copian el array del host
    double *d_resultados;       // aquí se guardan los resultados

    for (int i = 0; i < m; i++)
    {
        for (int j = 0; j < k; j++)
        {
            h_memory[i * k + j] = j;
        }
    }

    cudaMalloc((void **)&d_memory, tamano * sizeof(int));       // robando memoria 🥷
    cudaMalloc((void **)&d_resultados, m * 4 * sizeof(double)); // robando memoria 🥷

    cudaMemcpy(d_memory, h_memory, tamano * sizeof(int), cudaMemcpyHostToDevice);

    dim3 blkDim(4, 1, 1);
    dim3 grdDim(m, 1, 1);

    mean_array<<<grdDim, blkDim>>>(d_memory, d_resultados, k);

    cudaMemcpy(h_resultados, d_resultados, m * 4 * sizeof(double), cudaMemcpyDeviceToHost);

    for (int i = 0; i < m; i++)
    {
        std::cout << "Mean: " << h_resultados[i * 4];
        std::cout << ", Max: " << h_resultados[i * 4 + 1];
        std::cout << ", Min: " << h_resultados[i * 4 + 2];
        std::cout << ", Desv: " << h_resultados[i * 4 + 3] << std::endl;
    }

    cudaFree(&d_resultados);
    cudaFree(&d_memory);

    return 0;
}