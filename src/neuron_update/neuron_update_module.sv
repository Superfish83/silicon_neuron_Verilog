interface num_if(
    parameter NR_WIDTH = 56, 
    parameter NR_DEPTH = 16
);

    logic freeze;
    // Assumes time_index is controlled by the controller
    logic time_index;
    logic spike_out;

    wire [NR_WIDTH-1:0] nr_read;
    wire [NR_WIDTH-1:0] nr_write;
    wire nr_we;
    wire [$clog2(NR_DEPTH)-1:0] nr_addr;

    modport updater (
        input freeze, time_index,
        output spike_out,
        input nr_read, 
        input sr_read, 
        output nr_write, nr_we, nr_addr,
    );
    
endinterface //num_if


module neuron_update_module #(
    parameter NR_WIDTH = 56, 
    parameter NR_DEPTH = 16,
) (
    input logic clk,
    input logic reset,
    num_if.updater num_if_inst
);

    // 0 - read, 1 - write
    logic phase;

    logic [NR_WIDTH-1:0] neuron_in;
    logic [NR_WIDTH-1:0] neuron_out;

    assign neuron_in = num_if_inst.nr_read;

    // TODO: Remove Hard coded values
    IZH_neuron #(
        .V_WIDTH(20), // Assuming V_WIDTH is half of NR_WIDTH
        .FR_WIDTH(11)
    ) izh_neuron_inst (
        .clk(clk),
        .reset(reset),
        .synin(neuron_in[0+:20]), // Assuming synin is in the upper half
        .synout(num_if_inst.spike_out),
        .vout(neuron_out[NR_WIDTH-1:NR_WIDTH/2]) // Output voltage
    );
    // IZH_integrator#(
    //     .V_WIDTH(NR_WIDTH),
    //     .FR_WIDTH(11)
    // ) izh_inst (
    //     .I(neuron_in[40+:16]),  
    //     .w_old(neuron_in[20+:20]),
    //     .v_old(neuron_in[0+:20]),
    //     .w_new(neuron_out[NR_WIDTH-1:0]),
    //     .v_new(neuron_out[NR_WIDTH*2-1:NR_WIDTH]),
    //     .fire(num_if_inst.spike_out)
    // );

    always_comb begin : bus_mux
        case (phase)
            0: begin // Read phase
                num_if_inst.nr_read = neuron_in; // Read from neuron register
            end 
            1: begin // Write phase
                num_if_inst.nr_write = neuron_out; // Write to neuron register
                num_if_inst.nr_we = 1'b1; // Enable write
                num_if_inst.nr_addr = num_if_inst.time_index; // Set address
            end
            default: begin
                num_if_inst.nr_we = 1'b0; // Default to no write
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

   
