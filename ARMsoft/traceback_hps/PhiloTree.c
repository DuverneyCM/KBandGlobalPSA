#include <stdio.h>
#include <stdlib.h>

#define dimPacket		512
#define NoPacketFile	200
#define NooRegs			64
#define dimPackSeq	10000000
#define dirH	1431655765 //"010101..."
#define dirV	2863311530 //"101010..."

/*
	Estructura de parametros del MAIN
	0.		Nombre del ejecutable. Probablemente será traceBack
	1.		Número de secuencias que conforman el arbol
	2.		Nombre del archivo con la distancia entre seq#1 y seq#2, ruta incluida
	...
	...
	N(N-1)/2 + 1.	Nombre del archivo con la distancia entre seq#N-1 y seq#N, ruta incluida
	N(N-1)/2 + 2.	Nombre del archivo donde se guardará el arbol
*/
int main(int argc, char *argv[]) {
	int noSeqs = atoi(argv[1]); /*Numero de secuencias*/
	int noCiclos = noSeqs-1;
	FILE *fDistSeq;	/*variable donde se van a montar los archivos con las distancias entre secuencias*/
	int dimFileDistSeq; /*Tamaño del archivo con la distancia entre secuencias específica*/
	int distSeq;
	static char bufferDistSeq[16];
	int matrizD[noSeqs+1][noSeqs+1]; //matriz D
	int matrizDaux[noSeqs+1][noSeqs+1]; //matriz D temporal
	int matrizN[noSeqs+1][noSeqs+1]; //Definir N, distancias promedio
	int r[noSeqs];
	int Dkm[noSeqs];
	int listSeqs[2*(noSeqs)]; //2*(noSeqs-1)
	int i, j, m;
	int distMin, offsetROW, offsetCOL;
	int posI, posJ, Dik, Djk;
	
	//Lista de secuencias
	for (i=0; i<2*(noSeqs); i++) listSeqs[i] = i;
	
	//Inicializar Matriz D con las distancias leidas
	for (i=0; i<noSeqs+1; i++){
		for (j=0; j<noSeqs+1; j++){
			matrizD[i][j] = 0;
			matrizN[i][j] = 0;
		}
	}
		matrizD[0][0] = 0;
		matrizD[0][1] = 3;
		matrizD[0][2] = 5;
		matrizD[0][3] = 6;
		matrizD[1][0] = 3;
		matrizD[1][1] = 0;
		matrizD[1][2] = 6;
		matrizD[1][3] = 5;
		matrizD[2][0] = 5;
		matrizD[2][1] = 6;
		matrizD[2][2] = 0;
		matrizD[2][3] = 9;
		matrizD[3][0] = 6;
		matrizD[3][1] = 5;
		matrizD[3][2] = 9;
		matrizD[3][3] = 0;
	/*
	for (i=0; i<noSeqs; i++){
		for (j=i+1; j<noSeqs; j++){
			//Obtener la distancia entre secuencias
			//Se puede mejorar esta tarea con nombres similares o todo en un solo archivo 
				fDistSeq =	fopen(argv[i],"r");
				fseek(fDistSeq, 0, SEEK_END);
				dimFileDistSeq = ftell(fDistSeq);
				fread(&bufferDistSeq,1,dimFileDistSeq,fDistSeq);
				bufferDistSeq[dimFileDistSeq] = '\0';
				distSeq = atoi(bufferDistSeq); 
				fclose(fDistSeq);
				
			matrizD[i][j] = distSeq;
			matrizD[j][i] = distSeq;
		}
	}
	*/
	for (int ciclo = 1; ciclo < noCiclos; ciclo++){
			
		//Calcular Vector R
		for (i=0; i<noSeqs; i++){
			r[i] = 0;
			for (j=0; j<noSeqs; j++){
				r[i] = r[i] + matrizD[i][j];
			}
			r[i] = r[i]/(noSeqs - 2);
			printf("r[%d] = %d \n",i,r[i]);
		}
		
		//Calcular matriz N con distancias promedio
		for (i=0; i<noSeqs; i++){
			for (j=0; j<noSeqs; j++){
				if (i == j)	matrizN[i][j] = 0;
				else		matrizN[i][j] = matrizD[i][j] - (r[i]+r[j]);
				printf("matrizN[%d][%d] = %d \n",i,j,matrizN[i][j]);
			}
		}
		
		//Encontrar el nodo con la menor distancia
		distMin = 0;
		for (i=0; i<noSeqs; i++){
			for (j=0; j<noSeqs; j++){
				if (matrizN[i][j] < distMin && i!=j){
					distMin = matrizN[i][j];
					posI = i;
					posJ = j;
				}
			}
		}
		printf("alinear %d con %d \n", listSeqs[posI],listSeqs[posJ]);
		printf("alinear %d con %d \n", posI,posJ);
		
		//calcular las distancias entre el nodo K y los demás nodos
		for (m=0; m<noSeqs; m++){
			Dkm[m] = (matrizD[posI][m] + matrizD[posJ][m] - matrizD[posI][posJ])/2;
		}
		Dik = (matrizD[posI][posJ] + r[posI] - r[posJ])/2;
		Djk = matrizD[posI][posJ] - Dik;
		
		//remover los nodos i y j de matriz D
		offsetROW = 0;
		for (i=0; i<noSeqs; i++){
			if (i == posI || i == posJ)
				offsetROW++;
			else{
				//listSeqs[i-offsetROW] = listSeqs[i];
				offsetCOL = 0;
				for (j=0; j<noSeqs; j++){
					if (j == posI || j == posJ)
						offsetCOL++;
					else{
						//matrizDaux[i+1-offsetROW][j+1-offsetCOL] = matrizD[i][j];
						matrizDaux[i-offsetROW][j-offsetCOL] = matrizD[i][j];
						//printf("matrizDaux[%d][%d] = %d \n",i+1-offsetROW,j+1-offsetCOL,matrizD[i][j]);
						printf("matrizDaux[%d][%d] = %d \n",i-offsetROW,j-offsetCOL,matrizD[i][j]);
					}
				}
			}
		}
		
		//remover los nodos i y j de listSeqs
		offsetROW = 0;
		for (i=0; i<2*noSeqs; i++){
			listSeqs[i-offsetROW] = listSeqs[i];
			if (i == posI || i == posJ)	offsetROW++;
		}
		
		//Agregar el nodo K de (primero) ultimo
		offsetROW = 0;
		for (i=0; i<noSeqs; i++){
			if (i == posI || i == posJ){
				offsetROW++;
			}
			else{
				//matrizDaux[0][i+1-offsetROW] = Dkm[i];
				//matrizDaux[i+1-offsetROW][0] = Dkm[i];
				matrizDaux[noSeqs-2][i-offsetROW] = Dkm[i];
				matrizDaux[i-offsetROW][noSeqs-2] = Dkm[i];
				
				
				//printf("matrizDaux[0][%d] = %d \n",i+1-offsetROW,Dkm[i]);
				//printf("matrizDaux[%d][0] = %d \n",i+1-offsetROW,Dkm[i]);
			}
		}
		
		//Actualizar matriz D
		noSeqs--;
		for (i=0; i<noSeqs; i++){
			for (j=0; j<noSeqs; j++){
				if (i == j) matrizD[i][j] = 0;
				else		matrizD[i][j] = matrizDaux[i][j];
				printf("matrizD[%d][%d] = %d \n",i,j,matrizD[i][j]);
			}
		}
	}
	printf("alinear %d con %d \n", listSeqs[0],listSeqs[1]);
	
	
	return 0;
}

