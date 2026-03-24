module dut (
    input bit clk,
    input bit rstn
);
    // Twoja logika projektowa, np.:
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            // logika resetu
        end else begin
            // logika pracy
        end
    end
endmodule