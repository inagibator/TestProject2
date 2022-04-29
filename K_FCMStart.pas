unit K_FCMStart;

interface

uses
  Forms, jpeg, StdCtrls, Classes, ExtCtrls, Controls;

type
  TK_FormCMStart = class(TForm)
    Image: TImage;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure ShowImage( AFName : string );
  end;

var
  K_FormCMStart: TK_FormCMStart;
  K_CMSkipSplashScreen : Boolean = FALSE;

procedure K_SplashScreenShow();
procedure K_SplashScreenHide();
procedure K_SplashScreenCust( ACustFlag : Boolean );

implementation

{$R *.dfm}

uses
  Graphics, SysUtils,
  K_UDT2, K_CLib0, K_CLib,
  N_Lib1, N_Lib2, N_Gra2, N_Types;

var SavedCursor : Integer;

procedure K_SplashScreenShow();
var
  WFName : string;

begin
  if K_CMSkipSplashScreen then
  begin
    N_Dump1Str( '!!!SkipSplashScreen by user' );
    Exit;
  end;

  WFName := N_MemIniToString( 'CMS_Main', 'SplashScreenImgFName', '' );

  if Screen.Cursor <> crHourGlass then
  begin
    SavedCursor := Screen.Cursor;
    Screen.Cursor := crHourGlass;
  end;

  if WFName <> '' then
  begin
    K_FormCMStart := TK_FormCMStart.Create( Application );
    K_FormCMStart.DoubleBuffered := TRUE;
    K_FormCMStart.Caption := WFName;
    K_FormCMStart.Show();
    K_FormCMStart.Refresh();
  end;
end; // procedure K_SplashScreenShow

procedure K_SplashScreenHide();
begin
  if K_FormCMStart <> nil then
    K_FormCMStart.Close;
  K_FormCMStart := nil;
  if Screen.Cursor = crHourGlass then
    Screen.Cursor := SavedCursor;
end; // procedure K_SplashScreenHide

procedure K_SplashScreenCust( ACustFlag : Boolean );
begin
  if K_FormCMStart = nil then
    K_SplashScreenShow();
  if (K_FormCMStart = nil) or not ACustFlag then Exit;

  with K_FormCMStart do
  begin
    Caption := N_MemIniToString( 'CMS_Main', 'SplashScreenImgEFName', '' );
    OnShow( nil );
    Refresh();
  end;
end; // procedure K_SplashScreenCust

procedure TK_FormCMStart.FormShow(Sender: TObject);
begin
  if Caption = '' then Exit;
  ShowImage( Caption );
end; // procedure TK_FormCMStart.FormShow

procedure TK_FormCMStart.ShowImage( AFName : string );
var
 VColor : Integer;

  procedure NoImage;
  begin
    Height := 1;
    Width  := 1;
  end;

begin
  if AFName = '' then
  begin
    N_Dump1Str( '!!!SplashScreenFile >> image file is not set ' );
    NoImage();
    Exit;
  end;
  try
//    VColor := K_LoadTImage( Image, 'C:\Delphi_prj_new\DTMP\CMS Test Data\Test.png' );
//    VColor := N_LoadTImage( Image, K_ExpandFileName(AFName), FALSE );
    VColor := K_LoadTImage( Image, K_ExpandFileName(AFName) );
    if VColor >= 0 then
      TransparentColorValue := VColor
    else
    if VColor = -1 then
    begin
      N_Dump1Str( '!!!SplashScreenFile >> image file is not found ' + AFName );
      NoImage();
      Exit;
    end;
  except end;

  ClientHeight := Image.Picture.Height;
  if ClientHeight = 0 then ClientHeight := 200;
  ClientWidth := Image.Picture.Width;
  if ClientWidth = 0 then ClientWidth := 200;
end; // procedure TK_FormCMStart.ShowImage


end.
