#include <stdio.h>
#include <stdlib.h>

//////DECODIFICAR LA FLECHA
//(invertir offsetPos pq est�n invertidas con respecto a Mathematica)
//(invertir up y left, ya que el orden de bits est� invertido)
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
	0.	Nombre del ejecutable. Probablemente ser� traceBack
	1.	Nombre del archivo con la seqA, ruta incluida
	2.	Nombre del archivo con la seqB, ruta incluida
	3.	Nombre del archivo con las flechas, resultado del proceso de FordWard
*/
int main(int argc, char *argv[]) {
	//Definiciones (pueden volverse constantes. NoPEs puede ser un par�metro de entrada)
	int dimPacket = 512;
	int dimPackSeq = 1000*1000;
	char dataIn1[dimPacket + 1];
	int NoPEs = atoi(argv[1]); //64
	int dimFila = 2*NoPEs;
	int dimUInt = sizeof(unsigned int);
	int NoRegs = dimFila/(8*dimUInt);
	//static char VfnewseqA[2*50*1000*1000];
	//static char VfnewseqB[2*50*1000*1000];//[2*dimSeqB];
		char VfnewseqA[dimPackSeq+1];
		char VfnewseqB[dimPackSeq+1];
	int cntLocal = 0;
	
	int i = 0; //Indice de los registros empezando por el �ltimo
	int j = 0;
	
	//Definir archivos a utilizar, tanto fuentes como destinos
	FILE *fseqA;		//r
	FILE *fseqB;
	FILE *farrows;
	FILE *fnewseqA;		//w
	FILE *fnewseqB;
	FILE *fnewIndexA;
	FILE *fnewIndexB;
	char arrowFILEname[32];
	//Abrir archivos a LEER con flechas, y las secuencias A y B
	fseqA =		fopen(argv[2],"r");
	fseqB =		fopen(argv[3],"r");
	int noFile =	atoi(argv[5]);
		
	//Abrir archivos a ESCRIBIR con flechas, y las secuencias A y B
	fnewseqA	= fopen(argv[6],"w+");
	fnewseqB	= fopen(argv[7],"w+");
	fnewIndexA	= fopen(argv[8],"w");
	fnewIndexB	= fopen(argv[9],"w");
	
	/*
	sprintf(arrowFILEname, "%sp%d.bin", argv[4], noFile);
	farrows =	fopen(arrowFILEname,"rb");
		printf("File = %s\n",arrowFILEname);
	*/
	
	//////CARGAR SECUENCIAS DE ENTRADA Y SALIDA, MANEJADAS CON VARIABLES
	//identificar tama�o de del archivo A y B
		fseek(fseqA, 0, SEEK_END);
		long int dimFileSeqA = ftell(fseqA);
		fseek(fseqB, 0, SEEK_END);
		long int dimFileSeqB = ftell(fseqB);
	//Buscar la posici�n del primer enter, solo si es un archivo fasta >
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
	//identificar tama�o de seqA y seqB+
		int dimSeqA, dimSeqB = 0; //dimSeqMAX = 0;
		dimSeqA = dimFileSeqA - (posFirstEnterA + 1);
			printf("dimSeqA = %d\n",dimSeqA);
		dimSeqB = dimFileSeqB - (posFirstEnterB + 1);
			printf("dimSeqB = %d\n",dimSeqB);
	
	//char VseqA;
	//char VseqB;
	//Pasar las secuencias A y B a variables
		//char VseqA[dimSeqA];
		//char VseqB[dimSeqB];
		char VseqA[dimPackSeq+1];
		char VseqB[dimPackSeq+1];
	/*
		fseek(fseqA, posFirstEnterA+1, SEEK_SET);
		fseek(fseqB, posFirstEnterB+1, SEEK_SET);
		
		///////////////////////////////////////////
		fread(&VseqA,1,dimSeqA,fseqA);
		fread(&VseqB,1,dimSeqB,fseqB);
			//printf("SeqA = %s\n",VseqA);
			//printf("SeqB = %s\n",VseqB);
	*/
	
	int currentFILA; //lastPosMemory, firstPosMemory, 
	//////IDENTIFICAR EL �LTIMO REGISTRO CON DATOS DE LA MEMORIA
	//fseek(farrows, 0, SEEK_END);
	//lastPosMemory = ftell(farrows);
		//printf("%d\n",lastPosMemory);
	//////IDENTIFICAR EL PRIMER REGISTRO CON DATOS DE LA MEMORIA
	//fseek(farrows, 0, SEEK_SET);
	//firstPosMemory = ftell(farrows);
		//printf("%d\n",firstPosMemory);
		
	//////VERIFICAR QUE LA �LTIMA FILA CONTIENE LA DIRECCI�N H/V DEL �LTIMO CICLO DEL KBAND
	//int endM = lastPosMemory; //lastPosMemory!!!! C�mo obtener este dato?
	//int isCero = 0;
	
	sprintf(arrowFILEname, "%sp%d.bin", argv[4], noFile);
	farrows =	fopen(arrowFILEname,"rb");
		printf("File = %s\n",arrowFILEname);
		
	unsigned int fila[NoRegs];
	fseek(farrows, 0, SEEK_END);
	fseek(farrows, -1*NoRegs*dimUInt, SEEK_CUR);
		//lastPosMemory = ftell(farrows);
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
			
	//////BUSCAR LA POSICI�N DE LA FLECHA EN LA PRIMERA FILA DE FLECHAS (next row). SOLO DEBE HABER UNA FLECHA
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
		//Si es mayor a 1, hay varias flechas en la fila, lo cual no corresponde con la �ltima fila de flechas
		printf("ARROW = %d\n",ARROW);
		printf("noArrows = %d\n",noArrows);
		printf("posArrow = %d\n",posArrow);
	
	
	
	
	
	//definir variables de destino
		int posSeqA = dimSeqA;
		int posSeqB = dimSeqB;
		int gapA = 0;
		int gapB = 0;
	
		int offsetPos;
		int offsetFila;
		/*
	//////DECODIFICAR LA FLECHA
	decoArrow(&offsetPos, &offsetFila, &dirHV, ARROW);
		printf("offsetPos = %d\n",offsetPos);
		printf("offsetFila = %d\n",offsetFila);
		*/
	
	int packA, packB;
		if (dimSeqA % dimPackSeq == 0) packA = dimSeqA / dimPackSeq;
		else packA = dimSeqA / dimPackSeq + 1;
		if (dimSeqB % dimPackSeq == 0) packB = dimSeqB / dimPackSeq;
		else packB = dimSeqB / dimPackSeq + 1;
		
		//LEER SEQA Y SEQB POR PAQUETES DE TAMA�O dimPackSeq. Primer paquete (este) es de residuo
			fseek(fseqA, posFirstEnterA + 1 + dimPackSeq*(packA-1), SEEK_SET);
			fread(&VseqA,dimSeqA%dimPackSeq,1,fseqA);
			//printf("VseqA = %s\n",VseqA);
			printf("packA = %d\n",packA);
			//printf("range packA = %d %d\n",posFirstEnterA + 1 + dimPackSeq*(packA-1), (int)ftell(fseqA) );
			printf("range packA = %d %d\n", dimPackSeq*(packA-1), (int)ftell(fseqA) - (posFirstEnterA + 1) );
			packA--;
			
			fseek(fseqB, posFirstEnterB + 1 + dimPackSeq*(packB-1), SEEK_SET);
			fread(&VseqB,dimSeqB%dimPackSeq,1,fseqB);
			printf("packB = %d\n",packB);
			//printf("range packB = %d %d\n",posFirstEnterB + 1 + dimPackSeq*(packB-1), (int)ftell(fseqB) );
			printf("range packB = %d %d\n",dimPackSeq*(packB-1), (int)ftell(fseqB) - (posFirstEnterB + 1) );
			packB--;
		
	int cnt = 0;
	int flag = 0;
	while (/*ARROW != 0 ||*/ posSeqA != 0 || posSeqB != 0 ) {
		cntLocal = cnt%dimPackSeq;
				
		//////DECODIFICAR LA FLECHA
		if 		(posSeqA == 0)	decoArrow(&offsetPos, &offsetFila, &dirHV, 2);
		else if (posSeqB == 0)	decoArrow(&offsetPos, &offsetFila, &dirHV, 1);
		else	decoArrow(&offsetPos, &offsetFila, &dirHV, ARROW);
		
		//guardar el nuevo valor en las nuevas secuencias alineadas
		if (ARROW==0) {
			printf("posSeqA** = %d\n",posSeqA);
			printf("posSeqB** = %d\n",posSeqB);
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
		
				
		//////GUARDAR LAS NUEVAS SECUENCIAS EN LOS ARCHIVOS
		if (cntLocal == 0 && cnt != 0){
			printf("posSeqA**** = %d\n",posSeqA);
			printf("posSeqB**** = %d\n",posSeqB);
			for (i=0; i<dimPackSeq; i++){
				fwrite(&VfnewseqA[i], 1, 1, fnewseqA);
				fwrite(&VfnewseqB[i], 1, 1, fnewseqB);
			}
		}else if (posSeqA == 0 && posSeqB == 0){
			//////Antes o despues del siguiente bloque
			if (gapA == 0) VfnewseqA[cntLocal] = VseqA[(posSeqA)%dimPackSeq];
				else VfnewseqA[cntLocal] = '_';
			if (gapB == 0) VfnewseqB[cntLocal] = VseqB[(posSeqB)%dimPackSeq];
				else VfnewseqB[cntLocal] = '_';

			for (i=0; i<=cntLocal; i++){
				fwrite(&VfnewseqA[i], 1, 1, fnewseqA);
				fwrite(&VfnewseqB[i], 1, 1, fnewseqB);
			}
		}
		

		//LEER SEQA Y SEQB POR PAQUETES DE TAMA�O dimPackSeq
		if ((posSeqA) % dimPackSeq == 0) {
		//if ((dimSeqA - posSeqA) % dimPackSeq == 0) {
			if (packA != 0){
				fseek(fseqA, posFirstEnterA + 1 + dimPackSeq*(packA-1), SEEK_SET);
				fread(&VseqA,dimPackSeq,1,fseqA);
				printf("packA = %d\n",packA);
				//printf("range packA = %d %d\n",posFirstEnterA + 1 + dimPackSeq*(packA-1), (int)ftell(fseqA) );
				printf("range packA = %d %d\n", dimPackSeq*(packA-1), (int)ftell(fseqA) - (posFirstEnterA + 1) );
				packA--;
			}
		}
		if ((posSeqB) % dimPackSeq == 0) {
		//if ((dimSeqB - posSeqB) % dimPackSeq == 0) {
			if (packB != 0){
				fseek(fseqB, posFirstEnterB + 1 + dimPackSeq*(packB-1), SEEK_SET);
				fread(&VseqB,dimPackSeq,1,fseqB);
				printf("packB = %d\n",packB);
				//printf("range packB = %d %d\n",posFirstEnterB + 1 + dimPackSeq*(packB-1), (int)ftell(fseqB) );
				printf("range packB = %d %d\n",dimPackSeq*(packB-1), (int)ftell(fseqB) - (posFirstEnterB + 1) );
				packB--;
			}
		}
		
		//////Antes o despues del siguiente bloque
		if (gapA == 0) VfnewseqA[cntLocal] = VseqA[(posSeqA)%dimPackSeq];
			else VfnewseqA[cntLocal] = '_';
		if (gapB == 0) VfnewseqB[cntLocal] = VseqB[(posSeqB)%dimPackSeq];
			else VfnewseqB[cntLocal] = '_';
		
		
		
		
		
		
		
		//////OBTENER PR�XIMA FLECHA
		currentFILA = ftell(farrows)/(NoRegs*dimUInt); //pos next arrow
		if (currentFILA < offsetFila){ //&& noFile != 1
			printf("cnt = %d\n",cnt);
			printf("posSeqA = %d\n",posSeqA);
			printf("posSeqB = %d\n",posSeqB);
			flag = 1;
			//////GUARDAR FILA A INICIAR EN EL PR�XIMO ARCHIVO
				offsetFila = (offsetFila - currentFILA); //m�s constante
			//////CERRAR EL ARCHIVO ACTUAL Y ABRIR EL SIGUIENTE ARCHIVO
			fclose(farrows);
			noFile--;
			sprintf(arrowFILEname, "%sp%d.bin", argv[4], noFile);
			farrows =	fopen(arrowFILEname,"rb");
			printf("File = %s\n",arrowFILEname);

			//////MOVER EL CURSOR A LA POSICI�N DE LA NUEVA FLECHA
				fseek(farrows, 0, SEEK_END);
				currentFILA = ftell(farrows)/(NoRegs*dimUInt); //pos next arrow
		}
		
		
		fseek(farrows, -(1+offsetFila)*NoRegs*dimUInt, SEEK_CUR);
		fread(&fila,dimUInt,NoRegs,farrows); //Lee la fila desde el archivo
		posArrow = posArrow + offsetPos;
			i = (posArrow) / (8*dimUInt); //cociente, #reg de la fila
			j = (posArrow) % (8*dimUInt); //residuo, #pos en el reg
		ARROW = (fila[i]>>j) & 3; //ARROW = 0 @ ERROR, 1 @ UP, 2 @ LEFT, 3 @ DIAGONAL
			//printf("ARROW = %d, posArrow = %d, dirHV = %d\n",ARROW,posArrow,dirHV);
		
		
		
		/*
		if (flag == 1){
			printf("currentFILA = %d\n",currentFILA);
			printf("ARROW = %d, posArrow = %d, dirHV = %d\n",ARROW,posArrow,dirHV);
			flag = 0;
		}
		*/
		cnt++;

	}


	
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




