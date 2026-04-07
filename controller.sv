`timescale 1ns / 10ps

module controller (
    input  bit clk, rstn,
    input  bit valid,
    output logic ready,
    input  bit [7:0] d_in,
    input  bit [23:0] d_in_address,
    input  bit [7:0] d_in_data,
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


    typedef enum logic [2:0] {IDLE, COMMAND_TRANSMIT, ADDRESS_TRANSMIT, ADDRESS_TRANSMIT_PURGE, RECEIVE, WRITE, FINISH} state_5;
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
                //wait for command
                IDLE: begin
                    ceb   <= 0;
                    
                    if (valid) begin
                        state <= COMMAND_TRANSMIT;    
                        phase_clk <= 0;    
                        count <= 7;
                        count_address <= 23;
                    end
                end
                //receive command
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
                            count_address <= 23;

                            case (d_in)
                                8'h03, 8'h02: state <= ADDRESS_TRANSMIT;       
                                8'h06:        state <= FINISH;                 
                                8'h20:        state <= ADDRESS_TRANSMIT_PURGE; 
                                default:      state <= RECEIVE;                
                            endcase
                        end
                        else count <= count - 1;

                    end
                    
                end
                //transmiting address to read from or write to
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
                            
                            if(d_in == 8'h02) begin
                                state <= WRITE;
                            end

                            else begin
                                state <= RECEIVE;
                            end

                            count_address <= 23;
                            count <=7 ;


                        end
                        else count_address <= count_address - 1;

                    end
                    
                end

                //transmiting address to purge or write
                ADDRESS_TRANSMIT_PURGE: begin

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
                            state <= FINISH;

                        end
                        else count_address <= count_address - 1;

                    end
                    
                end
    
                //receiving data
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

                WRITE: begin

                    if(phase_clk == 0) begin
                        
                        si <= d_in_data[count];
                        phase_clk <= 1;
                        sck <= 0;

                    end

                    else begin

                        phase_clk <= 0;
                        sck <= 1;

                        if(count == 0) begin

                            count <= 7;
                            state <= FINISH;


                        end
                    
                        else count <= count - 1;
                    end
                end
                //last clock cycle, reset
                FINISH: begin

                    ceb <= 1;
                    phase_clk <= 0;
                    sck <= 0;
                    state <= IDLE;

                end

                
                default: 
                    state <= IDLE;
            endcase

        end


    end

    
endmodule