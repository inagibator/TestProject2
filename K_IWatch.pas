unit K_IWatch;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls,
  K_CLib0, K_Types,
  N_BaseF, N_Lib1;

type
  TK_InfoWatch = class;

  TK_FormInfoWatch = class(TN_BaseForm)
    Memo: TMemo;
    procedure FormClose ( Sender: TObject; var Action: TCloseAction ); override;
  private
    { Private declarations }
  public
    InfoWatch : TK_InfoWatch;
    { Public declarations }
  end;

  TK_IWFlagSet = Set of (
         K_iwContinueDump,
         K_iwNotShowNumbers,
         K_iwShowDate
          );

  TK_InfoWatch = class( TObject ) //
      private
  FDumpFlags : TK_IWFlagSet;         // DumpFlags
  FDateFormat : string;
  FInfoCount : Integer;          // Message Count

  FWatchForm : TK_FormInfoWatch; // Watch Info Form
  FWatchLinesCur : Integer;      // Watch Form Lines Count
  FWatchLinesMax : Integer;      // Watch Form Lines Max Count
  FWatchRect     : TRect;        // Watch Form Screen Pos Rectangle
  FWatchMLevel   : Integer;      // Watch Message Min Level

  FInfoFile      : string;       // Info File Name
  FFileInfoCount : Integer;      // Info File Message Count
  FFileMlevel    : Integer;      // Info File Message Min Level

  FConsoleUse       : Boolean;   // for System.IsConsole mode only
  FConsoleMlevel    : Integer;   // Info Console Message Min Level

  FStatusBar       : TStatusBar; // Info Status Bar
  FStatusBarMlevel : Integer;    // Info Status Bar Message Min Level

  FInfoLevel : Integer;
  FWarningLevel : Integer;
  FErrorLevel : Integer;
      public
  constructor Create( AWatchLinesMax : Integer = 0; AInfoFile : string = '';
                AStatusBar : TStatusBar = nil );

  destructor  Destroy; override;
  procedure   AddInfoLine( AInfo : string; InfoTag : Integer = 0 ); overload;
  procedure   AddInfoLine( AInfo : string; MesStatus : TK_MesStatus ); overload;
  procedure   AddInfoLines( SL : TStrings; InfoTag : Integer = 0 );
  function    GetWatchRect : TRect;
  procedure   SetWatchRect( WRect : TRect );

  property StatusBar      : TStatusBar read FStatusBar write FStatusBar;
  property StatusBarMLevel: Integer read FStatusBarMLevel write FStatusBarMLevel;
  property WatchMax       : Integer read FWatchLinesMax write  FWatchLinesMax;
  property WatchMLevel    : Integer read FWatchMlevel write  FWatchMlevel;
  property DumpFileName   : string read FInfoFile write FInfoFile;
  property DumpFileMlevel : Integer read FFileMlevel write FFileMlevel;
  property DumpFlags      : TK_IWFlagSet read FDumpFlags write FDumpFlags;         // DumpFlags
  property DateFormat     : string read FDateFormat write FDateFormat;
  property ConsoleMlevel  : Integer read FConsoleMlevel write FConsoleMlevel;
  property Console        : Boolean read FConsoleUse write FConsoleUse;
  property InfoLevel      : Integer read FInfoLevel write FInfoLevel;
  property WarningLevel   : Integer read FWarningLevel write FWarningLevel;
  property ErrorLevel     : Integer read FErrorLevel write FErrorLevel;

end; //*** end of type TK_UDFilter = class( TObject )

var
K_InfoWatch : TK_InfoWatch;

implementation

uses N_Types;

{$R *.dfm}

{*** TK_InfoWatch ***}

constructor TK_InfoWatch.Create( AWatchLinesMax : Integer = 0; AInfoFile : string = '';
                AStatusBar : TStatusBar = nil );
begin
  FWatchLinesMax := AWatchLinesMax;
  FInfoFile := AInfoFile;
  FStatusBar := AStatusBar;
  FDateFormat := '';
  FInfoLevel := 0;
  FWarningLevel := 1;
  FErrorLevel := 2;
end;

destructor TK_InfoWatch.Destroy;
begin
  inherited;
end;


procedure TK_InfoWatch.AddInfoLine( AInfo: string; InfoTag: Integer = 0 );
var
  F: TextFile;
  BufStr: String; // AnsiString;
begin
  if AInfo <> '' then N_Dump1Str( AInfo );
  if Self = nil then Exit;
  Inc(FInfoCount);
  BufStr := '';
  if AInfo <> '' then begin
    if not (K_iwNotShowNumbers in FDumpFlags) then
      BufStr := Format( '%.4d ', [ FInfoCount ] );
    if K_iwShowDate in FDumpFlags then
      BufStr := BufStr + TimeToStr(Time) + ' ';
  //    BufStr := BufStr + K_DateTimeToSTr( Now(), FDateFormat ) + ' ';
    BufStr := BufStr + AInfo;
  end;

  if (FInfoFile <> '') and (FFileMLevel <= InfoTag) then begin // add Info line to file
    try
      Assign( F, FInfoFile );
      if not FileExists( FInfoFile ) or
        ( (FFileInfoCount = 0) and
           not (K_iwContinueDump in FDumpFlags) ) then
        Rewrite( F )
      else
        Append( F );
      if FFileInfoCount = 0 then begin
        WriteLn( F, '' );
        WriteLn( F, '***** Dump start ' + K_DateTimeToSTr( Now(), FDateFormat ) );
      end;
      WriteLn( F, BufStr );
      Flush( F );
      Close( F );
      Inc(FFileInfoCount);
    except
      FInfoFile := ''; // Prevent Application Dump if something is wrong with Dump File
    end;
  end;

  if (FWatchLinesMax > 0) and (FWatchMLevel <= InfoTag) then begin
    if FWatchForm = nil then begin
      FWatchForm := TK_FormInfoWatch.Create(Application);
      FWatchForm.BaseFormInit(nil);
      FWatchForm.InfoWatch := self;
      FWatchLinesCur := 0;
      FWatchForm.Left := FWatchRect.Left;
      FWatchForm.Top := FWatchRect.Top;
      if FWatchRect.Right <> 0 then
        FWatchForm.Width := FWatchRect.Right;
      if FWatchRect.Bottom <> 0 then
        FWatchForm.Height := FWatchRect.Bottom;
      FWatchForm.Show;
    end;
    if FWatchLinesCur = FWatchLinesMax then
      FWatchForm.Memo.Lines.Delete(0)
    else
      Inc(FWatchLinesCur);
    FWatchForm.Memo.Lines.Add( BufStr );
  end else if FWatchForm <> nil then
    FWatchForm.Release;

  if (FStatusBar <> nil) and (FStatusBarMLevel <= InfoTag) then
    FStatusBar.SimpleText := BufStr;

  if IsConsole   and
     FConsoleUse and
     (FConsoleMlevel <= InfoTag) then begin
    CharToOemBuff( @BufStr[1], PAnsiChar(@BufStr[1]), Length(BufStr) );
    WriteLn( BufStr );
  end;
end;

procedure TK_InfoWatch.AddInfoLine( AInfo : string; MesStatus : TK_MesStatus );
var Level : Integer;
begin
  Level := FInfoLevel;
  case MesStatus of
    K_msWarning : Level := FWarningLevel;
    K_msError   : Level := FErrorLevel;
  end;
  AddInfoLine( AInfo, Level );
end;

procedure TK_InfoWatch.AddInfoLines( SL: TStrings; InfoTag: Integer = 0 );
var i : Integer;
begin
  for i := 0 to SL.Count - 1 do
    AddInfoLine( SL.Strings[i], InfoTag );
end;

function TK_InfoWatch.GetWatchRect: TRect;
begin
  Result := Rect(0,0,0,0);
  if Self = nil then Exit;
  if FWatchForm = nil then Exit;
  Result.Left := FWatchForm.Left;
  Result.Top := FWatchForm.Top;
  Result.Right := FWatchForm.Width;
  Result.Bottom := FWatchForm.Height;
end;

procedure TK_InfoWatch.SetWatchRect(WRect: TRect);
begin
  if Self = nil then Exit;
  FWatchRect := WRect;
  if FWatchForm = nil then Exit;
  FWatchForm.Left := FWatchRect.Left;
  FWatchForm.Top := FWatchRect.Top;
  FWatchForm.Width := FWatchRect.Right;
  FWatchForm.Height := FWatchRect.Bottom;
end;

{*** end of TK_InfoWatch ***}

{*** TK_FormInfoWatch ***}
procedure TK_FormInfoWatch.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  InfoWatch.FWatchForm := nil;
  inherited;
end;

{*** end of TK_FormInfoWatch ***}

end.
