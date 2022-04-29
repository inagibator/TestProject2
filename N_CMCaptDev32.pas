unit N_CMCaptDev32;
// Trios device

// 03.11.18 - first version, only cases opening through native viewer yet
// 2018.11.07 CDSGetDefaultDevIconInd function added
// 12.11.18 - changed interface
// 30.11.18 - added unlimited count of images, fixed trios database error
// 11.12.18 - empty password requests fixed
// 17.12.18 - icons fixed

interface

{$IFNDEF VER150} //***** not Delphi 7

uses
  Windows, Messages, Classes, Forms, Graphics, StdCtrls, ExtCtrls, WinSock,
  K_CM0, K_CMCaptDevReg, N_Types, N_CMCaptDev0, N_CMCaptDev32F,
  N_CML2F, N_CMCaptDev32aF;

type TN_CMCDServObj32 = class(TK_CMCDServObj)
  CDSDllHandle:  THandle; // DLL Windows Handle
  PProfile:      TK_PCMDeviceProfile; // CMS Profile Pointer

  CDSErrorStr:   string;  // Error message
  CDSErrorInt:   integer; // Error code

  function CDSInitAll(AGroupName, AProductName: string ): Integer;
  function CDSFreeAll(): Integer;

  function CDSOpenDev3DViewer( const A3DPathToObj : string ) : Integer; override;

  function CDSGetGroupDevNames( AGroupDevNames: TStrings ): Integer; override;
  procedure SendExtMsg( Cmd, Param1, Param2, Param3: Integer );
  procedure CDSCaptureImages( APDevProfile: TK_PCMDeviceProfile;
                                    var ASlidesArray: TN_UDCMSArray ); override;
  procedure CDSSettingsDlg      ( APDevProfile: TK_PCMDeviceProfile ); override;

  destructor Destroy; override;
  function   CDSGetDefaultDevIconInd ( const AProductName : string): Integer; override;
  function   CDSGetDefaultDevDCMMod( const AProductName : string ): string; override;
end; // end of type TN_CMCD ServObj32 = class( TK_CMCDServObj )

var
  N_CMCDServObj32: TN_CMCDServObj32;
  CMCaptDev32Form: TN_CMCaptDev32Form;

implementation

uses
  SysUtils, Dialogs,
  K_CLib0, N_Gra2,
  N_Lib1, N_CM1, N_Lib0, IniFiles, ShellAPI, IdHTTP, xmldom,
  XMLIntf, msxml, msxmldom, XMLDoc, OleCtrls, SHDocVw, IdIOHandler,
  IdIOHandlerSocket, IdIOHandlerStack, IdSSL, IdSSLOpenSSL, MSHTML;

//************************************************* TN_CMCDServObj32 **********

//************************************* TN_CMCDServObj32.CDSOpenDev3DViewer ***
// Algorithm for opening slides via natives Viewers
//
//     Parameters
// A3DPathToObj - Info saved to this slide
// Result       - return 0 if OK
//
function  TN_CMCDServObj32.CDSOpenDev3DViewer( const A3DPathToObj : string ) :
                                                                        Integer;
var
  mStream: TStream;
  idHttpTemp: TIdHTTP;
  lReply:   string;
  UserID:   string;
  Password: string;
  IdSSLIOHandlerSocketOpenSSL1: TIdSSLIOHandlerSocketOpenSSL;
  lParamList: TStringList;
  SS:         TStringStream;
  DOB:        TDateTime;
  DateBirth:  string;
  Fmt:        TFormatSettings;
  xml:        IXMLDocument;
  LNodeElement: IXMLNode;
  FileName, TempStr, RequestStr: string;
  XmlStr:     TStringList;
  ClientIdNum, LoginReq, PasswordReq: string;

function GetName(): String;
var
  ComputerName: Array [0 .. 256] of char;
  Size: DWORD;
begin
  Size := 256;
  GetComputerName(ComputerName, Size);
  Result := ComputerName;
end;

begin

  Result := 0;

  N_Dump1Str( 'Case that is opening = ' + A3DPathToObj );
  SS :=      TStringStream.Create('');
  mStream := TStringStream.Create();

  idHttpTemp := TIdHTTP.Create(nil);
  try

  IdSSLIOHandlerSocketOpenSSL1 := TIdSSLIOHandlerSocketOpenSSL.Create(Nil);
  idHttpTemp.IOHandler := IdSSLIOHandlerSocketOpenSSL1;

  //***** get login/password
  LoginReq := Copy( PProfile.CMDPStrPar2, 0,
                                  Pos( '/~/',PProfile.CMDPStrPar2) - 1 );
  PasswordReq := Copy( PProfile.CMDPStrPar2,
                                  Pos( '/~/',PProfile.CMDPStrPar2 ) + 3,
                                  Length(PProfile.CMDPStrPar2) );

  UserID:=LoginReq;
  Password:=PasswordReq;

  idHttpTemp.Request.ContentType := 'text/xml';
  idHttpTemp.Request.Charset := 'utf-8';

  idHttpTemp.Request.BasicAuthentication := True;
  idHttpTemp.Request.Username := UserID;
  idHttpTemp.Request.Password := Password;
  idHttpTemp.AllowCookies := true;
  idHttpTemp.HandleRedirects := True;

  // ***** request itself
  RequestStr := 'https://' + PProfile.CMDPStrPar1 +
                        ':5484/DentalDesktop/WebService/GetAvailableClientList';

  FileName := N_CMV_GetWrkDir();
  SS := TStringStream.Create();
  idHttpTemp.Get( RequestStr, SS );
  SS.Clear;
  idHttpTemp.Get( RequestStr, SS );

  xml := TXMLDocument.Create(Nil);
  TempStr := SS.DataString;
  TempStr := StringReplace(TempStr, '- ', '  ', [rfReplaceAll, rfIgnoreCase]);

  XmlStr := TStringList.Create();
  XmlStr.Add( TempStr );

  XmlStr.SaveToFile( FileName + '\Trios.xml' ); // final client list xml is ready
  N_Dump1Str( 'Client list is ready and saved' );

  xml.LoadFromFile( Filename + '\Trios.xml' );

  // find a specific node
  LNodeElement := xml.ChildNodes.FindNode('ArrayOfClientInfo');
  if (LNodeElement <> nil) then
  LNodeElement := LNodeElement.ChildNodes.FindNode('ClientInfo');

  if (LNodeElement <> nil) then
    ClientIDNum := LNodeElement.ChildNodes['ClientId'].Text;

  N_Dump1Str( 'ClientID is ' + ClientIdNum );

  lParamList := TStringList.Create;

  lParamList.Add('<ProcessPatientRequest>');
  lParamList.Add('<CaseId>' + A3DPathToObj + '</CaseId>');
  lParamList.Add('<ClientId>' + ClientIdNum + '</ClientId>');
  lParamList.Add('<Patient>');

  N_Dump1Str( 'Before creating a date' );

  fmt.ShortDateFormat:='dd/mm/yyyy';
  fmt.DateSeparator  :='/';
  fmt.LongTimeFormat :='hh:nn';
  fmt.TimeSeparator  :=':';

  if K_CMGetPatientDetails( -1, '(#PatientDOB#)' ) <> '' then // if no error in a date
  begin
    DOB := StrToDateTime(K_CMGetPatientDetails( -1, '(#PatientDOB#)' ) +
                                                                ' 00:00', Fmt );
  end
  else
  begin
    DOB := StrToDateTime( '01/01/1980 00:00', Fmt ); // default
  end;
  DateTimeToString( DateBirth, 'yyyy-mm-dd', DOB );

  N_Dump1Str('After date');

  // ***** open case xml
  lParamList.Add('<DateOfBirth>' + DateBirth + 'T00:00:00</DateOfBirth>');
  lParamList.Add('<FirstName>' + K_CMGetPatientDetails( -1, '(#PatientFirstName#)' ) + '</FirstName>');
  lParamList.Add('<LastName>' + K_CMGetPatientDetails( -1, '(#PatientSurname#)' ) + '</LastName>');
  lParamList.Add('<PatientId>' + K_CMGetPatientDetails( -1, '(#PatientCardNumber#)' ) + '</PatientId>');
  lParamList.Add('</Patient>');
  lParamList.Add('<RequestType>OpenCase</RequestType>');
  lParamList.Add('</ProcessPatientRequest>');
  mStream := TStringStream.Create( lParamList.Text, TEncoding.UTF8 );

  N_Dump1Str( 'Patient XML is created' );

  //try
    N_Dump1Str( 'Before Case creation request' );

    // request itself
    RequestStr := 'https://' + PProfile.CMDPStrPar1 +
                         ':5484/DentalDesktop/WebService/RequestProcessPatient';

    idHttpTemp.Request.Method := 'POST';
    N_Dump1Str( 'Before Post' );

    // send the request
    lReply := idHttpTemp.Post(RequestStr, mStream);

    N_Dump1Str( 'After Post' );

    except
    on E: Exception do
    begin
      N_Dump1Str( 'Exception cathed, ' + E.Message );
      //CMOFStatus := 0;
      K_CMShowMessageDlg( 'Trios server disconnected', mtError );
    end;
  end;
  idHttpTemp.Free;

  //finally

  // cleaning
  mStream.Free;
  FreeAndNil(SS);

  //end;
end; // function  TN_CMCDServObj32.CDSOpenDev3DViewer

//********************************************* TN_CMCDServObj32.CDSInitAll ***
// Initialize Device and needed Soft
//
//     Parameters
// AGroupName   - ServObj32 Group Name
// AProductName - Device Name
// Result       - return 0 if OK
//
function TN_CMCDServObj32.CDSInitAll(AGroupName, AProductName: string )
                                                                      : Integer;
begin
  //if AProductName = N_CMECD_ClearVision then Device := 1;

  CDSErrorStr := '';
  Result := 0;
end; // procedure N_CMCDServObj32.CDSInitAll

//********************************************** TN_CMCDServObj32.CDSFreeAll ***
// Close Device and Free all resources
//
//     Parameters
// Result - return 0 if OK
//
function TN_CMCDServObj32.CDSFreeAll(): Integer;
begin
  if CDSDLLHandle <> 0 then
  begin
    FreeLibrary( CDSDLLHandle );
    CDSDLLHandle := 0;
  end; // if CDSDLLHandle <> 0 then

  Result := 0; // freed OK
end; // procedure TN_CMCDServObj32.CDSFreeAll

//**************************************** N_CMCDServObj32.CDSCaptureImages ***
// Capture images
//
//    Parameters
// APDevProfile - pointer to profile
// ASlidesArray - slides array
//
procedure TN_CMCDServObj32.CDSCaptureImages( APDevProfile: TK_PCMDeviceProfile;
                                             var ASlidesArray: TN_UDCMSArray );
begin
  PProfile := APDevProfile;
  N_Dump1Str( 'Trios >> CDSCaptureImages begin' );

  SetLength(ASlidesArray, 0);
  CMCaptDev32Form          := TN_CMCaptDev32Form.Create(Application);
  CMCaptDev32Form.CMOFThisForm := CMCaptDev32Form;

  with CMCaptDev32Form, APDevProfile^ do
  begin
    BaseFormInit( nil, '', [rspfMFRect, rspfCenter], [rspfAppWAR, rspfShiftAll] );
    CMOFPProfile := TK_PCMOtherProfile(APDevProfile);
    // set CMCaptDev11Form.CMOFPProfile field
    Caption        := CMDPCaption;
    CMOFPNewSlides := @ASlidesArray; // for using in CMCaptDev11Form methods
    N_Dump1Str( 'Trios >> CDSCaptureImages before ShowModal' );

    ShowModal();
    
    CDSFreeAll();
    N_Dump1Str( 'Trios >> CDSCaptureImages after ShowModal' );
  end; // with CMCaptDev11Form, APDevProfile^ do

  N_Dump1Str( 'Trios >> CDSCaptureImages end' );
end; // procedure N_CMCDServObj32.CDSCaptureImages

//********************************************* TN_CMCDServObj32.SendExtMsg ***
// Send message to C++ driver
//
//    Parameters
// Cmd - command for driver
// Param1 - 1st parameter
// Param2 - 2nd parameter
// Param3 - 3rd parameter
//
procedure TN_CMCDServObj32.SendExtMsg( Cmd, Param1, Param2, Param3: Integer );
begin
  // not used
end; // procedure SendExtMsg

//***************************************** TN_CMCDServObj32.CDSSettingsDlg ***
// Show Special Seting Dialog
//
//     Parameters
// APDevProfile - Pointer to Device Profile record
//
procedure TN_CMCDServObj32.CDSSettingsDlg( APDevProfile: TK_PCMDeviceProfile );
var
  Form: TN_CMCaptDev32aForm;
begin
  PProfile := APDevProfile;
  N_Dump1Str( 'Trios >> CDSSettingsDlg begin' );
  Form := TN_CMCaptDev32aForm.Create( Application );

  // create a setup form
  Form.BaseFormInit( nil, '', [rspfMFRect, rspfCenter], [rspfAppWAR,
                                                                rspfShiftAll] );
  Form.CMOFPDevProfile := APDevProfile; // link form variable to profile
  Form.Caption := APDevProfile.CMDPCaption; // set form caption

  Form.CMOFPDevProfile := PProfile;

  Form.ShowModal(); // Show setup form
  N_Dump1Str( 'Trios >> CDSSettingsDlg end' );
end; // procedure TN_CMCDServObj32.CDSSettingsDlg

//************************************* TN_CMCDServObj32.CDSGetGroupDevNames ***
// Get Devices Names
//
//     Parameters
// AGroupDevNames - given Strings object to fill
// Result         - number of all Devices Names
//
function TN_CMCDServObj32.CDSGetGroupDevNames( AGroupDevNames: TStrings ):
                                                                        Integer;
begin
  Result := AGroupDevNames.Count;
end; // function TN_CMCDServObj32.CDSGetGroupDevNames

// destructor N_CMCDServObj32.Destroy
//
destructor TN_CMCDServObj32.Destroy();
begin
  //CDSFreeAll();
end; // destructor N_CMCDServObj32.Destroy

//******************************** TN_CMCDServObj32.CDSGetDefaultDevIconInd ***
// Get Device default Icon index by Device Name (Profile Product Name)
//
//     Parameters
// AProductName - device Product name
// Result - Returns device Icon default Index
//
function TN_CMCDServObj32.CDSGetDefaultDevIconInd( const AProductName : string): Integer;
begin
  Result := 49;
end; // function TN_CMCDServObj32.CDSGetDefaultDevIconInd

//********************************* TN_CMCDServObj32.CDSGetDefaultDevDCMMod ***
// Get Device default modality by Device Name (Profile Product Name)
//
//     Parameters
// AProductName - device Product name
// Result - Returns device Icon default Index
//
function TN_CMCDServObj32.CDSGetDefaultDevDCMMod( const AProductName : string ): string;
begin
    Result := '';
end; // function TN_CMCDServObj32.CDSGetDefaultDevDCMMod

Initialization

// Create and Register Service Object
N_CMCDServObj32 := TN_CMCDServObj32.Create( N_CMECD_Trios_Name );

with K_CMCDRegisterDeviceObj( N_CMCDServObj32 ) do
begin
  CDSCaption := 'Trios';
  IsGroup := False;
  ShowSettingsDlg := True;
end; // with K_CMCDRegisterDeviceObj( N_CMCDServObj32 ) do

{$ELSE} //************** no code in Delphi 7
implementation
{$ENDIF VER150} //****** no code in Delphi 7

end.
