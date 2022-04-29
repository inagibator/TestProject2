unit K_FCMLinkCLFSetup;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  N_Types, N_BaseF;

type
  TK_FormCMLinkCLFSetup = class(TN_BaseForm)
    BtCancel: TButton;
    BtOK: TButton;
    RBCL2000: TRadioButton;
    RBVW: TRadioButton;
    RBIni: TRadioButton;
    RBUDVW: TRadioButton;
    RBNone: TRadioButton;
    BtSetup: TButton;
    procedure RBVWClick(Sender: TObject);
    procedure BtSetupClick(Sender: TObject);
  private
    { Private declarations }
    NewMode : Integer;
    NewFormat : string;
  public
    { Public declarations }
  end;

var
  K_FormCMLinkCLFSetup: TK_FormCMLinkCLFSetup;

function K_CMSLinkCLFSetup(  ) : Boolean;

implementation

uses
//Math,
  K_CML1F, K_CM0, K_FEText;
//  N_Lib0, N_Lib1, N_Comp1, N_CompCL, N_CM1;

{$R *.dfm}

function K_CMSLinkCLFSetup(  ) : Boolean;
begin
  with TK_FormCMLinkCLFSetup.Create(Application) do begin
//    BaseFormInit( nil );
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfMFRect,rspfCenter] );

    Result := FALSE; // to prevent warning

    // Get Remote CLient Device Context Type
    N_Dump2Str( 'Start Standalone Mode Setup' );
    with TK_CMEDDBAccess(K_CMEDAccess) do
    begin
      try
        with CurBlobDSet do
        begin
          ExtDataErrorCode := K_eeDBSelect;
          Connection := LANDBConnection;
          SQL.Text := 'select ' + K_CMENDBGTFLinkCLMode + ',' + K_CMENDBGTFLinkCLUDFormat +
            ' from ' + K_CMENDBGlobAttrsTable;
          Filtered := false;
          Open;
          Byte(K_CMSLinkCommandLineFormatMode) := Fields[0].AsInteger;
          K_CMSLinkCommandLineUDFormat := Fields[1].AsString;

          case K_CMSLinkCommandLineFormatMode of
          K_cmclfNone   : RBNone.Checked := TRUE;
          K_cmclfCL2000 : RBCL2000.Checked := TRUE;
          K_cmclfVW     : RBVW.Checked := TRUE;
          K_cmclfIni    : RBIni.Checked := TRUE;
          K_cmclfUDVW   : RBUDVW.Checked := TRUE;
          else
            K_CMShowMessageDlg( K_CML1Form.LLLLinkCLFSetup1.Caption, mtWarning );
            Close;
            Exit;
          end;
          BtSetup.Enabled := RBUDVW.Checked;

          NewMode := Ord(K_CMSLinkCommandLineFormatMode);
          NewFormat := K_CMSLinkCommandLineUDFormat;
          Result := ShowModal() = mrOK;
          if Result and
             (NewMode <> Ord(K_CMSLinkCommandLineFormatMode)) and
             (mrYes = K_CMShowMessageDlg( K_CML1Form.LLLLinkCLFSetup2.Caption + ' ' +
                                          K_CML1Form.LLLPressYesToProceed.Caption,
                                          mtConfirmation )) then
          begin
            K_CMSLinkCommandLineFormatMode := TK_CMSLinkCommandLineFormatMode(NewMode);
            Edit;
            FieldList.Fields[0].AsInteger := NewMode;
            UpdateBatch;
            N_Dump1Str( 'Set link command line format = ' + IntToStr(NewMode) );
          end
          else
            N_Dump2Str( 'Cancel link command line format' );
          Close;
        end;
      except
        on E: Exception do
        begin
          ExtDataErrorString := 'Link command line format ' + E.Message;
          EDAShowErrMessage(TRUE);
        end;
      end;
    end;
  end;
end;

procedure TK_FormCMLinkCLFSetup.RBVWClick(Sender: TObject);
begin
  if RBNone.Checked then
  begin
    RBCL2000.Checked := FALSE;
    RBVW.Checked := FALSE;
    RBIni.Checked := FALSE;
    RBUDVW.Checked := FALSE;
    NewMode := Integer(K_cmclfNone);
  end
  else
  if RBCL2000.Checked then
  begin
    RBNone.Checked := FALSE;
    RBVW.Checked := FALSE;
    RBIni.Checked := FALSE;
    RBUDVW.Checked := FALSE;
    NewMode := Integer(K_cmclfCL2000);
  end
  else
  if RBVW.Checked then
  begin
    RBNone.Checked := FALSE;
    RBCL2000.Checked := FALSE;
    RBIni.Checked := FALSE;
    RBUDVW.Checked := FALSE;
    NewMode := Integer(K_cmclfVW);
  end
  else
  if RBIni.Checked then
  begin
    RBNone.Checked := FALSE;
    RBCL2000.Checked := FALSE;
    RBVW.Checked := FALSE;
    RBUDVW.Checked := FALSE;
    NewMode := Integer(K_cmclfINI);
  end
  else
  if RBUDVW.Checked then
  begin
    RBNone.Checked := FALSE;
    RBCL2000.Checked := FALSE;
    RBVW.Checked := FALSE;
    RBIni.Checked := FALSE;
    NewMode := Integer(K_cmclfUDVW);
  end;
  BtSetup.Enabled := RBUDVW.Checked;

end;

procedure TK_FormCMLinkCLFSetup.BtSetupClick(Sender: TObject);
var
  UDText : string;
label ContinueEdit;
begin
//
ContinueEdit:
  with K_GetFormTextEdit do
  begin
    MMemo.WordWrap := TRUE;
    MMemo.Color := $00A2FFFF;
    UDText := NewFormat;
    if UDText = '' then
      UDText := '"K1" <PatID> "K2" <PatSurname> "K3" <PatFirstName> "K4" <PatientDOB> "K5" <PatCard> ' + #13#10 +
                '"K6" <ProvID> "K7" <ProvSurname> "K8" <ProvFirstName> ' + #13#10 +
                '"K9" <LocID> "K10" <LocName> "K11" <CP>';
    if not EditText( UDText, 'User defined Command Line link' ) then Exit;
    if UDText = K_CMSLinkCommandLineUDFormat then Exit;

    if mrOK <> K_CMShowMessageDlg( format( K_CML1Form.LLLLinkCLFSetup3.Caption,[UDText] ),
                                          mtInformation, [mbOK, mbCancel] ) then goto ContinueEdit;
    NewFormat := UDText;

    with TK_CMEDDBAccess(K_CMEDAccess) do
    begin
      try
        with CurBlobDSet do
        begin
          Edit;
          Fields[1].AsString := NewFormat;
          UpdateBatch;
        end;
        K_CMSLinkCommandLineUDFormat := NewFormat;
      except
        on E: Exception do
        begin
          ExtDataErrorString := 'Link command line UD format ' + E.Message;
          EDAShowErrMessage(TRUE);
        end;
      end;
    end;
  end;
end;

end.
