unit L_VirtUI;

interface

uses
  VirtualUI_SDK, Windows, Messages, Classes, SysUtils, WinSock, {WinSock2, }N_Types, K_CM0, HTTPApp,
    ADODB;             ////Igor MySQL 05.11.2019

const
  ANY_SIZE = 1000000;
  AF_INET = 2;
  ERROR_INSUFFICIENT_BUFFER = 122;

  TCP_TABLE_BASIC_LISTENER = 0;
  TCP_TABLE_BASIC_CONNECTIONS = 1;
  TCP_TABLE_BASIC_ALL = 2;
  TCP_TABLE_OWNER_PID_LISTENER = 3;
  TCP_TABLE_OWNER_PID_CONNECTIONS = 4;
  TCP_TABLE_OWNER_PID_ALL = 5;
  TCP_TABLE_OWNER_MODULE_LISTENER = 6;
  TCP_TABLE_OWNER_MODULE_CONNECTIONS = 7;
  TCP_TABLE_OWNER_MODULE_ALL = 8;

  MIB_TCP_STATE_CLOSED = 1;
  MIB_TCP_STATE_LISTEN = 2;
  MIB_TCP_STATE_SYN_SENT = 3;
  MIB_TCP_STATE_SYN_RCVD = 4;
  MIB_TCP_STATE_ESTAB = 5;
  MIB_TCP_STATE_FIN_WAIT1 = 6;
  MIB_TCP_STATE_FIN_WAIT2 = 7;
  MIB_TCP_STATE_CLOSE_WAIT = 8;
  MIB_TCP_STATE_CLOSING = 9;
  MIB_TCP_STATE_LAST_ACK = 10;
  MIB_TCP_STATE_TIME_WAIT = 11;
  MIB_TCP_STATE_DELETE_TCB = 12;

type
  MIB_TCPROW_OWNER_PID = packed record
    dwState: DWORD;
    dwLocalAddr: DWORD;
    dwLocalPort: DWORD;
    dwRemoteAddr: DWORD;
    dwRemotePort: DWORD;
    dwOwningPid: DWORD;
  end;

type
  PMIB_TCPTABLE_OWNER_PID = ^MIB_TCPTABLE_OWNER_PID;
  MIB_TCPTABLE_OWNER_PID = packed record
    dwNumEntries: DWord;
    Table: array [0..ANY_SIZE - 1] of MIB_TCPROW_OWNER_PID ;
  end;

type
  TCP_TABLE_CLASS = Integer;
  ULONG = Longword;

type
    Paddrinfo = ^addrinfo;
    addrinfo = packed record
      ai_flags     : Integer;
      ai_family    : Integer;
      ai_socktype  : Integer;
      ai_protocol  : Integer;
      ai_addrlen   : Cardinal;
      ai_canonname : PPAnsiChar;
//      ai_addr      : LPSOCKADDR;  for comp in D7
//      ai_next      : ^addrinfo;
    end;

var
     getaddrinfo : function ( pNodeName : PAnsiChar;
                              pServiceName : PAnsiChar;
                              const pHints : Paddrinfo;
                              out ppResult : Paddrinfo
                             ) : DWORD; stdcall;
     freeaddrinfo : function ( ai : Paddrinfo) : DWORD; stdcall;

var
  VirtUI_Obj: TVirtualUI;
  //VirtUI_Data: IJSObject;
  VirtUI_ScanName: string;
  VirtUI_ScanID: string;        //SIR#26380 SIR#26381
  VirtUI_ScanVersion: string;   //SIR#26380 SIR#26381
  VirtUI_DateOut: string;   //SIR#26380 SIR#26381
  VirtUI_LastScanVersion: string;   //SIR#26380 SIR#26381
  VirtUI_Port: string;
  VirtUI_Info: string;
  VirtUI_Location, VirtUI_BrowserId: string;
  VirtUI_InitUI: Boolean = false;
  VirtUI_CountTime : Integer;                    ////Igor 14072020
  VirtUI_ScanRun: Boolean = false;               ////Igor 16092020 SIR#24767
  //WebDAVPort, WebDAVDrive, WebDAVHost, WebDAVUser, WebDAVPassword: String; //SIR#26380 SIR#26381
  L_VirtUICMScanWebInstallURL: string;        //SIR#26380 SIR#26381
  L_VirtUIWebDAVHost: string;                 //SIR#26380 SIR#26381
  L_VirtUIWebDAVPort: string;                 //SIR#26380 SIR#26381
  L_VirtUIWebDAVDrive: string;                 //SIR#26380 SIR#26381
  L_VirtUIWebDAVUser: string;                 //SIR#26380 SIR#26381
  L_VirtUIWebDAVPassword: string;                 //SIR#26380 SIR#26381

//function GetExtendedTcpTable(pTcpTable: PVOID; var dwSize: DWORD; bOrder: BOOL;  for comp in D7
function GetExtendedTcpTable(pTcpTable: Pointer; var dwSize: DWORD; bOrder: BOOL;
        ulAf: ULONG; TableClass: TCP_TABLE_CLASS; Reserved: ULONG): DWORD; stdcall;
        external 'iphlpapi.dll' name 'GetExtendedTcpTable';

function VirtUI_Init: String;
function CreateCompName(UserName: string): string;
function CreateCompID: string;                            //SIR#26380 SIR#26381
function GetHostAddr(HostName: string): LongWord;
function CheckConnection(Addr: LongWord; Port: Word): Boolean;

function DeCodeParamURL(ParamStr, Psw: String): String;
function EnCodeParamURL(ParamStr, Psw: String): String;

function ReadConfigDB: String;

function getScanCompName(Port: Integer; Params: String): String;
function getLastScanVersion(Version: String): String;

function L_CMVUICheckProvIU() : Boolean;
function L_CMVUISetWEBAttrs() : Boolean;

function Decrypt(src: String): String;   //Ura crypt password 09.02.2021

implementation

uses Controls,
  L_WEBSettingsF, L_WEBCheckVersionF,
  N_CM1;

var
  Wnd: HWnd;
  b: boolean;

type
  TMsgHandler = class(TObject)
  public
    procedure WndProc(var Msg: TMessage);
  end;

// function Decript Password 09.02.2021 Igor
function Decrypt(src: String): String;
var
  n, c, i: Integer;
  s, dst: String;

  function CodeToChar(c: Integer): Char;
  begin
    //result := Chr(Ord('a') + (c - 10 - 26));
    //if (c < (10 + 26)) then
        result := Chr(Ord('A') + (c - 10));
    if (c < 10) then
        result := Chr(Ord('0') + c);
  end;

  function Decode(c: Char; k: Integer): Integer;
  var
    i: Integer;
  begin
    result := -1;
    for i := 1 to 68 do
    begin
      if (s[i] = c) then
          result := (i + 68 - (k Mod 68)) Mod 68;
    end;
  end;

begin
  result := '';
  s := 'iqJPQNI7sR\_Zrl[mbUL1Kvp9a28dx4DyESt0H6u`eF5GBjWngcXfVT3]kwoM^zChYAO';
  n := Length(src);
  for i := 1 to n do
  begin
    c := Decode(src[i], i);
    if (c < 0) then Exit;
    dst := dst + CodeToChar(c);
  end;
  result := dst;
end;

function RSHash(s: string): int64;      //Hash function
var
  coef: int64;
  i: integer;
begin
  Result := 0;
  coef := 17;
  for i := 0 to Length(s) - 1 do
  begin;
    Result := Result * coef + ord(s[i + 1]);
    coef := coef * 37851;
  end;
end;

function StrToHash(st: string): int64;  //Hash function alternate
var
  i: integer;
begin
  result := 0;
  for i := 1 to length(st) do
    result := result * $20844 xor byte(st[i]);
end;

function CreateCompName(UserName: string): string;
var
  intHash: int64;
  strHash: string;
  PartCompName: string;
begin
  //intHash := RSHash(UserName);
  intHash := StrToHash(UserName);
  strHash := IntToHex(intHash, 15);
  strHash := Copy(strHash, 10, 6);
  PartCompName := Copy(UserName, 1, 5);
  result := 'VUI-' + PartCompName + strHash;
end;

function CreateCompID: string;                          //SIR#26380 SIR#26381
var
  formattedDateTime : string;
begin
  DateTimeToString(formattedDateTime, 'ddhhmmsszzz', Now);
  result := 'PC-' + formattedDateTime;
end;

procedure TmsgHandler.WndProc(var Msg: TMessage);
begin
  with Msg do
    Result := DefWindowProc(Wnd, Msg, wParam, lParam);
end;
//------------
procedure PropGet(const Parent: IJSObject; const Prop: IJSproperty);
begin
  Prop.AsString := VirtUI_ScanName;
end;

procedure PropSet(const Parent: IJSObject; const Prop: IJSproperty);
begin
  VirtUI_ScanName := Prop.AsString;
  b:= true;
  N_Dump1Str('VUI>> EventJS, VirtUI_ScanName = ' + VirtUI_ScanName);
end;
//------------
procedure PropPortGet(const Parent: IJSObject; const Prop: IJSproperty);
begin
  Prop.AsString := VirtUI_Port;
end;

procedure PropPortSet(const Parent: IJSObject; const Prop: IJSproperty);
begin
  VirtUI_Port := Prop.AsString;
end;

procedure PropInfoGet(const Parent: IJSObject; const Prop: IJSproperty);
begin
  Prop.AsString := VirtUI_Info;
end;

procedure PropInfoSet(const Parent: IJSObject; const Prop: IJSproperty);
begin
  VirtUI_Info := Prop.AsString;
end;
//------------

function VirtUI_Init: String;
var
  Position: Integer;
  i: Integer;
  s: String;
begin
   Result := '';

   VirtUI_InitUI := true;
   VirtUI_ScanName := '';
   VirtUI_Location := '';
   VirtUI_Obj := TVirtualUI.Create;
   try
     VirtUI_BrowserId := VirtUI_Obj.BrowserInfo.UniqueBrowserId;
     VirtUI_Location := VirtUI_Obj.BrowserInfo.IPAddress;
   except
   end;
   if VirtUI_Location = '' then Exit;

   K_CMVUIURLList := TStringList.Create;
   K_CMVUIURLList.Delimiter := '&';
   Position := pos('&', ParamStr(1));   //check encode     28112019
   if Position <> 0 then
      K_CMVUIURLList.DelimitedText := ParamStr(1) // with out encode
   else
      K_CMVUIURLList.DelimitedText := DeCodeParamURL(ParamStr(1), 'cms');    // in encode

   Result := 'Error in URL';
   if K_CMVUIURLList.Values['UserID'] = '' then Exit;
   if K_CMVUIURLList.Values['UserName'] = '' then Exit;
   if K_CMVUIURLList.Values['CustomerID'] = '' then Exit;
   //if URLList.Values['PatientID'] = '' then Exit;
   //if URLList.Values['PatientCardNum'] = '' then Exit;
   //if URLList.Values['PatientSurName'] = '' then Exit;
   //if URLList.Values['PatientFirstName'] = '' then Exit;
   //if URLList.Values['PatientTitle'] = '' then Exit;
   //if URLList.Values['PatientDOB'] = '' then Exit;
   //if URLList.Values['DentistID'] = '' then Exit;
   //if URLList.Values['DentistTitle'] = '' then Exit;
   //if URLList.Values['DentistSurName'] = '' then Exit;
   //if URLList.Values['DentistFirstName'] = '' then Exit;
   //if URLList.Values['PracticeID'] = '' then Exit;
   //if URLList.Values['PracticeName'] = '' then Exit;
   for i := K_CMVUIURLList.Count - 1 downto 0 do
   begin
      s := '';
      try
         s := String(HTTPDecode(AnsiString(K_CMVUIURLList.ValueFromIndex[i])));   //decode   ////Igor 14072020
      except
      end;
      K_CMVUIURLList.ValueFromIndex[i] := s;
   end;
   s := K_CMVUIURLList.Values['PatientDOB'];                                     ////Igor 28072020
   if (Pos('/', s) = 0) and (Length(s) = 8) then                                   //// Add / in date dd/mm/yyyy
   begin
      Insert('/', s, 5);
      Insert('/', s, 3);
      K_CMVUIURLList.Values['PatientDOB'] := s;
   end;

   Result := '';
end;

function getScanCompName(Port: Integer; Params: String): String;
var
   URL,BinFilesDir: string;
   Msh: TMsgHandler;
   i: integer;
   Prop: IJSProperty;
//   BindingGet: TJSBinding;
//   BindingSet: TJSBinding;
   PropPort: IJSProperty;
//   BindingPortGet: TJSBinding;
//   BindingPortSet: TJSBinding;
//   BindingInfoGet: TJSBinding;
//   BindingInfoSet: TJSBinding;
   VirtUI_Data: IJSObject;
   ListParam: TStringList;
begin
   Result := '';
   VirtUI_ScanName := '';
   ListParam := TStringList.Create;

   N_Dump1Str('VUI>> Start function getScanCompName Port: ' + IntToStr(Port) + Params);

   BinFilesDir := ExtractFilePath(ParamStr(0));

   URL := VirtUI_Obj.HTMLDoc.GetSafeURL(BinFilesDir + 'ScanCompName.js', 5);
   //VirtUI_Obj.HTMLDoc.LoadScript(URL, 'ScanCompName.js');

   Msh := TMsgHandler.Create;
   Wnd := AllocateHWnd(Msh.WndProc);

   VirtUI_Data := TJSObject.Create('ro');

   Prop := VirtUI_Data.Properties.Add('ScanCompName');
//   BindingGet := TJSBinding.Create(PropGet);  for comp in D7
//   BindingSet := TJSBinding.Create(PropSet);  for comp in D7
//   Prop.OnGet(BindingGet);   for comp in D7
//   Prop.OnSet(BindingSet);   for comp in D7

   PropPort := VirtUI_Data.Properties.Add('ScanPort');
//   BindingPortGet := TJSBinding.Create(PropPortGet); for comp in D7
//   BindingPortSet := TJSBinding.Create(PropPortSet); for comp in D7
//   PropPort.OnGet(BindingPortGet);  for comp in D7
//   PropPort.OnSet(BindingPortSet);  for comp in D7

   PropPort := VirtUI_Data.Properties.Add('Info');
//   BindingInfoGet := TJSBinding.Create(PropInfoGet); for comp in D7
//   BindingInfoSet := TJSBinding.Create(PropInfoSet); for comp in D7
//   PropPort.OnGet(BindingInfoGet);  for comp in D7
//   PropPort.OnSet(BindingInfoSet);  for comp in D7

   VirtUI_Data.ApplyModel;
   VirtUI_Obj.HTMLDoc.LoadScript(URL, 'ScanCompName.js');
   VirtUI_Port := IntToStr(Port) + Params;
   Sleep(100); /////////////////////////////////////////
   VirtUI_Data.ApplyChanges;

   b := false;
   for i := 1 to 30 do
   begin
    SendMessage(Wnd,WM_NULL,0,0);
    if b then Break;
    Sleep(100);
   end;

   if pos('Win', VirtUI_Info) > 0 then
      VirtUI_Info := 'Windows';
   if pos('Linux', VirtUI_Info) > 0 then
      VirtUI_Info := 'Linux';
   if pos('Android', VirtUI_Info) > 0 then
      VirtUI_Info := 'Android';

   if Params = '/?info' then
   begin
      ListParam.Clear;
      ListParam.Delimiter := '&';
      ListParam.DelimitedText := VirtUI_ScanName;

      VirtUI_ScanName := ListParam.Values['CompName'];
      VirtUI_ScanID := ListParam.Values['CompID'];
      VirtUI_ScanVersion := ListParam.Values['Version'];
      VirtUI_DateOut := ListParam.Values['DateOut'];
   end;

   if b then
      N_Dump1Str('VUI>> ScanCompName = ' + VirtUI_ScanName + ', Cycle: ' + IntToStr(i))
   else
      N_Dump1Str('VUI>> CMScanWEB not RUN, ScanCompName = ' + VirtUI_ScanName + ', Cycle: ' + IntToStr(i));

   VirtUI_LastScanVersion := Copy(getLastScanVersion(N_CMSVersion), 24, 9);

   VirtUI_ScanName := VirtUI_ScanID;               //SIR#26380   //Igor 09.02.2021
   Result := VirtUI_ScanName;
   DeallocateHWnd(Wnd);
   Msh.Free;
   ListParam.Free;
end;

function GetHostAddr(HostName: string): LongWord;
var
//     MyIP: Int64;
     rez1, rez2 : Paddrinfo;
     lwsaData : WSAData;
     error : DWORD;
     hWs2_32 : THandle;
begin
  Result := 0;
  hWs2_32 := LoadLibraryA('Ws2_32.dll');
  getaddrinfo := GetProcAddress(hWs2_32, 'getaddrinfo');
  freeaddrinfo := GetProcAddress(hWs2_32, 'freeaddrinfo');

  if not (Assigned(getaddrinfo) and Assigned (freeaddrinfo)) then begin
    if hWs2_32 <> 0 then FreeLibrary(hWs2_32);
    Exit;
  end;

  New(rez1);
  try
    if WSAStartup(MakeWord(2,2), lwsaData) <> 0 then
    begin
      Exit;
    end;
    //rez1 := nil;
    rez2 := nil;
    //if rez1 = nil then New(rez1);
    with rez1^ do begin
      ai_flags := 0;
      ai_family := af_inet;
      ai_socktype := SOCK_STREAM;
      ai_protocol := IPPROTO_TCP;
      ai_addrlen := 0;
      ai_canonname := nil;
//      ai_addr := nil;
//      ai_next := nil;
    end;
    error := GetAddrInfo(PAnsiChar(AnsiString(HostName)), 'hostnames', rez1, rez2);
    if error = 0 then begin
//      MyIP := SOCKADDR_IN(rez2^.ai_addr^).sin_addr.S_addr;   for comp in D7
//      Result := MyIP;   for comp in D7
    end;
  finally
    WSACleanup;
    if rez1 <> nil then begin
      Dispose(rez1);
      rez1 := nil;
    end;
    if rez2 <> nil then begin
      freeaddrinfo(rez2);
      rez2 := nil;
    end;
    if hWs2_32 <> 0 then FreeLibrary(hWs2_32);
  end;
end;

function CheckConnection(Addr: LongWord; Port: Word): Boolean;
var
  TCPTable: PMIB_TCPTABLE_OWNER_PID;
  Size: DWord;
  Res: Dword;
  i: integer;
  PID: cardinal;
  PortL: Word;
begin
  Result := false;
  TCPTable := nil;
  PID := GetCurrentProcessId();
  PortL := Port;
  PortL := ((PortL and $00FF) shl 8) or ((PortL and $FF00) shr 8);
  Res := GetExtendedTcpTable(TCPTable, Size, False, AF_INET, TCP_TABLE_OWNER_PID_CONNECTIONS, 0);
  if Res <> ERROR_INSUFFICIENT_BUFFER then Exit;
  GetMem(TCPTable, Size);
  try
    Res := GetExtendedTcpTable(TCPTable, Size, False, AF_INET, TCP_TABLE_OWNER_PID_CONNECTIONS, 0);
    if Res <> NO_ERROR then Exit;
    for i := 0 to TCPTable^.dwNumEntries - 1 do
    begin
      if TCPTable^.Table[i].dwOwningPID <> PID then Continue;
      if TCPTable^.Table[i].dwRemoteAddr <> Addr then Continue;
      if TCPTable^.Table[i].dwRemotePort <> PortL then Continue;
      if TCPTable^.Table[i].dwState = MIB_TCP_STATE_ESTAB then
      begin
        Result := true;
        Break;
      end;
    end;
  finally
    FreeMem(TCPTable);
  end;
end;

// function of encoding string with password
function DeCodeParamURL(ParamStr, Psw: String): String;
var
  MyStr, MyPsw, MyOut, dhex: AnsiString;
  i, j: Integer;
  a, b, c: byte;
begin
  MyStr := AnsiString(ParamStr);
  MyPsw := AnsiString(Psw);

  j := 1;
  i := 1;

  while i < Length(MyStr) do
  begin

    dhex := Copy(MyStr, i, 2);
    a := (StrToInt(String('$' + dhex)));
    b := Ord(PAnsiChar(Copy(MyPsw, j, 1))[0]);
    c := a xor b;

    MyOut := MyOut + AnsiString(AnsiChar(c));

    i := i + 2;
    j := j + 1;
    if j > Length(MyPsw) then j := 1;
  end;

  Result := String(MyOut);
end;

// function of decoding string with password
function EnCodeParamURL(ParamStr, Psw: String): String;
var
  MyStr, MyPsw, MyOut: AnsiString;
  i, j: Integer;
  a, b, c: byte;
begin
  MyStr := AnsiString(ParamStr);
  MyPsw := AnsiString(Psw);

  j := 1;
  i := 1;

  while i <= Length(MyStr) do
  begin

    a := Ord(PAnsiChar(Copy(MyStr, i, 1))[0]);
    b := Ord(PAnsiChar(Copy(MyPsw, j, 1))[0]);
    c := a xor b;

    MyOut := MyOut + AnsiString(IntToHex(c, 2));

    i := i + 1;
    j := j + 1;
    if j > Length(MyPsw) then j := 1;
  end;

   Result := String(MyOut);
end;

////Igor MySQL 05.11.2019  Data from ConfigDB MySQL
function ReadConfigDB: string;
var
   ADOConfigDB: TADOQuery;
   WebDAVHost, tPsw: string;
begin
   Result := '';
   ADOConfigDB := TADOQuery.Create(nil);
   try
      try
          ADOConfigDB.ConnectionString := 'Provider=MSDASQL.1;Data Source=configdb;';
          //!!!Ura 22.06.20
          ADOConfigDB.SQL.Add('select *, ');
          ADOConfigDB.SQL.Add('(select ParamValue from configdb.server_settings where ParamName = ''CustomersWebRoot'') as CustomersWebRoot, ');
          ADOConfigDB.SQL.Add('(select ParamValue from configdb.server_settings where ParamName = ''WorkfolderWebRoot'') as WorkfolderWebRoot, ');
          ADOConfigDB.SQL.Add('(select ParamValue from configdb.server_settings where ParamName = ''CMScanWebInstallURL'') as CMScanWebInstallURL, ');  //SIR#26380
          ADOConfigDB.SQL.Add('(select ParamValue from configdb.server_settings where ParamName = ''WebDAVHost'') as WebDAVHost ');           //SIR#26380
          ADOConfigDB.SQL.Add('from configdb.customer where CustomerID = ''' + K_CMVUIURLList.Values['CustomerID'] + '''');
          //!!!Ura
          ADOConfigDB.Active := true;
          //!!!Ura 22.06.20 ADOConfigDB.ExecSQL;

          if ADOConfigDB.RecordCount <> 1 then       // record ConfigDB not exists or more 1
          begin
            Result := 'Customer configuration not found.';
            Exit;
          end;

          K_CMVUICustomerID := K_CMVUIURLList.Values['CustomerID'];
          K_CMVUILongName := ADOConfigDB.FieldByName('LongName').AsString;
          K_CMVUIDataBaseDriver := ADOConfigDB.FieldByName('CMSDBDriver').AsString; //!!!Ura 22.06.20
          K_CMVUIDataBaseHost := ADOConfigDB.FieldByName('CMSDBHost1').AsString;
          K_CMVUIDataBaseIP := GetHostAddr(K_CMVUIDataBaseHost);
          K_CMVUIDataBasePort := ADOConfigDB.FieldByName('CMSDBPort1').AsInteger;
          K_CMVUICMSIdleTime := ADOConfigDB.FieldByName('CMSIdleTime').AsInteger;
          K_CMVUICMSDBServerName := ADOConfigDB.FieldByName('CMSDBServerName').AsString;
          K_CMVUICustomersRoot := ADOConfigDB.FieldByName('CustomersWebRoot').AsString; //!!!Ura 22.06.20
          K_CMVUIWorkfolderRoot := ADOConfigDB.FieldByName('WorkfolderWebRoot').AsString; //!!!Ura 22.06.20
          L_VirtUICMScanWebInstallURL := ADOConfigDB.FieldByName('CMScanWebInstallURL').AsString; //SIR#26380

          WebDAVHost := ADOConfigDB.FieldByName('WebDAVHost').AsString; //SIR#26380
          L_VirtUIWebDAVHost  := StringReplace(WebDAVHost, '<CustomerID>', K_CMVUICustomerID, [rfReplaceAll, rfIgnoreCase]);

          L_VirtUIWebDAVPort := '81'; //ADOConfigDB.FieldByName('WebDAVPort').AsString; //SIR#26380
          L_VirtUIWebDAVDrive := 'Z'; //ADOConfigDB.FieldByName('WebDAVDrive').AsString; //SIR#26380
          L_VirtUIWebDAVUser := ADOConfigDB.FieldByName('WebDAVUser').AsString; //SIR#26380
          tPsw := ADOConfigDB.FieldByName('WebDAVPassword').AsString; //SIR#26380
          L_VirtUIWebDAVPassword := Decrypt(tPsw);
          //K_CMVUIWebDAVPassword := tPsw;
          //Decrypt(tPsw, K_CMVUIWebDAVPassword);             //Igor 09.02.2021
          //!!!Ura 22.06.20
          Result := 'Customer database parameters are not set';
          if (K_CMVUIDataBaseDriver = '') or (K_CMVUIDataBaseHost = '') or (K_CMVUIDataBasePort <= 0) or (K_CMVUICMSDBServerName = '') then Exit;
          Result := 'Data paths are not set';
          if (K_CMVUICustomersRoot = '') or (K_CMVUIWorkfolderRoot = '') then Exit;
          if K_CMVUICustomersRoot[Length(K_CMVUICustomersRoot)] <> '\' then K_CMVUICustomersRoot := K_CMVUICustomersRoot + '\';
          if K_CMVUIWorkfolderRoot[Length(K_CMVUIWorkfolderRoot)] <> '\' then K_CMVUIWorkfolderRoot := K_CMVUIWorkfolderRoot + '\';
          K_CMVUICustomersRoot := K_CMVUICustomersRoot + 'CustomersWeb\';
          K_CMVUIWorkfolderRoot := K_CMVUIWorkfolderRoot + 'WorkfolderWeb\';
          K_CMVUICMSRootFolder := K_CMVUIWorkfolderRoot + K_CMVUICustomerID + '\CMS\Logs\';
          //!!!Ura
          Result := 'Log folder doesn''t exist';
          if not DirectoryExists(K_CMVUICMSRootFolder) then Exit;
          Result := '';
      except
        on E: Exception do
          Result := E.Message;
        else
          Result := 'Exception while reading customer configuration';
      end;
   finally
     ADOConfigDB.Free;
   end;
   {CustomerID := URLList.Values['CustomerID'];
   K_CMVUIDataBaseHost := 'localhost';
   K_CMVUIDataBaseIP := GetHostAddr(K_CMVUIDataBaseHost);
   K_CMVUIDataBasePort := 2638;
   CMSIdleTime := 15;
   CMSDBServerName := 'CMSImgAU2001';
   CMSLogFiles := 'C:\Customers\AU2001\CMS_Logs\';}
end;

function L_CMVUISetWEBAttrs : Boolean;
begin
  Result := L_WEBSettingsDlg();
end;

function L_CMVUICheckProvIU : Boolean;        //SIR#26380-26381
//var
//  CurCheckDate : TDate;
begin
  Result := FALSE;
  if VirtUI_ScanName <> '' then               //VirtUI_DateOut
  begin
      N_Dump1Str('VUI>> ScanCompName = ' + VirtUI_ScanName + ', LastScanVersion: ' + VirtUI_LastScanVersion + ', SuiteVersion:' + N_CMSVersion);
      if VirtUI_LastScanVersion = N_CMSVersion then
          Exit;
      if VirtUI_DateOut = '' then VirtUI_DateOut := DateToStr(Now + 1); // + 1day
      N_Dump1Str('VUI>> VirtUI_DateOut = ' + VirtUI_DateOut);
      if StrToDate(VirtUI_DateOut) < Now then
          Result := L_WEBCheckVersionDlg();
  end;
end;


function getLastScanVersion(Version: String): String;
//var
//  IdHTTP: TIdHTTP;
//  IdSSLIOHandlerSocketOpenSSL: TIdSSLIOHandlerSocketOpenSSL;
//  IdCookieManager: TIdCookieManager;
//  SourceCode: String;
//  ListFile: TStringList;
//  i: Integer;
begin
  Result := '';
{
  SourceCode := '';
  ListFile := TStringList.Create;
  IdHTTP := TIdHTTP.Create;  for comp in D7

  IdSSLIOHandlerSocketOpenSSL := TIdSSLIOHandlerSocketOpenSSL.Create;   for comp in D7
  IdCookieManager := TIdCookieManager.Create;
  IdHTTP.CookieManager := IdCookieManager;
  IdHTTP.IOHandler := IdSSLIOHandlerSocketOpenSSL;

  try
    IdHTTP.Request.UserAgent := 'Mozilla/5.0 (Windows NT 6.2; WOW64; rv:22.0) Gecko/20100101 Firefox/22.0';
    IdHTTP.Request.Accept := 'application/json, text/javascript, */*; q=0.01';
    IdHTTP.Request.AcceptLanguage := 'ru-RU,ru;q=0.8,en-US;q=0.5,en;q=0.3';

    SourceCode := IdHTTP.Get(L_VirtUICMScanWebInstallURL + 'CMScanWebUpgrades.txt');   // read to list from file of Install CMScanWEB
    if SourceCode <> '' then
    begin
      ListFile.Text := SourceCode;
      for i := 0 to ListFile.Count-1 do
      begin
        if Pos(Version, ListFile.Strings[i]) > 0 then
            Result := ListFile.Strings[i];
      end;
    end;
  finally
    IdHTTP.Free;
    IdSSLIOHandlerSocketOpenSSL.Free;
    IdCookieManager.Free;
    ListFile.Free;
  end;
}
end;

end.
