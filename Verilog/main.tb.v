module test_AutomatedDeliveryLockerSystem;

    // Inputs
    reg [3:0] user_pin;
    reg [3:0] user_pin_retrieval;
    reg package_present;
    reg clk;
    reg reset;
    reg reset_lockers;

    // Outputs
    wire auth_success_led;
    wire retrieval_auth_led;
    wire [2:0] assigned_locker_display;
    wire [7:0] locker_doors;

    // Instantiate the AutomatedDeliveryLockerSystem
    AutomatedDeliveryLockerSystem uut (
        .user_pin(user_pin),
        .user_pin_retrieval(user_pin_retrieval),
        .package_present(package_present),
        .clk(clk),
        .reset(reset),
        .reset_lockers(reset_lockers),
        .auth_success_led(auth_success_led),
        .retrieval_auth_led(retrieval_auth_led),
        .assigned_locker_display(assigned_locker_display),
        .locker_doors(locker_doors)
    );

    // Clock generation: Toggle clock every 5 time units
    always begin
        #5 clk = ~clk;
    end

    // Test sequence
    initial begin
        // Initialize Inputs
        clk = 0;
        reset = 1;  // Start with reset active
        reset_lockers = 0;
        user_pin = 4'b0000;
        user_pin_retrieval = 4'b0000;
        package_present = 0;

        // Step 1: Reset and initialize system
        #10 reset = 0;  // Deactivate reset

        // Test Case 1: Correct PIN Authentication
        #10 user_pin = 4'b1010;  // Set correct PIN
        package_present = 1;     // Simulate a package present
        #10;
        if (auth_success_led)
            $display("Test Case 1 Passed: Authentication Successful");
        else
            $display("Test Case 1 Failed: Authentication Unsuccessful");

        // Test Case 2: Locker Assignment upon Authentication
        reset_lockers = 1;  // Reset lockers to available state
        #10 reset_lockers = 0;  // Release reset lockers
        #10;
        if (assigned_locker_display == 3'b000)
            $display("Test Case 2 Passed: Locker Assigned Correctly");
        else
            $display("Test Case 2 Failed: Locker Assignment Incorrect");

        // Test Case 3: Retrieval Authentication and Door Opening
        #10 user_pin_retrieval = 4'b1010;  // Set correct retrieval PIN
        #10;
        if (locker_doors == 8'b00000001)
            $display("Test Case 3 Passed: Locker Door Opened");
        else
            $display("Test Case 3 Failed: Locker Door Did Not Open");

        // Test Case 4: Reset Lockers
        #10 reset_lockers = 1;  // Trigger locker reset
        #10 reset_lockers = 0;
        if (locker_doors == 8'b00000000)
            $display("Test Case 4 Passed: Lockers Reset Successfully");
        else
            $display("Test Case 4 Failed: Lockers Reset Unsuccessful");

        $finish;  // End the simulation
    end

    // Monitor output signals for debugging
    initial begin
        $monitor("Time: %0t | Auth LED: %b | Assigned Locker: %b | Locker Doors: %b",
                 $time, auth_success_led, assigned_locker_display, locker_doors);
    end

endmodule