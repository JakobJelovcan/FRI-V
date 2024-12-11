`ifndef WB_REGISTERED
`define WB_MAX_RSP_DELAY 0
`endif

`ifndef WB_MAX_RSP_DELAY
`define WB_MAX_RSP_DELAY 3
`endif

// Input assumptions
`ifdef WB_SLAVE
always @(posedge i_clk) begin
    // Currently supported cycle types
    assume (i_wb_cti == 3'd0 || i_wb_cti == 3'd2 || i_wb_cti == 3'd7);

    assume ((i_wb_stb) ? i_wb_cyc : 1);
    assume ((!i_wb_cyc) ? !i_wb_stb : 1);


    if ($fell(i_rst)) begin
        assume (!i_wb_stb);
        assume (!i_wb_cyc);
    end else if (!i_rst) begin
        // stb and cyc have to remain high after a type 2 cycle
        assume (($past(i_wb_stb) && $past(i_wb_cti) == 'd2) ? $stable(i_wb_stb) : 1);

        // stb has to remain high until an ack or err is sent
        assume (($past(i_wb_stb) && !$past(o_wb_ack) && !$past(o_wb_err)) ? i_wb_stb : 1);

        // stb has to be set to low after the end of an transaction
        assume (($past(i_wb_stb) && ($past(i_wb_cti == 'd7) || $past(i_wb_cti == 'd0)) && ($past(o_wb_ack) || $past(o_wb_err))) ? !i_wb_stb : 1);
    end
end
`else
// TODO: Master
`endif

// Assert response delay
`ifdef WB_SLAVE
int wb_rsp_counter = 0;
always @(posedge i_clk) begin
    if (i_rst) begin
        wb_rsp_counter = 0;
    end else if (o_wb_ack || o_wb_err) begin
        wb_rsp_counter = 0;
    end else if (i_wb_stb) begin
        wb_rsp_counter = wb_rsp_counter + 1;
    end
    assert ((!i_wb_stb) ? wb_rsp_counter == 0 : 1);
    assert (wb_rsp_counter <= `WB_MAX_RSP_DELAY);
end
`endif

// Assert response
`ifdef WB_SLAVE
always @(posedge i_clk) begin
    if ($fell(i_rst)) begin
        assert (!(o_wb_ack || o_wb_err));
    end else if (!i_rst) begin
        assert (!(o_wb_ack && o_wb_err));
        assert ((!i_wb_stb) ? !(o_wb_ack || o_wb_err) : 1);
    end

end
`endif

// Cover
`ifdef WB_SLAVE
initial cover (o_wb_ack);

`ifdef WB_SUPPORTS_ERROR
initial cover (o_wb_err);
`endif

`else
// TODO: Master
`endif
