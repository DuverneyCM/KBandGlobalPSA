library IEEE;
use ieee.std_logic_1164.all;

entity KbandPairwiseAlignIP is
	generic(
		NoCell			: 	natural  :=	64;
		dimH			: 	natural  :=	8;
		dimADN		: 	natural  :=	3
	);
	port(
		--pruebas
		oADNh, oADNv											:	out	std_logic_vector(2 downto 0);
		oADNen, oDirection									:	out	std_logic;
		oflag															:	out	std_logic;
		oArrows														:	out std_logic_vector(2*NoCell-1 downto 0);
	
		-- clk and reset interface
		clk, reset													:	in		std_logic;
		--Streamming Sink Interface
		din_startOfPacket, din_endOfPacket		:	in		std_logic;
		din_Ready													:	out	std_logic;
		din_Valid														:	in		std_logic;
		din_Data														:	in		std_logic_vector(32 downto 1);
		--Streamming Source Interface
		dout_startOfPacket, dout_endOfPacket		:	out	std_logic;
		dout_Ready														:	in		std_logic;
		dout_Valid															:	out	std_logic;
		dout_Data															:	out	std_logic_vector(32 downto 1)		
	);
end KbandPairwiseAlignIP;

ARCHITECTURE rtl OF KbandPairwiseAlignIP IS
--components
component SystolicFordward is
	generic(
		NoCell			: 	natural  :=	64;
		dimH			: 	natural  :=	8;
		dimADN		: 	natural  :=	3
	);
	port(
		-- Input ports
		CLOCK_50	:	in	std_logic;
		reset			:	in std_logic;
		inDireccion	:	in std_logic;	--0 vertical, 1 horizontal
		iADNh			:	in std_logic_vector(dimADN-1 downto 0);
		iADNv			:	in std_logic_vector(dimADN-1 downto 0);
		iEnable		:	in std_logic;
		-- Output ports
		oADNfinish, oADNvalid				:	out std_logic;
		flag						:	out	std_logic;
		oArrows				:	out std_logic_vector(2*NoCell-1 downto 0)
	);
end component;
component KbandPairwiseInCtrlLogic is
	port(
		-- clk and reset interface
		clk, reset													:	in		std_logic;
		--Streamming Sink Interface
		din_startOfPacket, din_endOfPacket		:	in		std_logic;
		din_Ready													:	out	std_logic;
		din_Valid														:	in		std_logic;
		din_Data														:	in		std_logic_vector(32 downto 1);
		--interLogic Ports
		iWait, iKBandEndProcess								:	in		std_logic;
		oADNh, oADNv											:	out	std_logic_vector(2 downto 0);
		oADNen, oDirection									:	out	std_logic		
	);
end component;
component KbandPairwiseOutCtrlLogic is
	port(
		-- clk and reset interface
		clk, reset															:	in		std_logic;
		--Streamming Source Interface
		dout_startOfPacket, dout_endOfPacket		:	out	std_logic;
		dout_Ready														:	in		std_logic;
		dout_Valid															:	out	std_logic;
		dout_Data															:	out	std_logic_vector(32 downto 1);	
		--interLogic Ports
		iADNen, iADNfinish											:	in	std_logic;
		oFIFOfull															:	out	std_logic;
		iArrows																:	in	std_logic_vector(2*64 downto 1);
		iFlag																	:	in	std_logic
	);
end component;

--signals
signal	siStartOfPacket, siEndOfPacket, soStartOfPacket, soEndOfPacket	:	std_logic;
signal	siReady, siValid, soReady, soValid	:	std_logic;
signal	siData, soData	:	std_logic_vector(32 downto 1);
signal	sADNh, sADNv	:	std_logic_vector(2 downto 0);
signal	sADNen, sADNvalid, sArrowEn, sDirection, sFlag, sFIFOfull	:	std_logic;
signal	sArrows	:	 std_logic_vector(2*NoCell-1 downto 0);

BEGIN

	uInControlLogic	:	KbandPairwiseInCtrlLogic
	port map(
		-- clk and reset interface
		clk		=>	clk,	
		reset	=>	reset,
		--Streamming Sink Interface
		din_startOfPacket	=>	siStartOfPacket, 
		din_endOfPacket		=>	siEndOfPacket,
		din_Ready					=>	siReady,
		din_Valid					=>	siValid,
		din_Data					=>	siData,
		--interLogic Ports
		iWait			=>	sFIFOfull,
		iKBandEndProcess	=>	sArrowEn,
		oADNh		=>	sADNh, 
		oADNv		=>	sADNv,
		oADNen		=>	sADNen, 
		oDirection	=>	sDirection
	);

	uSystolicKBand	: SystolicFordward
	generic map(
		NoCell		=>	64,
		dimH		=>	8,
		dimADN	=>	3
	)
	port map(
		-- Input ports
		CLOCK_50	=>	clk,
		reset			=>	reset,
		inDireccion	=>	sDirection,
		iADNh			=>	sADNh,
		iADNv			=>	sADNv,
		iEnable		=>	sADNen,
		-- Output ports
		oADNfinish		=>	sArrowEn,
		oADNvalid		=>	sADNvalid,
		flag				=>	sFlag,
		oArrows		=>	sArrows
	);
	
	uOutControlLogic	:	KbandPairwiseOutCtrlLogic
	port map(
		-- clk and reset interface
		clk		=>	clk,	
		reset	=>	reset,
		--Streamming Source Interface
		dout_startOfPacket		=>	soStartOfPacket, 
		dout_endOfPacket		=>	soEndOfPacket,
		dout_Ready					=>	soReady,
		dout_Valid						=>	soValid,
		dout_Data						=>	soData,
		--interLogic Ports
		iADNen							=>	sADNvalid,
		iADNfinish						=>	sArrowEn,
		oFIFOfull						=>	sFIFOfull,
		iArrows							=>	sArrows,
		iFlag								=>	sFlag
	);
	
	siStartOfPacket		<=	din_startOfPacket;
	siEndOfPacket			<=	din_endOfPacket;
	din_Ready					<=	siReady;
	siValid							<=	din_Valid;
	siData							<=	din_Data;
	
	dout_startOfPacket	<=	soStartOfPacket;
	dout_endOfPacket	<=	soEndOfPacket;
	soReady						<=	dout_Ready;
	dout_Valid					<=	soValid;
	dout_Data					<=	soData;
	
	
	--pruebas
	oADNh		<=	sADNh; 
	oADNv		<=	sADNv;
	oADNen		<=	sADNen;
	oDirection	<=	sDirection;
	oflag			<=	sFlag;
	oArrows		<=	sArrows;
END rtl;

--		--MemoryMapped Master Source Interface
--		address
--		--byteenable
--		debugaccess
--		--read
--		--readdata
--		response
--		--write
--		--writedata
--		lock
--		waitrequest
--		readdatavalid
--		writeresponsevalid
--		burstcount
--		
--		beginbursttransfer
--		
--		
--		
--		
--		read, write, chipselect	:	
--		writedata
--		readdata