unit K_FCMRegister;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,
  N_BaseF, ExtCtrls;

type
  TK_FormCMRegister = class(TN_BaseForm)
    MemRegInfo: TMemo;
    BtOK: TButton;
    BtChangeReg: TButton;
    OpenDialog: TOpenDialog;
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BtChangeRegClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    SaveCursor : TCursor;
  public
    { Public declarations }
    ML : TStringList;
  end;

var
  K_FormCMRegister: TK_FormCMRegister;

implementation

uses IniFiles, ADODB,
  K_CM0, K_CLib0, K_MapiControl, K_FCMRegCode,
  N_Types, N_Lib0, N_CM1, N_CMMain5F, N_CMResF, K_CML1F;

{$R *.dfm}

//*********************************** TK_FormCMRegister.FormCloseQuery ***
//  Form Close Query Event Handler
//
procedure TK_FormCMRegister.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  ML.Free;
end; // end of procedure TK_FormCMRegister.FormCloseQuery

//*********************************** TK_FormCMRegister.FormShow ***
//  Form Show Event Handler
//
procedure TK_FormCMRegister.FormShow(Sender: TObject);
var
  RegInfoText : string;
begin
  SaveCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;

  with TK_CMEDDBAccess(K_CMEDAccess) do begin
    ML.Clear;
    if (K_CMSLiRegState <> K_lrsDBTrialExpired) and
       (K_CMSLiRegState <> K_lrsDBTrial) then
//    if TRUE then
    begin
      RegInfoText := RegInfoText + K_CML1Form.LLLRegister6.Caption + #13#10;
//        'The system has detected that Centaur Media Suite is registered for (#LI#)(#L#) user license(s).'#13#10;

      if K_CMSLiRegState = K_lrsNumConExceeded then
        RegInfoText := RegInfoText + K_CML1Form.LLLRegister7.Caption + #13#10;
//          'Number of allowed connections to Media Suite Database exceeded.'#13#10;

      RegInfoText := RegInfoText + K_CML1Form.LLLRegister8.Caption + #13#10;
//          'The Media Suite Database Server (Computer) Identification Number is: (#ID#).'#13#10;

//      RegInfoText := RegInfoText#13#10;

      if K_CMSLiRegState = K_lrsUnregCMSBuild then
        RegInfoText := RegInfoText + K_CML1Form.LLLRegister9.Caption + #13#10
//          'Your Media Suite build (#VN#) differs from registered build (#VNR#)!' +  Chr($0D) + Chr($0A)
      else
        RegInfoText := RegInfoText + K_CML1Form.LLLRegister10.Caption + #13#10;
//          'The Media Suite build is (#VNR#) (#RegType#).'#13#10;

//      RegInfoText := RegInfoText#13#10;

      if not K_CMShowEnterprise() then
      begin
        if K_CMSLiRegStatus = K_lrtLight then
          ML.Add( 'RegType=' + K_CML1Form.LLLRegisterType.Items[0] )
//          ML.Add( 'RegType=Light' )
        else if K_CMSLiRegStatus = K_LrtEnterprise then
          ML.Add( 'RegType=' + K_CML1Form.LLLRegisterType.Items[2] )
//          ML.Add( 'RegType=Enterprise' )
        else
          ML.Add( 'RegType=' + K_CML1Form.LLLRegisterType.Items[1] );
//          ML.Add( 'RegType=Professional' );
      end
      else
        ML.Add( 'RegType=' + K_CML1Form.LLLRegisterType.Items[2] );
//        ML.Add( 'RegType=Enterprise' );

      if K_CMSLiRegState = K_lrsEnterpriseUnreg then
      begin
  //      RegInfoText := RegInfoText#13#10;
        RegInfoText := RegInfoText + K_CML1Form.LLLRegister11.Caption + #13#10;
//          'You need to registered to use Media Suite in Enterprise Mode.'#13#10;
      end;
    end
    else
    begin
      RegInfoText := RegInfoText + K_CML1Form.LLLRegister12.Caption + #13#10;
//        'The system has detected that Centaur Media Suite is not registered.'#13#10;
      if K_CMSLiRegState = K_lrsDBTrial then
        RegInfoText := RegInfoText + K_CML1Form.LLLRegister13.Caption + #13#10
//          'The system will be able to work for (#TM#), after that it will become unusable.'#13#10
      else
        RegInfoText := RegInfoText + K_CML1Form.LLLRegister14.Caption + #13#10;
//          'The Database trial period is already expired and Centaur Media Suite is now unusable.'#13#10;

      RegInfoText := RegInfoText + K_CML1Form.LLLRegister8.Caption + #13#10;
//      RegInfoText := RegInfoText + K_CML1Form.LLLRegister15.Caption + #13#10;
//          'The Media Suite Database Server (Computer) Identification Number is: (#ID#).'#13#10;

//      RegInfoText := RegInfoText#13#10 +
      RegInfoText := RegInfoText + K_CML1Form.LLLRegister16.Caption + #13#10;
//        'The Media Suite build is (#VN0#).'#13#10;
    end;

    RegInfoText := RegInfoText + #13#10;

    ML.Add( 'VN0=' + N_CMSVersion );
    ML.Add(  'VN=' + copy( N_CMSVersion, 1, 6) );
    if Length(K_CMSLiRegBuildInfo) > 2 then
      ML.Add( 'VNR=' + copy( K_CMSLiRegBuildInfo, 1, Length(K_CMSLiRegBuildInfo) - 3 ) +
                 '.' + copy( K_CMSLiRegBuildInfo, Length(K_CMSLiRegBuildInfo) - 2, 3 ) )
    else
      ML.Add( 'VNR=' + copy( N_CMSVersion, 1, 6) );

    if (K_CMSLiRegState >= K_lrsOK) then
      EDAAddRegInfoStrings( ML )
    else
      ML.AddStrings( K_CMSLiRegMacroInfo );

//  ParseDBTrialExpiredInfo();
    K_CMParseLiDBTrialExpiredInfo( ML );

    case K_CMSLiRegState of
      K_lrsOK : begin
        if K_CMSLiRegStatus = K_lrtLight then
          RegInfoText := RegInfoText + K_CML1Form.LLLRegister17.Caption
//            'To purchase additional Media Suite user licenses or change version type to Professional please call (#N#) on (#PH#) or email to (#E#) for a registration code.'
        else
          RegInfoText := RegInfoText + K_CML1Form.LLLRegister18.Caption;
//            'To purchase additional Media Suite user licenses please call (#N#) on (#PH#) or email to (#E#) for a registration code.';
      end;
      K_lrsDBTrial: RegInfoText := RegInfoText + K_CML1Form.LLLRegister19.Caption;
//        'To get your registration code please call (#N#) on (#PH#) or email to (#E#).';
      K_lrsNumConExceeded,
      K_lrsDBTrialExpired,
      K_lrsUnregCMSBuild: RegInfoText := RegInfoText + K_CML1Form.LLLRegister20.Caption;
//        'To solve the problem please call (#N#) on (#PH#) or email to (#E#).';
    end;
  end;

  RegInfoText := K_StringMListReplace( RegInfoText, ML, K_ummRemoveMacro );
  MemRegInfo.Lines.Text := RegInfoText;

  Screen.Cursor := SaveCursor;

end; // end of procedure TK_FormCMRegister.FormShow

//*********************************** TK_FormCMRegister.BtChangeRegClick ***
//  Change Registration Button Click Handler
//
procedure TK_FormCMRegister.BtChangeRegClick(Sender: TObject);
var
  WStr : string;
  PrevCMSLiRegState : TK_CMSLiRegState;
  RegCode : string;
  DBConnection: TADOConnection;
  TextPos : Integer;
  RegistrationOK : Integer;
  // =0 - OK,
  // =1 - Bad Registration Code,
  // =2 - Exceeded the number of users currently registered

label LBadRegCodeExit;

  function CheckDBRegistration( ) : Integer;
  begin
    with K_CMEDAccess do
    try
//      Raise Exception.Create( 'Connection limit' ); //!!!Debug code to check >> Exceeded the number of users currently registered

      DBConnection := TADOConnection.Create( Application );
      DBConnection.ConnectionString :=
//                  K_CMDBGetConnectionString( RegCode + K_CMDBGetSessionID() );
                  K_CMDBGetConnectionString( RegCode );

// !!!2020-12-03 don't dump DB Connection string because of security
//      N_Dump2Str( 'DB>> Open RegDB connection >= ' + DBConnection.ConnectionString );

      N_CM_MainForm.CMMFShowString( K_CML1Form.LLLRegister5.Caption
//        ' Media Suite Database registration is started. Wait please ...'
                                  );
      SaveCursor := Screen.Cursor;
      Screen.Cursor := crHourglass;
      DBConnection.Open(); // Registration
      Screen.Cursor := SaveCursor;
      DBConnection.Free;
      Result := 0; // Registration is OK

    except
      on E: Exception do begin
        ExtDataErrorString := E.Message;
        N_Dump2Str( 'DB>> Err RegDB connection >= ' + ExtDataErrorString );
        Screen.Cursor := SaveCursor;
        DBConnection.Free;
        TextPos := Pos('Connection limit', ExtDataErrorString);
        if TextPos > 0 then
          Result := 2 // Exceeded the number of users currently registered
        else
        begin
          Result := 1; // Bad Registration Code
          if (Pos( 'Trial period expired', ExtDataErrorString )= 0) and
             (Pos( 'Bad registration code', ExtDataErrorString ) = 0) then
            EDAShowErrMessage( TRUE ); // Uknown exception - Raise System Errow message and close CMS
        end;
      end;
    end;
  end;

begin
// Get Registration Code Dialog

//  if FALSE then begin // Test Registration Change !!!
  if not K_CMGetRegCodeDlg( RegCode ) then begin
  // Cancel Change RegCode
    Exit;
  end;

//  if FALSE then begin // Test Registration Change !!!
  if Length(RegCode) < 8  then
  begin
LBadRegCodeExit:
    K_CMShowMessageDlg1( K_CML1Form.LLLRegister1.Caption,
// 'You entered incorrect CMS Database Registration Code.'#13#10 +
// '                              Please reenter',
                         mtWarning );
    Exit;
  end;

 // Continue DB Register
  N_Dump2Str( 'DB Registration start' );

  PrevCMSLiRegState := K_CMSLiRegState;

  RegistrationOK := CheckDBRegistration( );
  if RegistrationOK = 1 then
    goto LBadRegCodeExit
  else
  if RegistrationOK = 2 then
  begin
    // Prepare to close CMS
    K_CMShowMessageDlg( K_CML1Form.LLLRegister2.Caption,
//'You have exceeded the number of users currently registered.'#13#10 +
//'            Centaur Media Suite will close now.',
                        mtWarning );

    N_CM_MainForm.CMMCallActionByTimer( N_CMResForm.aServCloseCMS, TRUE );
    Self.ModalResult := mrOK;
    Exit;
  end;

//  K_CMSLiRegState := K_lrsOK;
//  K_CMSLiRegState := K_lrsDBTrial;
  if (PrevCMSLiRegState = K_lrsDBTrialExpired)  or
     (PrevCMSLiRegState = K_lrsNumConExceeded)  or
     (PrevCMSLiRegState = K_lrsEnterpriseUnreg) or
     (PrevCMSLiRegState = K_lrsEnterpriseErr) then
  // CMS cur DB Connection was closed - New DB Connection will be opened inside EDAInit()
    K_CMEDAccess.EDAInit()
  else
  // CMS cur DB Connection is opened - Get new registration Info Only
    TK_CMEDDBAccess(K_CMEDAccess).EDAGetVersionRegInfo( ); // get Version Info after Registration

  FormShow(Sender); // Rebuild Registration Info Text

 // Rebuild CMS actions State according to new Registration State
  if (K_CMSLiRegState < K_lrsOK) then
    Include(N_CM_MainForm.CMMUICurStateFlags, uicsAllActsDisabled)
  else
    Exclude(N_CM_MainForm.CMMUICurStateFlags, uicsAllActsDisabled);
  N_CM_MainForm.CMMFDisableActions( nil );

  if not K_CMD4WAppRunByCOMClient and not K_CMEDAccess.AccessReady then
  begin
  //
  // Show Restart  Warning if not D4W Client Mode and Registration is called during CMS Initialization
  //
    WStr := K_CML1Form.LLLRegister3.Caption; // 'System registration parameters are changed.';
    if (PrevCMSLiRegState = K_lrsDBTrialExpired)  or
       (PrevCMSLiRegState = K_lrsNumConExceeded)  or
       (PrevCMSLiRegState = K_lrsEnterpriseUnreg) or
       (PrevCMSLiRegState = K_lrsUnregCMSBuild) then
      WStr := WStr + #13#10'       ' + K_CML1Form.LLLRegister4.Caption;
//                   #13#10'       Please restart Media Suite.';
    K_CMShowMessageDlg1( WStr, mtInformation );
  end;

  N_Dump1Str( 'DB Registration fin' );
end; // end of procedure TK_FormCMRegister.BtChangeRegClick

procedure TK_FormCMRegister.FormCreate(Sender: TObject);
begin
  ML := TStringList.Create;
end;

end.
