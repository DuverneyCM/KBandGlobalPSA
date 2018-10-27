library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_signed.all;

entity pipelineKBandMod is
	generic(
		dimH		: 	natural  :=	8;
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
		iArrow		:	in std_logic_vector(1 downto 0);
		iHGDiagEqual:	in std_logic;
		iCero			:	in	std_logic;
		iFinish		:	in	std_logic;
		-- Output ports
		oADNa			:	out std_logic_vector(dimADN-1 downto 0);
		oADNb			:	out std_logic_vector(dimADN-1 downto 0);
		oH1			:	out std_logic_vector(dimH-1 downto 0);
		oH2			:	out std_logic_vector(dimH-1 downto 0);
		oArrow		:	out std_logic_vector(1 downto 0)
	);
end pipelineKBandMod;


architecture rtl of pipelineKBandMod is
signal	sH1, sH1mux, sH2		:	std_logic_vector(dimH-1 downto 0);
signal	sArrow		:	std_logic_vector(1 downto 0);
signal	clearH2, sHGDiagEqual		:	std_logic;
begin
	process(reset, CLOCK_50) is
	begin
		if(reset = '1') then
			oADNa		<= (others => '0');
			oADNb		<= (others => '0');
			sH1		<= (others => '0');
			sH2		<= (others => '0');
			sArrow	<= (others => '0');
			sHGDiagEqual	<=	'0';
		elsif(rising_edge(CLOCK_50)) then
			if (inDireccion = '0' AND iEnable = '1') then
				oADNa		<= iADNa;
			end if;
			if (inDireccion = '1' AND iEnable = '1') then
				oADNb		<= iADNb;
			end if;
			if (iEnable = '1') then
				--registros de desplazamiento para aminoH y aminoV, cargan de forma alternada
--				if (inDireccion = '0') then
--					oADNa		<= iADNa;
--				else
--					oADNb		<= iADNb;
--				end if;

				--reset del bit N (resta de 2^N) cuando dicho bit sea 1 en todo el componente
				sH2		<= sH1mux;
				sH1		<= iH;
				--oH2(dimH-1 downto 0)		<= sH1(dimH-1 downto 0);

				sArrow	<= iArrow;
				sHGDiagEqual	<=	iHGDiagEqual;
			end if;
		end if;
		if (clearH2 = '1') then
			sH1mux	<= (others => '0');
		else
			sH1mux	<= sH1;
		end if;
	end process;
	clearH2		<=	iCero or iFinish;
	oArrow		<= (others => '0') when sHGDiagEqual = '1' and clearH2 = '0' else sArrow;
	oH1	<=	sH1mux; --sH1
	oH2	<=	sH2;
end rtl;
