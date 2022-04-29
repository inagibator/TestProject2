unit K_FCMRemoteClientSetup;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  N_Types, N_BaseF;

type
  TK_FormCMRemoteClientSetup = class(TN_BaseForm)
    BtCancel: TButton;
    BtOK: TButton;
    GBDeviceContext: TGroupBox;
    RBGAServer: TRadioButton;
    RBClientName: TRadioButton;
    RBGALocation: TRadioButton;
    RBServer: TRadioButton;
    RBClientIP: TRadioButton;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure RBGAServerClick(Sender: TObject);
  private
    { Private declarations }
    CurContext : Integer;
    NewContext : Integer;
  public
    { Public declarations }
  end;

var
  K_FormCMRemoteClientSetup: TK_FormCMRemoteClientSetup;

function K_CMRemoteClientSetupDlg(  ) : Boolean;

implementation

uses
//Math,
  K_CM0, K_CML1F;
//  N_Lib0, N_Lib1, N_Comp1, N_CompCL, N_CM1;

{$R *.dfm}

function K_CMRemoteClientSetupDlg(  ) : Boolean;
begin
  with TK_FormCMRemoteClientSetup.Create(Application) do begin
//    BaseFormInit( nil );
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfMFRect,rspfCenter] );

    Result := FALSE; // to prevent warning

    // Get Remote CLient Device Context Type
    N_Dump2Str( 'Start Remote Client Setup' );
    with TK_CMEDDBAccess(K_CMEDAccess) do
    begin
      try
        with CurBlobDSet do
        begin
          ExtDataErrorCode := K_eeDBSelect;
          Connection := LANDBConnection;
          SQL.Text := 'select ' + K_CMENDBGTFDPContType +
            ' from ' + K_CMENDBGlobAttrsTable;
          Filtered := false;
          Open;
          CurContext := FieldList.Fields[0].AsInteger;
          case TK_CMEDDevProfilesSaveMode(CurContext) of
          K_cmdpServer        : RBServer.Checked := TRUE;
          K_cmdpGAServer      : RBGAServer.Checked := TRUE;
          K_cmdpGALocation    : RBGALocation.Checked := TRUE;
          K_cmdpClientName    : RBClientName.Checked := TRUE;
          K_cmdpClientIP      : RBClientIP.Checked := TRUE;
          else
            K_CMShowMessageDlg( K_CML1Form.LLLClientSetup1.Caption,
//            'Wrong Remote Client Device Context saving mode',
                                mtWarning );
            Close;
            Exit;
          end;
          Result := ShowModal() = mrOK;
          if Result and (NewContext <> CurContext) then
          begin
          // Save Device Context Type to DB and if TS Mode change Current Context Type
            Edit;
            FieldList.Fields[0].AsInteger := NewContext;
            UpdateBatch;
//            if K_CMSTermSessionMode then
//              ProfilesSaveMode := TK_CMEDDevProfilesSaveMode(NewContext);
            N_Dump1Str( 'Set New Remote Client Setup Device Context = ' + IntToStr(NewContext) );
            K_CMShowMessageDlg( K_CML1Form.LLLClientSetup2.Caption,
//            'New Device profile context will be applied after Centaur Media Suite restart',
                                mtInformation );
          end
          else
            N_Dump2Str( 'Cancel Remote Client Setup' );
          Close;
        end;
      except
        on E: Exception do
        begin
          ExtDataErrorString := 'Remote Client Setup ' + E.Message;
          EDAShowErrMessage(TRUE);
        end;
      end;
    end;
  end;
end;

procedure TK_FormCMRemoteClientSetup.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := (ModalResult <> mrOK)     or
              (NewContext = CurContext) or
              (mrYes = K_CMShowMessageDlg( K_CML1Form.LLLClientSetup3.Caption,
//    'You are about to change the Device profile context for all remote users.'#13#10 +
//    'This might require the subsequent device installations for them.'#13#10 +
//    '                Are you still willing to proceed?',
    mtConfirmation ) );
end;

procedure TK_FormCMRemoteClientSetup.RBGAServerClick(Sender: TObject);
begin
  if RBServer.Checked then
  begin
    RBGALocation.Checked := FALSE;
    RBClientName.Checked := FALSE;
    RBGAServer.Checked := FALSE;
    RBClientIP.Checked := FALSE;
    NewContext := Integer(K_cmdpServer);
  end
  else
  if RBGAServer.Checked then
  begin
    RBServer.Checked := FALSE;
    RBGALocation.Checked := FALSE;
    RBClientName.Checked := FALSE;
    RBClientIP.Checked := FALSE;
    NewContext := Integer(K_cmdpGAServer);
  end
  else
  if RBGALocation.Checked then
  begin
    RBServer.Checked := FALSE;
    RBGAServer.Checked := FALSE;
    RBClientName.Checked := FALSE;
    RBClientIP.Checked := FALSE;
    NewContext := Integer(K_cmdpGALocation);
  end
  else
  if RBClientName.Checked then
  begin
    RBServer.Checked := FALSE;
    RBGALocation.Checked := FALSE;
    RBGAServer.Checked := FALSE;
    RBClientIP.Checked := FALSE;
    NewContext := Integer(K_cmdpClientName);
  end
  else
  if RBClientIP.Checked then
  begin
    RBServer.Checked := FALSE;
    RBGALocation.Checked := FALSE;
    RBGAServer.Checked := FALSE;
    RBClientName.Checked := FALSE;
    NewContext := Integer(K_cmdpClientIP);
  end
end;

end.
