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
						sdout_Data(103 downto 96) & sdout_Data(111 downto 104) & sdout_Data(119 downto 112) & sdout_Data(127 downto 120) &
						
						sdout_Data(135 downto 128) & sdout_Data(143 downto 136) & sdout_Data(151 downto 144) & sdout_Data(159 downto 152) &
						sdout_Data(167 downto 160) & sdout_Data(175 downto 168) & sdout_Data(183 downto 176) & sdout_Data(191 downto 184) &
						sdout_Data(199 downto 192) & sdout_Data(207 downto 200) & sdout_Data(215 downto 208) & sdout_Data(223 downto 216) &
						sdout_Data(231 downto 224) & sdout_Data(239 downto 232) & sdout_Data(247 downto 240) & sdout_Data(255 downto 248) &
						
						sdout_Data(263 downto 256) & sdout_Data(271 downto 264) & sdout_Data(279 downto 272) & sdout_Data(287 downto 280) &
						sdout_Data(295 downto 288) & sdout_Data(303 downto 296) & sdout_Data(311 downto 304) & sdout_Data(319 downto 312) &
						sdout_Data(327 downto 320) & sdout_Data(335 downto 328) & sdout_Data(343 downto 336) & sdout_Data(351 downto 344) &
						sdout_Data(359 downto 352) & sdout_Data(367 downto 360) & sdout_Data(375 downto 368) & sdout_Data(383 downto 376) &
						
						sdout_Data(391 downto 384) & sdout_Data(399 downto 392) & sdout_Data(407 downto 400) & sdout_Data(415 downto 408) &
						sdout_Data(423 downto 416) & sdout_Data(431 downto 424) & sdout_Data(439 downto 432) & sdout_Data(447 downto 440) &
						sdout_Data(455 downto 448) & sdout_Data(463 downto 456) & sdout_Data(471 downto 464) & sdout_Data(479 downto 472) &
						sdout_Data(487 downto 480) & sdout_Data(495 downto 488) & sdout_Data(503 downto 496) & sdout_Data(511 downto 504) &
						
						
						sdout_Data(519 downto 512) & sdout_Data(527 downto 520) & sdout_Data(535 downto 528) & sdout_Data(543 downto 536) &
						sdout_Data(551	downto 544) & sdout_Data(559 downto 552) & sdout_Data(567 downto 560) & sdout_Data(575 downto 568) &
						sdout_Data(583 downto 576) & sdout_Data(591 downto 584) & sdout_Data(599 downto 592) & sdout_Data(607 downto 600) &
						sdout_Data(615 downto 608) & sdout_Data(623 downto 616) & sdout_Data(631 downto 624) & sdout_Data(639 downto 632) &
						
						sdout_Data(647 downto 640) & sdout_Data(655 downto 648) & sdout_Data(663 downto 656) & sdout_Data(671 downto 664) &
						sdout_Data(679 downto 672) & sdout_Data(687 downto 680) & sdout_Data(695 downto 688) & sdout_Data(703 downto 696) &
						sdout_Data(711 downto 704) & sdout_Data(719 downto 712) & sdout_Data(727 downto 720) & sdout_Data(735 downto 728) &
						sdout_Data(743 downto 736) & sdout_Data(751 downto 744) & sdout_Data(759 downto 752) & sdout_Data(767 downto 760) &
						
						sdout_Data(775 downto 768) & sdout_Data(783 downto 776) & sdout_Data(791 downto 784) & sdout_Data(799 downto 792) &
						sdout_Data(807 downto 800) & sdout_Data(815 downto 808) & sdout_Data(823 downto 816) & sdout_Data(831 downto 824) &
						sdout_Data(839 downto 832) & sdout_Data(847 downto 840) & sdout_Data(855 downto 848) & sdout_Data(863 downto 856) &
						sdout_Data(871 downto 864) & sdout_Data(879 downto 872) & sdout_Data(887 downto 880) & sdout_Data(895 downto 888) &
						
						sdout_Data(903 downto 896) & sdout_Data(911 downto 904) & sdout_Data(919 downto 912) & sdout_Data(927 downto 920) &
						sdout_Data(935 downto 928) & sdout_Data(943 downto 936) & sdout_Data(951 downto 944) & sdout_Data(959 downto 952) &
						sdout_Data(967 downto 960) & sdout_Data(975 downto 968) & sdout_Data(983 downto 976) & sdout_Data(991 downto 984) &
						sdout_Data(999 downto 992) & sdout_Data(1007 downto 1000) & sdout_Data(1015 downto 1008) & sdout_Data(1023 downto 1016);
						
	--dout_Data	<=	sdout_Data when iSendDirection = '0' else
		--				(others => iDirection);

end rtl;
