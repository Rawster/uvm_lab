`timescale 1ns / 10ps

module controller (
    input  bit clk, rstn,
    input  bit valid,
    output logic ready,
    input  bit [7:0] d_in,
    input  bit [23:0] d_in_address,
    input  bit [7:0] burst_len,             
    input  bit [7:0] d_in_data_arr [0:255], 
    output logic [7:0] d_out_arr [0:255],   
    output logic si, ceb =1, wpb, holdb,
    output logic sck = 0,
    input  bit so 
);
    localparam WRITE_COMMAND = 8'h02;
    localparam READ_COMMAND = 8'h03;
    localparam READ_REGISTER_COMMAND = 8'h05;
    localparam PURGE_COMMAND = 8'h20;
    localparam READ_MANUFACTURER_COMMAND = 8'h9F;
    localparam ENABLE_WRITE_COMMAND = 8'h06;

    assign wpb   = 1'b1; 
    assign holdb = 1'b1; 

    logic phase_clk;
    logic [2:0] count;        
    logic [5:0] count_address;
    logic [7:0] byte_idx; 
      
    typedef enum logic [2:0] {IDLE, COMMAND_TRANSMIT, ADDRESS_TRANSMIT, ADDRESS_TRANSMIT_PURGE, RECEIVE, WRITE, FINISH} state_e;
    state_e state = IDLE;

    assign ready = (state == IDLE);

    always_ff @(posedge clk, negedge rstn) begin
        if (!rstn) begin
            ceb <= 1;
            state <= IDLE;
            count <= 7;
            count_address <= 23;
            sck <= 0;
            byte_idx <= 0;
        end
        else begin
            case (state)
                IDLE: begin
                    ceb   <= 0;
                    if (valid) begin
                        state <= COMMAND_TRANSMIT;
                        phase_clk <= 0;    
                        count <= 7;
                        count_address <= 23;
                        byte_idx <= 0; 
                    end
                end
                
                COMMAND_TRANSMIT: begin
                    if(phase_clk == 0) begin
                        si <= d_in[count];
                        phase_clk <= 1;
                        sck <= 0;
                    end else begin
                        phase_clk <= 0;
                        sck <= 1;
                        if(count == 0) begin
                            count <= 7;
                            count_address <= 23;
                            case (d_in)
                               
                                READ_COMMAND, WRITE_COMMAND: state <= ADDRESS_TRANSMIT;
                                ENABLE_WRITE_COMMAND:        state <= FINISH;
                                PURGE_COMMAND:               state <= ADDRESS_TRANSMIT_PURGE;
                                default:                     state <= RECEIVE;
                            endcase
                        end else count <= count - 1;
                    end
                end

                ADDRESS_TRANSMIT: begin
                    if(phase_clk == 0) begin
                        si <= d_in_address[count_address];
                        phase_clk <= 1;
                        sck <= 0;
                    end else begin
                        phase_clk <= 0;
                        sck <= 1;
                        if(count_address == 0) begin
                            
                            if(d_in == WRITE_COMMAND) state <= WRITE;
                            else state <= RECEIVE;
                            count_address <= 23;
                            count <= 7;
                        end else count_address <= count_address - 1;
                    end
                end

                ADDRESS_TRANSMIT_PURGE: begin
                    if(phase_clk == 0) begin
                        si <= d_in_address[count_address];
                        phase_clk <= 1;
                        sck <= 0;
                    end else begin
                        phase_clk <= 0;
                        sck <= 1;
                        if(count_address == 0) begin
                            count_address <= 23;
                            state <= FINISH;
                        end else count_address <= count_address - 1;
                    end
                end
    
                RECEIVE: begin
                    if(phase_clk == 0) begin
                        phase_clk <= 1;
                        sck <= 0;
                    end else begin
                        phase_clk <= 0;
                        sck <= 1;
                        
                        d_out_arr[byte_idx][count] <= so; 

                        if(count == 0) begin
                            count <= 7;
                            
                            if (byte_idx == burst_len) begin
                                state <= FINISH;
                            end else begin
                                byte_idx <= byte_idx + 1; 
                            end
                        end else count <= count - 1;
                    end    
                end

                WRITE: begin
                    if(phase_clk == 0) begin
                        si <= d_in_data_arr[byte_idx][count]; 
                        phase_clk <= 1;
                        sck <= 0;
                    end else begin
                        phase_clk <= 0;
                        sck <= 1;

                        if(count == 0) begin
                            count <= 7;
                            
                            if (byte_idx == burst_len) begin
                                state <= FINISH;
                            end else begin
                                byte_idx <= byte_idx + 1; 
                            end
                        end else count <= count - 1;
                    end
                end

                FINISH: begin
                    ceb <= 1;
                    phase_clk <= 0;
                    sck <= 0;
                    state <= IDLE;
                end
                
                default: state <= IDLE;
            endcase
        end
    end
endmodule