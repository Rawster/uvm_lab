`timescale 1ns / 10ps

module controller (
    input  bit clk, rstn,
    input  bit valid,
    output logic ready,
    input  bit [7:0] d_in,
    input  bit [23:0] d_in_address,
    output logic [7:0] d_out,
    output logic si, ceb =1, wpb, holdb,
    output logic sck = 0,
    input  bit so 
);
    assign wpb   = 1'b1; 
    assign holdb = 1'b1; 


    logic phase_clk;
    logic [2:0] count;        
    logic [5:0] count_address;   


    typedef enum logic [2:0] {IDLE, COMMAND_TRANSMIT, ADDRESS_TRANSMIT, RECEIVE, FINISH} state_5;
    state_5 state = IDLE;

    assign ready = (state == IDLE);

    
    always_ff @(posedge clk, negedge rstn) begin
        
        if (!rstn) begin
            ceb <= 1;
            state <= IDLE;
            count <= 7;
            count_address <= 23;
            sck <= 0;
        end
        
        else begin

            case (state)

                IDLE: begin
                    ceb   <= 1;

                    if (valid) begin
                        state <= COMMAND_TRANSMIT;
                        ceb   <= 0;    
                        phase_clk <= 0;    
                        count <= 7;
                        count_address <= 23;
                    end
                end

                COMMAND_TRANSMIT: begin
                    
                    if(phase_clk == 0) begin
                        
                        si <= d_in[count];
                        phase_clk <= 1;
                        sck <= 0;

                    end

                    else begin

                        phase_clk <= 0;
                        sck <= 1;

                        if(count == 0) begin

                            count <= 7;

                            if (d_in == 8'h03) begin
                                state <= ADDRESS_TRANSMIT;
                            end

                            else begin
                                state <= RECEIVE;
                                
                            end 

                        end
                        else count <= count - 1;

                    end
                    
                end

                ADDRESS_TRANSMIT: begin

                    if(phase_clk == 0) begin
                        
                        si <= d_in_address[count_address];
                        phase_clk <= 1;
                        sck <= 0;


                    end

                    else begin
                        phase_clk <= 0;
                        sck <= 1;

                        if(count_address == 0) begin

                            count_address <= 23;
                            state <= RECEIVE;

                        end
                        else count_address <= count_address - 1;

                    end
                    
                end
    

                RECEIVE: begin
                
                    if(phase_clk == 0) begin
                        
                        phase_clk <= 1;
                        sck <= 0;

                    end

                    else begin

                        phase_clk <= 0;
                        sck <= 1;
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
                    phase_clk <= 0;
                    sck <= 1;
                    state <= IDLE;

                end

                
                default: 
                    state <= IDLE;
            endcase

        end


    end

    
endmodule