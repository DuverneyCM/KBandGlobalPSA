#include <stdio.h>
#include <stdlib.h>

//////DECODIFICAR LA FLECHA
//(invertir offsetPos pq están invertidas con respecto a Mathematica)
//(invertir up y left, ya que el orden de bits está invertido)
void decoArrow(int* offsetPos, int* offsetFila, int* dirHV, int ARROW) {
	if (*dirHV == 1){ //V
		if (ARROW == 0) {	//Error
			*offsetFila = 0;
			*offsetPos = 0;
		}
		else if (ARROW == 1) {	//Up
			*offsetFila = 1;
			*offsetPos = 0;
			*dirHV = -1;
		}
		else if (ARROW == 2) {	//Left
			*offsetFila = 1;
			*offsetPos = 2;
			*dirHV = -1;
		}
		else if (ARROW == 3) {	//Diagonal
			*offsetFila = 2;
			*offsetPos = 0;
		}
	}
	else if (*dirHV == -1){ //H
		if (ARROW == 0) {	//Error
			*offsetFila = 0;
			*offsetPos = 0;
		}
		if (ARROW == 1) {	//Up
			*offsetFila = 1;
			*offsetPos = -2;
			*dirHV = 1;
		}
		if (ARROW == 2) {	//Left
			*offsetFila = 1;
			*offsetPos = 0;
			*dirHV = 1;
		}
		if (ARROW == 3) {	//Diagonal
			*offsetFila = 2;
			*offsetPos = 0;
		}
	}
}

//////OTRA FUNCION

/* run this program using the console pauser or add your own getch, system("pause") or input loop */

/*
	Estructura de parametros del MAIN
	0.	Nombre del ejecutable. Probablemente será traceBack
	1.	Nombre del archivo con la seqA, ruta incluida
	2.	Nombre del archivo con la seqB, ruta incluida
	3.	Nombre del archivo con las flechas, resultado del proceso de FordWard
*/
int main(int argc, char *argv[]) {
	//Definiciones (pueden volverse constantes. NoPEs puede ser un parámetro de entrada)
	int dimPacket = 512;
	char dataIn1[dimPacket + 1];
	int NoPEs = atoi(argv[1]); //64
	int dimFila = 2*NoPEs;
	int dimUInt = sizeof(unsigned int);
	int NoRegs = dimFila/(8*dimUInt);
	
	//Definir archivos a utilizar, tanto fuentes como destinos
	FILE *fseqA;		//r
	FILE *fseqB;
	FILE *farrows;
	FILE *fnewseqA;		//w
	FILE *fnewseqB;
	FILE *fnewIndexA;
	FILE *fnewIndexB;
	//Abrir archivos a LEER con flechas, y las secuencias A y B
	fseqA =		fopen(argv[2],"r");
	fseqB =		fopen(argv[3],"r");
	farrows =	fopen(argv[4],"rb");
	//Abrir archivos a ESCRIBIR con flechas, y las secuencias A y B
	fnewseqA	= fopen(argv[5],"w+");
	fnewseqB	= fopen(argv[6],"w+");
	fnewIndexA	= fopen(argv[7],"w");
	fnewIndexB	= fopen(argv[8],"w");
	
	//////IDENTIFICAR EL ÚLTIMO REGISTRO CON DATOS DE LA MEMORIA
	fseek(farrows, 0, SEEK_END);
	int lastPosMemory = ftell(farrows);
		printf("%d\n",lastPosMemory);
		
	//////VERIFICAR QUE LA ÚLTIMA FILA CONTIENE LA DIRECCIÓN H/V DEL ÚLTIMO CICLO DEL KBAND
	//int endM = lastPosMemory; //lastPosMemory!!!! Cómo obtener este dato?
	int i = 0; //Indice de los registros empezando por el último
	int j = 0;
	//int isCero = 0;
	unsigned int fila[NoRegs];
	fseek(farrows, -NoRegs*dimUInt, SEEK_CUR);
		lastPosMemory = ftell(farrows);
		//printf("%d\n",lastPosMemory);
	
	unsigned int dirH = 1431655765; //"010101..."
	unsigned int dirV = 2863311530; //"101010..."
	int isHV = 0;
	int dirHV = 0;
	fread(&fila,dimUInt,NoRegs,farrows); //Lee la fila desde el archivo
	for (i=0;i<NoRegs;i++){
		//printf("%X\n",fila[i]);
		if (fila[i] == dirH) isHV++;
		if (fila[i] == dirV) isHV--;
		//isCero = fila[endM - i - 1];
	}
		//si dirHV sigue siendo cero, error en el archivo
	if (isHV == NoRegs) dirHV = 1;		// V
	if (isHV == -NoRegs) dirHV = -1;	// H
		printf("dirHV = %d\n",dirHV);
			
	//////BUSCAR LA POSICIÓN DE LA FLECHA EN LA PRIMERA FILA DE FLECHAS (next row). SOLO DEBE HABER UNA FLECHA
	fseek(farrows, -2*NoRegs*dimUInt, SEEK_CUR);
	fread(&fila,dimUInt,NoRegs,farrows); //Lee la fila desde el archivo
	int dupla = 0;
	int noArrows = 0;
	int posArrow = -1;
	int ARROW = 0;
	//int prueba = (dirH>>6) & 3;
	//	printf("%8X\n",prueba);
	for (i=0;i<NoRegs;i++){
		for (j=0;j<dimUInt*8/2;j++){
			dupla = (fila[i]>>2*j) & 3;
			if (dupla != 0) {
				noArrows++;
				posArrow = i*8*dimUInt + 2*j;
				ARROW = dupla; //ARROW = 0 @ ERROR, 1 @ UP, 2 @ LEFT, 3 @ DIAGONAL
			}
		}
	}
		//Si noArrows es cero, no hay flechas en la fila.
		//Si es mayor a 1, hay varias flechas en la fila, lo cual no corresponde con la última fila de flechas
		printf("ARROW = %d\n",ARROW);
		printf("noArrows = %d\n",noArrows);
		printf("posArrow = %d\n",posArrow);
	
	
	//////CARGAR SECUENCIAS DE ENTRADA Y SALIDA, MANEJADAS CON VARIABLES
	//identificar tamaño de del archivo A y B
		fseek(fseqA, 0, SEEK_END);
		int dimFileSeqA = ftell(fseqA);
		fseek(fseqB, 0, SEEK_END);
		int dimFileSeqB = ftell(fseqB);
	//Buscar la posición del primer enter, solo si es un archivo fasta >
		int SearchPacket, posFirstEnterA, posFirstEnterB = 0;
		if (dimFileSeqA > dimPacket)	SearchPacket = dimPacket;
			else SearchPacket = dimFileSeqA;
		fseek(fseqA, 0, SEEK_SET);
		fread(&dataIn1,1,SearchPacket,fseqA);
		if (dataIn1[0] == '>'){
			for (i=SearchPacket-1; i>=1; i--){
				if (dataIn1[i] == '\n') posFirstEnterA = i;
			}
		}else {
			printf("SeqA no es un archivo con formato fasta\n");
			return 100;
		}
		
		if (dimFileSeqB > dimPacket)	SearchPacket = dimPacket;
			else SearchPacket = dimFileSeqB;
		fseek(fseqA, 0, SEEK_SET);
		fread(&dataIn1,1,SearchPacket,fseqA);
		if (dataIn1[0] == '>'){
			for (i=SearchPacket-1; i>=1; i--){
				if (dataIn1[i] == '\n') posFirstEnterB = i;
			}
		}else {
			printf("SeqB no es un archivo con formato fasta\n");
			return 100;
		}
	//identificar tamaño de seqA y seqB+
		int dimSeqA, dimSeqB = 0; //dimSeqMAX = 0;
		dimSeqA = dimFileSeqA - (posFirstEnterA + 1);
			printf("dimSeqA = %d\n",dimSeqA);
		dimSeqB = dimFileSeqB - (posFirstEnterB + 1);
			printf("dimSeqB = %d\n",dimSeqB);
	/*
		fseek(fseqA, 0, SEEK_END);
		int dimSeqA = ftell(fseqA);
			printf("dimSeqA = %d\n",dimSeqA);
		fseek(fseqB, 0, SEEK_END);
		int dimSeqB = ftell(fseqB);
			printf("dimSeqB = %d\n",dimSeqB);
	*/
	//Pasar las secuencias A y B a variables
		fseek(fseqA, posFirstEnterA+1, SEEK_SET);
		fseek(fseqB, posFirstEnterB+1, SEEK_SET);
		char VseqA[dimSeqA];
		char VseqB[dimSeqB];
		fread(&VseqA,1,dimSeqA,fseqA);
		fread(&VseqB,1,dimSeqB,fseqB);
			//printf("SeqA = %s\n",VseqA);
			//printf("SeqB = %s\n",VseqB);
	
	//////DECODIFICAR LA FLECHA
	int offsetPos;
	int offsetFila;
	decoArrow(&offsetPos, &offsetFila, &dirHV, ARROW);
		printf("offsetPos = %d\n",offsetPos);
		printf("offsetFila = %d\n",offsetFila);
	
	//definir variables de destino
		char VfnewseqA[2*dimSeqA];
		char VfnewseqB[2*dimSeqB];
		int posSeqA = dimSeqA;
		int posSeqB = dimSeqB;
		int gapA = 0;
		int gapB = 0;
		
	int cnt = 0;
	while (ARROW != 0 || posSeqA != 0 || posSeqB != 0 ) {
		//guardar el nuevo valor en las nuevas secuencias alineadas
		if (ARROW==0) {
			if (posSeqA != 0) {
				posSeqA--;
				gapA = 0;
			} else gapA = 1;
			if (posSeqB != 0) {
				posSeqB--;
				gapB = 0;
			} else gapB = 1;
		}
		if (ARROW==1) {
			posSeqA--;
			gapA = 0;
			gapB = 1;
		}
		if (ARROW==2) {
			posSeqB--;
			gapB = 0;
			gapA = 1;
		}
		if (ARROW==3) {
			posSeqA--;
			gapA = 0;
			posSeqB--;
			gapB = 0;
		}
		
		if (posSeqA < 200) printf("posSeqA = %d\n",posSeqA);
		if (posSeqB < 200) printf("posSeqB = %d\n",posSeqB);
		if (posSeqA < 200 || posSeqB < 200) printf("ARROW = %d\n",ARROW);
			
		
		if (gapA == 0) VfnewseqA[cnt] = VseqA[posSeqA];
			else VfnewseqA[cnt] = '_';
		if (gapB == 0) VfnewseqB[cnt] = VseqB[posSeqB];
			else VfnewseqB[cnt] = '_';
		
		//////OBTENER PRÓXIMA FLECHA
		fseek(farrows, -(1+offsetFila)*NoRegs*dimUInt, SEEK_CUR);
		fread(&fila,dimUInt,NoRegs,farrows); //Lee la fila desde el archivo
		posArrow = posArrow + offsetPos;
			i = (posArrow) / (8*dimUInt); //cociente, #reg de la fila
			j = (posArrow) % (8*dimUInt); //residuo, #pos en el reg
		ARROW = (fila[i]>>j) & 3; //ARROW = 0 @ ERROR, 1 @ UP, 2 @ LEFT, 3 @ DIAGONAL
			//printf("ARROW = %d, posArrow = %d, dirHV = %d\n",ARROW,posArrow,dirHV);
			
		//////DECODIFICAR LA FLECHA
		if 		(posSeqA == 0)	decoArrow(&offsetPos, &offsetFila, &dirHV, 2);
		else if (posSeqB == 0)	decoArrow(&offsetPos, &offsetFila, &dirHV, 1);
		else	decoArrow(&offsetPos, &offsetFila, &dirHV, ARROW);
		cnt++;
	}
	VfnewseqA[cnt] = '\0';
	VfnewseqB[cnt] = '\0';
	
	printf("cnt = %d\n",cnt);
	//printf("newSeqA = %s\n",VfnewseqA);
	//printf("newSeqB = %s\n",VfnewseqB);
	
	//////GUARDAR LAS NUEVAS SECUENCIAS EN LOS ARCHIVOS
	for (i=0; i<cnt; i++){
		fwrite(&VfnewseqA[cnt-i-1], 1, 1, fnewseqA);	
		fwrite(&VfnewseqB[cnt-i-1], 1, 1, fnewseqB);
	}
		
	//////BUSCAR LA POSICIÓN DE LA FLECHA EN LA SIGUIENTE FILA. SOLO DEBE HABER UNA FLECHA	
	
	//fseek(farrows, 0, SEEK_SET);
	//fread(fila,sizeof(int),8,farrows);
	

	//printf("%d\n",NoRegs);
	//printf("%d\n",fila[0]);
	
	/*
	for (i=0;i<NoRegs;i++){
		fread(&dato,4,1,farrows);
		fila[i] = dato;
		//isCero = fila[endM - i - 1];
		isCero = fila[i];
		printf("%X\n",isCero);
	}
	*/

	
	//cerrar archivos 
	fclose(fseqA);
	fclose(fseqB);
	fclose(farrows);
	fclose(fnewseqA);
	fclose(fnewseqB);
	fclose(fnewIndexA);
	fclose(fnewIndexB);
	return 0;
}




