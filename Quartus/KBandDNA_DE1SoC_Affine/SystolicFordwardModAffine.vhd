library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity SystolicFordwardModAffine is
	generic(
		NoCell			: 	natural  :=	64;
		dimH			: 	natural  :=	4;
		dimADN		: 	natural  :=	3;
		dimLUT	:	natural  :=	3
	);
	port(
		-- Input ports (parameters)
		iMatch, iMisMatch, iOG, iEG	:	in std_logic_vector(dimLUT-1 downto 0);
		-- Input ports
		CLOCK_50	:	in	std_logic;
		reset			:	in std_logic;
		inDireccion	:	in std_logic;	--0 vertical, 1 horizontal
		iADNh			:	in std_logic_vector(dimADN-1 downto 0);
		iADNv			:	in std_logic_vector(dimADN-1 downto 0);
		iEnable		:	in std_logic;
		iADNFinish	:	in std_logic;

		-- Output ports
		oADNfinish, oADNvalid				:	out std_logic;
		flag						:	out	std_logic;
		oArrows				:	out std_logic_vector(2*NoCell-1 downto 0)
		
		--prueba
		--H1, H2, H3, H4, H5	:	out std_logic_vector(dimH-1 downto 0);
		--rADNa0, rADNa1, rADNa2, rADNa3, rADNa4, rADNa5 : out	std_logic_vector(dimADN-1 downto 0);
		--rADNb0, rADNb1, rADNb2, rADNb3, rADNb4, rADNb5 : out	std_logic_vector(dimADN-1 downto 0)
	);
end SystolicFordwardModAffine;

	--(0 => Ne, others => '0')
	--(others => '0')	

architecture rtl of SystolicFordwardModAffine is

	function reverse_any_vector (a: in std_logic_vector)
	return std_logic_vector is
	  variable result: std_logic_vector(a'RANGE);
	  alias aa: std_logic_vector(a'REVERSE_RANGE) is a;
	begin
	  for i in aa'RANGE loop
		 result(i) := aa(i);
	  end loop;
	  return result;
	end; -- function reverse_any_vector

	Type TipoADN	is	Array (NoCell+1 downto 0) of std_logic_vector(dimADN-1 downto 0);
	Type TipoH		is	Array (NoCell+1 downto 0) of std_logic_vector(dimH-1 downto 0);
	Type TipoArrow	is	Array (NoCell+1 downto 0) of std_logic_vector(1 downto 0);

	
	signal	andAux		:	std_logic_vector(NoCell downto 1);
	signal	sensorAnd	:	std_logic;

	signal	sADNa,sADNb, rADNa,rADNb	:	TipoADN;
	signal	sH, rH1, rH2, sG, rG1, rG2				:	TipoH;
	signal	arrayHU,	arrayHL, arrayGU,	arrayGL	:	TipoH;
	signal	sDireccionVector, rDireccionVector	:	std_logic_vector(2*NoCell-1 downto 0);
	signal	sArrow, rArrow								:	TipoArrow;
	signal	sDirGap, sDirGapDiag						:	std_logic_vector(NoCell downto 0);
	
	signal	sEnable, sADNfinish, sDirection	:	std_logic;
	
	signal	sBlockCero	:	std_logic_vector(NoCell downto 0);
	
	
	component PEadnModAffine is
		generic(
			dimH		: 	natural  :=	4;
			dimADN	:	natural  :=	3;
			dimLUT	:	natural  :=	3
		);
		port
		(
			-- Input ports (parameters)
			iMatch, iMisMatch, iOG, iEG	:	in std_logic_vector(dimLUT-1 downto 0);

			--	Input ports
			iADNa			:	in std_logic_vector(dimADN-1 downto 0);
			iADNb			:	in std_logic_vector(dimADN-1 downto 0);
			iHd			:	in std_logic_vector(dimH-1 downto 0);
			iHu			:	in std_logic_vector(dimH-1 downto 0);
			iHl			:	in std_logic_vector(dimH-1 downto 0);
			iADNFinish	:	in	std_logic;
			iDirGap		:	in	std_logic;
			iGapDiag		:	in std_logic_vector(dimH-1 downto 0);
			iGapUp		:	in std_logic_vector(dimH-1 downto 0);
			iGapLeft		:	in std_logic_vector(dimH-1 downto 0);
			iGedge		:	in std_logic_vector(dimH-1 downto 0);
			-- Output ports
			oGap			:	out std_logic_vector(dimH-1 downto 0);
			oDirGap		:	out	std_logic;
			oADNa			:	out std_logic_vector(dimADN-1 downto 0);
			oADNb			:	out std_logic_vector(dimADN-1 downto 0);
			oH				:	out std_logic_vector(dimH-1 downto 0);
			oArrow		:	out std_logic_vector(1 downto 0)
		);
	end component;
	
	component pipelineKBandModAffine is
		generic(
			dimH		: 	natural  :=	5;
			dimADN	:	natural  :=	3
		);
		port
		(
			-- Input ports
			CLOCK_50		:	in	std_logic;
			reset			:	in std_logic;
			iEnable		:	in std_logic;
			inDireccion	:	in std_logic;	--0 vertical, 1 horizontal
			iBitCl		:	in std_logic;
			iADNa			:	in std_logic_vector(dimADN-1 downto 0);
			iADNb			:	in std_logic_vector(dimADN-1 downto 0);
			iH				:	in std_logic_vector(dimH-1 downto 0);
			iG				:	in std_logic_vector(dimH-1 downto 0);
			iArrow		:	in std_logic_vector(1 downto 0);
			iDirGap		:	in	std_logic;
			iCero			:	in	std_logic;
			iFinish		:	in	std_logic;
			-- Output ports
			oADNa			:	out std_logic_vector(dimADN-1 downto 0);
			oADNb			:	out std_logic_vector(dimADN-1 downto 0);
			oH1msb		:	out std_logic_vector(1 downto 0);
			oH1			:	out std_logic_vector(dimH-1 downto 0);
			oH2			:	out std_logic_vector(dimH-1 downto 0);
			oG1			:	out std_logic_vector(dimH-1 downto 0);
			oG2			:	out std_logic_vector(dimH-1 downto 0);
			oDirGapDiag	:	out std_logic;
			oArrow		:	out std_logic_vector(1 downto 0)
		);
	end component;
	
begin
	
	--crea las celdas de procesamiento
	processor_cell: 
	for i in 1 to NoCell generate
		PE: PEadnModAffine
		generic map(
			dimH		=>	dimH,
			dimADN	=>	dimADN,
			dimLUT	=> dimLUT
		)
		port map(
			-- Input ports (parameters)
			iMatch		=>	iMatch,--"0101",	--  3+2
			iMisMatch	=>	iMisMatch,--"0001",	-- -1+2
			iOG			=>	iOG,
			iEG			=>	iEG,
			-- Input ports
			iADNa			=>	rADNa(i-1),
			iADNb			=>	rADNb(i),--arrayInAminoV(NoCell+1 - i),
			iHd			=>	rH2(i),
			iHu			=>	arrayHU(i),
			iHl			=>	arrayHL(i),
			iADNFinish	=>	iADNFinish,--'0',		
			iDirGap		=>	sDirGapDiag(i),		--:	in	std_logic;
			iGapDiag		=>	rG2(i),		--:	in std_logic_vector(dimH-1 downto 0);
			iGapUp		=>	arrayGU(i),	--:	in std_logic_vector(dimH-1 downto 0);
			iGapLeft		=>	arrayGL(i),	--:	in std_logic_vector(dimH-1 downto 0);
			iGedge		=>	rG1(i),
			-- Output ports
			oGap			=>	sG(i),		--:	out std_logic_vector(dimH-1 downto 0);
			oDirGap		=>	sDirGap(i),	--:	out	std_logic;
			oADNa			=>	sADNa(i),
			oADNb			=>	sADNb(i),
			oH				=>	sH(i), --igual a antes en H1, h0
			oArrow		=>	sArrow(i)
		);
	end generate;
	
	--crea los registros de pipeline
	register_cell: 
	for i in 0 to NoCell generate
		rPIPE	:	pipelineKBandModAffine
		generic map(
			dimH		=>	dimH,
			dimADN	=>	dimADN
		)
		port map(
			-- Input ports
			CLOCK_50		=>	CLOCK_50,
			reset			=>	reset,
			iEnable		=>	sEnable,
			inDireccion	=>	inDireccion,
			iBitCl		=>	sensorAnd,
			iADNa			=>	sADNa(i),
			iADNb			=>	sADNb(i+1),
			iH				=>	sH(i),
			iG				=>	sG(i),
			iArrow		=>	sArrow(i),
			iDirGap		=>	sDirGap(i),
			iCero			=>	'0',--sBlockCero(i),
			iFinish		=>	'0',--iADNFinish,
			-- Output ports
			oADNa			=>	rADNa(i),
			oADNb			=>	rADNb(i),
			oH1			=>	rH1(i),
			oH2			=>	rH2(i),
			oG1			=>	rG1(i),--:	out std_logic_vector(dimH-1 downto 0);
			oG2			=>	rG2(i),--:	out std_logic_vector(dimH-1 downto 0);
			oDirGapDiag	=>	sDirGapDiag(i),
			oArrow		=>	rArrow(i)
		);
	end generate;
	
	--REGISTROS
	--carga los registros de desplazamiento
	sADNb(NoCell+1)	<=	iADNh;
	sADNa(0)				<=	iADNv;
	
	--Sincronizacion de dirección
	--Direction
	process (CLOCK_50, reset)
	begin
		if reset = '1' then
			sDirection <= '1';
		elsif (rising_edge(CLOCK_50)) then
			if iEnable = '1' then
				--sDirection <= inDireccion;
				sDirection <= not sDirection;
			end if;
		end if;
	end process;
	--sDirection <= inDireccion;
	
	
	--crea los multiplexores
	--son los registros que se conectan en U y L en los bordes
	rH1(NoCell+1)	<=	rH2(NoCell);--(dimH-1 => '1', 1 => '1', others => '0'); --(others => '1');
	sH(0)				<=	rH2(1);--(dimH-1 => '1', 1 => '1', others => '0'); --sH
	rG1(NoCell+1)	<=	rG2(NoCell);
	sG(0)				<=	rG2(1);
	
	mux:
	for i in 2 to NoCell generate
		mux_HU: arrayHU(i) <=	rH1(i) when sDirection = '1' else rH1(i+1); --si el ultimo movimiento fue vertical (0)										
		mux_HL: arrayHL(i) <=	rH1(i) when sDirection = '0' else rH1(i-1); --si el ultimo movimiento fue horizontal(1)											
		mux_GU: arrayGU(i) <=	rG1(i) when sDirection = '1' else rG1(i+1);									
		mux_GL: arrayGL(i) <=	rG1(i) when sDirection = '0' else rG1(i-1);	
	end generate;
	arrayHU(1) <=	rH1(1) when sDirection = '1' else rH1(2);
	arrayHL(1) <=	rH1(1) when sDirection = '0' else sH(0);
	arrayGU(1) <=	rG1(1) when sDirection = '1' else rG1(2);
	arrayGL(1) <=	rG1(1) when sDirection = '0' else sG(0);
	
	

	
	--AND del segundo bit mas significativo
	and_sensor:
	for i in 1 to NoCell generate
		andAux(i)	<=	sH(i)(DimH-2) and rH1(i)(DimH-2) and rH2(i)(DimH-2);
	end generate;
	sensorAnd	<=	'1' when andAux = (andAux'range => '1') else '0';
	flag	<= sDirection;
	
	--pasa el array a std_logic_vector
	array2stdLogicVector: 
	for i in 0 to NoCell-1 generate
		sDireccionVector(2*i+1 downto 2*i)	<=	sArrow(i+1);
		rDireccionVector(2*i+1 downto 2*i)	<=	rArrow(i+1);	
	end generate;
	oArrows	<=	reverse_any_vector(rDireccionVector); --(0 to 2*NoCell-1)
	
	sEnable	<=	iEnable;
	sADNfinish	<=	'1' when sDireccionVector = 0 else '0';	--sEnable;
	oADNfinish	<=	sADNfinish;
	oADNvalid	<=	iEnable and not sADNfinish;
	--el procesador debe seguir funcionando hasta que la salida de flechas sea nula
	--pero debe detenerse mientras la trama no ha terminado
	--Startofpacket y Endofpacket pueden usarse
	
	--Prueba
--	H1	<=	sH(1);	H2	<=	sH(2);	H3	<=	sH(3);	H4	<=	sH(4);	H5	<=	sH(5);
--	rADNa0	<=	rADNa(0);	rADNa1	<=	rADNa(1);	rADNa2	<=	rADNa(2);	
--	rADNa3	<=	rADNa(3);	rADNa4	<=	rADNa(4);	rADNa5	<=	rADNa(5);
--	
--	rADNb0	<=	rADNb(0);	rADNb1	<=	rADNb(1);	rADNb2	<=	rADNb(2);
--	rADNb3	<=	rADNb(3);	rADNb4	<=	rADNb(4);	rADNb5	<=	rADNb(5);
	
end rtl;

--	IMPORTANTE IMPORTANTE IMPORTANTE IMPORTANTE IMPORTANTE IMPORTANTE IMPORTANTE IMPORTANTE IMPORTANTE IMPORTANTE IMPORTANTE IMPORTANTE

--	--AND del segundo bit mas significativo
--	and_sensor:
--	for i in 1 to NoCell generate
--		andAux(i)	<=	arrayDelayH1(i)(DimH-2) and arrayDelayH2(i)(DimH-2) and arrayDelayH3(i)(DimH-2);
--	end generate;
--	sensorAnd	<=	'1' when andAux = (andAux'range => '1') else '0';
--	flag	<=	inDireccion;