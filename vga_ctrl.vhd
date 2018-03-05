-------------------------------------------------
-- Controlador VGA	(vga_ctrl)
--
-- Descripcion:	Modulo controlador VGA
--				implementado utilizando
--				programacion estructural
--
-- Autor:		Nahuel Müller
-------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity vga_ctrl is
	port (
		clk: in std_logic;		-- reloj del sistema (50 MHz)
		red_i: in std_logic;	-- entrada comandada por uno de los switches del kit
		grn_i: in std_logic;	-- entrada comandada por uno de los switches del kit
		blu_i: in std_logic;	-- entrada comandada por uno de los switches del kit
		hs: out std_logic;		-- sincronismo horizontal
		vs: out std_logic;		-- sincronismo vertical
		red_o: out std_logic;	-- salida de color rojo	
		grn_o: out std_logic;	-- salida de color verde
		blu_o: out std_logic;	-- salida de color azul
		pixel_x: out std_logic_vector(9 downto 0);	--	posición horizontal del pixel en la pantalla
		pixel_y: out std_logic_vector(9 downto 0)	--	posición vertical del pixel en la pantalla
	);
end entity;

architecture vga_ctrl_arq of vga_ctrl is

	constant hpixels: unsigned(9 downto 0) := to_unsigned(800, 10);	-- Número de pixeles en una linea horizontal (800, "1100100000")
	constant vlines: unsigned(9 downto 0) := to_unsigned(521, 10);	-- Número de lineas horizontales en el display (521, "1000001001")

	constant hpw: natural := 96; 									-- Ancho del pulso de sincronismo horizontal [pixeles]
	constant hbp: unsigned(7 downto 0) := to_unsigned(144, 8);		-- Back porch horizontal (144, "0010010000")
	constant hfp: unsigned(9 downto 0) := to_unsigned(784, 10);	 	-- Front porch horizontal (784, "1100010000")

	constant vpw: natural := 2; 									-- Ancho del pulso de sincronismo vertical [líneas]
	constant vbp: unsigned(9 downto 0) := to_unsigned(31, 10);	 	-- Back porch vertical (31, "0000011111")
	constant vfp: unsigned(9 downto 0) := to_unsigned(511, 10);		-- Front porch vertical (511, "0111111111")

	signal hc, vc: std_logic_vector(9 downto 0);					-- Contadores (horizontal y vertical)
	signal clkdiv_flag: std_logic;      							-- Flag para obtener una habilitación cada dos ciclos de clock
	signal vidon: std_logic;										-- Habilitar la visualización de datos
	signal vsenable: std_logic;										-- Habilita el contador vertical

	component ffd is
		port(
			D, clk, rst, ena: in std_logic;
			Q: out std_logic
		);
	end component;

	component cont_bN is	-- Contador binario de N bits
		generic (N : natural);
		port(
			clk, rst, ena: in std_logic;
			cont_out: out std_logic_vector(N-1 downto 0);
			carry: out std_logic
		);
	end component;

	signal D_aux, rst_H, rst_V: std_logic;

	component mux_2x1 is
		port(
			mux_x, mux_y, mux_sel: in std_logic;
			mux_out: out std_logic
		);
	end component;

	signal aux_pixel_x, aux_pixel_y: std_logic_vector(9 downto 0);

begin
	-- Generación de la señal de habilitación para dividir el clock de 50Mhz a la mitad
	ffdx: ffd				-- Flip flop D para dividir el clock (50 -> 25 MHz)
		port map (D_aux, clk, '0', '1', clkdiv_flag);
	D_aux <= not clkdiv_flag;

	-- Contador Horizontal
	cont_bNx_H: cont_bN
		generic map (10)
		port map (clk, rst_H, clkdiv_flag, hc);
	-- rst_H <= '1' when (unsigned(hc) = hpixels) else '0';
	rst_H <= hc(9) and hc(8) and hc(5);							-- hpixels = 1100100000
	-- vsenable <= '1' when (unsigned(hc) = hpixels) else '0';
	vsenable <= hc(9) and hc(8) and hc(5);						-- hpixels = 1100100000

	-- Contador Vertical
	cont_bNx_V: cont_bN
		generic map (10)
		port map (clk, rst_V, vsenable, vc);
	-- rst_V <= '1' when (unsigned(vc) = vlines) else '0';
	rst_V <= vc(9) and vc(3) and vc(0);							-- vlines = "1000001001"


	-- Generación de señales de sincronismo horizontal y vertical
	-- hs <= '1' when (unsigned(hc) <= hpw) else '0';
	hs <= not(hc(9) or hc(8) or hc(7) or (hc(6) and hc(5) and (hc(4) or hc(3) or hc(2) or hc(1) or hc(0))));
	-- vs <= '1' when (unsigned(vc) <= vpw) else '0';
	vs <= not(vc(9) or vc(8) or vc(7) or vc(6) or vc(5) or vc(4) or vc(3) or vc(2) or (vc(1) and vc(0)));

	-- Ubicación dentro de la pantalla
	-- pixel_x <= std_logic_vector(unsigned(hc) - hbp) when (vidon = '1') else hc;
	-- pixel_y <= std_logic_vector(unsigned(vc) - vbp) when (vidon = '1') else vc;
	aux_pixel_x <= std_logic_vector(unsigned(hc) - hbp);
	aux_pixel_y <= std_logic_vector(unsigned(vc) - vbp);

	GEN_mux_2x1:
	for I in 0 to 9 generate

		mux_2x1_pixel_x: mux_2x1
				port map (hc(I), aux_pixel_x(I), vidon, pixel_x(I));
		mux_2x1_pixel_y: mux_2x1
				port map (vc(I), aux_pixel_y(I), vidon, pixel_y(I));

	end generate;

	-- Señal de habilitación para la salida de datos por el display
	-- vidon <= '1' when (((hfp > unsigned(hc)) and (unsigned(hc) > hbp)) and ((vfp > unsigned(vc)) and (unsigned(vc) > vbp))) else '0';

	vidon <= ((hc(9) or hc(8) or (hc(7) and (hc(6) or hc(5) or (hc(4) and (hc(3) or hc(2) or hc(1) or hc(0))))))	-- hbp < hc
			and (not hc(9) or not hc(8) or (not hc(7) and not hc(6) and not hc(5) and not hc(4))))					-- hc < hfp
			and
			((vc(9) or vc(8) or vc(7) or vc(6) or vc(5))	-- vbp < vc
			and (not vc(9) and not (vc(8) and vc(7) and vc(6) and vc(5) and vc(4) and vc(3) and vc(2) and vc(1) and vc(0))));	-- vc < vfp

	-- red_o <= '1' when (red_i = '1' and vidon = '1') else '0';
	red_o <= red_i and vidon;									-- Pinta la pantalla del color formado
	-- grn_o <= '1' when (grn_i = '1' and vidon = '1') else '0';
	grn_o <= grn_i and vidon;									-- por la combinación de las entradas
	-- blu_o <= '1' when (blu_i = '1' and vidon = '1') else '0';
	blu_o <= blu_i and vidon;									-- red_i, grn_i y blu_i (switches)

end architecture;