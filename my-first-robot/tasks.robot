*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.HTTP
Library             RPA.Tables
Library             RPA.PDF
Library             RPA.Desktop
Library             RPA.Archive


*** Variables ***
${url}              https://robotsparebinindustries.com/#/robot-order
${csv_url}          https://robotsparebinindustries.com/orders.csv
${image_folder}     ${CURDIR}${/}image_files
${pdf_folder}       ${CURDIR}${/}pdf_files
${output_folder}    ${CURDIR}${/}output
${order_files}      ${CURDIR}${/}orders.csv
${zip_file}         ${output_folder}${/}pdf_archive.zip_file


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    Close the annoying modal
    Downloadcsv
    Read data from the CSV file
    Wait Until Keyword Succeeds    10x    2s    Preview the robot
    Wait Until Keyword Succeeds    10x    2s    Submit The Order
    ${orderid}    ${img_filename}=    Take a screenshot of the robot
    ${pdf_filename}=    Store the receipt as a PDF file    ORDER_NUMBER=${order_id}
    Embed the robot screenshot to the receipt PDF file    IMG_FILE=${img_filename}    PDF_FILE=${pdf_filename}
    Go to order another robot

Create a Zip File of the Receipts
    Archive Folder With ZIP    ${pdf_folder}    ${zip_file}    recursive=True    include=*.pdf


*** Keywords ***
Open the robot order website
    Open Available Browser    ${url}
    Maximize Browser Window
    Sleep    5

Downloadcsv
    Download    ${csv_url}    overwrite=true

Read data from the CSV file
    ${table}=    Read table from CSV    orders.csv
    FOR    ${element}    IN    @{table}
        order robot using csv file    ${element}
    END

order robot using csv file
    [Arguments]    ${element}

    Select From List By Value    head    ${element}[Head]
    Select Radio Button    body    ${element}[Body]
    Input Text    //div[@class='col-sm-7']/form/div[3]/input    ${element}[Legs]
    Input Text    //input[@id='address']    ${element}[Address]
    Set Selenium Implicit Wait    10

Close the annoying modal
    Click Button    //*[@id="root"]/div/div[2]/div/div/div/div/div/button[1]

Take a screenshot of the robot
    # Define local variables for the UI elements
    Set Local Variable    ${lbl_orderid}    xpath://html/body/div/div/div[1]/div/div[1]/div/div/p[1]
    Set Local Variable    ${img_robot}    //*[@id="robot-preview-image"]
    Wait Until Element Is Visible    ${img_robot}
    Wait Until Element Is Visible    ${lbl_orderid}

    #get the order ID
    ${orderid}=    Get Text    //*[@id="receipt"]/p[1]

    # Create the File Name
    Set Local Variable    ${fully_qualified_img_filename}    ${image_folder}${/}${orderid}.png

    Sleep    1sec
    Log To Console    Capturing Screenshot to ${fully_qualified_img_filename}
    Capture Element Screenshot    ${img_robot}    ${fully_qualified_img_filename}
    RETURN    ${orderid}    ${fully_qualified_img_filename}

Go to order another robot
    # Define local variables for the UI elements
    Set Local Variable    ${btn_order_another_robot}    //*[@id="order-another"]
    Click Button    ${btn_order_another_robot}

Log Out And Close The Browser
    Close Browser

Store the receipt as a PDF file
    [Arguments]    ${ORDER_NUMBER}

    Wait Until Element Is Visible    //*[@id="receipt"]
    Log To Console    Printing ${ORDER_NUMBER}
    ${order_receipt_html}=    Get Element Attribute    //*[@id="receipt"]    outerHTML

    Set Local Variable    ${fully_qualified_pdf_filename}    ${pdf_folder}${/}${ORDER_NUMBER}.pdf

    Html To Pdf    content=${order_receipt_html}    output_path=${fully_qualified_pdf_filename}
    RETURN    ${fully_qualified_pdf_filename}

Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${IMG_FILE}    ${PDF_FILE}

    Log To Console    Printing Embedding image ${IMG_FILE} in pdf file ${PDF_FILE}

    Open PDF    ${PDF_FILE}

    # Create the list of files that is to be added to the PDF (here, it is just one file)
    @{myfiles}=    Create List    ${IMG_FILE}:x=0,y=0

    # Add the files to the PDF
    #
    # Note:
    #
    # 'append' requires the latest RPAframework. Update the version in the conda.yaml file - otherwise,
    # this will not work. The VSCode auto-generated file contains a version number that is way too old.
    #
    # per https://github.com/robocorp/rpaframework/blob/master/packages/pdf/src/RPA/PDF/keywords/document.py,
    # an "append" always adds a NEW page to the file. I don't see a way to EMBED the image in the first page
    # which contains the order data
    Add Files To PDF    ${myfiles}    ${PDF_FILE}    ${True}

Preview the robot
    # Define local variables for the UI elements
    Set Local Variable    ${btn_preview}    //*[@id="preview"]
    Set Local Variable    ${img_preview}    //*[@id="robot-preview-image"]
    Click Button    ${btn_preview}
    Wait Until Element Is Visible    ${img_preview}

Submit the order
    # Define local variables for the UI elements
    Set Local Variable    ${btn_order}    //*[@id="order"]
    Set Local Variable    ${lbl_receipt}    //*[@id="receipt"]

    # Submit the order. If we have a receipt, then all is well
    Click button    ${btn_order}
    Page Should Contain Element    ${lbl_receipt}
