#include <iostream>
#include <math.h>
#include "./metrictime.hpp"

int main(int argc, char const *argv[]){
    if(argc != 3 ) {
        std::cout << "🤨🤨🤨" << std::endl;
        return 1; 
    }
    unsigned int m = atoi(argv[1]);
    unsigned int k = atoi(argv[2]);

    long long tamano = m * k;
    int * memory = (int *)malloc(m * k * sizeof(int));     
    double * resultados = (double *)malloc(m * 4 * sizeof(double));

    for (int i = 0; i < m; i++)
    {
        for (long long int j = 0; j < k; j++)
        {
            memory[i * k + j] = j+1;
        }
    }

    TIMERSTART(SEQUENTIAL);

    for(int i = 0; i < m; i++){
        double mean = 0;
        int max = memory[i * k];
        int min = memory[i * k];
        double desv = 0;
        for( int j = 0; j < k; j++){
            mean += memory[i * k + j];
            if(max < memory[i * k + j]) max = memory[i * k + j];
            if(min > memory[i  *k + j]) min = memory[i * k + j];
        }
        mean = mean/k;
        for(int j = 0; j < k; j++){
            float aux = memory[i * k + j] - mean;
            desv += aux * aux;
        }
        desv = desv / k;
        desv = sqrt(desv);

        resultados[i * 4 + 0] = mean;
        resultados[i * 4 + 1] = max;
        resultados[i * 4 + 2] = min;
        resultados[i * 4 + 3] = desv;
    }

    TIMERSTOP(SEQUENTIAL);
    
    for (long long i = 0; i < m; i++)
    {
        std::cout << "Mean: " << resultados[i * 4];
        std::cout << ", Max: " << resultados[i * 4 + 1];
        std::cout << ", Min: " << resultados[i * 4 + 2];
        std::cout << ", Desv: " << resultados[i * 4 + 3] << std::endl;
    }
    
    return 0;
}