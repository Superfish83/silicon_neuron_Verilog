interface nim_if#(
    parameter NR_WIDTH = 56, 
    parameter NR_DEPTH = 16,
    parameter SR_WIDTH = 64,
    parameter SR_DEPTH = 16384
);

    logic freeze;
    logic spike_index;
    // Assumes time_index is controlled by the controller
    logic time_index;

    wire [NR_WIDTH-1:0] nr_read;
    wire [NR_WIDTH-1:0] nr_write;
    wire nr_we;
    // wire nr_oe,
    // wire nr_cs,
    wire [$clog2(NR_DEPTH)-1:0] nr_addr;

    wire [SR_WIDTH-1:0] sr_read;
    wire [SR_WIDTH-1:0] sr_write;
    wire sr_we;
    // wire sr_oe,
    // wire sr_cs,
    wire [$clog2(SR_DEPTH)-1:0] sr_addr;

    modport updater (
        input freeze, spike_index, time_index,
        input nr_read, 
        input sr_read, 
        output nr_write, nr_we, nr_addr,
        output sr_write, sr_we, sr_addr
    );

endinterface //nim_if

module neuron_input_module #(
    parameter NR_WIDTH = 56, 
    parameter NR_DEPTH = 16,
    parameter SR_WIDTH = 64,
    parameter SR_DEPTH = 16384
) (
    input logic clk,
    input logic reset,
    nim_if.updater nim_if_inst
);

    logic [SR_WIDTH-1:0] weights;
    logic [NR_WIDTH-1:0] neuron_in;
    logic [NR_WIDTH-1:0] neuron_out;

    // 0 - read, 1 - write
    logic phase;

    assign weights = nim_if_inst.sr_read;
    assign neuron_in = nim_if_inst.nr_read;
    assign neuron_out = nim_if_inst.nr_write;

    // SR
    assign nim_if_inst.sr_addr = nim_if_inst.spike_index;
    assign nim_if_inst.sr_we   = 1'b0;  // This is expected to be 0


    always_comb begin
        // TODO: Remove hardcoded accumulate_size(16)
        neuron_out = neuron_in;
        neuron_out[40 +: 16] = neuron_in[40 +: 16] + weights[0 +: 16];
    end

    // We will add one of the 16 neuron at a time,
    // so we don't really need this.
    //
    // comb logic
    // genvar i;
    // generate
    //     // Hard coded weight(4) - TODO: Make this configurable
    //     for (i = 0; i < NR_WIDTH / 4; i++) begin : gen_accumulate
    //         always_comb begin
    //             if (!nim_if_inst.freeze) begin
    //                 neuron_out[i*4 +: 16] = weights[i*4 +: 4];
    //             end 
    //         end
    //     end
    // endgenerate

    always_comb begin : bus_mux
        case (phase)
            0: begin // Read phase
                nim_if_inst.nr_addr = nim_if_inst.time_index;
                nim_if_inst.nr_we = 1'b0; // Read
            end
            1: begin // Write phase
                nim_if_inst.nr_addr = nim_if_inst.time_index;
                nim_if_inst.nr_write = neuron_out;
                nim_if_inst.nr_we = 1'b1; // Write
            end
            default: begin
                nim_if_inst.nr_we = 1'b0; // Default to read
            end
        endcase
    end
            

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            phase <= 0; // Reset phase to read
        end else begin
            phase <= ~phase; // Toggle phase
        end
    end
    
endmodule