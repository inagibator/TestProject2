unit K_MapiControl;

{$R-}

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, Forms, Dialogs;

type
  { Вводим новый тип события для получения Errorcode }
  TMapiErrEvent = procedure(Sender: TObject; ErrCode: Integer) of object;
{
  TMapiControl = class(TComponent)
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
}
  TMapiControl = class(TObject)
//    constructor Create(AOwner : TComponent); override;
    constructor Create;
    destructor Destroy; override;
  private
    { Private-объявления }
    FSubject: string;
    FMailtext: string;
    FFromName: string;
    FFromAdress: string;
    FTOAdr: TStrings;
    FCCAdr: TStrings;
    FBCCAdr: TStrings;
    FAttachedFileName: TStrings;
    FDisplayFileName: TStrings;
    FShowDialog: Boolean;
    FUseAppHandle: Boolean;
    { Error Events: }
    FOnUserAbort: TNotifyEvent;
    FOnMapiError: TMapiErrEvent;
    FOnSuccess: TNotifyEvent;
    { +> Изменения, внесённые Eugene Mayevski [mailto:Mayevski@eldos.org]}
    procedure SetToAddr(newValue : TStrings);
    procedure SetCCAddr(newValue : TStrings);
    procedure SetBCCAddr(newValue : TStrings);
    procedure SetAttachedFileName(newValue : TStrings);
    { +< конец изменений }
  protected
    { Protected-объявления }
  public
    { Public-объявления }
    ApplicationHandle: THandle;
    function  Sendmail() : Integer;
    procedure Reset();
//  published
    { Published-объявления }
    property Subject: string read FSubject write FSubject;
    property Body: string read FMailText write FMailText;
    property FromName: string read FFromName write FFromName;
    property FromAdress: string read FFromAdress write FFromAdress;
    property Recipients: TStrings read FTOAdr write SetTOAddr;
    property CopyTo: TStrings read FCCAdr write SetCCAddr;
    property BlindCopyTo: TStrings read FBCCAdr write SetBCCAddr;
    property AttachedFiles: TStrings read FAttachedFileName write SetAttachedFileName;
    property DisplayFileName: TStrings read FDisplayFileName;
    property ShowDialog: Boolean read FShowDialog write FShowDialog;
    property UseAppHandle: Boolean read FUseAppHandle write FUseAppHandle;

    { события: }
    property OnUserAbort: TNotifyEvent read FOnUserAbort write FOnUserAbort;
    property OnMapiError: TMapiErrEvent read FOnMapiError write FOnMapiError;
    property OnSuccess: TNotifyEvent read FOnSuccess write FOnSuccess;
  end;

//procedure Register;

implementation

uses Mapi,
  K_CLib0,
  N_Types, N_Lib0;

/////////////////////////////////////////////
//  Self MapiSendMail instead of Delphi Mapi
//
var
  MAPIModule: HModule = 0;
  SendMail: TFNMapiSendMail = nil;
  MAPIChecked: Boolean = False;
  OwnMAPIDLL: string;
  MAPIDLL: string = 'MAPI32.DLL';
  MAPIUseDelphi: Boolean = FALSE;

function MapiSendMail( lhSession: LHANDLE; ulUIParam: Cardinal;
                       var lpMessage: TMapiMessage; flFlags: FLAGS;
                       ulReserved: Cardinal ) : Cardinal;
begin
//Result := MAPI.MapiSendMail(lhSession, ulUIParam, lpMessage, flFlags, ulReserved );
//exit;
  if not MAPIChecked then
  begin
    MAPIChecked := True;
    MAPIModule := 0;

    MAPIModule := LoadLibrary(PChar(MAPIDLL));

    if MAPIModule = 0 then
    begin
      OwnMAPIDLL := K_ExpandFileName( '(#DLLFiles#)' ) + MAPIDLL;
      if FileExists( OwnMAPIDLL ) then // use own MAPI32.DLL file in '(#DLLFiles#)'
        MAPIModule := LoadLibrary(PChar(OwnMAPIDLL));
    end;

    if MAPIModule = 0 then
      N_Dump1Str( '!!! MAPI32.DLL not found' );
  end;

  if Pointer(@SendMail) = nil then
    @SendMail := GetProcAddress(MAPIModule, 'MAPISendMail');

{!!! 2015-10-21 replace this code to below
  if Pointer(@SendMail) <> nil then
    Result := SendMail(lhSession, ulUIParam, lpMessage, flFlags, ulReserved)
  else
  begin
    N_Dump1Str( '!!! (#DLLFiles#)MAPI32.DLL or MAPISendMail entry is not found' );
    // Call Delphi MapiSendMail
    Result := MAPI.MapiSendMail( lhSession, ulUIParam, lpMessage, flFlags, ulReserved );
  end;
}
  Result := 0;
  if not MAPIUseDelphi and (Pointer(@SendMail) <> nil) then
  begin
    try
      Result := SendMail(lhSession, ulUIParam, lpMessage, flFlags, ulReserved)
    except
      on E: Exception do
      begin
        N_Dump1Str( '!!! (#DLLFiles#)MAPI32.DLL|MAPISendMail Error >> ' + E.Message );
        MAPIUseDelphi := TRUE; // Try to use Delphi MapiSendMail
      end
    end
  end;

  if (Pointer(@SendMail) = nil) or MAPIUseDelphi then
  begin
    if Pointer(@SendMail) = nil then
      N_Dump1Str( '!!! (#DLLFiles#)MAPI32.DLL or MAPISendMail entry is not found' );
    // Call Delphi MapiSendMail
    Result := MAPI.MapiSendMail( lhSession, ulUIParam, lpMessage, flFlags, ulReserved );
  end
end;
//
//  Self MapiSendMail instead of Delphi Mapi
/////////////////////////////////////////////

{ регистрируем компонент: }
{
procedure Register;
begin
  RegisterComponents('expectIT', [TMapiControl]);
end;
}
{ TMapiControl }

//constructor TMapiControl.Create(AOwner: TComponent);
constructor TMapiControl.Create();
begin
//  inherited Create(AOwner);
  inherited;
  FOnUserAbort := nil;
  FOnMapiError := nil;
  FOnSuccess := nil; 
  FSubject := ''; 
  FMailtext := ''; 
  FFromName := ''; 
  FFromAdress := '';
  FTOAdr := TStringList.Create; 
  FCCAdr := TStringList.Create; 
  FBCCAdr := TStringList.Create;
  FAttachedFileName := TStringList.Create; 
  FDisplayFileName := TStringList.Create;
  FShowDialog := False; 
  ApplicationHandle := Application.Handle; 
end; 

{ +> Изменения, внесённые Eugene Mayevski [mailto:Mayevski@eldos.org]} 
procedure TMapiControl.SetToAddr(newValue : TStrings); 
begin 
  FToAdr.Assign(newValue);
end; 

procedure TMapiControl.SetCCAddr(newValue : TStrings);
begin 
  FCCAdr.Assign(newValue); 
end; 

procedure TMapiControl.SetBCCAddr(newValue : TStrings); 
begin 
  FBCCAdr.Assign(newValue); 
end; 

procedure TMapiControl.SetAttachedFileName(newValue : TStrings);
begin
  FAttachedFileName.Assign(newValue);
end;
{ +< конец изменений }

destructor TMapiControl.Destroy; 
begin 
  FTOAdr.Free; 
  FCCAdr.Free; 
  FBCCAdr.Free; 
  FAttachedFileName.Free; 
  FDisplayFileName.Free; 
  inherited destroy; 
end;

{ Сбрасываем все используемые поля} 
procedure TMapiControl.Reset;
begin
  FSubject := '';
  FMailtext := '';
  FFromName := '';
  FFromAdress := '';
  FTOAdr.Clear;
  FCCAdr.Clear;
  FBCCAdr.Clear;
  FAttachedFileName.Clear;
  FDisplayFileName.Clear;
end;

{  Эта процедура составляет и отправляет Email }
function  TMapiControl.Sendmail : Integer;
var
  MapiMessage: TMapiMessage;
  MError: Cardinal;
  Sender: TMapiRecipDesc;
  PRecip, ARecipients: PMapiRecipDesc;
  PFiles, Attachments: PMapiFileDesc;
  i: Integer;
  AppHandle: THandle;
  ArrTOAddr, ArrTOAddr1, ArrCCAdr, ArrCCAdr1,
  ArrBCAdr, ArrBCAdr1, ArrAttach, ArrAttach1 : array of AnsiString;
  ASubject, ABody, AFromName, AFromAdress : AnsiString;
  MapiState : Integer;
  AddErrMessage : string;
begin
  { Перво-наперво сохраняем Handle приложения, if not
    the Component might fail to send the Email or
    your calling Program gets locked up. }
  AppHandle := Application.Handle;

  Attachments := nil;
  ARecipients := nil;
  MapiState := -1000;
  AddErrMessage := '';
  try
    with MapiMessage do
    begin
      ulReserved := 0;
      { Устанавливаем поле Subject: }
//      ASubject := AnsiString(Self.FSubject);
      ASubject := N_StringToAnsi(Self.FSubject);
      lpszSubject := PAnsiChar(ASubject);

      { ...  Body: }
//      ABody := AnsiString(FMailText);
      ABody := N_StringToAnsi(FMailText);
      lpszNoteText := PAnsiChar(ABody);

      lpszMessageType := nil;
      lpszDateReceived := nil;
      lpszConversationID := nil;
      flFlags := 0;

      { и отправителя: (MAPI_ORIG) }
      Sender.ulReserved := 0;
      Sender.ulRecipClass := MAPI_ORIG;
//      AFromName := AnsiString(FromName);
      AFromName := N_StringToAnsi(FromName);
      Sender.lpszName := PAnsiChar(AFromName);
//      AFromAdress := AnsiString(FromAdress);
      AFromAdress := N_StringToAnsi(FromAdress);
      Sender.lpszAddress := PAnsiChar(AFromAdress);
      Sender.ulEIDSize := 0;
      Sender.lpEntryID := nil;
      lpOriginator := @Sender;


      { У нас много получателей письма: (MAPI_TO)
        установим для каждого: }
      nRecipCount := FTOAdr.Count + FCCAdr.Count + FBCCAdr.Count;
      if nRecipCount > 0 then
      begin
       { Нам нужно зарезервировать память для всех получателей }
        GetMem(ARecipients, MapiMessage.nRecipCount * sizeof(TMapiRecipDesc));
        PRecip := ARecipients;
//
        SetLength( ArrTOAddr, FTOAdr.Count );
        SetLength( ArrTOAddr1, FTOAdr.Count );
        for i := 0 to FTOAdr.Count - 1 do
        begin
          PRecip^.ulReserved := 0;
          PRecip^.ulRecipClass := MAPI_TO;
          { lpszName should carry the Name like in the
            contacts or the adress book, I will take the
            email adress to keep it short: }
//          ArrTOAddr[i] := AnsiString(FTOAdr.Strings[i]);
          ArrTOAddr[i] := N_StringToAnsi(FTOAdr.Strings[i]);
          PRecip^.lpszName := PAnsiChar(ArrTOAddr[i]);
          { Если Вы используете этот компонент совместно с Outlook97 или 2000
            (не Express версии) , то Вам прийдётся добавить
            'SMTP:' в начало каждого (email-) адреса.
          }
          ArrTOAddr1[i] := AnsiString('SMTP:') + ArrTOAddr[i];
          PRecip^.lpszAddress := PAnsiChar(ArrTOAddr1[i]);
          PRecip^.ulEIDSize := 0;
          PRecip^.lpEntryID := nil;
          Inc(PRecip);
        end;

        { То же самое проделываем с получателями копии письма: (CC, MAPI_CC) }
        SetLength( ArrCCAdr, FCCAdr.Count );
        SetLength( ArrCCAdr1, FCCAdr.Count );
        for i := 0 to FCCAdr.Count - 1 do
        begin
          PRecip^.ulReserved := 0;
          PRecip^.ulRecipClass := MAPI_CC;
//          ArrCCAdr[i] := AnsiString(FCCAdr.Strings[i]);
          ArrCCAdr[i] := N_StringToAnsi(FCCAdr.Strings[i]);
          PRecip^.lpszName := PAnsiChar(ArrCCAdr[i]);
          ArrCCAdr1[i] := AnsiString('SMTP:') + ArrCCAdr[i];
          PRecip^.lpszAddress := PAnsiChar(ArrCCAdr1[i]);
          PRecip^.ulEIDSize := 0;
          PRecip^.lpEntryID := nil;
          Inc(PRecip);
        end;

        { ... тоже самое для Bcc: (BCC, MAPI_BCC) }
        SetLength( ArrBCAdr, FBCCAdr.Count );
        SetLength( ArrBCAdr1, FBCCAdr.Count );
        for i := 0 to FBCCAdr.Count - 1 do
        begin
          PRecip^.ulReserved := 0;
          PRecip^.ulRecipClass := MAPI_BCC;
//          ArrBCAdr[i] := AnsiString(FBCCAdr.Strings[i]);
          ArrBCAdr[i] := N_StringToAnsi(FBCCAdr.Strings[i]);
          PRecip^.lpszName := PAnsiChar(ArrBCAdr[i]);
          ArrBCAdr1[i] := AnsiString('SMTP:') + ArrBCAdr[i];
          PRecip^.lpszAddress := PAnsiChar(ArrBCAdr1[i]);
          PRecip^.ulEIDSize := 0;
          PRecip^.lpEntryID := nil;
          Inc(PRecip);
        end;
      end;
      lpRecips := ARecipients;

      { Теперь обработаем прикреплённые к письму файлы: }

      if FAttachedFileName.Count > 0 then
      begin
        nFileCount := FAttachedFileName.Count;
        GetMem(Attachments, MapiMessage.nFileCount * sizeof(TMapiFileDesc));

        PFiles := Attachments;

        { Во первых установим отображаемые на экране имена файлов (без пути): }
        FDisplayFileName.Clear;
        for i := 0 to FAttachedFileName.Count - 1 do begin
          FDisplayFileName.Add(ExtractFileName(FAttachedFileName[i]));
        end;

        if nFileCount > 0 then
        begin
          { Теперь составим структурку для прикреплённого файла: }
          SetLength( ArrAttach, FAttachedFileName.Count );
          SetLength( ArrAttach1, FAttachedFileName.Count );
          for i := 0 to FAttachedFileName.Count - 1 do
          begin
            { Устанавливаем полный путь }
//            ArrAttach[i] := AnsiString(FAttachedFileName.Strings[i]);
            ArrAttach[i] := N_StringToAnsi(FAttachedFileName.Strings[i]);
            PFiles^.lpszPathName := PAnsiChar(ArrAttach[i]);
            { ... и имя, отображаемое на дисплее: }
//            ArrAttach1[i] := AnsiString(FDisplayFileName.Strings[i]);
            ArrAttach1[i] := N_StringToAnsi(FDisplayFileName.Strings[i]);
            PFiles^.lpszFileName := PAnsiChar(ArrAttach1[i]);
            PFiles^.ulReserved := 0;
            PFiles^.flFlags := 0;
            { Положение должно быть -1, за разьяснениями обращайтесь в WinApi Help. }
            PFiles^.nPosition := Cardinal(-1);
            PFiles^.lpFileType := nil;
            Inc(PFiles);
          end;
        end;
        lpFiles := Attachments;
      end
      else
      begin
        nFileCount := 0;
        lpFiles := nil;
      end;
    end;

    { Send the Mail, silent or verbose:
      Verbose means in Express a Mail is composed and shown as setup.
      In non-Express versions we show the Login-Dialog for a new
      session and after we have choosen the profile to use, the
      composed email is shown before sending

      Silent does currently not work for non-Express version. We have
      no Session, no Login Dialog so the system refuses to compose a
      new email. In Express Versions the email is sent in the
      background.
     }
    MapiState := -1001;
    if FShowDialog then
      MError := MapiSendMail(0, AppHandle, MapiMessage, MAPI_DIALOG or MAPI_LOGON_UI or MAPI_NEW_SESSION, 0)
    else
      MError := MapiSendMail(0, AppHandle, MapiMessage, 0, 0);
    MapiState := Integer(MError);

    { Теперь обработаем сообщения об ошибках. В MAPI их присутствует достаточное.
      количество. В этом примере я обрабатываю только два из них: USER_ABORT и SUCCESS,
      относящиеся к специальным.

      Сообщения, не относящиеся к специальным:
MAPI_E_AMBIGUOUS_RECIPIENT - A recipient matched more than one of the recipient descriptor structures and MAPI_DIALOG was not set. No message was sent.
MAPI_E_ATTACHMENT_NOT_FOUND - The specified attachment was not found; no message was sent.
MAPI_E_ATTACHMENT_OPEN_FAILURE - The specified attachment could not be open; no message was sent.
MAPI_E_BAD_RECIPTYPE - The type of a recipient was not MAPI_TO, MAPI_CC, or MAPI_BCC. No message was sent.
MAPI_E_FAILURE - One or more unspecified errors occurred; no message was sent.
MAPI_E_INSUFFICIENT_MEMORY - There was insufficient memory to proceed. No message was sent.
MAPI_E_LOGIN_FAILURE = There was no default logon, and the user failed to log on successfully when the logon dialog box was displayed. No message was sent.
MAPI_E_TEXT_TOO_LARGE - The text in the message was too large to sent; the message was not sent.
MAPI_E_TOO_MANY_FILES - There were too many file attachments; no message was sent.
MAPI_E_TOO_MANY_RECIPIENTS - There were too many recipients; no message was sent.
MAPI_E_UNKNOWN_RECIPIENT - A recipient did not appear in the address list; no message was sent.
MAPI_E_USER_ABORT - The user canceled the process; no message was sent.
SUCCESS_SUCCESS = 0
MAPI_E_USER_ABORT = 1;
MAPI_E_USER_ABORT                  = MAPI_USER_ABORT;
MAPI_E_FAILURE = 2;
MAPI_E_LOGON_FAILURE = 3;
MAPI_E_LOGIN_FAILURE               = MAPI_E_LOGON_FAILURE;
MAPI_E_DISK_FULL = 4;
MAPI_E_INSUFFICIENT_MEMORY = 5;
MAPI_E_ACCESS_DENIED = 6;
MAPI_E_TOO_MANY_SESSIONS = 8;
MAPI_E_TOO_MANY_FILES = 9;
MAPI_E_TOO_MANY_RECIPIENTS = 10;
MAPI_E_ATTACHMENT_NOT_FOUND = 11;
MAPI_E_ATTACHMENT_OPEN_FAILURE = 12;
MAPI_E_ATTACHMENT_WRITE_FAILURE = 13;
MAPI_E_UNKNOWN_RECIPIENT = 14;
MAPI_E_BAD_RECIPTYPE = 15;
MAPI_E_NO_MESSAGES = 16;
MAPI_E_INVALID_MESSAGE = 17;
MAPI_E_TEXT_TOO_LARGE = 18;
MAPI_E_TYPE_NOT_SUPPORTED = 20;
MAPI_E_AMBIGUOUS_RECIPIENT = 21;
MAPI_E_AMBIG_RECIP                 = MAPI_E_AMBIGUOUS_RECIPIENT;
MAPI_E_MESSAGE_IN_USE = 22;
MAPI_E_NETWORK_FAILURE = 23;
MAPI_E_NETWORK_FAILURE = 23;
MAPI_E_INVALID_EDITFIELDS = 24;
MAPI_E_INVALID_RECIPS = 25;
MAPI_E_NOT_SUPPORTED = 26;
}

    case MError of
      MAPI_E_USER_ABORT: // 1
        begin
          if Assigned(FOnUserAbort) then
            FOnUserAbort(Self);
        end;
      SUCCESS_SUCCESS:  // 0
        begin
          if Assigned(FOnSuccess) then
            FOnSuccess(Self);
        end
    else begin
      if Assigned(FOnMapiError) then
        FOnMapiError(Self, MError);
    end;

    end;
  except
  // MapiState =-1000 - Some Exception before MapiSendMail
  // MapiState =-1001 - Some Exception inside MapiSendMail
  // MapiState = 0 - MapiSendMail OK
  // MapiState > 0 - MapiSendMail Error
  // MapiState = 1 - MapiSendMail dialog aborted by user
    on E: Exception do
      AddErrMessage := ' >> ' + E.Message;
  end;

  Result := MapiState;
  if MapiState < -10000 then
    N_Dump1Str( format( 'MapiSendMail Res=0x%x >> %s', [MapiState,SysErrorMessage( MapiState )] ) )
  else  
    N_Dump1Str( format( 'MapiSendMail Res=%d%s', [MapiState, AddErrMessage] ) );
  try
    { В заключение освобождаем память }
{
    if ARecipients <> nil then
      FreeMem(ARecipients, MapiMessage.nRecipCount * sizeof(TMapiRecipDesc));
    if Attachments <> nil then
      FreeMem(Attachments, FAttachedFileName.Count * sizeof(TMapiFileDesc));
}
    if ARecipients <> nil then
      FreeMem( ARecipients );
    if Attachments <> nil then
      FreeMem( Attachments );
  except
    Result := -1002;
    N_Dump1Str( 'MapiSendMail FreeMemExcept' );
  end;
end; // function  TMapiControl.Sendmail

{
  Вопросы и замечания присылайте Автору.
}
initialization
finalization
  if MAPIModule <> 0 then FreeLibrary(MAPIModule);
end.
