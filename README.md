# mybotlevel2
RPA - Order Robot - Robocorp Certificate II
A process automation robot to complete the Robocorp course "Certificate level II: Build a robot" assignment.
The robot automates the process of ordering several robots via the RobotSpareBin Industries Inc. website and can be used as an assistant, which asks for the CSV file URL.

The automated process

Open the order page in a web browser
Request the order file URL from the user using an input dialog
Download the CSV order file
Read in the orders information from the CSV file
For each order in the file:
    Close modal on order page
    Fill the form on the website with the order data
    Preview the soon orderd robot and take ascreenshot of the robot image
    Submit the order (this step uses the retry logic to avoid xxx occasional errors on submit)
    Create a receipt PDF with the robot preview image embedded
    Trigger ordering of a new robot
Create a ZIP file of all receipts and store it in the output directory
Close the browser
Remove all receipts and screenshot from output directory

Run the robot

As required by the course rules, the robot can be run without extra manual setup.
This includes a vault file containing the order page URL stored in the project reposotiry.

Provided having an Robocorp account and using Robocorp Lab or Visual Studio Code with the Robocorp extension, there are two ways to run the robot (the tools are downloadable here):

1)  Local in Robocorp Lab or Visual Studio Code
        Just run the robot in the IDE (no upload required)
2)  As an assistant via the Robocorp Assistant App
        Upload the robot code to the Control Room via the IDE
        In the Control Room add the robot as an assistant
        Download and install the Robocorp Assistant App
        Run the assistant from the app (see description here)
