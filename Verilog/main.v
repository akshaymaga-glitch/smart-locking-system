module AutomatedDeliveryLockerSystem (
    input [3:0] user_pin, 
    input package_present,
    input [3:0] user_pin_retrieval,
    input clk,
    input reset,
    input reset_lockers,
    output reg auth_success_led,
    output reg retrieval_auth_led,
    output reg [2:0] assigned_locker_display,
    output reg [7:0] locker_doors
);

    // Internal signals and registers
    reg [3:0] stored_pin;                  // Stores the correct pin
    reg [7:0] available_lockers;           // Available lockers, each bit represents one locker
    reg [2:0] locker_number;               // The assigned locker number
    reg locker_assigned;                   // Flag to indicate locker is assigned
    reg open_signal;                       // Open locker signal
    reg retrieval_auth_success;            // Successful retrieval authentication

    // Initialize stored PIN (for demonstration purposes)
    always @(posedge clk or posedge reset) begin
        if (reset)
            stored_pin <= 4'b1010;         // Default stored PIN is 1010
    end

    // User authentication for locker assignment (Package delivery)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            auth_success_led <= 0;
            locker_assigned <= 0;
        end else if (user_pin == stored_pin && package_present) begin
            auth_success_led <= 1;
            locker_assigned <= 1;
        end else begin
            auth_success_led <= 0;
            locker_assigned <= 0;
        end
    end

    // Locker management: Assign available locker
    always @(posedge clk or posedge reset_lockers) begin
        if (reset_lockers || reset) begin
            available_lockers <= 8'b11111111;   // All lockers set to available (1 means available)
        end else if (locker_assigned && available_lockers != 0) begin
            // Assign the first available locker
            case (available_lockers)
                8'b00000001: locker_number <= 3'b000;
                8'b00000010: locker_number <= 3'b001;
                8'b00000100: locker_number <= 3'b010;
                8'b00001000: locker_number <= 3'b011;
                8'b00010000: locker_number <= 3'b100;
                8'b00100000: locker_number <= 3'b101;
                8'b01000000: locker_number <= 3'b110;
                8'b10000000: locker_number <= 3'b111;
                default: locker_number <= 3'b000;  // Default to locker 0 if none available
            endcase

            // Mark the assigned locker as unavailable
            available_lockers[locker_number] <= 0;
        end
    end

    // Locker retrieval authentication
    always @(posedge clk) begin
        if (user_pin_retrieval == stored_pin) begin
            retrieval_auth_led <= 1;
            retrieval_auth_success <= 1;
        end else begin
            retrieval_auth_led <= 0;
            retrieval_auth_success <= 0;
        end
    end

    // Locker door control: Open locker if authenticated
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            open_signal <= 0;
        end else if (retrieval_auth_success) begin
            open_signal <= 1;  // Open locker
        end else begin
            open_signal <= 0;  // Close locker
        end
    end

    // Locker doors output logic (8-bit signal representing locker doors status)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            locker_doors <= 8'b00000000;   // All lockers closed
        end else if (open_signal) begin
            locker_doors[locker_number] <= 1;  // Open the assigned locker
        end else begin
            locker_doors <= 8'b00000000;   // Keep all lockers closed
        end
    end

    // Output the assigned locker number to display
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            assigned_locker_display <= 3'b000;  // Default locker display
        end else if (locker_assigned) begin
            assigned_locker_display <= locker_number;  // Show assigned locker number
        end
    end

endmodule