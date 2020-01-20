pageextension 50102 "ItemCard" extends "Item Card" //30
{
    layout
    {
        addafter(General)
        {
            usercontrol(Beep; beepAddin)
            {
                ApplicationArea = All;

                /*  trigger Ready()
                 begin
                     Message('Is ready');
                 end; */
            }
        }
    }

    actions
    {
        addfirst(Navigation)
        {
            action("Beep1")
            {
                ApplicationArea = All;
                Image = Start;
                ToolTip = 'Make great Music';

                trigger OnAction()
                begin
                    CurrPage.Beep.makeBeep();
                end;
            }
        }
    }
}