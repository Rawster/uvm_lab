`timescale 1ns / 10ps

module controller (
    input  bit clk, rstn,
    input  bit valid,
    output logic ready,
    input  bit [7:0] d_in,
    output logic [7:0] d_out,
    output logic sck, si, ceb, wpb, holdb,
    input  bit so
);
    assign wpb   = 1'b1; 
    assign holdb = 1'b1; 


    logic phase_clk;        
    logic [2:0] count;    


    typedef enum logic [2:0] {IDLE, TRANSMIT, RECEIVE, FINISH} state_3;
    state_3 state;

    assign ready = (state == IDLE);
    
    always_ff @(posedge clk, negedge rstn) begin
 
        if (!rstn) begin
            sck <= 0;
            ceb <= 1;
            state <= IDLE;
            count <= 7;
        end
        
        else begin

            case (state)

                IDLE: begin
                    ceb   <= 1;
                    sck   <= 0;
                    if (valid) begin
                        state <= TRANSMIT;
                        ceb   <= 0;    
                        phase_clk <= 0;    
                        count <= 7;
                    end
                end

                TRANSMIT: begin
                    
                    if(phase_clk == 0) begin
                        
                        si <= d_in[count];
                        phase_clk <= 1;
                        sck <= 0;

                    end

                    else begin

                        sck <= 1;
                        phase_clk <= 0;

                        if(count == 0) begin

                            state <= RECEIVE;
                            count <= 7;

                        end
                        else count <= count - 1;

                    end
                    
                end    

                RECEIVE: begin
                
                    if(phase_clk == 0) begin
                        
                        phase_clk <= 1;
                        sck <= 0;

                    end

                    else begin

                        sck <= 1;
                        phase_clk <= 0;
                        d_out[count] <= so;

                        if(count == 0) begin

                            state <= FINISH;
                            count <= 7;

                        end
                        else count <= count - 1;

                    end    


                end

                FINISH: begin

                    ceb <= 1;
                    sck <= 0;
                    phase_clk <= 0;
                    state <= IDLE;

                end

                
                default: 
                    state <= IDLE;
            endcase

        end


    end

    
endmodule