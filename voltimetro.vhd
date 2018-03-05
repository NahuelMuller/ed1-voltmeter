-------------------------------------------------
-- Voltimetro	(voltimetro)
--
-- Descripcion:	Voltimetro implementado
--				en vhdl para la placa
--				Spartan-3E Starter Kit de Xilinx
--
-- Autor:		Nahuel Müller
-------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity voltimetro is

	port(
		volt_in_p, volt_in_n, sys_clk, sys_rst: in std_logic;
		volt_fb, vga_hsync, vga_vsync, vga_red, vga_green, vga_blue: out std_logic
	);

	-- Mapeo de pines Spartan-3E Starter Kit
	attribute loc: string;
	attribute slew: string;
	attribute drive: string;
	attribute iostandard: string;

	attribute loc of sys_clk: signal is "C9";		-- CLK_50MHZ
	attribute loc of sys_rst: signal is "L13";		-- SW0

	-- Entradas diferenciales
	attribute iostandard of volt_in_p: signal is "LVDS_25";	
	attribute loc of volt_in_p: signal is "A4";
	attribute iostandard of volt_in_n: signal is "LVDS_25";	
	attribute loc of volt_in_n: signal is "B4";

	-- Salida realimentacion
	attribute loc of volt_fb: signal is "C5";
	attribute slew of volt_fb: signal is "FAST";
	attribute drive of volt_fb: signal is "8";
	attribute iostandard of volt_fb: signal is "LVCMOS25";

	-- VGA
	attribute loc of vga_hsync: signal is "F15";	-- VGA_HSYNC
	attribute loc of vga_vsync: signal is "F14";	-- VGA_VSYNC
	attribute loc of vga_red: signal is "H14";		-- VGA_RED
	attribute loc of vga_green: signal is "H15";	-- VGA_GREEN
	attribute loc of vga_blue: signal is "G15";		-- VGA_BLUE

end entity;

architecture voltimetro_arq of voltimetro is

	component IBUFDS
		port(
			I, IB: in std_logic;
			O: out std_logic
		);
	end component;

	signal volt_in_diff: std_logic;

	component ffd is
		port(
			D, clk, rst, ena: in std_logic;
			Q: out std_logic
		);
	end component;

	signal delta_sigma_out: std_logic;

	component cont_3330 is
		port(
			clk, rst: in std_logic;
			c3329, c3330: out std_logic
		);
	end component;

	signal write_reg, reset_bcd: std_logic;

	component cont_bcd_4 is
		port(
			clk, rst, ena: in std_logic;
			bcd_out_0, bcd_out_1, bcd_out_2: out std_logic_vector(3 downto 0)
		);
	end component;

	signal bcd_out_0, bcd_out_1, bcd_out_2: std_logic_vector(3 downto 0);

	component reg_bcd_4 is
		port(
			reg_in_0, reg_in_1, reg_in_2: in std_logic_vector(3 downto 0);
			clk, rst, write_ena: in std_logic;
			reg_out_0, reg_out_1, reg_out_2: out std_logic_vector(3 downto 0)
		);
	end component;

	signal reg_out_0, reg_out_1, reg_out_2: std_logic_vector(3 downto 0);

	signal mux_sel_x: std_logic_vector(2 downto 0);
	signal mux_sel_y: std_logic_vector(1 downto 0);

	component char_mux is
		port(
			dig_0, dig_1, dig_2: in std_logic_vector(3 downto 0);
			mux_sel_x: in std_logic_vector(2 downto 0);
			mux_sel_y: in std_logic_vector(1 downto 0);
			mux_out: out std_logic_vector(3 downto 0)
		);
	end component;

	signal mux_out: std_logic_vector(3 downto 0);

	signal sel_x, sel_y: std_logic_vector(2 downto 0);

	component rom_deco is
		port(
			digito: in std_logic_vector(3 downto 0);
			sel_x, sel_y: in std_logic_vector(2 downto 0);
			fila: out integer range 0 to 103;
			columna: out integer range 0 to 7
		);
	end component;

	signal fila: integer range 0 to 103;
	signal columna: integer range 0 to 7;

	component rom_char is
		port(
			fila: in integer range 0 to 103; 
			columna: in integer range 0 to 7;
			mem_out: out std_logic
		);
	end component;

	signal mem_out: std_logic;

	component vga_ctrl is
		port (
			clk: in std_logic;
			red_i: in std_logic;
			grn_i: in std_logic;
			blu_i: in std_logic;
			hs: out std_logic;
			vs: out std_logic;
			red_o: out std_logic;
			grn_o: out std_logic;
			blu_o: out std_logic;
			pixel_x: out std_logic_vector(9 downto 0);
			pixel_y: out std_logic_vector(9 downto 0)
		);
	end component;

	signal pixel_x, pixel_y: std_logic_vector(9 downto 0);

	signal cont: integer := 0;

begin

	ibufdsx: IBUFDS	-- Primitive: Differential Signaling Input Buffer
		port map (volt_in_p, volt_in_n, volt_in_diff);

	ffdx: ffd	-- Delta Sigma ADC
		port map (volt_in_diff, sys_clk, sys_rst, '1', delta_sigma_out);

	volt_fb <= delta_sigma_out;

	cont_3330x: cont_3330	-- Contador 3329/3330
		port map (sys_clk, sys_rst, write_reg, reset_bcd);

	cont_bcd_4x: cont_bcd_4		-- Contador de 4 digitos BCD
		port map (sys_clk, reset_bcd, delta_sigma_out, bcd_out_0, bcd_out_1, bcd_out_2);

	reg_bcd_4x: reg_bcd_4	-- Registro de 4 digitos BCD
		port map (bcd_out_0, bcd_out_1, bcd_out_2, sys_clk, sys_rst, write_reg, reg_out_0, reg_out_1, reg_out_2);

	mux_sel_x <= pixel_x(9) & pixel_x(8) & pixel_x(7);
	mux_sel_y <= pixel_y(8) & pixel_y(7);

	char_muxx: char_mux		-- Seleccion del digito en base a la posicion en pantalla
		port map (reg_out_0, reg_out_1, reg_out_2, mux_sel_x, mux_sel_y, mux_out);

	sel_x <= pixel_x(6) & pixel_x(5) & pixel_x(4);
	sel_y <= pixel_y(6) & pixel_y(5) & pixel_y(4);

	rom_decox: rom_deco		-- Busqueda en memoria del valor del pixel
		port map (mux_out, sel_x, sel_y, fila, columna);

	rom_charx: rom_char		-- Valores de pixel ordenados por caracter
		port map (fila, columna, mem_out);

	vga_ctrlx: vga_ctrl		-- Controladora VGA
		port map (sys_clk, mem_out, mem_out, '1', vga_hsync, vga_vsync, vga_red, vga_green, vga_blue, pixel_x, pixel_y);

end architecture;