(* ::Package:: *)

(* Wolfram Language Package *)
(* Created by the Wolfram Workbench 2/08/2018 *)

BeginPackage["NWSeqAlign`"]

TracebackKBandNW::usage = "TracebackKBandNW  "
ForwardKBandNW::usage = "ForwardKBandNW  "
ForwardKBandNWAffine::usage = "ForwardKBandNWAffine  "

NWSeqAlignAffine2::usage = "NWSeqAlignAffine2  "


(* Exported symbols added here with SymbolName::usage *)

Begin["`Private`"]
(* Implementation of the package *)
(*Global variables*)
diag = {1,1};
up = {1,0};
left = {0,1};
invalid = {0,0};



(* ::Subsection::Closed:: *)
(*Compiler Load*)
Needs["CCompilerDriver`"]
$CCompiler = {"Compiler" ->
   CCompilerDriver`GenericCCompiler`GenericCCompiler,
  "CompilerInstallation" -> "C:\\mingw-w64\\mingw64\\bin",
  "CompilerName" -> "gcc.exe"};

(* ::Subsection::Closed:: *)
(*Traceback functions*)

(* TODO - gives a list of the starting at which 'subSeq' appears in 'seq' *)
SeqPos[seq_List, subSeq_List] :=
	ReplaceList[seq, {x___, Sequence @@ subSeq, ___} :> 1 + Length[{x}]];


	(* TODO - decode arrow in the tags "diag", "left", "up" or "invalid" *)
	DecodeArrow[curArrow_, indexH_, indexV_, seqA_, seqB_, lastArrowTag_] :=
		If[indexH == 0 && indexV == 0, invalid,
		If[indexH == 0, up,
		If[indexV == 0, left,
		If[seqA[[indexH]]==seqB[[indexV]] && lastArrowTag==diag, diag,
		Switch[curArrow,
			{1,1}, diag,
			{1,0}, up,
			{0,1}, left,
			{0,0}, If[seqA[[indexH]]==seqB[[indexV]], diag,lastArrowTag]

		]]]]]


	(* TODO - gives a list with the next align indexes *)
	GetAlignIndexes[typeArrow_, indexH_, indexV_] :=
		Switch[typeArrow,
			diag,	{indexH-1,indexV-1},
			up,	{indexH,indexV-1},
			left,	{indexH-1,indexV},
			invalid, {0,0}
		]


	(* TODO - gives a list with the next align symbols *)
	GetAlignSymbols[typeArrow_, indexH_, indexV_, seqA_, seqB_] :=
		Switch[typeArrow,
			diag,	{seqA[[indexH]], seqB[[indexV]]},
			up,	{95 (*"_"*), seqB[[indexV]]},
			left,	{seqA[[indexH]], 95 (*"_"*)},
			invalid, {95,95} (*{"_","_"}*)
		]


	(* TODO - add the align symbols to align sequences*)
	AddAlignSymbols[symbolA_, symbolB_] :=
		Block[{},
			Sow[symbolA, tagSeqA];
			Sow[symbolB, tagSeqB];
		]


	(* TODO - gives a list with the next align symbols *)
	GetSimilarityAndDistance[AlignSymbols_, Similarity_, Distance_] :=
		If[AlignSymbols[[1]] == AlignSymbols[[2]],
			If[AlignSymbols[[1]] != 95, (*"_", *)
				{Similarity + 1, Distance},
				{Similarity, Distance}
			],{Similarity - 1, Distance + 1}
		]


	(* TODO - gives a list of the relative next arrow position: \'
		Position of the Row [[1]] and Position of the Arrow in the Row [[2]] *)
	DecodePosNextArrow[typeArrow_, curDir_] :=
		Switch[typeArrow,
			diag, {2,0},
			up, If[curDir == 0, {1,-1}, {1,0}],
			left,	If[curDir == 0, {1,0}, {1,1}],
			invalid, {0,0}
		]


	(* TODO - gives a list with the code of the next Arrow *)
	GetNextArrow[arrowMatrix_, indexArrow_, indexRow_] :=
		Partition[arrowMatrix[[ -indexRow ]], 2] [[ indexArrow ]]


	(* TODO - gives the next direction sweep *)
	GetNextDirectionSweep[curDirSweep_, posNextArrow_] :=
		Mod[curDirSweep + posNextArrow[[1]], 2];


	(* TODO - Traceback *)
	(*TracebackKBandNW[arrowMatrix_, flagD_, seqA_, seqB_] :=*)
	TracebackKBandNW = Compile[
		{{arrowMatrix,_Integer,2}, {flagD,_Integer}, {seqA,_Integer,1}, {seqB,_Integer,1}},
		Block[{h = Length@seqA, v = Length@seqB, newSeqA={}, newSeqB={}, similarity=0, distance=0,
			indexRow, indexArrow, arrow, arrowTag, symbolA, symbolB, posNextArrow, flagDSweep },

			arrowTag = diag;
			flagDSweep = flagD;
			{indexRow, indexArrow} = {1, Ceiling[SeqPos[arrowMatrix[[-1]], {1}][[1]]/2]};
			Reap[While[h != 0 || v != 0,
				arrow = GetNextArrow[arrowMatrix, indexArrow, indexRow];
				arrowTag = DecodeArrow[arrow, h, v, seqA, seqB, arrowTag];
				{symbolA, symbolB} = GetAlignSymbols[arrowTag, h, v, seqA, seqB];
				AddAlignSymbols[symbolA, symbolB];
				{h, v} = GetAlignIndexes[arrowTag, h, v];
				posNextArrow = DecodePosNextArrow[arrowTag, flagDSweep];
				{indexRow, indexArrow} = {indexRow + posNextArrow[[1]], indexArrow + posNextArrow[[2]]};
				flagDSweep = GetNextDirectionSweep[flagDSweep, posNextArrow];
				{similarity, distance} = GetSimilarityAndDistance[{symbolA, symbolB}, similarity, distance];
			];{similarity, distance}]
		]
	, Parallelization->True, CompilationTarget->"C"]


(* ::Subsection:: *)
(*Forward Functions*)


(* ::Subsubsection::Closed:: *)
(*General*)


(* TODO -  load sequence symbols in the input buffers *)
(*LoadInputBuffer[symbolSeqA_, symbolSeqB_, inBufferA_, inBufferB_, flagD_] :=*)
LoadInputBuffer = Compile[
	{{symbolSeqA,_Real}, {symbolSeqB,_Real}, {inBufferA,_Real,1}, {inBufferB,_Real,1}, {flagD,_Real}},

	Block[{bufferA, bufferB},
		If[flagD == 0.,
		 	{bufferA, bufferB} = {Join[{symbolSeqA}, inBufferA[[1;;-2]] ], inBufferB},
			{bufferA, bufferB} = {inBufferA, Join[inBufferB[[2;;-1]], {symbolSeqB}]}
		]
	]
] (*, Parallelization->True, CompilationTarget->"C"]*)


(* TODO -  get the Score Matrix values of complete row wavefront*)
(*ScoreMatrix[symbolA_, symbolB_, match_, mismatch_, noPEs_] :=*)
ScoreMatrix =  Compile[
	{{symbolA,_Integer,1}, {symbolB,_Integer,1}, {match,_Integer}, {mismatch,_Integer}, {gap,_Integer}, {noPEs,_Integer}},
	Block[{lutPEs, validPEs},
		validPEs = Table[
			If[symbolA[[i]] != 0 && symbolB[[i]] != 0, 1, 0]
			,{i,noPEs}];
		lutPEs = Table[
			If[symbolA[[i]] == symbolB[[i]], match, mismatch]  + gap
			, {i,noPEs}];
		{validPEs, lutPEs}
	]
] (*, Parallelization->True, CompilationTarget->"C"]*)



(* ::Subsubsection:: *)
(*Linear Gap*)


(* TODO -  Solve the NW algorithm using in-built functions *)
(*NWSeqAlign[h_, valid_, lut_, gap_, flagD_] :=*)

NWSeqAlign = Compile[
	{{h,_Integer, 2}, {valid,_Integer,1}, {lut,_Integer,1}, {gap,_Integer}, {flagD,_Integer}},
	Block[{n, funDiag, funUp, funLeft, funEdge, invalidRow,
		selMayor, mayorUL, mayorDUL, arrowsRow, casos},

		(*Inicializacion de variables*)
		n = Length@lut;
		funDiag = funUp = funLeft = funEdge = Table[0., {i, n}];
		invalidRow = Total[Abs[N@valid]];
		selMayor=Table[0,n,2];
		mayorUL = mayorDUL = Table[0., {i, n}];
		arrowsRow = Table[{0,0}, {i, n}];

		(*casos a elegir*)
		If[flagD == 0,
			funUp = Table[ h[[i, 1]] , {i, 2, n + 1}];
			funLeft = Table[ h[[i - 1, 1]] , {i, 2, n + 1}];
				,
   			funUp = Table[ h[[i + 1, 1]] , {i, 2, n + 1}];
   			funLeft = Table[ h[[i, 1]] , {i, 2, n + 1}];
   		];
   		funDiag	= h[[2;; n + 1, 2]] + lut;
   		funEdge = h[[2;; n + 1, 1]] ;

   		(*Seleccionar valor mayor*)
   		mayorUL = Max /@ ({funUp, funLeft}\[Transpose]);
   		mayorDUL = Max /@ ({funUp, funLeft, funDiag}\[Transpose]);
   		mayorDUL = Table[
   			If[valid[[i]] == 0, funEdge[[i]], mayorDUL[[i]] ] - gap
   		,{i, n}];
   		If[invalidRow == 0, mayorDUL = Table[0, n]];

		(*Seleccionar flecha asociada al mayor*)
   		selMayor[[1;;-1,2]] = Table[If[funUp[[i]] < funLeft[[i]],1,0], {i, n}];
   		selMayor[[1;;-1,1]] = Table[If[funDiag[[i]] < mayorUL[[i]],1,0], {i, n}];
   		(*
		arrowsRow = Table[
   			Switch[selMayor[[i]],
				{0,0}, {1,1},
				{1,0}, {0,1},
				{0,1}, {1,1},
				{1,1}, {1,0}
			]
   		,{i, n}];*)
   		arrowsRow = Table[{
   			If[selMayor[[i]]=={1,0},0,1],
   			If[selMayor[[i]]=={1,1},0,1]
   			},{i, n}];

   		arrowsRow = Table[
			If[valid[[i]] == 0, {0,0}, arrowsRow[[i]] ]
		,{i, n}];

		(*
		arrowsRow = Part[{{1,1}, {0,1}, {1,0}},Flatten@(First /@ MapThread[Position, {{funDiag, funUp, funLeft}\[Transpose], mayorDUL}])];
   		arrowsRow = (First /@ MapThread[Position, {{funDiag, funUp, funLeft}\[Transpose], mayorDUL}]) /. {{1} -> {1,1}, {2} -> {0,1}, {3} -> {1,0}};
   		*)

		{arrowsRow, mayorDUL}

	]
, Parallelization->True, CompilationTarget->"C"]



(* TODO - Forward *)
(*ForwardKBandNW[noPEs_, seqA_, seqB_, match_, mismatch_, gap_, offsetUser_] :=*)
ForwardKBandNW = Compile[
	{{noPEs,_Integer}, {seqA,_Integer,1}, {seqB,_Integer,1},
		{match,_Integer}, {mismatch,_Integer}, {gap,_Integer}, {offsetUser,_Integer}},
	Block[{lenA = Length@seqA, lenB = Length@seqB, enhSeqA, enhSeqB, lenSeqMax, offset,
		validPEs, lutByPE, cycle, arrowsRow, matrixH, outputH, noCYCLE=1, noValidRows, inBufferA,
		inBufferB, flagD },

		lenSeqMax = Max[lenA, lenB];
		noValidRows = lenA + lenB - 1;
		offset = Abs[Floor[(lenB - lenA)/2]] + offsetUser;
(*		{enhSeqA, enhSeqB} = If[lenB > lenA,
  			{Join[Table[0, offset], seqA, Table[0, (lenB-lenA) - offset]], seqB},
  			{seqA, Join[Table[0, offset], seqB, Table[0, (lenA-lenB) - offset]]}
  		];
*)
		enhSeqA = If[lenB > lenA,
  			Join[Table[0, {i,offset}], seqA, Table[0, {i,(lenB-lenA) - offset}]], seqA ];
		enhSeqB = If[lenB > lenA,
  			seqB, Join[Table[0, {i,offset}], seqB, Table[0, {i,(lenA-lenB) - offset}]] ];

  		enhSeqA = Join[enhSeqA,Table[0,{i,noPEs+offset}]];
  		enhSeqB = Join[enhSeqB,Table[0,{i,noPEs+offset}]];

  		inBufferA = inBufferB = validPEs = lutByPE = Table[0., noPEs];
  		matrixH = Table[-10^15{1, 1}, {i,noPEs + 2}];

  		flagD = 0;

  		Reap[For[cycle=1, cycle <= (noPEs + offset + noValidRows), cycle++,
  			{inBufferA, inBufferB} = LoadInputBuffer[enhSeqA[[noCYCLE]], enhSeqB[[noCYCLE]], inBufferA, inBufferB, flagD];
  			{validPEs, lutByPE} = ScoreMatrix[inBufferA, inBufferB, match, mismatch, gap, noPEs];

  			{arrowsRow, outputH} = NWSeqAlign[matrixH, validPEs, lutByPE, gap, flagD];
  				Sow[arrowsRow//Flatten, tagArrow];
  				Sow[outputH, tagMatrixH];

  			matrixH[[;;,2]] = matrixH[[;;,1]];
  			matrixH[[2;;-2,1]] = outputH;

  			If[flagD == 1, noCYCLE++];
  			flagD = If[flagD==1,0,1];(*Mod[flagD + 1, 2];*)
  		];flagD]
	]
, Parallelization->True, CompilationTarget->"C"]



(* ::Subsubsection:: *)
(*Affine Gap*)

NWSeqAlignAffine3[h_, g_, arrowGD_, iGEdge_, valid_, lut_, gapO_, gapE_, flagD_] :=
	Block[{n,
		HDiag, GDiag, HUp, GUp, HLeft, GLeft, HEdge, GEdge, oGEdge,
		validRow, selMayorH, selMayorG, selMayorHGUL, selMayorHGD,
		mayorHUL, mayorGUL, mayorHGUL, mayorHGDUL, mayorT, arrowsRow, arrowsG, arrowHGequal},

		(*Inicializacion de variables*)
		n = Length@lut;
		HDiag = HUp = HLeft = HEdge = Table[0, {i, n}];
		GDiag = GUp = GLeft = GEdge = Table[0, {i, n}];
		validRow = Total[Abs[N@valid]];
		selMayorH = selMayorG = selMayorHGUL = selMayorHGD = Table[0,n,2];
		mayorHUL = mayorGUL = mayorHGUL = mayorHGDUL = mayorT = Table[0, {i, n}];
		arrowsRow = Table[{0,0}, {i, n}];
		arrowHGequal = Table[0, n];

		(*casos a elegir - NO TOCAR - esta bien*)
		If[flagD == 0,
			HUp = Table[ h[[i, 1]], {i, 2, n + 1}];
			HLeft = Table[ h[[i - 1, 1]], {i, 2, n + 1}];
			GUp = Table[ g[[i, 1]], {i, 2, n + 1}];
			GLeft = Table[ g[[i - 1, 1]], {i, 2, n + 1}];
				,
   			HUp = Table[ h[[i + 1, 1]], {i, 2, n + 1}];
   			HLeft = Table[ h[[i, 1]], {i, 2, n + 1}];
   			GUp = Table[ g[[i + 1, 1]], {i, 2, n + 1}];
   			GLeft = Table[ g[[i, 1]], {i, 2, n + 1}];
   		];
   		HDiag = h[[2;; n + 1, 2]];
   		GDiag = g[[2;; n + 1, 2]];
   		HEdge = h[[2;; n + 1, 1]];

   		(*GEdge = g[[2;; n + 1, 1]];*)
   		(*GEdge = iGEdge;*)

   		(*Seleccionar valor mayor*)
   		mayorHUL = Max /@ ({HUp, HLeft}\[Transpose]);
   		mayorGUL = Max /@ ({GUp, GLeft}\[Transpose]);
   		mayorHGUL = Max /@ ({mayorHUL-gapO, mayorGUL-gapE}\[Transpose]);
   		mayorHGDUL = Max /@ ({mayorHGUL, HDiag+lut}\[Transpose]);

   		(*Tal vez no sea necesario*)
   		GEdge = mayorHGUL;
   		mayorT = Table[
   			If[valid[[i]] == 0, GEdge[[i]], mayorHGDUL[[i]] ]
   		,{i, n}];
   		(*mayorT = mayorHGDUL;*)

   		oGEdge = mayorHGUL; (*HEdge*)
   		(*If[validRow == 0, mayorT = Table[0, n]];*)



		(*Seleccionar flecha asociada al mayor*)
   		selMayorH = Table[If[HUp[[i]] < HLeft[[i]],1,0], {i, n}];
   		selMayorG = Table[If[GUp[[i]] < GLeft[[i]],1,0], {i, n}];
   		selMayorHGUL = Table[If[mayorHUL[[i]]-gapO < mayorGUL[[i]]-gapE,1,0], {i, n}];
   		selMayorHGD = Table[If[HDiag[[i]] + lut[[i]] < mayorHGUL[[i]],1,0], {i, n}];
   		arrowHGequal = Table[If[HDiag[[i]] + lut[[i]] == mayorHGUL[[i]],1,0], {i, n}];


   		arrowsG = Table[
   			If[selMayorHGUL[[i]] == 0,
   				If[selMayorH[[i]] == 0, {0,1}, {1,0}],
   				If[selMayorG[[i]] == 0, {0,1}, {1,0}]
   			]
		,{i, n}];


		arrowsRow = Table[
   			If[selMayorHGD[[i]] == 0,
   				{1,1},
   				arrowsG[[i]]
   				(*If[ (arrowHGequal[[i]] == 1) (*&& lut[[i]]==1 *), {0,0}, arrowsG[[i]] ] *)
   			]
   		,{i, n}];
   		arrowsRow = Table[
			If[ valid[[i]] == 0, {0,0}, arrowsRow[[i]] ]
		,{i, n}];

		{arrowsRow, mayorT, mayorHGUL, arrowsG, oGEdge, arrowHGequal}
	]


NWSeqAlignAffine2[h_, g_, arrowGD_, iGEdge_, valid_, lut_, gapO_, gapE_, flagD_] :=
	Block[{n,
		HDiag, GDiag, HUp, GUp, HLeft, GLeft, HEdge, GEdge, oGEdge,
		validRow, selMayorH, selMayorG, selMayorHGUL, selMayorHGD,
		mayorHUL, mayorGUL, mayorHGUL, mayorHGDUL, mayorT, arrowsRow, arrowsG, arrowHGequal},

		(*Inicializacion de variables*)
		n = Length@lut;
		HDiag = HUp = HLeft = HEdge = Table[0, {i, n}];
		GDiag = GUp = GLeft = GEdge = Table[0, {i, n}];
		validRow = Total[Abs[N@valid]];
		selMayorH = selMayorG = selMayorHGUL = selMayorHGD = Table[0,n,2];
		mayorHUL = mayorGUL = mayorHGUL = mayorHGDUL = mayorT = Table[0, {i, n}];
		arrowsRow = Table[{0,0}, {i, n}];
		arrowHGequal = Table[0, n];

		(*casos a elegir - NO TOCAR - esta bien*)
		If[flagD == 0,
			HUp = Table[ h[[i, 1]], {i, 2, n + 1}];
			HLeft = Table[ h[[i - 1, 1]], {i, 2, n + 1}];
			GUp = Table[ g[[i, 1]], {i, 2, n + 1}];
			GLeft = Table[ g[[i - 1, 1]], {i, 2, n + 1}];
				,
   			HUp = Table[ h[[i + 1, 1]], {i, 2, n + 1}];
   			HLeft = Table[ h[[i, 1]], {i, 2, n + 1}];
   			GUp = Table[ g[[i + 1, 1]], {i, 2, n + 1}];
   			GLeft = Table[ g[[i, 1]], {i, 2, n + 1}];
   		];
   		HDiag = h[[2;; n + 1, 2]];
   		GDiag = g[[2;; n + 1, 2]];
   		HEdge = h[[2;; n + 1, 1]];

   		(*GEdge = g[[2;; n + 1, 1]];*)
   		(*GEdge = iGEdge;*)

   		(*Seleccionar valor mayor*)
   		mayorHUL = Max /@ ({HUp, HLeft}\[Transpose]);
   		mayorGUL = Max /@ ({GUp, GLeft}\[Transpose]);
   		mayorHGUL = Max /@ ({mayorHUL-gapO, mayorGUL-gapE}\[Transpose]);
   			GEdge = mayorHGUL;

   		mayorHGDUL = Max /@ ({GDiag, HDiag}\[Transpose]);
   		mayorT = Table[
   			If[valid[[i]] == 0, GEdge[[i]], mayorHGDUL[[i]] + lut[[i]] ]
   		,{i, n}];


   		oGEdge = mayorHGUL; (*HEdge*)
   		(*If[validRow == 0, mayorT = Table[0, n]];*)



		(*Seleccionar flecha asociada al mayor*)
   		selMayorH = Table[If[HUp[[i]] < HLeft[[i]],1,0], {i, n}];
   		selMayorG = Table[If[GUp[[i]] < GLeft[[i]],1,0], {i, n}];
   			(*prioridad a extension*)
   		selMayorHGUL = Table[If[mayorHUL[[i]]-gapO < mayorGUL[[i]]-gapE,1,0], {i, n}];
   		selMayorHGD = Table[If[HDiag[[i]] < GDiag[[i]],1,0], {i, n}];
   		arrowHGequal = Table[If[HDiag[[i]] == GDiag[[i]],1,0], {i, n}];

   		arrowsG = Table[
   			If[selMayorHGUL[[i]] == 0,
   				If[selMayorH[[i]] == 0, {0,1}, {1,0}],
   				If[selMayorG[[i]] == 0, {0,1}, {1,0}]
   			]
		,{i, n}];


		arrowsRow = Table[
   			If[selMayorHGD[[i]] == 0,
   				{1,1},
   				(*arrowsG[[i]]*)
   				arrowGD[[i]]
   				(*If[ HDiag[[i]] == GDiag[[i]] && lut[[i]]==1, arrowsG[[i]], arrowsG[[i]] ],*)
   				(*arrowGD[[i]],*)

   			]
   		,{i, n}];
   		arrowsRow = Table[
			If[ valid[[i]] == 0, {0,0}, arrowsRow[[i]] ]
		,{i, n}];

		{arrowsRow, mayorT, mayorHGUL, arrowsG, oGEdge, arrowHGequal}
	]


(*TODO  *)
ForwardKBandNWAffine[mode_,noPEs_, seqA_, seqB_, match_, mismatch_, gapO_, gapE_, offsetUser_] :=
	Block[{lenA = Length@seqA, lenB = Length@seqB, enhSeqA, enhSeqB, lenSeqMax, offset,
		lutByPE, validPEs, cycle, matrixH, matrixG, arrowsRow, outputH, outputG, GEdge,
		arrowsG, rowArrowGD, noCYCLE=1, noValidRows, inBufferA, inBufferB, flagD, matrixHpremux,
		anyValidDelay, arrowsRowMux, arrowHGequal, finish, finish1 },

		lenSeqMax = Max[lenA, lenB];
		noValidRows = lenA + lenB - 1;
		offset = Abs[Floor[(lenB - lenA)/2]] + offsetUser;
		{enhSeqA, enhSeqB} = If[lenB > lenA,
  			{Join[Table[0, offset], seqA, Table[0, (lenB-lenA) - offset]], seqB},
  			{seqA, Join[Table[0, offset], seqB, Table[0, (lenA-lenB) - offset]]}
  		];
  		(*le sumo 1 ciclo a la simulacion*)
  		enhSeqA = Join[enhSeqA,Table[0,noPEs+offset+1]];
  		enhSeqB = Join[enhSeqB,Table[0,noPEs+offset+1]];
  		(**)
  		inBufferA = inBufferB = lutByPE = validPEs = GEdge = matrixHpremux = outputH = Table[0, noPEs];
  		matrixH = matrixG = Table[0{1, 1}, noPEs + 2];
  		matrixH[[1]] = matrixH[[-1]] = matrixG[[1]] = matrixG[[-1]] = -10^15{1, 1};
  		arrowsG = Table[{0,0}, noPEs];
  		rowArrowGD = Table[{0,0}, noPEs];
  		arrowsRow = Table[{0,0}, noPEs];
  		arrowHGequal = Table[0, noPEs];


  		flagD = 0;

  		(*le sumo 1 ciclo a la simulacion*)
  		Reap[For[cycle=1, cycle <= (noPEs + offset + noValidRows+1), cycle++,
  			{inBufferA, inBufferB} = LoadInputBuffer[enhSeqA[[noCYCLE]], enhSeqB[[noCYCLE]], inBufferA, inBufferB, flagD];
  			{validPEs, lutByPE} = ScoreMatrix[inBufferA, inBufferB, match, mismatch, 0, noPEs];

  			(*Total[Abs[N@validPEs]]*)
  			finish = Total[validPEs] == 0;
  			arrowsRowMux = Table[ If[arrowHGequal[[i]]==1, {0,0}, arrowsRow[[i]] ], {i, noPEs}];
  			arrowsRowMux = If[finish, arrowsRow, arrowsRowMux];
  			(*arrowsRowMux = arrowsRow;*)


  			matrixH[[2;;-2,1]] = If[finish, Table[0, noPEs], outputH ];

  			{arrowsRow, outputH, outputG, arrowsG, GEdge, arrowHGequal} =
  			If[mode == 1,
  				NWSeqAlignAffine2[matrixH, matrixG, rowArrowGD[[;;,2]], GEdge, validPEs, lutByPE, gapO, gapE, flagD],
  				NWSeqAlignAffine3[matrixH, matrixG, rowArrowGD[[;;,2]], GEdge, validPEs, lutByPE, gapO, gapE, flagD]
  			];


  			matrixH[[2;;-2,2]] = If[finish, Table[0, noPEs], matrixHpremux ];
  			matrixHpremux = outputH;
  			finish1 = finish;
  			(*matrixH[[;;,2]] = matrixH[[;;,1]];*)
  			(*matrixH[[2;;-2,1]] = If[Total[Abs[N@validPEs]] == 0, Table[0, noPEs], outputH ];*)
  			(*matrixH[[2;;-2,1]] = outputH;*)

  			(*anyValidDelay = Total[Abs[N@validPEs]];*)



  			matrixG[[;;,2]] = matrixG[[;;,1]];
  			matrixG[[2;;-2,1]] = outputG;
  			rowArrowGD[[;;,2]] = rowArrowGD[[;;,1]];
  			rowArrowGD[[;;,1]] = arrowsG;

  				Sow[arrowHGequal, tagEqHG];
  				Sow[arrowsRowMux//Flatten, tagArrow];
  				Sow[outputH(*matrixH[[2;;-2,1]]*), tagMatrixH];
  				Sow[outputG, tagMatrixG];

  			If[flagD == 1, noCYCLE++];
  			flagD = Mod[flagD + 1, 2];
  		];flagD]

  	]

End[]

EndPackage[]
