unit N_CMCaptDev25aF;

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  StdCtrls, ExtCtrls, Forms, Dialogs,
  K_CM0, N_Types, N_Lib1, N_BaseF, N_CMCaptDev0, IniFiles, K_CLib0, N_Lib0,
  K_FPathNameFr;

type TN_CMCaptDev25aForm = class( TN_BaseForm )
  bnOK:             TButton;
  SrcMailslotFrame: TK_FPathNameFrame;
  SrcImagesFrame:   TK_FPathNameFrame;
  edNumber:         TEdit;
  lbLineNumber:     TLabel;
  lbOrderNumber:    TLabel;
  edOrderNumber:    TEdit;
  Apply:            TButton;
    edMailslotName: TEdit;
    lbName: TLabel;

  // ***** events handlers
  procedure bnOKClick        ( Sender: TObject );
  procedure RadioGroup1Click ( Sender: TObject );
  procedure FormShow         ( Sender: TObject );
  procedure ApplyClick       ( Sender: TObject );
    procedure lbNameClick(Sender: TObject);

  public
    CMOFPDevProfile: TK_PCMDeviceProfile;
end;

implementation
{$R *.dfm}

uses
  N_CMCaptDev25, K_CM1;

//******************************************* TN_CMCaptDev25aForm.bnOKClick ***
// Button "OK" click event handler
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev25aForm.ApplyClick(Sender: TObject);
begin
  inherited;
  N_Dump1Str( 'Order Number Starting Point Changed To = ' +
                                                           edOrderNumber.Text );
  K_CMSetUserString( 'SlidaOrderNumber', edOrderNumber.Text );
  K_CMSaveUserStrings();
end;

procedure TN_CMCaptDev25aForm.bnOKClick( Sender: TObject );
begin
  // creating a final string

  SrcMailslotFrame.mbPathName.Text :=
       StringReplace( SrcMailslotFrame.mbPathName.Text, '/', '\', [rfReplaceAll,
                                                                rfIgnoreCase] );
  SrcImagesFrame.mbPathName.Text :=
       StringReplace( SrcImagesFrame.mbPathName.Text, '/', '\', [rfReplaceAll,
                                                                rfIgnoreCase] );

  CMOFPDevProfile.CMDPStrPar1 :=
              IncludeTrailingPathDelimiter( SrcMailslotFrame.mbPathName.Text ) +
                                                   edMailslotName.Text + '/~/' +
                IncludeTrailingPathDelimiter( SrcImagesFrame.mbPathName.Text ) +
                                                          '/#/' + edNumber.Text;
end; // procedure TN_CMCaptDev25aForm.bnOKClick

//******************************************** TN_CMCaptDev25aForm.FormShow ***
// FormShow event handler
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev25aForm.FormShow( Sender: TObject );
begin
  inherited;

  // ***** parsing a string
  if CMOFPDevProfile.CMDPStrPar1 <> '' then
  begin
    SrcMailslotFrame.mbPathName.Text := Copy( CMOFPDevProfile.CMDPStrPar1, 0,
                                  Pos( '/~/',CMOFPDevProfile.CMDPStrPar1) - 1 );
    edMailslotName.Text := ExtractFileName( SrcMailslotFrame.mbPathName.Text );
    SrcMailslotFrame.mbPathName.Text := ExtractFilePath( SrcMailslotFrame.mbPathName.Text );
    SrcImagesFrame.mbPathName.Text := Copy( CMOFPDevProfile.CMDPStrPar1,
                                  Pos( '/~/',CMOFPDevProfile.CMDPStrPar1 ) + 3,
                                  Pos( '/#/',CMOFPDevProfile.CMDPStrPar1 ) -
                                  Pos( '/~/',CMOFPDevProfile.CMDPStrPar1) - 3 );
    edNumber.Text := Copy( CMOFPDevProfile.CMDPStrPar1,
                                  Pos( '/#/',CMOFPDevProfile.CMDPStrPar1 ) + 3,
                                          Length(CMOFPDevProfile.CMDPStrPar1) );
  end
  else
    edMailslotName.Text := 'sidexis.sdx';

  //***** set previous order number to an edit component
  K_CMLoadUserStrings();
  edOrderNumber.Text := K_CMGetUserString( 'SlidaOrderNumber' );
  if StrToIntDef( edOrderNumber.Text, 0 ) < 2  then
    edOrderNumber.Text := '2'; // starting point

  K_CMSetUserString( 'SlidaOrderNumber', edOrderNumber.Text );

  N_Dump1Str( 'Order Number after changing = ' + edOrderNumber.Text );
end; procedure TN_CMCaptDev25aForm.lbNameClick(Sender: TObject);
begin
  inherited;

end;

// procedure TN_CMCaptDev25aForm.FormShow( Sender: TObject );

//************************************ TN_CMCaptDev25aForm.RadioGroup1Click ***
// Chosed a device mode event
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev25aForm.RadioGroup1Click( Sender: TObject );
begin
  inherited;
  // save chosed mode (actual mode will be more by 1 then a chosed index)
end; // procedure TN_CMCaptDev25aForm.RadioGroup1Click

end.
