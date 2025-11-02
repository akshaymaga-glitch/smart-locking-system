

# AUTOMATED DELIVERY LOCKER SYSTEM

<!-- First Section -->
## Team Details
<details>
  <summary>Detail</summary>

  > Semester: 3rd Sem B. Tech. CSE

  > Section: S1

  > member-1 : 241CS105.,Akshaymaga,akshaymaga.241cs105@nitk.edu.in  

  > member-2: 241CS108.,AnikethanaRudresh,anikethanarudresh.241cs108@nitk.edu.in

  > Member-3: 241CS138.,NiteeshKumar,niteeshkumar.241cs138@nitk.edu.in
</details>

<!-- Second Section -->
## Abstract
<details>
  <summary>Detail</summary>
  
  > Problem statement:
> Our system uses Verilog Hardware Description Language (HDL) to program microcontrollers or FPGAs that precisely control electronic locks, ensuring reliable operation (Brown \& Vranesic, 2014). The software interface manages locker assignments, tracks deliveries, and communicates with customers through notifications. Integration with Microsoft Azure IoT Hub enables cloud-based monitoring and real-time data management, enhancing scalability and remote accessibility (Microsoft Azure Documentation, 2023).

  > Motivation:
> The surge in e-commerce has led to increased package deliveries, resulting in challenges like missed deliveries and package theft (Morganti et al., 2014). Traditional delivery methods often fail to address these issues effectively. To enhance package security and delivery efficiency, we propose an \textbf{Automated Delivery Locker System} utilizing Verilog-controlled locking mechanisms.

  > Features:1.
> Verilog-Based Hardware Control for Automated Delivery: The system utilizes Verilog to
manage hardware, automating the delivery process in residential complexes, retail stores, and
offices. This improves operational efficiency and reduces the risks of theft.
2.Cloud Integration for Scalability and Efficiency: By integrating with the cloud, the solution
offers a scalable infrastructure that enhances delivery management, making it adaptable to
different environments while ensuring seamless operation (Williams Brown, 2020).

</details>

## Functional Block diagram 
<details>
  <summary>Detail</summary>
<img alt="s1-t21" src="https://github.com/user-attachments/assets/28ec6284-67b6-492e-8372-b28b4f373f98"><img/>
<!-- Third Section -->
</details>

<!-- Fourth Section -->
## Working
<details>
  <summary>Detail</summary>
   This Automated Delivery Locker System operates through user authentica-
tion, dynamic locker management, and notifications to provide a seamless
user experience for delivery and retrieval of packages. The system comprises
lockers, sensors, a user interface, and control logic, all connected to ensure
security and ease of use.
  
Key Components in the System

• Locker Array: A set of lockers where packages are stored, each locker
being individually controlled.

• Authentication System: Users authenticate themselves via PIN or
biometric verification to access their packages.

• Control Logic: Manages locker assignment and user interactions.

• User Interface: A screen or keypad for inputting credentials.

• Notification System: Sends real-time notifications to users for pack-
age delivery and retrieval.
</details>

<!-- Fifth Section -->
## Logisim Circuit Diagram
<details>

![IMG-20241016-WA0009](https://github.com/user-attachments/assets/d8b60ced-75c4-4ead-8353-de3db66d9eb1)

  
  <summary>Detail</summary>

  
</details>

<!-- Sixth Section -->


## Verilog Code
<details>
  <summary>Detail</summary>
  <details>
     <summary>Main</summary>

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
</details>


<details>
 

  <summary>Testbench</summary>


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

  </details>

<details>
  <summary>Output</summary>

   ![Screenshot 2024-10-17 035049](https://github.com/user-attachments/assets/d3acc01b-63ab-4860-8bd6-87a6fb910392)

</details>
</details>

## References
<details>
  <summary>Detail</summary>

1. Morganti, E., Dablanc, L., & Fortin, F. (2014). https://doi.org/10.1016/j.rtbm.2014.03.002
2. Microsoft Azure Documentation. (2023). https://learn.microsoft.com/en-us/azure/iot-hub/
3. Williams, R., & Brown, T. (2020). https://doi.org/10.14569/IJACSA.2020.0110804
4. Bhasker, J. (2005). A Verilog HDL Primer (3rd ed.). Star Galaxy Publishing.
5. Brown, S. D., & Vranesic, Z. G. (2014). Fundamentals of Digital Logic with Verilog Design
(3rd ed.). McGraw-Hill Education.  
  
  </details>
  
