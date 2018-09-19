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
		-- Output ports
		oADNa			:	out std_logic_vector(dimADN-1 downto 0);
		oADNb			:	out std_logic_vector(dimADN-1 downto 0);
		oH1			:	out std_logic_vector(dimH-1 downto 0);
		oH2			:	out std_logic_vector(dimH-1 downto 0);
		oArrow		:	out std_logic_vector(1 downto 0)
	);
end pipelineKBandMod;


architecture rtl of pipelineKBandMod is
signal	sH1		:	std_logic_vector(dimH-1 downto 0);
begin
	process(reset, CLOCK_50) is 
	begin 
		if(reset = '1') then
			oADNa		<= (others => '0');
			oADNb		<= (others => '0');
			sH1		<= (others => '0');
			oH2		<= (others => '0');
			oArrow	<= (others => '0');
		elsif(rising_edge(CLOCK_50)) then
			if (iEnable = '1') then
				--registros de desplazamiento para aminoH y aminoV, cargan de forma alternada
				if (inDireccion = '0') then
					oADNa		<= iADNa;
				else
					oADNb		<= iADNb;
				end if;
				
				--reset del bit N (resta de 2^N) cuando dicho bit sea 1 en todo el componente
				sH1(dimH-1 downto 0)		<= iH(dimH-1 downto 0);
				oH2(dimH-1 downto 0)		<= sH1(dimH-1 downto 0);
				
				oArrow	<= iArrow;
			end if;
		end if;
	end process;
	oH1	<=	sH1;
end rtl;