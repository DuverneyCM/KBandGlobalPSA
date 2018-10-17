library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity KbandSource is
	generic(
		NoCell		: 	natural  :=	1024;	--MULTIPLOS DE 16
		dimADN		: 	natural  :=	3;
		bitsOUT		: 	natural  :=	64;	--32
		widthu		: 	natural  :=	6		--#regs
		--NoCell/bitsOUT < 16	Si >32, causa error
	);
	port(
		-- clk and reset interface
		clk_ext, clk_int, reset															:	in		std_logic;
		--Streamming Source Interface
		din_Ready															:	in		std_logic;
		dout_Valid															:	out	std_logic;
		dout_Data															:	out	std_logic_vector(bitsOUT downto 1);
		--interLogic Ports
		iSendDirection, iDirection										:	in	std_logic;
		iWrite																:	in	std_logic;
		iTransmitir															:	in	std_logic;
		oFIFOfull															:	out	std_logic;
		oFIFOEmpty															:	out	std_logic;
		iArrows																:	in	std_logic_vector(2*NoCell downto 1)
	);
end KbandSource;

architecture rtl of KbandSource  is
	constant	bitsIN	: 	natural  :=	2*NoCell;	--MULTIPLOS DE 32
component FifoKBandOUT IS
	GENERIC(
		bitsIN		: 	natural  :=	128;	--MULTIPLOS DE 32
		bitsOUT		: 	natural  :=	32;	--32
		widthu		: 	natural  :=	8
	);
	PORT(
		aclr		: IN STD_LOGIC  := '0';
		data		: IN STD_LOGIC_VECTOR (bitsIN-1 DOWNTO 0);
		rdclk		: IN STD_LOGIC ;
		rdreq		: IN STD_LOGIC ;
		wrclk		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		q			: OUT STD_LOGIC_VECTOR (bitsOUT-1 DOWNTO 0);
		rdempty	: OUT STD_LOGIC ;
		wrfull	: OUT STD_LOGIC ;
		wrusedw		: OUT STD_LOGIC_VECTOR (2 DOWNTO 0)
	);
END component;

signal	sFifoDataIn, ssFifoDataIn, LastRow	:	std_logic_vector(bitsIN downto 1);
signal	sFifoCount	:	std_logic_vector(6 downto 0);
signal	sFifoRead, sFifoWrite, sFifoEmpty, sFifoFull	:	std_logic;
signal	sDirFifoDataIn	:	std_logic_vector(bitsIN downto 1);
signal	cnt	:	std_logic_vector(3 downto 0);
signal	sdout_Data	:	std_logic_vector(bitsOUT-1 downto 0);
signal	susedw		: STD_LOGIC_VECTOR (2 DOWNTO 0);
signal	sTransmitir	:	std_logic;

	type state_type is (s0, s1, s2, s3);
	signal state   : state_type;

begin
	sTransmitir		<=	'1';--iTransmitir;
	ssFifoDataIn	<=	iArrows;
	sFifoRead		<=	din_Ready and sTransmitir and not sFifoEmpty;
	sFifoWrite		<=	iWrite;-- and not sFifoFull;
	oFIFOfull		<=	'0' when susedw < 1 else '1'; --sFifoFull;
	oFifoEmpty		<=	sFifoEmpty;

		--Retardos de sincronizacion
	process(reset, clk_ext) is
	begin
		if(reset = '1') then
			dout_Valid	<= '0';
			sFifoDataIn	<=	(others => '0');
		elsif(rising_edge(clk_ext)) then
			dout_Valid	<=	not sFifoEmpty;--sFifoRead;
			if iWrite = '1' then
				sFifoDataIn	<=	ssFifoDataIn; --clk_int
			end if;
		end if;
	end process;

	--envio de direccion
	uLastRow:
	for i in 1 to NoCell generate
		LastRow(2*i-1)	<=	iDirection;--iDirection;
		LastRow(2*i)	<=	not iDirection;--not iDirection;
	end generate;
	sDirFifoDataIn	<=	ssFifoDataIn when iSendDirection = '0' else
							LastRow;
							--(others => iDirection);

	--FIFO buffer
	uFIFOout	:	FifoKBandOUT
	generic map( bitsIN, bitsOUT, widthu )
	port map(
		aclr			=>	reset,
		data		=>	sDirFifoDataIn,
		rdclk		=>	clk_ext,
		rdreq		=>	sFifoRead,
		wrclk		=>	clk_int,
		wrreq		=>	sFifoWrite,
		q				=>	sdout_Data,
		rdempty	=>	sFifoEmpty,
		wrfull		=>	sFifoFull,
		wrusedw		=>	susedw
	);

	--Conversor de Little Endian a Big Endian
	dout_Data	<=	sdout_Data(7 downto 0) & sdout_Data(15 downto 8) & sdout_Data(23 downto 16) & sdout_Data(31 downto 24) &
						sdout_Data(39 downto 32) & sdout_Data(47 downto 40) & sdout_Data(55 downto 48) & sdout_Data(63 downto 56) &
						sdout_Data(71 downto 64) & sdout_Data(79 downto 72) & sdout_Data(87 downto 80) & sdout_Data(95 downto 88) &
						sdout_Data(103 downto 96) & sdout_Data(111 downto 104) & sdout_Data(119 downto 112) & sdout_Data(127 downto 120);

	--dout_Data	<=	sdout_Data when iSendDirection = '0' else
		--				(others => iDirection);

end rtl;
