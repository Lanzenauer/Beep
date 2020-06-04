page 50075 "Inventory Pick WF Scan New"
{
    // version NAVW113.00,T13.01,WF

    // HSG Hanse Solution GmbH
    // Wichmannstrasse 4
    // D - 22607 Hamburg
    // 
    // Date    Module  ID  Description
    // ==========================================================================================
    // 121219  WF_01   CH  Copied from p 7377
    // 130220  WF_02   CH  Print WF pick document
    // 180220  WF_03   CH  New page action - parcels per documents
    // 200220  WF_04   CH  New page part "ShipTo Info"
    // 040320  WF_05   CH  Several code changes
    // 190320  WF_06   CH  Column Container set to Visible = False
    // 070420  WF_07   CH  Add beep if bad scan read error

    Caption = 'Inventory Pick Scanner';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = Document;
    RefreshOnActivate = true;
    SaveValues = true;
    SourceTable = "Warehouse Activity Header";
    SourceTableView = WHERE(Type = CONST("Invt. Pick"));

    layout
    {
        area(content)
        {
            //-WF_07
            usercontrol(Beep; beepAddin)
            {
                ApplicationArea = All;

                trigger Ready()
                begin
                    Message('Is ready');
                end;
            }

            group(Control1)
            {
                Caption = 'General';
                field(ScanInput_gTxt; ScanInput_gTxt)
                {
                    Importance = Promoted;
                    ShowCaption = false;
                    ShowMandatory = true;
                    Style = AttentionAccent;
                    StyleExpr = TRUE;

                    trigger OnValidate()
                    begin
                        ReadScan_lFnc;
                    end;
                }
                field(ResultScanInput_gTxt; ResultScanInput_gTxt)
                {
                    Editable = false;
                }
                field("No."; "No.")
                {
                    ApplicationArea = Warehouse;
                    Editable = false;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';

                    trigger OnAssistEdit()
                    begin
                        if AssistEdit(xRec) then
                            CurrPage.Update;
                    end;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = Location;
                    Editable = false;
                    ToolTip = 'Specifies the code for the location where the warehouse activity takes place.';
                    Visible = false;
                }
                field("Source Document"; "Source Document")
                {
                    ApplicationArea = Warehouse;
                    DrillDown = false;
                    Editable = false;
                    Lookup = false;
                    ToolTip = 'Specifies the type of document that the line relates to.';
                    Visible = false;
                }
                field("Source No."; "Source No.")
                {
                    ApplicationArea = Warehouse;
                    Editable = false;
                    ToolTip = 'Specifies the number of the source document that the entry originates from.';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        CODEUNIT.Run(CODEUNIT::"Create Inventory Pick/Movement", Rec);
                        CurrPage.Update;
                        CurrPage.WhseActivityLines.PAGE.UpdateForm;
                    end;

                    trigger OnValidate()
                    begin
                        SourceNoOnAfterValidate;
                    end;
                }
                field("Destination No."; "Destination No.")
                {
                    ApplicationArea = Warehouse;
                    CaptionClass = Format(WMSMgt.GetCaption("Destination Type", "Source Document", 0));
                    Editable = false;
                    ToolTip = 'Specifies the number or the code of the customer or vendor that the line is linked to.';
                }
                field("WMSMgt.GetDestinationName(""Destination Type"",""Destination No."")"; WMSMgt.GetDestinationName("Destination Type", "Destination No."))
                {
                    ApplicationArea = Warehouse;
                    CaptionClass = Format(WMSMgt.GetCaption("Destination Type", "Source Document", 1));
                    Caption = 'Name';
                    Editable = false;
                    ToolTip = 'Specifies the name of the inventory picks used for these outbound source documents: sales orders, purchase return orders, and outbound transfer orders.';
                }
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = Warehouse;
                    Editable = false;
                    ToolTip = 'Specifies the date when the warehouse activity should be recorded as being posted.';
                    Visible = false;
                }
                field("Shipment Date"; "Shipment Date")
                {
                    ApplicationArea = Warehouse;
                    Editable = false;
                    ToolTip = 'Specifies when items on the document are shipped or were shipped. A shipment date is usually calculated from a requested delivery date plus lead time.';
                    Visible = false;
                }
                field("External Document No."; "External Document No.")
                {
                    ApplicationArea = Warehouse;
                    CaptionClass = Format(WMSMgt.GetCaption("Destination Type", "Source Document", 2));
                    Editable = false;
                    ToolTip = 'Specifies a document number that refers to the customer''s or vendor''s numbering system.';
                    Visible = false;
                }
                field("External Document No.2"; "External Document No.2")
                {
                    ApplicationArea = Warehouse;
                    CaptionClass = Format(WMSMgt.GetCaption("Destination Type", "Source Document", 3));
                    Editable = false;
                    ToolTip = 'Specifies an additional part of the document number that refers to the customer''s or vendor''s numbering system.';
                    Visible = false;
                }
                field("Pick Document No."; "Pick Document No.")
                {
                    Editable = false;
                    Visible = false;
                }
                field("Container No."; "Container No.")
                {
                    Editable = false;
                    Visible = false;
                }
            }
            part(WhseActivityLines; "Invt. Pick Subform WF")
            {
                ApplicationArea = Warehouse;
                Caption = 'Scan View';
                Editable = false;
                SubPageLink = "Activity Type" = FIELD(Type),
                              "No." = FIELD("No.");
                SubPageView = SORTING("Activity Type", "No.", "Sorting Sequence No.")
                              WHERE(Breakbulk = CONST(false));
            }
            part(WhseActivityLinesEditable; "Invt. Pick Subform WF")
            {
                ApplicationArea = Warehouse;
                Caption = 'Edit View';
                Editable = true;
                SubPageLink = "Activity Type" = FIELD(Type),
                              "No." = FIELD("No.");
                SubPageView = SORTING("Activity Type", "No.", "Sorting Sequence No.")
                              WHERE(Breakbulk = CONST(false));
                Visible = false;
            }
        }
        area(factboxes)
        {
            part(Control1000000002; "Sales Comment Fact Box")
            {
                Caption = 'Pick Comments';
                SubPageLink = "Document Type" = CONST(Order),
                              "No." = FIELD("Source No."),
                              "Document Line No." = CONST(0),
                              "Handling 1" = CONST(true);
            }
            part(Control1000000003; "Sales Header ShipTo FactBox")
            {
                Caption = 'Sales Header ShipTo FactBox';
                SubPageLink = "Document Type" = CONST(Order),
                              "No." = FIELD("Source No.");
            }
            part(Control100000006; "Lot Numbers by Bin FactBox")
            {
                ApplicationArea = ItemTracking;
                Provider = WhseActivityLines;
                SubPageLink = "Item No." = FIELD("Item No."),
                              "Variant Code" = FIELD("Variant Code"),
                              "Location Code" = FIELD("Location Code");
                Visible = false;
            }
            systempart(Control100000005; Links)
            {
                Visible = false;
            }
            systempart(Control100000004; Notes)
            {
                Visible = false;
            }
            part(Control100000003; "Page Actions FactBox")
            {
                Provider = WhseActivityLines;
                SubPageLink = "Page ID" = CONST(7377),
                              "Rec Key 1 (Temp)" = CONST(5),
                              "Rec Key 2 (Temp)" = FIELD("No."),
                              "Rec Key 3 (temp)" = FIELD("Line No.");
                Visible = false;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group(ActionGroup100)
            {
                Caption = 'P&ick';
                Image = CreateInventoryPickup;
                // -WF_07
                action("TestBeep")
                {
                    ApplicationArea = All;
                    Image = Start;
                    ToolTip = 'Make great Music';
                    trigger OnAction()
                    begin
                        makeSound();
                    end;
                }
                action(Action101)
                {
                    ApplicationArea = Warehouse;
                    Caption = 'List';
                    Image = OpportunitiesList;
                    ShortCutKey = 'Shift+Ctrl+L';
                    ToolTip = 'View all warehouse documents of this type that exist.';

                    trigger OnAction()
                    begin
                        LookupActivityHeader("Location Code", Rec);
                    end;
                }
                action(Action25)
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    RunObject = Page "Warehouse Comment Sheet";
                    RunPageLink = "Table Name" = CONST("Whse. Activity Header"),
                                  Type = FIELD(Type),
                                  "No." = FIELD("No.");
                    ToolTip = 'View or add comments for the record.';
                }
                action(Action31)
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Posted Picks';
                    Image = PostedInventoryPick;
                    RunObject = Page "Posted Invt. Pick List";
                    RunPageLink = "Invt Pick No." = FIELD("No.");
                    RunPageView = SORTING("Invt Pick No.");
                    ToolTip = 'View any quantities that have already been picked.';
                }
                action(Action40)
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Source Document';
                    Image = "Order";
                    ToolTip = 'View the source document of the warehouse activity.';

                    trigger OnAction()
                    var
                        WMSMgt: Codeunit "WMS Management";
                    begin
                        WMSMgt.ShowSourceDocCard("Source Type", "Source Subtype", "Source No.");
                    end;
                }
                action(Action100000000)
                {
                    Caption = 'Parcels Per Document';
                    Image = GetActionMessages;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    var
                        SalesHeader_lRec: Record "Sales Header";
                        ParcelperDoc_lPag: Page "Parcels per Document";
                        ParcelperDoc_lRec: Record "Parcel per Document";
                    begin
                        // WF_03

                        Rec.TestField("Source Document", Rec."Source Document"::"Sales Order");
                        Rec.TestField("Source No.");
                        Rec.TestField("Pick Document No.");

                        SalesHeader_lRec.Get(SalesHeader_lRec."Document Type"::Order, Rec."Source No.");

                        Clear(ParcelperDoc_lPag);
                        Clear(ParcelperDoc_lRec);
                        ParcelperDoc_lRec.SetRange("Document Type", ParcelperDoc_lRec."Document Type"::Order);
                        ParcelperDoc_lRec.SetRange("No.", SalesHeader_lRec."No.");

                        ParcelperDoc_lRec.SetRange("Pick Document No.", Rec."Pick Document No.");
                        ParcelperDoc_lPag.SetTableView(ParcelperDoc_lRec);
                        ParcelperDoc_lPag.SetShipAgent_gFnc(SalesHeader_lRec."Shipping Agent Code");
                        ParcelperDoc_lPag.SetShipAgentService_gFnc(SalesHeader_lRec."Shipping Agent Service Code");
                        ParcelperDoc_lPag.RunModal;
                    end;
                }
            }
        }
        area(processing)
        {
            group(ActionGroup9)
            {
                Caption = 'F&unctions';
                Image = "Action";
                action(Action13)
                {
                    ApplicationArea = Warehouse;
                    Caption = '&Get Source Document';
                    Ellipsis = true;
                    Image = GetSourceDoc;
                    ShortCutKey = 'Ctrl+F7';
                    ToolTip = 'Select the source document that you want to pick items for.';

                    trigger OnAction()
                    begin
                        CODEUNIT.Run(CODEUNIT::"Create Inventory Pick/Movement", Rec);
                    end;
                }
                action(AutofillQtyToHandle2)
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Autofill Qty. to Handle';
                    Image = AutofillQtyToHandle;
                    ToolTip = 'Have the system enter the outstanding quantity in the Qty. to Handle field.';

                    trigger OnAction()
                    begin
                        AutofillQtyToHandle;
                    end;
                }
                action(Action39)
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Delete Qty. to Handle';
                    Image = DeleteQtyToHandle;
                    ToolTip = 'Have the system clear the value in the Qty. To Handle field. ';

                    trigger OnAction()
                    begin
                        DeleteQtyToHandle;
                    end;
                }
                action(CreateParcelsAndTracking)
                {
                    Caption = 'Create Parcels And Tracking ID and Print';
                    Image = GetActionMessages;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    var
                        SalesMgt_lCdu: Codeunit "Sales Management";
                    begin
                        SalesMgt_lCdu.WhsActHeader_CreateParcels_gFnc(Rec); // WF_04
                    end;
                }
            }
            group(ActionGroup24)
            {
                Caption = 'P&osting';
                Image = Post;
                action(Action28)
                {
                    ApplicationArea = Warehouse;
                    Caption = 'P&ost';
                    Ellipsis = true;
                    Image = PostOrder;
                    ShortCutKey = 'F9';
                    ToolTip = 'Finalize the document or journal by posting the amounts and quantities to the related accounts in your company books.';

                    trigger OnAction()
                    begin
                        PostPickYesNo;
                    end;
                }
                action(PostAndPrint2)
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Post and &Print';
                    Ellipsis = true;
                    Image = PostPrint;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'Shift+F9';
                    ToolTip = 'Finalize and prepare to print the document or journal. The values and quantities are posted to the related accounts. A report request window where you can specify what to include on the print-out.';

                    trigger OnAction()
                    begin
                        PostAndPrint;
                    end;
                }
            }
        }
        area(reporting)
        {
            action(Action100000002)
            {
                ApplicationArea = Warehouse;
                Caption = '&Print';
                Ellipsis = true;
                Image = Print;
                ToolTip = 'Prepare to print the document. A report request window for the document opens where you can specify what to include on the print-out.';

                trigger OnAction()
                var
                    InventoryPickingListWF_lRep: Report "Inventory Picking List WF";
                    WhsActHeader_lRec: Record "Warehouse Activity Header";
                begin
                    // -WF_02
                    WhsActHeader_lRec := Rec;
                    WhsActHeader_lRec.SetRecFilter;
                    Clear(InventoryPickingListWF_lRep);
                    InventoryPickingListWF_lRep.SetTableView(WhsActHeader_lRec);
                    InventoryPickingListWF_lRep.RunModal;
                    // WhseActPrint.PrintInvtPickHeader(Rec,FALSE);
                    // +WF_02
                end;
            }
        }
    }

    trigger OnDeleteRecord(): Boolean
    begin
        CurrPage.Update;
    end;

    trigger OnFindRecord(Which: Text): Boolean
    begin
        exit(FindFirstAllowedRec(Which));
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        "Location Code" := GetUserLocation;
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    begin
        exit(FindNextAllowedRec(Steps));
    end;

    trigger OnOpenPage()
    begin
        ErrorIfUserIsNotWhseEmployee;

        InitAllScanField_lFnc;
    end;

    var
        WhseActPrint: Codeunit "Warehouse Document-Print";
        WMSMgt: Codeunit "WMS Management";
        ScanInput_gTxt: Text;
        ResultScanInput_gTxt: Text;

    local procedure AutofillQtyToHandle()
    begin
        CurrPage.WhseActivityLines.PAGE.AutofillQtyToHandle;
    end;
    //WF_07
    procedure makeSound()
    begin
        CurrPage.Beep.makeBeep();
    end;

    local procedure DeleteQtyToHandle()
    begin
        CurrPage.WhseActivityLines.PAGE.DeleteQtyToHandle;
    end;

    local procedure PostPickYesNo()
    begin
        CurrPage.WhseActivityLines.PAGE.PostPickYesNo_gFnc;
    end;

    local procedure PostAndPrint()
    begin
        CurrPage.WhseActivityLines.PAGE.PostAndPrint_gFnc;
    end;

    local procedure SourceNoOnAfterValidate()
    begin
        CurrPage.Update;
        CurrPage.WhseActivityLines.PAGE.UpdateForm;
    end;

    local procedure "---"()
    begin
    end;

    local procedure ReadScan_lFnc()
    begin
        ProcessScanWhsHeader_gFnc(ScanInput_gTxt, Rec, ResultScanInput_gTxt);
        CurrPage.Update(false);

        ScanInput_gTxt := '';
    end;

    [Scope('Personalization')]
    procedure ProcessScanWhsHeader_gFnc(ScanInput_iTxt: Text; WhsHeader_iRec: Record "Warehouse Activity Header"; var ScanResult_vTxt: Text)
    var
        ItemCrossRef_lRec: Record "Item Cross Reference";
        WhsActLine_lRec: Record "Warehouse Activity Line";
        Item_lRec: Record Item;
    begin

        Clear(ItemCrossRef_lRec);
        ItemCrossRef_lRec.SetRange("Cross-Reference Type", ItemCrossRef_lRec."Cross-Reference Type"::"Bar Code");
        ItemCrossRef_lRec.SetFilter("Cross-Reference No.", ScanInput_iTxt);
        if not ItemCrossRef_lRec.FindFirst then begin
            Clear(Item_lRec);
            Item_lRec.SetFilter("No.", ScanInput_iTxt);
            if Item_lRec.FindFirst then begin
                ItemCrossRef_lRec."Item No." := Item_lRec."No.";
            end else begin
                ScanResult_vTxt := 'Artikel ' + ScanInput_iTxt + ' nicht gefunden.';
                // -WF_07
                makeSound();
                // +WF_07
                exit;
            end;
        end;

        Clear(WhsActLine_lRec);
        WhsActLine_lRec.SetRange("Activity Type", WhsHeader_iRec.Type);
        WhsActLine_lRec.SetRange("No.", WhsHeader_iRec."No.");
        WhsActLine_lRec.SetRange("Item No.", ItemCrossRef_lRec."Item No.");
        if not WhsActLine_lRec.FindFirst then begin
            ScanResult_vTxt := 'Artikel ' + ItemCrossRef_lRec."Item No." + ' nicht gefunden in Beleg ' + WhsHeader_iRec."No.";
            exit;
        end;

        if (WhsActLine_lRec."Qty. (Base)" - WhsActLine_lRec."Qty. to Handle (Base)") >= 1 then begin
            WhsActLine_lRec.Validate("Qty. to Handle", WhsActLine_lRec."Qty. to Handle" + 1);
            WhsActLine_lRec.Modify;
        end else begin
            ScanResult_vTxt := 'Restmenge ' + Format(WhsActLine_lRec."Qty. (Base)" - WhsActLine_lRec."Qty. to Handle (Base)") + ' von Artikel ' + ItemCrossRef_lRec."Item No." + ' nicht ausreichend';
            exit;
        end;

        ScanResult_vTxt := 'Scan OK';

        exit;
    end;

    local procedure InitAllScanField_lFnc()
    begin
        ScanInput_gTxt := '';
        ResultScanInput_gTxt := '';
    end;
}

