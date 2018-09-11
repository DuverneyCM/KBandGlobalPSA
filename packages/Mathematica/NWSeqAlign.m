(* Wolfram Language Package *)

(* Created by the Wolfram Workbench 2/08/2018 *)

BeginPackage["NWSeqAlign`"]

(*
GetPosNextArrow::usage = "GetPosNextArrow  "
DecodeArrow::usage = "DecodeArrow  "
SeqPos::usage = "SeqPos  "
GetNextArrow::usage = "GetNextArrow  "
GetAlignIndexes::usage = "GetAlignIndexes  "
GetAlignSymbols::usage = "GetAlignSymbols  "
AddAlignSymbols::usage = "AddAlignSymbols  "
GetSimilarityAndDistance::usage = "GetSimilarityAndDistance  "
DecodePosNextArrow::usage = "DecodePosNextArrow  "
GetNextDirectionSweep::usage = "GetNextDirectionSweep  "
*)

TracebackKBandNW::usage = "TracebackKBandNW  "
ForwardKBandNW::usage = "ForwardKBandNW  "

NWSeqAlign::usage = "NWSeqAlign  "
compileNWSeqAlign::usage = "compileNWSeqAlign  "
(*compileForwardKBandNW::usage = "CompileForwardKBandNW  "*)

LoadInputBuffer::usage = "LoadInputBuffer  "
ScoreMatrix::usage = "ScoreMatrix  "

ForwardKBandNW::usage = "ForwardKBandNW  "

ForwardKBandNWAffine::usage = "ForwardKBandNWAffine  "

(* Exported symbols added here with SymbolName::usage *)

Begin["`Private`"]
(* Implementation of the package *)

(* TODO - gives a list of the starting at which 'subSeq' appears in 'seq' *)
SeqPos[seq_List, subSeq_List] :=
	ReplaceList[seq, {x___, Sequence @@ subSeq, ___} :> 1 + Length[{x}]];

(* TODO - decode arrow in the tags "diag", "left", "up" or "invalid" *)
DecodeArrow[curArrow_, indexH_, indexV_] :=
	If[indexH == 0, "up",
	If[indexV == 0, "left",
	Switch[curArrow,
		{1,1}, "diag",
		{1,0}, "up",
		{0,1}, "left",
		{0,0}, "invalid"
	]]]

(* TODO - gives a list with the next align indexes *)
GetAlignIndexes[typeArrow_, indexH_, indexV_] :=
	Switch[typeArrow,
		"diag",	{indexH-1,indexV-1},
		"up",	{indexH,indexV-1},
		"left",	{indexH-1,indexV},
		"invalid", {0,0}
	]

(* TODO - gives a list with the next align symbols *)
GetAlignSymbols[typeArrow_, indexH_, indexV_, seqA_, seqB_] :=
	Switch[typeArrow,
		"diag",	{seqA[[indexH]], seqB[[indexV]]},
		"up",	{"_", seqB[[indexV]]},
		"left",	{seqA[[indexH]], "_"},
		"invalid", {"_","_"}
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
		If[AlignSymbols[[1]] != "_",
			{Similarity + 1, Distance},
			{Similarity, Distance}
		],{Similarity - 1, Distance + 1}
	]


(* TODO - gives a list of the relative next arrow position: \'
Position of the Row [[1]] and Position of the Arrow in the Row [[2]] *)
DecodePosNextArrow[typeArrow_, curDir_] :=
	Switch[typeArrow,
		"diag", {2,0},
		"up", If[curDir == 0, {1,-1}, {1,0}],
		"left",	If[curDir == 0, {1,0}, {1,1}],
		"invalid", {0,0}
	]

(* TODO - gives a list with the code of the next Arrow *)
GetNextArrow[arrowMatrix_, indexArrow_, indexRow_] :=
	Partition[arrowMatrix[[ -indexRow ]], 2] [[ indexArrow ]]
(* TODO - gives the next direction sweep *)
GetNextDirectionSweep[curDirSweep_, posNextArrow_] :=
	Mod[curDirSweep + posNextArrow[[1]], 2];

(* TODO - Traceback *)
TracebackKBandNW[arrowMatrix_, flagD_, seqA_, seqB_] :=
	Block[{h = Length@seqA, v = Length@seqB, newSeqA={}, newSeqB={}, similarity=0, distance=0,
		indexRow, indexArrow, arrow, arrowTag, symbolA, symbolB, posNextArrow, flagDSweep },

		flagDSweep = flagD;
		{indexRow, indexArrow} = {1, Ceiling[SeqPos[arrowMatrix[[-1]], {1}][[1]]/2]};
		Reap[While[h != 0 || v != 0,
			arrow = GetNextArrow[arrowMatrix, indexArrow, indexRow];
			arrowTag = DecodeArrow[arrow, h, v];
			{symbolA, symbolB} = GetAlignSymbols[arrowTag, h, v, seqA, seqB];
			AddAlignSymbols[symbolA, symbolB];
			{h, v} = GetAlignIndexes[arrowTag, h, v];
			posNextArrow = DecodePosNextArrow[arrowTag, flagDSweep];
			{indexRow, indexArrow} = {indexRow + posNextArrow[[1]], indexArrow + posNextArrow[[2]]};
			flagDSweep = GetNextDirectionSweep[flagDSweep, posNextArrow];
			{similarity, distance} = GetSimilarityAndDistance[{symbolA, symbolB}, similarity, distance];
		];{similarity, distance}]
	]




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

(*ScoreMatrix[symbolA_, symbolB_, match_, mismatch_, noPEs_] :=*)
ScoreMatrix =  Compile[
	{{symbolA,_Integer,1}, {symbolB,_Integer,1}, {match,_Integer}, {mismatch,_Integer}, {noPEs,_Integer}},
	Table[

		If[symbolA[[i]] != 0 && symbolB[[i]] != 0,
			If[symbolA[[i]] == symbolB[[i]], match, mismatch],
			0
		]
		(*
		Boole[symbolA[[i]] != 0 && symbolB[[i]] != 0] If[symbolA[[i]] == symbolB[[i]], match, mismatch]
		*)
	, {i,noPEs}]
] (*, Parallelization->True, CompilationTarget->"C"]*)

compileNWSeqAlign = Compile[
	{{h,_Integer,2}, {lut,_Integer,1}, {gap,_Integer}, {flagD,_Integer}},
	Block[{n, funDiag, funUp, funLeft, funEdge, invalidRow,
		selMayor, mayorUL, mayorDUL, arrowsRow},

		n = Length@lut;
		funDiag = funUp = funLeft = funEdge = Table[0, {i, n}];
		invalidRow = Total[Abs[lut]];
		selMayor=Table[0,n,2];
		mayorUL = mayorDUL = Table[0, {i, n}];
		arrowsRow = Table[{0,0}, {i, n}];

		(*
		Table[If[flagD == 0,
			funUp[[i-1]] = h[[i, 1]] - gap,
   			funUp[[i-1]] = h[[i + 1, 1]] - gap], {i, 2, n + 1}
   		];
		Table[If[flagD == 0,
			funLeft[[i-1]] = h[[i - 1, 1]] - gap,
   			funLeft[[i-1]] = h[[i, 1]] - gap], {i, 2, n + 1}
   		];

   		Table[
   			funDiag[[i-1]] = h[[i, 2]] + lut[[i-1]];
   			funEdge[[i-1]] = h[[i, 1]] - gap;, {i, 2, n + 1}
   		];
   		*)

   		If[flagD == 0,
			funUp = Table[ h[[i, 1]] - gap, {i, 2, n + 1}];
			funLeft = Table[ h[[i - 1, 1]] - gap, {i, 2, n + 1}];
				,
   			funUp = Table[ h[[i + 1, 1]] - gap, {i, 2, n + 1}];
   			funLeft = Table[ h[[i, 1]] - gap, {i, 2, n + 1}];
   		];
   		funDiag	= h[[2;; n + 1, 2]] + lut;
   		funEdge = h[[2;; n + 1, 1]] - gap;


   		mayorUL = Max /@ ({funUp, funLeft}\[Transpose]);


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
   		,{i, n}];
   		*)
   		Table[
   			arrowsRow[[i]] = Switch[selMayor[[i]],
				{0,0}, {1,1},
				{1,0}, {0,1},
				{0,1}, {1,1},
				{1,1}, {1,0}
			];
   		,{i, n}];
   		arrowsRow = Table[
			If[ lut[[i]] == 0, {0,0}, arrowsRow[[i]] ]
		,{i, n}];


   		(*
   		Table[selMayor[[i,2]] = If[funUp[[i]] < funLeft[[i]],1,0], {i, n}];
   		Table[selMayor[[i,1]] = If[funDiag[[i]] < mayorUL[[i]],1,0], {i, n}];

   		Table[
   			arrowsRow[[i]] = Switch[selMayor[[i]],
				{0,0}, {1,1},
				{1,0}, {0,1},
				{0,1}, {1,1},
				{1,1}, {1,0}
			];
			arrowsRow[[i]] = If[ lut[[i]] == 0, {0,0}, arrowsRow[[i]] ];
   		,{i, n}];
		*)
		(*
   		Table[
   			mayorDUL[[i]] = Switch[arrowsRow[[i]],
				{1,1}, funDiag[[i]], {1,0}, funLeft[[i]],
				{0,1}, funUp[[i]],	{0,0}, 0];
			mayorDUL[[i]] = If[lut[[i]] == 0, funEdge[[i]], mayorDUL[[i]] ];
			(*mayorDUL[[i]] = If[invalidRow == 0, 0, mayorDUL[[i]] ];*)
   		,{i, n}];
   		If[invalidRow == 0, mayorDUL = Table[0, n]];
   		*)
   		(*
   		mayorDUL = Table[
   			 Switch[arrowsRow[[i]],
				{1,1}, funDiag[[i]], {1,0}, funLeft[[i]],
				{0,1}, funUp[[i]],	{0,0}, 0]
			(*mayorDUL[[i]] = If[invalidRow == 0, 0, mayorDUL[[i]] ];*)
   		,{i, n}];
   		*)
   		Table[
   			mayorDUL[[i]] = Switch[arrowsRow[[i]],
				{1,1}, funDiag[[i]], {1,0}, funLeft[[i]],
				{0,1}, funUp[[i]],	{0,0}, 0];
   		,{i, n}];
   		mayorDUL = Table[
   			If[lut[[i]] == 0, funEdge[[i]], mayorDUL[[i]] ]
   		,{i, n}];
   		If[invalidRow == 0, mayorDUL = Table[0, n]];

		{arrowsRow, mayorDUL}
	]
]

NWSeqAlign[h_, lut_, gap_, flagD_] :=
	Block[{n, funDiag, funUp, funLeft, funEdge, invalidRow,
		selMayor, mayorUL, mayorDUL, arrowsRow, casos},

		(*Inicializaci\:e824e variables*)
		n = Length@lut;
		funDiag = funUp = funLeft = funEdge = Table[0., {i, n}];
		invalidRow = Total[Abs[N@lut]];
		selMayor=Table[0,n,2];
		mayorUL = mayorDUL = Table[0., {i, n}];
		arrowsRow = Table[{0,0}, {i, n}];

		(*casos a elegir*)
		If[flagD == 0,
			funUp = Table[ h[[i, 1]] - gap, {i, 2, n + 1}];
			funLeft = Table[ h[[i - 1, 1]] - gap, {i, 2, n + 1}];
				,
   			funUp = Table[ h[[i + 1, 1]] - gap, {i, 2, n + 1}];
   			funLeft = Table[ h[[i, 1]] - gap, {i, 2, n + 1}];
   		];
   		funDiag	= h[[2;; n + 1, 2]] + lut;
   		funEdge = h[[2;; n + 1, 1]] - gap;

   		(*Seleccionar valor mayor*)
   		mayorUL = Max /@ ({funUp, funLeft}\[Transpose]);
   		mayorDUL = Max /@ ({funUp, funLeft, funDiag}\[Transpose]);

   		(*
   		selMayor[[;;,2]] = Apply[Less, {funUp,funLeft}\[Transpose], 1];
   		selMayor[[;;,1]] = Apply[Less, {funDiag,mayorUL}\[Transpose], 1];
   		Table[
   			arrowsRow[[i]] = Switch[selMayor[[i]],
				{False,False}, {1,1},
				{True,False}, {0,1},
				{False,True}, {1,1},
				{True,True}, {1,0}
			];
			arrowsRow[[i]] = If[ lut[[i]] == 0, {0,0}, arrowsRow[[i]] ];
   		,{i, n}];
   		*)

		(*Seleccionar flecha asociada al mayor*)
   		selMayor[[;;,2]] = Table[If[funUp[[i]] < funLeft[[i]],1,0], {i, n}];
   		selMayor[[;;,1]] = Table[If[funDiag[[i]] < mayorUL[[i]],1,0], {i, n}];
		arrowsRow = Table[
   			Switch[selMayor[[i]],
				{0,0}, {1,1},
				{1,0}, {0,1},
				{0,1}, {1,1},
				{1,1}, {1,0}
			]
   		,{i, n}];

   		(*Casos especiales*)
   		(*
   		{arrowsRow, mayorDUL} = Table[
   			If[lut[[i]] == 0,
   				{{0,0}, funEdge[[i]]},
   				{arrowsRow[[i]], mayorDUL[[i]]}
   			]
   		,{i, n}]\[Transpose]
   		*)

   		mayorDUL = Table[
   			If[lut[[i]] == 0, funEdge[[i]], mayorDUL[[i]] ]
   		,{i, n}];
   		If[invalidRow == 0, mayorDUL = Table[0, n]];
   		arrowsRow = Table[
			If[ lut[[i]] == 0, {0,0}, arrowsRow[[i]] ]
		,{i, n}];

		(*arrowsRow = Part[{{1,1}, {0,1}, {1,0}},Flatten@(First /@ MapThread[Position, {{funDiag, funUp, funLeft}\[Transpose], mayorDUL}])];
   		arrowsRow = (First /@ MapThread[Position, {{funDiag, funUp, funLeft}\[Transpose], mayorDUL}]) /. {{1} -> {1,1}, {2} -> {0,1}, {3} -> {1,0}};   *)





   		(*
		mayorDUL = If[invalidRow == 0, Table[0, n],
   			Table[ If[lut[[i]] == 0, funEdge[[i]],
   				Switch[arrowsRow[[i]],
				{1,1}, funDiag[[i]], {1,0}, funLeft[[i]],
				{0,1}, funUp[[i]],	{0,0}, 0]]
			,{i,n}]
		];
		*)
		{arrowsRow, mayorDUL}
	]


(* TODO - Forward *)


 Region Title

ForwardKBandNW[noPEs_, seqA_, seqB_, match_, mismatch_, gap_, offsetUser_] :=
	Block[{lenA = Length@seqA, lenB = Length@seqB, enhSeqA, enhSeqB, lenSeqMax, offset,
		lutByPE, cycle, arrowsRow, matrixH, outputH, noCYCLE=1, noValidRows, inBufferA,
		inBufferB, flagD },

		lenSeqMax = Max[lenA, lenB];
		noValidRows = lenA + lenB - 1;
		offset = Abs[Floor[(lenB - lenA)/2]] + offsetUser;
		{enhSeqA, enhSeqB} = If[lenB > lenA,
  			{Join[Table[0, offset], seqA, Table[0, (lenB-lenA) - offset]], seqB},
  			{seqA, Join[Table[0, offset], seqB, Table[0, (lenA-lenB) - offset]]}
  		];
  		enhSeqA = Join[enhSeqA,Table[0,noPEs+offset]];
  		enhSeqB = Join[enhSeqB,Table[0,noPEs+offset]];

  		inBufferA = inBufferB = lutByPE = Table[0., noPEs];
  		matrixH = Table[-10^15{1, 1}, noPEs + 2];

  		flagD = 0;

  		Reap[For[cycle=1, cycle <= (noPEs + offset + noValidRows), cycle++,
  			{inBufferA, inBufferB} = LoadInputBuffer[enhSeqA[[noCYCLE]], enhSeqB[[noCYCLE]], inBufferA, inBufferB, flagD];
  			(*lutByPE = Table[ScoreMatrix[inBufferA[[i]], inBufferB[[i]], match, mismatch], {i,noPEs}];*)
  			lutByPE = ScoreMatrix[inBufferA, inBufferB, match, mismatch, noPEs];

  			{arrowsRow, outputH} = NWSeqAlign[matrixH, lutByPE, gap, flagD];
  				Sow[arrowsRow//Flatten, tagArrow]; Sow[outputH, tagMatrixH];

  			matrixH[[;;,2]] = matrixH[[;;,1]];
  			matrixH[[2;;-2,1]] = outputH;

  			If[flagD == 1, noCYCLE++];
  			flagD = Mod[flagD + 1, 2];
  		];flagD]

  	]





(* TODO - Compiled Versions *)
(*
compileForwardKBandNW = Compile[
	{{noPEs,_Integer}, {seqA,_Integer,1}, {seqB,_Integer,1}, {match,_Integer}, {mismatch,_Integer}, {gap,_Integer}, {offsetUser,_Integer}},
	Block[{lenA = Length@seqA, lenB = Length@seqB, enhSeqA, enhSeqB, lenSeqMax, offset,
		lutByPE, cycle, arrowsRow, matrixH, outputH, noCYCLE=1, noValidRows, inBufferA, inBufferB, arrow, posNextArrow, flagD },

		lenSeqMax = Max[lenA, lenB];
		noValidRows = lenA + lenB - 1;
		offset = Abs[Floor[(lenB - lenA)/2]] + offsetUser;
		{enhSeqA, enhSeqB} = If[lenB > lenA,
  			{Join[Table[0, offset], seqA, Table[0, (lenB-lenA) - offset]], seqB},
  			{seqA, Join[Table[0, offset], seqB, Table[0, (lenA-lenB) - offset]]}
  		];
  		enhSeqA = Join[enhSeqA,Table[0,noPEs+offset]];
  		enhSeqB = Join[enhSeqB,Table[0,noPEs+offset]];

  		inBufferA = inBufferB = lutByPE = Table[0, noPEs];
  		matrixH = Table[-10^15{1, 1}, noPEs + 2];

  		flagD = 0;

  		Reap[For[cycle=1, cycle <= (noPEs + offset + noValidRows), cycle++,
  			{inBufferA, inBufferB} = LoadInputBuffer[enhSeqA[[noCYCLE]], enhSeqB[[noCYCLE]], inBufferA, inBufferB, flagD];
  			lutByPE = ScoreMatrix[inBufferA, inBufferB, match, mismatch, noPEs];

  			{arrowsRow, outputH} = compileNWSeqAlign[matrixH, lutByPE, gap, flagD];
  				Sow[arrowsRow//Flatten, tagArrow]; (*Sow[outputH, tagMatrixH];*)

  			matrixH[[1;;-1,2]] = matrixH[[1;;-1,1]];
  			matrixH[[2;;-2,1]] = outputH;

  			If[flagD == 1, noCYCLE++];
  			flagD = Mod[flagD + 1, 2];
  		];flagD]

  	]

]
*)

NWSeqAlignAffine[h_, lut_, gapO_, gapE_, flagD_] :=
	Block[{n, funDiag, funUp, funLeft, funEdge, invalidRow,
		selMayor, mayorUL, mayorDUL, arrowsRow},

		(*Inicializaci\:e824e variables*)
		n = Length@lut;
		funDiag = funUp = funLeft = funEdge = Table[0, {i, n}];
		invalidRow = Total[Abs[lut]];
		selMayor=Table[0,n,2];
		mayorUL = mayorDUL = Table[0, {i, n}];
		arrowsRow = Table[{0,0}, {i, n}];

		(*Casos a elegir*)
		If[flagD == 0,
			funUp = Table[ h[[i, 1]] - gap, {i, 2, n + 1}];
			funLeft = Table[ h[[i - 1, 1]] - gap, {i, 2, n + 1}];
				,
   			funUp = Table[ h[[i + 1, 1]] - gap, {i, 2, n + 1}];
   			funLeft = Table[ h[[i, 1]] - gap, {i, 2, n + 1}];
   		];
   		funDiag	= h[[2;; n + 1, 2]] + lut;
   		funEdge = h[[2;; n + 1, 1]] - gap;

   		(*Elegir el mayor y la direcci\:eaa9
   		mayorUL = Max /@ ({funUp, funLeft}\[Transpose]);

   		selMayor[[;;,2]] = Table[If[funUp[[i]] < funLeft[[i]],1,0], {i, n}];
   		selMayor[[;;,1]] = Table[If[funDiag[[i]] < mayorUL[[i]],1,0], {i, n}];

		arrowsRow = Table[
   			Switch[selMayor[[i]],
				{0,0}, {1,1},
				{1,0}, {0,1},
				{0,1}, {1,1},
				{1,1}, {1,0}
			]
   		,{i, n}];
   		arrowsRow = Table[
			If[ lut[[i]] == 0, {0,0}, arrowsRow[[i]] ]
		,{i, n}];


   		mayorDUL = Table[
   			 Switch[arrowsRow[[i]],
				{1,1}, funDiag[[i]], {1,0}, funLeft[[i]],
				{0,1}, funUp[[i]],	{0,0}, 0]
			(*mayorDUL[[i]] = If[invalidRow == 0, 0, mayorDUL[[i]] ];*)
   		,{i, n}];
   		mayorDUL = Table[
   			If[lut[[i]] == 0, funEdge[[i]], mayorDUL[[i]] ]
   		,{i, n}];
   		If[invalidRow == 0, mayorDUL = Table[0, n]];

		{arrowsRow, mayorDUL}
	]

ForwardKBandNWAffine[noPEs_, seqA_, seqB_, match_, mismatch_, gapO_, gapE_, offsetUser_] :=
	Block[{lenA = Length@seqA, lenB = Length@seqB, enhSeqA, enhSeqB, lenSeqMax, offset,
		lutByPE, cycle, arrowsRow, matrixH, outputH, noCYCLE=1, noValidRows, inBufferA,
		inBufferB, flagD },

		lenSeqMax = Max[lenA, lenB];
		noValidRows = lenA + lenB - 1;
		offset = Abs[Floor[(lenB - lenA)/2]] + offsetUser;
		{enhSeqA, enhSeqB} = If[lenB > lenA,
  			{Join[Table[0, offset], seqA, Table[0, (lenB-lenA) - offset]], seqB},
  			{seqA, Join[Table[0, offset], seqB, Table[0, (lenA-lenB) - offset]]}
  		];
  		enhSeqA = Join[enhSeqA,Table[0,noPEs+offset]];
  		enhSeqB = Join[enhSeqB,Table[0,noPEs+offset]];

  		inBufferA = inBufferB = lutByPE = Table[0, noPEs];
  		matrixH = Table[-10^15{1, 1}, noPEs + 2];

  		flagD = 0;

  		Reap[For[cycle=1, cycle <= (noPEs + offset + noValidRows), cycle++,
  			{inBufferA, inBufferB} = LoadInputBuffer[enhSeqA[[noCYCLE]], enhSeqB[[noCYCLE]], inBufferA, inBufferB, flagD];
  			(*lutByPE = Table[ScoreMatrix[inBufferA[[i]], inBufferB[[i]], match, mismatch], {i,noPEs}];*)
  			lutByPE = ScoreMatrix[inBufferA, inBufferB, match, mismatch, noPEs];

  			{arrowsRow, outputH} = NWSeqAlignAffine[matrixH, lutByPE, gapO, gapE, flagD];
  				Sow[arrowsRow//Flatten, tagArrow]; Sow[outputH, tagMatrixH];

  			matrixH[[;;,2]] = matrixH[[;;,1]];
  			matrixH[[2;;-2,1]] = outputH;

  			If[flagD == 1, noCYCLE++];
  			flagD = Mod[flagD + 1, 2];
  		];flagD]

  	]

End[]

EndPackage[]
