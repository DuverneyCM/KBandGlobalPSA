library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity KbandSink is
	generic(
		dimSymbol	:	natural	:=	32;
		dimADN		:	natural	:=	3
	);
	port(
		-- clk and reset interface
		clk_ext, clk_int, reset													:	in		std_logic;
		--Streamming Sink Interface
		dout_Ready													:	out	std_logic;
		din_Valid													:	in		std_logic;
		din_Data														:	in		std_logic_vector(dimSymbol downto 1);
		--interLogic Ports
		iRead															:	in		std_logic;
		oEmpty														:	out	std_logic;
		oFinalPacket												:	out	std_logic;
		oADN1, oADN2												:	out	std_logic_vector(dimADN downto 1)
		
	);
end KbandSink;

architecture rtl of KbandSink  is
COMPONENT FifoKBandIN IS
	PORT
	(
		aclr		: IN STD_LOGIC  := '0';
		data		: IN STD_LOGIC_VECTOR (5 DOWNTO 0);
		rdclk		: IN STD_LOGIC ;
		rdreq		: IN STD_LOGIC ;
		wrclk		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (5 DOWNTO 0);
		rdempty		: OUT STD_LOGIC ;
		wrfull		: OUT STD_LOGIC 
	);
END COMPONENT;

type state_type is (s0, s1, s2, s3);
signal state   : state_type;

signal	sDinData1, sDinData2	:	std_logic_vector(dimADN downto 1);
signal	sData1, sData2			:	std_logic_vector(8 downto 1);
signal	sDinData, sFifoDataOut	:	std_logic_vector(2*dimADN downto 1);
signal	sFifoCount	:	std_logic_vector(2 downto 0);
signal	sFifoRead, sFifoWrite, sFifoEmpty, sFifoFull, ssFifoEmpty, sssFifoEmpty, ssssFifoEmpty, sFifoEmptyDelay	:	std_logic;
signal	sLoadShReg, shr	:	std_logic;
signal	cnt	:	std_logic_vector(3 downto 0);
signal	adquirir, procesar, sFinalPacket	:	std_logic;
signal	sADN1mux, sADN2mux, rADN1mux, rADN2mux							:	std_logic_vector(dimADN downto 1);

begin
	--Retardos de sincronizacion
	process(reset, clk_int) is 
	begin 
		if(reset = '1') then
			--sDinData	<=	(others => '0');
			--sFifoWrite	<=	'0';
			sFifoEmptyDelay	<=	'0';
			ssFifoEmpty		<=	'0';
			sssFifoEmpty		<=	'0';
			sFinalPacket	<=	'0';
			rADN1mux	<=	(others => '0');
			rADN2mux	<=	(others => '0');
		elsif(rising_edge(clk_int)) then
			--sDinData	<=	sDinData1 & sDinData2;
			--sFifoWrite	<=	din_Valid and not sFifoFull;
			sFifoEmptyDelay	<=	sFifoEmpty;
			if(iRead = '1') then
				ssFifoEmpty	<=	sFifoEmpty and sFinalPacket;
				sssFifoEmpty	<=	ssFifoEmpty;
				rADN1mux	<=	sADN1mux;
				rADN2mux	<=	sADN2mux;
			end if;
			if(sFifoWrite = '1') then
				sFinalPacket	<=	din_Data(32);
			end if;
		end if;
	end process;
	sDinData	<=	sDinData1 & sDinData2;


	
	uFIFOin	:	FifoKBandIN
	port map(
		aclr		=>	reset,		
		data		=>	sDinData, ------- contenar 1 y 2
		rdclk		=>	clk_int,
		rdreq		=>	sFifoRead,
		wrclk		=>	clk_ext,
		wrreq		=>	sFifoWrite,
		rdempty	=>	sFifoEmpty,
		wrfull	=>	sFifoFull,
		q			=>	sFifoDataOut
	);
	
	sFifoRead	<=	iRead and not(sFifoEmpty);
	sFifoWrite	<=	din_Valid and not sFifoFull;-- and iAdquirir;
	--sDinData		<=	din_Data;
	
	--      sFifoDataOut
	--	      
	--		match = 3	missmatch = -1
	sData1	<=	din_Data(8 downto 1);
	sData2	<=	din_Data(16 downto 9);
	with sData1 select
	sDinData1	<= "100" when "01000001",	--A=100		A=65
						"100" when "01100001",	--a=100		a=97
						"101" when "01010100",	--T=101		T=84
						"101" when "01110100",	--t=101		T=116
						"110" when "01000011",	--C=110		C=67
						"110" when "01100011",	--c=110		c=99
						"111" when "01000111",	--G=111		G=71
						"111" when "01100111",	--g=111		g=103
						"101" when "01010101",	--U=101		U=85
						"101" when "01110101",	--u=101		u=117
						"011" when "01011111",	--_=011		_=95
						--"011" when "01101110",	--n=011		n=110
						--"011" when "01001110",	--N=011		N=78
						"000" when others;		--nada=000
						
	with sData2 select
	sDinData2	<= "100" when "01000001",	--A=100		A=65
						"100" when "01100001",	--a=100		a=97
						"101" when "01010100",	--T=101		T=84
						"101" when "01110100",	--t=101		T=116
						"110" when "01000011",	--C=110		C=67
						"110" when "01100011",	--c=110		c=99
						"111" when "01000111",	--G=111		G=71
						"111" when "01100111",	--g=111		g=103
						"101" when "01010101",	--U=101		U=85
						"101" when "01110101",	--u=101		u=117
						"011" when "01011111",	--_=011		_=95
						--"011" when "01101110",	--n=011		n=110
						--"011" when "01001110",	--N=011		N=78
						"000" when others;		--nada=000
					
	sADN1mux	<=	sFifoDataOut(3 downto 1) when ssFifoEmpty = '0' else	(others => '0');
	sADN2mux	<=	sFifoDataOut(6 downto 4) when ssFifoEmpty = '0' else	(others => '0');
	--oADN1	<=	sFifoDataOut(3 downto 1);
	--oADN2	<=	sFifoDataOut(6 downto 4);
	oADN1	<=	rADN1mux;
	oADN2	<=	rADN2mux;
	
	oEmpty	<=	sFifoEmpty;--sFifoEmptyDelay;--ssFifoEmpty;
	oFinalPacket	<=	sFinalPacket;
	
	--dout_Ready	<=	not sFifoFull and iAdquirir;
	dout_Ready	<=	not sFifoFull;
	
end rtl;

