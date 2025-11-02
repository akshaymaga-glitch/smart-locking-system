// 1-bit D Flip-Flop with Reset using gates
module DFFR (
    input D,       // Data input
    input CLK,     // Clock input
    input R,       // Reset input (active high)
    output Q       // Output
);
    wire nR, Dn, nQ, nCLK, Dmux_out;

    // Inverted Reset
    not (nR, R);

    // D latches
    nand (Dn, nR, D, nCLK);
    nand (nQ, nR, Dn, CLK);

    // Flip-flop output
    nand (Q, nQ, nR);
endmodule

// 4-bit stored pin using DFFR
module StoredPin (
    input CLK,
    input R,
    output [3:0] stored_pin
);
    DFFR dff0 (.D(1'b0), .CLK(CLK), .R(R), .Q(stored_pin[0]));
    DFFR dff1 (.D(1'b1), .CLK(CLK), .R(R), .Q(stored_pin[1]));
    DFFR dff2 (.D(1'b0), .CLK(CLK), .R(R), .Q(stored_pin[2]));
    DFFR dff3 (.D(1'b1), .CLK(CLK), .R(R), .Q(stored_pin[3]));
endmodule

// 2-input XOR gate
module XOR2 (
    input A,  // First input
    input B,  // Second input
    output Y  // XOR result
);
    assign Y = A ^ B;
endmodule

// 4-input NOR gate
module NOR4 (
    input A,  // First input
    input B,  // Second input
    input C,  // Third input
    input D,  // Fourth input
    output Y  // NOR result
);
    assign Y = ~(A | B | C | D);
endmodule

// Main Module (Automated Delivery Locker System) in gate level
module AutomatedDeliveryLockerSystem (
    input [3:0] user_pin,
    input package_present,
    input [3:0] user_pin_retrieval,
    input clk,
    input reset,
    input reset_lockers,
    output auth_success_led,
    output retrieval_auth_led,
    output [2:0] assigned_locker_display,
    output [7:0] locker_doors
);

// Internal Signals
wire [3:0] stored_pin;
wire [7:0] available_lockers;
wire [2:0] locker_number;
wire assign_locker, locker_assigned, retrieval_auth_success;
wire open_signal;

// Instantiate StoredPin
StoredPin stored_pin_inst (
    .CLK(clk),
    .R(reset),
    .stored_pin(stored_pin)
);

// User Authentication Logic
wire auth_match;
wire auth_pin_0_diff, auth_pin_1_diff, auth_pin_2_diff, auth_pin_3_diff;

XOR2 auth_xor0 (.A(user_pin[0]), .B(stored_pin[0]), .Y(auth_pin_0_diff));
XOR2 auth_xor1 (.A(user_pin[1]), .B(stored_pin[1]), .Y(auth_pin_1_diff));
XOR2 auth_xor2 (.A(user_pin[2]), .B(stored_pin[2]), .Y(auth_pin_2_diff));
XOR2 auth_xor3 (.A(user_pin[3]), .B(stored_pin[3]), .Y(auth_pin_3_diff));

NOR4 auth_nor (
    .A(auth_pin_0_diff),
    .B(auth_pin_1_diff),
    .C(auth_pin_2_diff),
    .D(auth_pin_3_diff),
    .Y(auth_match)
);

assign auth_success_led = auth_match;

// Locker Assignment Logic (simplified)
assign locker_number = (available_lockers[0]) ? 3'b000 :
                       (available_lockers[1]) ? 3'b001 :
                       (available_lockers[2]) ? 3'b010 :
                       (available_lockers[3]) ? 3'b011 :
                       (available_lockers[4]) ? 3'b100 :
                       (available_lockers[5]) ? 3'b101 :
                       (available_lockers[6]) ? 3'b110 : 3'b111;

// Manage available lockers
wire [7:0] available_lockers_next;

assign available_lockers_next = (reset || reset_lockers) ? 8'b11111111 : (assign_locker) ? available_lockers & ~(1 << locker_number) : available_lockers;

// Lockers output control (simplified)
assign locker_doors = open_signal ? 4'b0001 : 4'b0000;

endmodule