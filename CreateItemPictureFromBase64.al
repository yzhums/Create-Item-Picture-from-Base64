pageextension 50118 ZYItemPictureExt extends "Item Picture"
{
    actions
    {
        addafter(TakePicture)
        {
            action(ImportPictureFromiEncodedText)
            {
                Caption = 'Import Picture From Encoded Text';
                Image = Import;
                ApplicationArea = All;

                trigger OnAction()
                var
                    PictureEncodedTextDialog: Page "Picture Encoded Text Dialog";
                begin
                    PictureEncodedTextDialog.SetItemInfo(Rec."No.", Rec.Description);
                    if PictureEncodedTextDialog.RunModal() = Action::OK then
                        PictureEncodedTextDialog.ImportPictureFromiEncodedText();
                end;
            }
        }
    }
}

page 50102 "Picture Encoded Text Dialog"
{
    PageType = StandardDialog;
    Caption = 'Picture Encoded Text Dialog';

    layout
    {
        area(content)
        {
            field(ItemNo; ItemNo)
            {
                ApplicationArea = All;
                Caption = 'Item No.';
                Editable = false;
            }
            field(ItemDesc; ItemDesc)
            {
                ApplicationArea = All;
                Caption = 'Item Description';
                Editable = false;
            }
            field(PictureEncodedTextDialog; PictureEncodedTextDialog)
            {
                ApplicationArea = All;
                Caption = 'Picture Encoded Text';
                MultiLine = true;
            }
        }
    }
    var
        ItemNo: Code[20];
        ItemDesc: Text[100];
        PictureEncodedTextDialog: Text;

    procedure SetItemInfo(NewItemNo: Code[20]; NewItemDesc: Text[100])
    begin
        ItemNo := NewItemNo;
        ItemDesc := NewItemDesc;
    end;

    procedure ImportPictureFromiEncodedText()
    var
        FileManagement: Codeunit "File Management";
        FileName: Text;
        ClientFileName: Text;
        InStr: InStream;
        OutStr: OutStream;
        TempBlob: Codeunit "Temp Blob";
        Item: Record Item;
        OverrideImageQst: Label 'The existing picture will be replaced. Do you want to continue?';
        MustSpecifyDescriptionErr: Label 'You must add a description to the item before you can import a picture.';
        Base64Convert: Codeunit "Base64 Convert";
    begin
        if Item.Get(ItemNo) then begin
            if Item.Description = '' then
                Error(MustSpecifyDescriptionErr);

            if Item.Picture.Count > 0 then
                if not Confirm(OverrideImageQst) then
                    Error('');
            FileName := ItemDesc + '.png';
            TempBlob.CreateOutStream(OutStr);
            Base64Convert.FromBase64(PictureEncodedTextDialog, OutStr);
            TempBlob.CreateInStream(InStr);

            Clear(Item.Picture);
            Item.Picture.ImportStream(InStr, FileName);
            Item.Modify(true);
        end;
    end;
}
