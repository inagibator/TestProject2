unit N_CMCaptDev17aF;

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, StdCtrls, ExtCtrls, Forms, Dialogs, ShlObj,
  K_CM0, K_CLib0,
  N_Types, N_Lib1, N_BaseF, N_CMCaptDev17F, N_CMCaptDev0, N_CML2F, N_CMCaptDev17;

type TN_CMCaptDev17aForm = class( TN_BaseForm )
    bnOK:     TButton;
    StatusShape:    TShape;
    StatusLabel:    TLabel;
    bnSetup: TButton;
    procedure bnOKClick ( Sender: TObject );
    procedure OnCommand( var Msg: TMessage ); message WM_PROGENY_COMMAND;
    procedure OnHandle( var Msg: TMessage );  message WM_PROGENY_HANDLE;
    procedure FormActivate(Sender: TObject); override;
    procedure FormClose(Sender: TObject; var Action: TCloseAction); override;
    procedure FormShow(Sender: TObject);
    procedure bnSetupClick(Sender: TObject);

  public
    CMOFPDevProfile: TK_PCMDeviceProfile; // Pointer to Profile
    ThisForm:        TN_CMCaptDev17aForm; // Pointer to this form
    N_CMCDServObj17: TN_CMCDServObj17;
end;

implementation

{$R *.dfm}

//******************************************** TN_CMCaptDev13aForm.bnOKClick ***
// Button "OK" click event handle
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev17aForm.bnOKClick( Sender: TObject );
begin
  PostMessage( HWND(ProgenyHandle), WM_PROGENY_COMMAND, 1, 0 );
end; // procedure TN_CMCaptDev17aForm.bnOKClick

//**************************************** TN_CMCaptDev17aForm.bnSetupClick ***
// form activate event handle
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev17aForm.bnSetupClick(Sender: TObject);
begin
  inherited;
  PostMessage( HWND(ProgenyHandle), WM_PROGENY_COMMAND, 2, 0 );
end; // procedure TN_CMCaptDev17aForm.bnSetupClick

//**************************************** TN_CMCaptDev17aForm.FormActivate ***
// form activate event handle
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev17aForm.FormActivate( Sender: TObject );
var
  WrkDir, LogDir, CurDir, FileName, cmd: String;
  Res: Boolean;
  FormHandle, ResCode: Integer;
begin
  inherited;

  ProgenyHandle := 0;
  WrkDir       := K_ExpandFileName( '(#TmpFiles#)' );
  LogDir       := N_CMV_GetLogDir();
  CurDir       := ExtractFilePath( ParamStr( 0 ) );
  N_Dump1Str( 'Progeny >> Exe directory = "' + CurDir + '"' );
  FileName  := CurDir + 'Progeny\Progeny.exe'; // driver path

  FormHandle := ThisForm.Handle;

  N_Dump1Str( 'CDSCaptureImages before CDSInitAll' );
  ResCode := N_CMCDServObj17.CDSInitAll( GroupName, ProductName );
  N_Dump1Str( 'CDSCaptureImages After CDSInitAll ' + IntToStr(ResCode) );

  // wait old driver session closing
  N_CMV_WaitProcess( False, FileName, -1 );

  if not FileExists( FileName ) then // find driver
  begin
    Exit;
  end; // if not FileExists( FileName ) then // find driver

  N_CMCDServObj17.CDSInitAll( CMOFPDevProfile.CMDPGroupName,
                                              CMOFPDevProfile.CMDPProductName );
  cmd := '"' + WrkDir + '" "' + IntToStr( FormHandle ) + '" "' +
                                                       IntToStr( Device ) + '"';

  // start driver executable file with command line parameters
  Res := N_CMV_CreateProcess( '"' + FileName + '" ' + cmd );

  if not Res then // if driver start fail
  begin
    Exit;
  end; // if not Result then // if driver start fail
end; // procedure TN_CMCaptDev17aForm.FormActivate

procedure TN_CMCaptDev17aForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  inherited;
end;

//******************************************** TN_CMCaptDev13aForm.FormShow ***
// Form show event
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev17aForm.FormShow(Sender: TObject);
begin
  inherited;
  bnSetup.Enabled := False;
end; // procedure TN_CMCaptDev17aForm.FormShow

//******************************************* TN_CMCaptDev13aForm.OnCommand ***
// Windows message from Progeny ( reply )
//
//     Parameters
// Msg - incoming Windows message
//
procedure TN_CMCaptDev17aForm.OnCommand( var Msg: TMessage );
var
  WP, LP: Integer;
  // set aquired status
  procedure SetStatus( Status: Integer );
  begin
    case LP of
        0: begin
          StatusLabel.Caption := N_CML2Form.LLLOther3Disconnected.Caption;
          StatusLabel.Font.Color  := clRed;
          StatusShape.Pen.Color   := clRed;
          StatusShape.Brush.Color := clRed;
          bnSetup.Enabled := False;
        end;
        1: begin
          StatusLabel.Caption := N_CML2Form.LLLOther3Disconnected.Caption;
          StatusLabel.Font.Color  := clRed;
          StatusShape.Pen.Color   := clRed;
          StatusShape.Brush.Color := clRed;
          bnSetup.Enabled := False;
        end;
        2: begin
          StatusLabel.Caption := N_CML2Form.LLLOther3Disconnected.Caption;
          StatusLabel.Font.Color  := clRed;
          StatusShape.Pen.Color   := clRed;
          StatusShape.Brush.Color := clRed;
          bnSetup.Enabled := False;
        end;
        3: begin
          StatusLabel.Caption := 'Ready';
          StatusLabel.Font.Color  := TColor( $168EF7 ); // orange color
          StatusShape.Pen.Color   := TColor( $168EF7 );
          StatusShape.Brush.Color := TColor( $168EF7 );
          bnSetup.Enabled := True;
        end;
        4: begin
          StatusLabel.Caption := 'Optimizing captured image';
          StatusLabel.Font.Color  := clBlue;
          StatusShape.Pen.Color   := clBlue;
          StatusShape.Brush.Color := clBlue;
        end;
        5: begin
          StatusLabel.Caption := 'Optimizing captured image';
          StatusLabel.Font.Color  := clBlue;
          StatusShape.Pen.Color   := clBlue;
          StatusShape.Brush.Color := clBlue;
        end;
        6: begin
          StatusLabel.Caption := N_CML2Form.LLLOther3Error.Caption;
          StatusLabel.Font.Color  := clRed;
          StatusShape.Pen.Color   := clRed;
          StatusShape.Brush.Color := clRed;
        end;
        7: begin
          StatusLabel.Caption := N_CML2Form.LLLOther3Error.Caption;
          StatusLabel.Font.Color  := clRed;
          StatusShape.Pen.Color   := clRed;
          StatusShape.Brush.Color := clRed;
        end;
        8: begin
          StatusLabel.Caption := N_CML2Form.LLLOther3Error.Caption;
          StatusLabel.Font.Color  := clRed;
          StatusShape.Pen.Color   := clRed;
          StatusShape.Brush.Color := clRed;
        end;
        9: begin
          //StatusLabel.Caption := 'Capture cancelled';
          StatusLabel.Font.Color  := clBlue;
          StatusShape.Pen.Color   := clBlue;
          StatusShape.Brush.Color := clBlue;
        end;
        10: begin
          StatusLabel.Caption := N_CML2Form.LLLOther3Error.Caption;
          StatusLabel.Font.Color  := clRed;
          StatusShape.Pen.Color   := clRed;
          StatusShape.Brush.Color := clRed;
        end;
        11: begin
          StatusLabel.Caption := N_CML2Form.LLLOther3Error.Caption;
          StatusLabel.Font.Color  := clBlue;
          StatusShape.Pen.Color   := clBlue;
          StatusShape.Brush.Color := clBlue;
        end;
        12: begin
          //StatusLabel.Caption := 'Device added';
          StatusLabel.Font.Color  := clBlue;
          StatusShape.Pen.Color   := clBlue;
          StatusShape.Brush.Color := clBlue;
        end;
        13: begin
          //StatusLabel.Caption := 'Clear';
          StatusLabel.Font.Color  := clBlue;
          StatusShape.Pen.Color   := clBlue;
          StatusShape.Brush.Color := clBlue;
        end;
        14: begin
          StatusLabel.Caption := 'Ready';
          StatusLabel.Font.Color  := clGreen;
          StatusShape.Pen.Color   := clGreen;
          StatusShape.Brush.Color := clGreen;
        end;
        15: begin
          StatusLabel.Caption := 'Capturing image';
          StatusLabel.Font.Color  := clBlue;
          StatusShape.Pen.Color   := clBlue;
          StatusShape.Brush.Color := clBlue;
        end;
        16: begin
          StatusLabel.Caption := 'Capturing image';
          StatusLabel.Font.Color  := clBlue;
          StatusShape.Pen.Color   := clBlue;
          StatusShape.Brush.Color := clBlue;
        end;
        17: begin
          StatusLabel.Caption := 'Capturing image';
          StatusLabel.Font.Color  := clBlue;
          StatusShape.Pen.Color   := clBlue;
          StatusShape.Brush.Color := clBlue;
        end;
        18: begin
          StatusLabel.Caption := 'Capturing image';
          StatusLabel.Font.Color  := clBlue;
          StatusShape.Pen.Color   := clBlue;
          StatusShape.Brush.Color := clBlue;
        end;
        19: begin
          StatusLabel.Caption := N_CML2Form.LLLOther3Error.Caption;
          StatusLabel.Font.Color  := clRed;
          StatusShape.Pen.Color   := clRed;
          StatusShape.Brush.Color := clRed;
        end;
        20: begin
          StatusLabel.Caption := N_CML2Form.LLLOther3Error.Caption;
          StatusLabel.Font.Color  := clRed;
          StatusShape.Pen.Color   := clRed;
          StatusShape.Brush.Color := clRed;
        end;
        21: begin
          StatusLabel.Caption := N_CML2Form.LLLOther3Error.Caption;
          StatusLabel.Font.Color  := clRed;
          StatusShape.Pen.Color   := clRed;
          StatusShape.Brush.Color := clRed;
        end;
        22: begin
          StatusLabel.Caption := 'Optimizing captured image';
          StatusLabel.Font.Color  := clBlue;
          StatusShape.Pen.Color   := clBlue;
          StatusShape.Brush.Color := clBlue;
          //FlagReady := False;
        end;
        23: begin
          StatusLabel.Caption := 'N_CML2Form.LLLOther3Error.Caption';
          StatusLabel.Font.Color  := clRed;
          StatusShape.Pen.Color   := clRed;
          StatusShape.Brush.Color := clRed;
        end;

        // extra, only for cms
        24: begin
          StatusLabel.Caption := 'Device Initialization';
          StatusLabel.Font.Color  := TColor( $168EF7 ); // orange color
          StatusShape.Pen.Color   := TColor( $168EF7 );
          StatusShape.Brush.Color := TColor( $168EF7 );
        end;
        25: begin
          StatusLabel.Caption := N_CML2Form.LLLOther3Disconnected.Caption;
          StatusLabel.Font.Color  := clRed;
          StatusShape.Pen.Color   := clRed;
          StatusShape.Brush.Color := clRed;
        end;
    end;
  end;
begin
  WP := Integer( Msg.WParam );
  LP := Integer( Msg.LParam );

  case WP of
    0: begin
      SetStatus( LP );
    end;
  end;
end; // procedure TN_CMCaptDev17Form.OnCommand

//********************************************* TN_CMCaptDev17Form.OnHandle ***
// Receiving a driver's window handle
//
//     Parameters
// Msg - message received
//
procedure TN_CMCaptDev17aForm.OnHandle( var Msg: TMessage );
var
  WP{, LP}: Integer;
begin
  WP := Integer( Msg.WParam );
  //LP := Integer( Msg.LParam );
  ProgenyHandle := WP;
end; // procedure TN_CMCaptDev17aForm.OnHandle

end.
