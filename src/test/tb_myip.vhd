library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library vunit_lib;
context vunit_lib.vunit_context;
context vunit_lib.vc_context;

 use work.axil_pkg.all;
 use work.axi_pkg.all;
-- use work.axi_lite_master_pkg.all;

entity tb_myip is
    generic (runner_cfg : string);
end entity tb_myip;

architecture tb of tb_myip is

    constant clk_period : time := 1 ns;

    constant axil_bus : bus_master_t := new_bus(data_length => 32,
                                                address_length => 4,
                                                logger => get_logger("axil_bus"));


    signal clk      : std_logic := '0';                                                
    signal axil_m2s : axil_m2s_t := axil_m2s_init;
    signal axil_s2m : axil_s2m_t;
    signal aresetn	: std_logic:='0';
    signal awprot   : std_logic_vector(2 downto 0):="000";
    signal arprot   : std_logic_vector(2 downto 0):="000";
    signal address  : std_logic_vector(3 downto 0);
    signal data     : std_logic_vector(31 downto 0);
    signal expected_bresp : std_logic_vector(1 downto 0);
    signal byte_enable : std_logic_vector(3 downto 0) := "1111";

    component myip_v1_0 is
        generic (

            C_S00_AXI_DATA_WIDTH	: integer	:= 32;
            C_S00_AXI_ADDR_WIDTH	: integer	:= 4
        );
        port (

            s00_axi_aclk	: in std_logic;
            s00_axi_aresetn	: in std_logic;
            s00_axi_awaddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
            s00_axi_awprot	: in std_logic_vector(2 downto 0);
            s00_axi_awvalid	: in std_logic;
            s00_axi_awready	: out std_logic;
            s00_axi_wdata	: in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
            s00_axi_wstrb	: in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
            s00_axi_wvalid	: in std_logic;
            s00_axi_wready	: out std_logic;
            s00_axi_bresp	: out std_logic_vector(1 downto 0);
            s00_axi_bvalid	: out std_logic;
            s00_axi_bready	: in std_logic;
            s00_axi_araddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
            s00_axi_arprot	: in std_logic_vector(2 downto 0);
            s00_axi_arvalid	: in std_logic;
            s00_axi_arready	: out std_logic;
            s00_axi_rdata	: out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
            s00_axi_rresp	: out std_logic_vector(1 downto 0);
            s00_axi_rvalid	: out std_logic;
            s00_axi_rready	: in std_logic
        );
    end component;

begin
    
    dut: myip_v1_0 
    generic map(
        C_S00_AXI_DATA_WIDTH => 32,
        C_S00_AXI_ADDR_WIDTH => 4
    )
    port map (
        s00_axi_aclk	=> clk,
        s00_axi_aresetn	=> aresetn,
        s00_axi_awaddr	=> axil_m2s.aw.addr,
        s00_axi_awprot	=> awprot,
        s00_axi_awvalid	=> axil_m2s.aw.valid,
        s00_axi_awready	=> axil_s2m.aw.ready,
        s00_axi_wdata	=> axil_m2s.w.data,
        s00_axi_wstrb	=> axil_m2s.w.strb,
        s00_axi_wvalid	=> axil_m2s.w.valid,
        s00_axi_wready	=> axil_s2m.w.ready,
        s00_axi_bresp	=> axil_s2m.b.resp,
        s00_axi_bvalid	=> axil_s2m.b.valid,
        s00_axi_bready	=> axil_m2s.b.ready,
        s00_axi_araddr	=> axil_m2s.ar.addr,
        s00_axi_arprot	=> arprot,
        s00_axi_arvalid	=> axil_m2s.ar.valid,
        s00_axi_arready	=> axil_s2m.ar.ready,
        s00_axi_rdata	=> axil_s2m.r.data,
        s00_axi_rresp	=> axil_s2m.r.resp,
        s00_axi_rvalid	=> axil_s2m.r.valid,
        s00_axi_rready	=> axil_m2s.r.ready

    );


    axi_lite_master_inst: entity vunit_lib.axi_lite_master
    generic map (
      bus_handle => axil_bus)
    port map (
      aclk    => clk,
      arready => axil_s2m.ar.ready,
      arvalid => axil_m2s.ar.valid,
      araddr  => axil_m2s.ar.addr,
      rready  => axil_m2s.r.ready,
      rvalid  => axil_s2m.r.valid,
      rdata   => axil_s2m.r.data,
      rresp   => axil_s2m.r.resp,
      awready => axil_s2m.aw.ready,
      awvalid => axil_m2s.aw.valid,
      awaddr  => axil_m2s.aw.addr,
      wready  => axil_s2m.w.ready,
      wvalid  => axil_m2s.w.valid,
      wdata   => axil_m2s.w.data,
      wstrb   => axil_m2s.w.strb,
      bvalid  => axil_s2m.b.valid,
      bready  => axil_m2s.b.ready,
      bresp   => axil_s2m.b.resp);    
      
    clk <= not clk after clk_period/2;

    process
    begin
        test_runner_setup(runner, runner_cfg);
            if run("Perform simple transfers") then
            address <= "0100";
            data <= x"01010101";
            expected_bresp <="00";

            write_axi_lite(net, axil_bus, address, data, expected_bresp, byte_enable);        
            --write_bus(net, axil_bus, address, data, byte_enable);           
        end if;            
        test_runner_cleanup(runner);
    end process;
    
end architecture tb;
