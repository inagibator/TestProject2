unit K_FCMImportPPL;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, Grids,
  N_Types, N_BaseF,
  K_Types, K_CLib0, N_FNameFr, Menus;

type
  TK_FormCMImportPPL = class(TN_BaseForm)
    BtCancel: TButton;
    BtStart: TButton;
    SGStateView: TStringGrid;
    FileNameFrame: TN_FileNameFrame;
    LbInfo: TLabel;
    Timer: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SGStateViewDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure SGStateViewExit(Sender: TObject);
    procedure BtStartClick(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
    CurImportPath : string;
    SkipSelectedDraw : Boolean;
    SL : TStringList;
    ////////////////////////
    // Do Import Context
    SavedCursor: TCursor;
    ImportState : Integer;
    FNameDate : string;
    SPos, FPos, SLeng, AllPatCount : Integer;

    PatT, ProvT, LocT : Integer;
    PatU, ProvU, LocU : Integer;
    PatN, ProvN, LocN : Integer;
    PatA, ProvA, LocA : Integer;
    PatFName, ProvFName, LocFName : string;
    procedure OnFileChange();
    function  TestLinkFile( const APathName, AFileName : string; AScanLevel : Integer ) : TK_ScanTreeResult;
    procedure DoImportPPL();
  public
    { Public declarations }
    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;
  end;

var
  K_FormCMImportPPL: TK_FormCMImportPPL;

procedure K_CMImportPPLDlg( );

implementation

{$R *.dfm}
uses DB, ADODB,
     N_Lib0, N_Lib1, N_CMMain5F,
     K_CM0, K_CML1F, K_CLib, K_UDT2;

//******************************************************* K_CMImportPPLDlg ***
// Files Export Dialog
//
//   Parameters
// APSlide       - pointer to slides
// ASlidesCount  - number of slides
// Result - Returns TRUE if some files were exported
//
procedure K_CMImportPPLDlg( );
//var
//  i : Integer;
begin
  K_FormCMImportPPL := TK_FormCMImportPPL.Create(Application);
  with K_FormCMImportPPL do
  begin
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    OnFileChange();
    ShowModal();
    K_FormCMImportPPL := nil;
  end;
end; // K_CMImportPPLDlg

//*********************************************** TK_FormCMImportPPL.OnFileChange ***
//
procedure TK_FormCMImportPPL.OnFileChange;
begin
//  BtStart.Enabled := SameText( ExtractFileExt(FileNameFrame.mbFileName.Text), '.xml' );
  BtStart.Enabled := K_CheckTextPattern( ExtractFileName(FileNameFrame.mbFileName.Text), '*_????-??-??.xml' );
end; // procedure TK_FormCMImportPPL.OnFileChange


//*********************************************** TK_FormCMImportPPL.FormCreate ***
//
procedure TK_FormCMImportPPL.FormCreate(Sender: TObject);
begin
  inherited;
  FileNameFrame.OnChange := OnFileChange;

{$IF CompilerVersion >= 26.0} // Delphi >= XE5
  SGStateView.DefaultDrawing := FALSE;
{$IFEND CompilerVersion >= 26.0}

end; // TK_FormCMImportPPL.FormCreate

//*********************************************** TK_FormCMImportPPL.FormShow ***
//
procedure TK_FormCMImportPPL.FormShow(Sender: TObject);
var
  i, j : Integer;
  SelRect: TGridRect;
begin
{
  SGStateView.Cells[0,1] := 'Patients';
  SGStateView.Cells[0,2] := 'Dentists';
  SGStateView.Cells[0,3] := 'Practices';
  SGStateView.Cells[1,0] := 'Total';
  SGStateView.Cells[2,0] := 'Imported';
  SGStateView.Cells[3,0] := 'Updated';
  SGStateView.Cells[4,0] := 'Created';
}
  SGStateView.Cells[0,1] := K_CML1Form.LLLExpImpRowNames.Items[0];// 'Patients';
  SGStateView.Cells[0,2] := K_CML1Form.LLLExpImpRowNames.Items[1];// 'Dentists';
  SGStateView.Cells[0,3] := K_CML1Form.LLLExpImpRowNames.Items[2];// 'Practices';
  SGStateView.Cells[1,0] := K_CML1Form.LLLImpColNames.Items[0];// 'Total';
  SGStateView.Cells[2,0] := K_CML1Form.LLLImpColNames.Items[1];// 'Imported';
  SGStateView.Cells[3,0] := K_CML1Form.LLLImpColNames.Items[2];// 'Updated';
  SGStateView.Cells[4,0] := K_CML1Form.LLLImpColNames.Items[3];// 'Created';

  for i := 1 to 4 do
    for j := 1 to 3 do
      SGStateView.Cells[i,j] := '0';

//  RebuildExportInfoView();

  SelRect.Left := -1;
  SelRect.Right := -1;
  SelRect.Top := -1;
  SelRect.Bottom := -1;
  SGStateView.Selection := SelRect;

end; // TK_FormCMImportPPL.FormShow

//***********************************  TK_FormCMImportPPL.CurStateToMemIni  ***
//
procedure TK_FormCMImportPPL.CurStateToMemIni();
begin
  inherited;
  N_ComboBoxToMemIni( 'CMSImportPPLFilesHistory', FileNameFrame.mbFileName );
end; // end of TK_FormCMImportPPL.CurStateToMemIni

//***********************************  TK_FormCMImportPPL.MemIniToCurState  ******
//
procedure TK_FormCMImportPPL.MemIniToCurState();
begin
  inherited;
  N_MemIniToComboBox( 'CMSImportPPLFilesHistory', FileNameFrame.mbFileName );
end; // end of TK_FormCMImportPPL.MemIniToCurState

//***********************************  TK_FormCMImportPPL.SGStateViewDrawCell  ******
// Info String Grid onDraw handler
//
procedure TK_FormCMImportPPL.SGStateViewDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
begin
  if SkipSelectedDraw then
  begin
    SkipSelectedDraw := FALSE;
    SGStateView.Canvas.Brush.Color := ColorToRGB(SGStateView.Color);
  end;
  K_CellDrawString( SGStateView.Cells[ACol,ARow], Rect, K_ppCenter, K_ppCenter, SGStateView.Canvas, 5, 0, 0 );
end; // procedure TK_FormCMImportPPL.SGStateViewDrawCell


//***********************************  TK_FormCMImportPPL.SGStateViewExit  ******
// Info String Grid onExit handler
//
procedure TK_FormCMImportPPL.SGStateViewExit(Sender: TObject);
begin
  SkipSelectedDraw := TRUE;
end; // procedure TK_FormCMImportPPL.SGStateViewExit
{
//***********************************  TK_FormCMImportPPL.BtStartClick  ******
// BtStart onClick handler
//
procedure TK_FormCMImportPPL.BtStartClick(Sender: TObject);
var
  SQLText : string;
  L : Integer;
  WPos, SPos, FPos, SLeng, PatCount, AllPatCount : Integer;
begin
//
  N_Dump1Str( 'SAI>> Import Start ' + CurImportPath );

  if TK_CMEDDBAccess(K_CMEDAccess).EDACheckActiveInstances( K_CMEDAInstanceStandaloneFlag ) > 1 then
  begin
//    if (mrYes <> K_CMShowMessageDlg( 'Some users run CMS in alone mode. Press Yes to proceed',
//                                      mtConfirmation )) then Exit;
    if (mrYes <> K_CMShowMessageDlg( K_CML1Form.LLLExpImpNotSingleUser.Caption,
                                      mtConfirmation )) then Exit;
  end;

  SL := TStringList.Create;


  CurImportPath := IncludeTrailingPathDelimiter( ExtractFilePath( FileNameFrame.mbFileName.Text ) );
  FNameDate := ExtractFileName(FileNameFrame.mbFileName.Text);
  L := Length( FNameDate );
  FNameDate := Copy( FNameDate, L - 13, 10 );
  PatFName := 'patients_' + FNameDate + '.xml';
  K_ScanFilesTree( CurImportPath, TestLinkFile, PatFName );
  if SL.Count = 0 then
  begin
//    K_CMShowMessageDlg1( format(
//      'File %s is missing. Please copy this file to the XML folder and resume import.'#13#10 +
//      '                            Press OK to continue.', [PatFName] ), mtWarning  );
    K_CMShowMessageDlg1( format( K_CML1Form.LLLImpFileIsMissing.Caption, [PatFName] ), mtWarning );
    SL.Free;
    Exit;
  end;

//  SL.Sort();
//  PatFName := SL[SL.Count - 1];
//  FNameDate := Copy( PatFName, 10, 10 );

  ProvFName := 'dentists_' + FNameDate + '.xml';
  if not FileExists( CurImportPath + ProvFName ) then
  begin
//    K_CMShowMessageDlg1( format(
//      'File %s is missing. Please copy this file to the XML folder and resume import.'#13#10 +
//      '                            Press OK to continue.', [ProvFName] ), mtWarning  );
    K_CMShowMessageDlg1( format( K_CML1Form.LLLImpFileIsMissing.Caption, [ProvFName] ), mtWarning );
    SL.Free;
    Exit;
  end;

  LocFName := 'practices_' + FNameDate + '.xml';
  if not FileExists( CurImportPath + LocFName ) then
  begin
//    K_CMShowMessageDlg1( 'File ' + LocFName + ' is not found', mtWarning );
//    SL.Free;
//    Exit;
    LocFName := '';
  end;

  SL.Clear;

  SavedCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;
  with TK_CMEDDBAccess(K_CMEDAccess) do
  begin
    try
    // Process Import Files

      LocT := 0;
      SGStateView.Cells[1,3] := '0';
      LocU := 0;
      SGStateView.Cells[3,3] := '0';
      LocN := 0;
      SGStateView.Cells[4,3] := '0';
      LocA := 0;

      ProvT := 0;
      SGStateView.Cells[1,2] := '0';
      ProvU := 0;
      SGStateView.Cells[3,2] := '0';
      ProvN := 0;
      SGStateView.Cells[4,2] := '0';
      ProvA := 0;

      PatT := 0;
      SGStateView.Cells[1,1] := '0';
      PatU := 0;
      SGStateView.Cells[3,1] := '0';
      PatN := 0;
      SGStateView.Cells[4,1] := '0';
      PatA := 0;

      if LocFName <> '' then
      begin
    //////////////////////////////
    //  Import Locations data
    //
        N_Dump1Str( 'SAI>> Import from ' + LocFName );
        if not K_VFLoadText( StrTextBuf, CurImportPath + LocFName ) then
        begin
          K_CMShowMessageDlg1( format( K_CML1Form.LLLImpReadFileError.Caption, [LocFName] ), mtWarning );
        end
        else
        begin
          // Parse SQL to Special Import Table
          LbInfo.Caption := K_CML1Form.LLLImpProcTexts.Items[0];
          LbInfo.Refresh();

          with CurStoredProc1 do
          begin
            Connection := LANDBConnection;

            // Exec Procedure
            ProcedureName := 'dba.cms_ImportLocationsData';
            Parameters.Clear;
            with Parameters.AddParameter do
            begin
              Name := '@xml_data';
              Direction := pdInput;
              DataType := ftString;
              Value := StrTextBuf;
            end;
            ExecProc;
          end; // with CurStoredProc1 do

          // Count Total|Updated|Created|Orphaned
          with CurDSet1 do
          begin
            Connection := LANDBConnection;
            Filtered := FALSE;

            // Total Locations
            SQLText := 'select count(*) ' +
                       ' from ' + K_CMENDBImportLocationsTable;
            SQL.Text := SQLText;
            Open();
            LocT := Fields[0].AsInteger;
            SGStateView.Cells[1,3] := Fields[0].AsString;
            Close();

            // Update Locations
            SQL.Text := SQLText + ',' + K_CMENDBAllLocationsTable +
                    ' where ' + K_CMENDALBridgeID + '=' + K_CMENDILID;
            Open();
            LocU := Fields[0].AsInteger;
            SGStateView.Cells[3,3] := Fields[0].AsString;
            Close();

            // New Locations
            SQL.Text := SQLText +
                        ' where not exists (select 1 from ' + K_CMENDBAllLocationsTable +
                                       ' where ' + K_CMENDALBridgeID + '=' + K_CMENDILID + ')';
            Open();
            LocN := Fields[0].AsInteger;
            SGStateView.Cells[4,3] := Fields[0].AsString;
            Close();
            SGStateView.Cells[2,3] := IntToStr( LocU + LocN );

            // Orphans Locations
            SQL.Text := 'select ' + K_CMENDALID + ',' + K_CMENDALBridgeID + ',' + K_CMENDALName +
                        ' from ' + K_CMENDBAllLocationsTable +
                        ' where '+ K_CMENDALBridgeID + ' > 0' +
                        ' and not exists (select 1 from ' + K_CMENDBImportLocationsTable +
                                          ' where ' + K_CMENDALBridgeID + '=' + K_CMENDILID + ')';
            Open();
            LocA := 0;
            while not EOF do
            begin
              Inc(LocA);
              SL.Add( format('%d;%s;%s;%s;',
                 [LocA,Fields[0].AsString,Fields[1].AsString,Fields[2].AsString] ) );
              Next;
            end;
            Close();
            if LocA > 0 then
            begin
              SL.Insert( 0, 'Orphan practice;;;;' );
              SL.Insert( 1, '#;CMS ID;Bridge ID;Name;' );
            end;
          end; // with CurDSet1 do

         // Load Data from Import Table
          with CurSQLCommand1 do
          begin
          // Update Existing
            Connection := LANDBConnection;
            CommandText :='UPDATE ' + K_CMENDBAllLocationsTable +
                          ' SET ' + K_CMENDALName + '=' + K_CMENDILName +
                          ' FROM ' + K_CMENDBImportLocationsTable +
                          ' WHERE ' + K_CMENDALBridgeID + ' = ' + K_CMENDILID;
            Execute;

          // Create New
            CommandText :='INSERT INTO ' + K_CMENDBAllLocationsTable +
                          ' (' + K_CMENDALBridgeID + ',' + K_CMENDALName + ')' +
                          ' SELECT ' + K_CMENDILID + ',' + K_CMENDILName +
                          ' FROM ' + K_CMENDBImportLocationsTable +
                          ' WHERE NOT EXISTS (SELECT 1 FROM ' + K_CMENDBAllLocationsTable +
                                             ' WHERE ' + K_CMENDALBridgeID + ' = ' + K_CMENDILID + ')';
            Execute;
          end; // with CurSQLCommand1 do
        end; // Import Locations
    //
    //  Import Locations data
    //////////////////////////////
      end;

      SGStateView.Refresh();

    //////////////////////////////
    //  Import Providers data
    //
      N_Dump1Str( 'SAI>> Import from ' + ProvFName );
      if not K_VFLoadText( StrTextBuf, CurImportPath + ProvFName ) then
      begin
        K_CMShowMessageDlg1( format( K_CML1Form.LLLImpReadFileError1.Caption, [ProvFName] ), mtWarning );
      end
      else
      begin
        // Parse SQL to Special Import Table
        LbInfo.Caption := K_CML1Form.LLLImpProcTexts.Items[1];
        LbInfo.Refresh();

        with CurStoredProc1 do
        begin
          Connection := LANDBConnection;

          // Exec Procedure
          ProcedureName := 'dba.cms_ImportProvidersData';
          Parameters.Clear;
          with Parameters.AddParameter do
          begin
            Name := '@xml_data';
            Direction := pdInput;
            DataType := ftString;
            Value := StrTextBuf;
          end;
          ExecProc;
        end; // with CurStoredProc1 do

        // Count Total|Updated|Created|Orphaned
        with CurDSet1 do
        begin
          Connection := LANDBConnection;
          Filtered := FALSE;

          // Total Providers
          SQLText := 'select count(*) ' +
                     ' from ' + K_CMENDBImportProvidersTable;
          SQL.Text := SQLText;
          Open();
          ProvT := Fields[0].AsInteger;
          SGStateView.Cells[1,2] := Fields[0].AsString;
          Close();

          // Update Providers
          SQL.Text := SQLText + ',' + K_CMENDBAllProvidersTable +
                  ' where ' + K_CMENDAUBridgeID + '=' + K_CMENDIUID;
          Open();
          ProvU := Fields[0].AsInteger;
          SGStateView.Cells[3,2] := Fields[0].AsString;
          Close();

          // New Providers
          SQL.Text := SQLText +
                  ' where not exists (select 1 from ' + K_CMENDBAllProvidersTable +
                                     ' where ' + K_CMENDAUBridgeID + '=' + K_CMENDIUID + ')';
          Open();
          ProvN := Fields[0].AsInteger;
          SGStateView.Cells[4,2] := Fields[0].AsString;
          Close();
          SGStateView.Cells[2,2] := IntToStr(ProvU + ProvN);

          // Orphans Providers
          SQL.Text := 'select ' + K_CMENDAUID + ',' + K_CMENDAUBridgeID + ',' +
                                  K_CMENDAUSurname + ',' + K_CMENDAUFirstname +
                      ' from ' + K_CMENDBAllProvidersTable +
                      ' where '+ K_CMENDAUBridgeID + ' > 0' +
                      ' and not exists (select 1 from ' + K_CMENDBImportProvidersTable +
                                        ' where ' + K_CMENDAUBridgeID + '=' + K_CMENDIUID + ')';
          Open();
          ProvA := 0;
          while not EOF do
          begin
            SL.Insert( ProvA, format('%d;%s;%s;%s;%s',
               [ProvA+1,Fields[0].AsString,Fields[1].AsString,
                Fields[2].AsString,Fields[3].AsString] ) );
            Inc(ProvA);
            Next;
          end;
          Close();
          if ProvA > 0 then
          begin
            SL.Insert( 0, 'Orphan Dentists;;;;' );
            SL.Insert( 1, '#;CMS ID;Bridge ID;Surname;Name' );
          end;
        end; // with CurDSet1 do

       // Load Data from Import Table
        with CurSQLCommand1 do
        begin
        // Update Existing
          Connection := LANDBConnection;
          CommandText :='UPDATE ' + K_CMENDBAllProvidersTable +
                        ' SET ' + K_CMENDAUSurname     + '=' + K_CMENDIUSurname + ',' +
                                  K_CMENDAUFirstname   + '=' + K_CMENDIUFirstname + ',' +
                                  K_CMENDAUMiddle      + '=' + K_CMENDIUMiddle + ',' +
                                  K_CMENDAUTitle       + '=' + K_CMENDIUTitle + ',' +
                                  K_CMENDAUAuthorities + '=' + K_CMENDIUAuthorities +
                        ' FROM ' + K_CMENDBImportProvidersTable +
                        ' WHERE ' + K_CMENDAUBridgeID + ' = ' + K_CMENDIUID;
          Execute;

        // Create New
          CommandText :='INSERT INTO ' + K_CMENDBAllProvidersTable +
                        ' (' + K_CMENDAUBridgeID  + ',' + K_CMENDAUSurname + ',' +
                               K_CMENDAUFirstname + ',' + K_CMENDAUMiddle + ',' +
                               K_CMENDAUTitle     + ',' + K_CMENDAUAuthorities + ')' +
                        ' SELECT ' + K_CMENDIUID        + ',' + K_CMENDIUSurname + ',' +
                                     K_CMENDIUFirstname + ',' + K_CMENDIUMiddle + ',' +
                                     K_CMENDIUTitle     + ',' + K_CMENDIUAuthorities +
                        ' FROM ' + K_CMENDBImportProvidersTable +
                        ' WHERE NOT EXISTS (SELECT 1 FROM ' + K_CMENDBAllProvidersTable +
                                           ' WHERE ' + K_CMENDAUBridgeID + ' = ' + K_CMENDIUID + ')';
          Execute;
        end; // with CurSQLCommand1 do
      //
      //  Import Providers data
      //////////////////////////////
      SGStateView.Refresh();

      //////////////////////////////
      //  Import Patients data
      //
        N_Dump1Str( 'SAI>> Import from ' + PatFName );
        if not K_VFLoadText( StrTextBuf, CurImportPath + PatFName ) then
        begin
          K_CMShowMessageDlg1( format( K_CML1Form.LLLImpReadFileError.Caption, [PatFName] ), mtWarning );
        end
        else
        begin
          // Parse SQL to Special Import Table
          with CurStoredProc1 do
          begin
            Connection := LANDBConnection;

            ProcedureName := 'dba.cms_ImportPatientsData';
            with Parameters.AddParameter do
            begin
              Name := '@xml_data';
              Direction := pdInput;
              DataType := ftString;
            end;
            with Parameters.AddParameter do
            begin
              Name := '@ind';
              Direction := pdInput;
              DataType := ftInteger;
              Value := 0; // for 1-st portion
            end;

            // Init Patients Loop
            // Search start position
            SLeng := Length(StrTextBuf);
            SPos := 1;
            SPos := N_PosEx( '>', StrTextBuf, SPos, SLeng );
            SPos := N_PosEx( '<', StrTextBuf, SPos, SLeng );
            WPos := 0;

            //////////////////////
            // All Patients Loop
            //
            AllPatCount := 0;
            FPos := SPos;
            while TRUE do
            begin
              PatCount := 0;
//              while PatCount < 1 do
              while PatCount < 1000 do
              begin // Next 100 patients loop
                WPos := N_PosEx( '/>', StrTextBuf, FPos, SLeng );
                if WPos > 0 then
                begin
                  FPos := WPos + 2;
                  Inc(PatCount);
                end
                else
                  break;
              end; // Next 100 patients loop

              AllPatCount := AllPatCount + PatCount;
              LbInfo.Caption := format( K_CML1Form.LLLImpProcTexts.Items[2], [AllPatCount, 100.0*FPos/SLeng] );
              LbInfo.Refresh();
              if PatCount = 0 then break; // Empty Patients Portion
              // Exec Procedure

              Parameters.Items[0].Value := '<patients>' +
                                           Copy( StrTextBuf, SPos, FPos - SPos ) +
                                           '</patients>';
              ExecProc;

              Parameters.Items[1].Value := 1; // for next portions

              SPos := FPos;
              if WPos = 0 then break; // Last Patients Portion
            end;
            //
            // All Patients Loop
            //////////////////////
          end; // with CurStoredProc1 do

          // Count Total|Updated|Created|Orphaned
          with CurDSet1 do
          begin
            Connection := LANDBConnection;
            Filtered := FALSE;

            // Total Patients
            SQLText := 'select count(*) ' +
                       ' from ' + K_CMENDBImportPatientsTable;
            SQL.Text := SQLText;
            Open();
            PatT := Fields[0].AsInteger;
            SGStateView.Cells[1,1] := Fields[0].AsString;
            Close();

            // Update Patients
            SQL.Text := SQLText + ',' + K_CMENDBAllPatientsTable +
                    ' where ' + K_CMENDAPBridgeID + '=' + K_CMENDIPID;
            Open();
            PatU := Fields[0].AsInteger;
            SGStateView.Cells[3,1] := Fields[0].AsString;
            Close();

            // New Patients
            SQL.Text := SQLText +
                    ' where not exists (select 1 from ' + K_CMENDBAllPatientsTable +
                                       ' where ' + K_CMENDAPBridgeID + '=' + K_CMENDIPID + ')';
            Open();
            PatN := Fields[0].AsInteger;
            SGStateView.Cells[4,1] := Fields[0].AsString;
            Close();
            SGStateView.Cells[2,1] := IntToStr(PatU + PatN);

            // Orphans Patients
            SQL.Text := 'select ' + K_CMENDAPID + ',' + K_CMENDAPBridgeID + ',' +
                                    K_CMENDAPSurname + ',' + K_CMENDAPFirstname +
                        ' from ' + K_CMENDBAllPatientsTable +
                        ' where '+ K_CMENDAPBridgeID + ' > 0' +
                        ' and not exists (select 1 from ' + K_CMENDBImportPatientsTable +
                                          ' where ' + K_CMENDAPBridgeID + '=' + K_CMENDIPID + ')';
            Open();
            PatA := 0;
            while not EOF do
            begin
              SL.Insert( PatA, format('%d;%s;%s;%s;%s',
                 [PatA+1,Fields[0].AsString,Fields[1].AsString,
                  Fields[2].AsString,Fields[3].AsString] ) );
              Inc(PatA);
              Next;
            end;
            Close();
            if PatA > 0 then
            begin
              SL.Insert( 0, 'Orphan Patients;;;;' );
              SL.Insert( 1, '#;CMS ID;Bridge ID;Surname;Name' );
            end;

          end; // with CurDSet1 do

         // Load Data from Import Table
          with CurSQLCommand1 do
          begin
            LbInfo.Caption := K_CML1Form.LLLImpProcTexts.Items[3];
            LbInfo.Refresh();

          // Update Existing
            Connection := LANDBConnection;
            CommandText :='UPDATE ' + K_CMENDBAllPatientsTable +
                          ' SET ' + K_CMENDAPSurname     + '=' + K_CMENDIPSurname + ',' +
                                    K_CMENDAPFirstname   + '=' + K_CMENDIPFirstname + ',' +
                                    K_CMENDAPMiddle      + '=' + K_CMENDIPMiddle + ',' +
                                    K_CMENDAPTitle       + '=' + K_CMENDIPTitle + ',' +
                                    K_CMENDAPGender      + '=' + K_CMENDIPGender + ',' +
                                    K_CMENDAPCardNum     + '=' + K_CMENDIPCardNum + ',' +
                                    K_CMENDAPDOB         + '=' + K_CMENDIPDOB + ',' +
                                    K_CMENDAPProvID      + '=' + K_CMENDAUID + ',' +
                                    K_CMENDAPAddr1       + '=' + K_CMENDIPAddr1 + ',' +
                                    K_CMENDAPAddr2       + '=' + K_CMENDIPAddr2 + ',' +
                                    K_CMENDAPSuburb      + '=' + K_CMENDIPSuburb + ',' +
                                    K_CMENDAPPostCode    + '=' + K_CMENDIPPostCode + ',' +
                                    K_CMENDAPState       + '=' + K_CMENDIPState + ',' +
                                    K_CMENDAPPhone1      + '=' + K_CMENDIPPhone1 + ',' +
                                    K_CMENDAPPhone2      + '=' + K_CMENDIPPhone2 +
                          ' FROM ' + K_CMENDBImportPatientsTable + ',' + K_CMENDBAllProvidersTable +
                          ' WHERE ' + K_CMENDAPBridgeID + ' = ' + K_CMENDIPID +
                          '   AND ' + K_CMENDIPProvID + ' = ' + K_CMENDAUBridgeID;
            Execute;

            LbInfo.Caption := K_CML1Form.LLLImpProcTexts.Items[4];
            LbInfo.Refresh();
          // Create New
            CommandText :='INSERT INTO ' + K_CMENDBAllPatientsTable +
                          ' (' + K_CMENDAPBridgeID  + ',' + K_CMENDAPSurname + ',' +
                                 K_CMENDAPFirstname + ',' + K_CMENDAPMiddle + ',' +
                                 K_CMENDAPTitle     + ',' + K_CMENDAPGender + ',' +
                                 K_CMENDAPCardNum   + ',' + K_CMENDAPDOB + ',' +
                                 K_CMENDAPProvID    + ',' + K_CMENDAPAddr1 + ',' +
                                 K_CMENDAPAddr2     + ',' + K_CMENDAPSuburb + ',' +
                                 K_CMENDAPPostCode  + ',' + K_CMENDAPState + ',' +
                                 K_CMENDAPPhone1    + ',' + K_CMENDAPPhone2 + ')' +
                          ' SELECT ' + K_CMENDIPID        + ',' + K_CMENDIPSurname + ',' +
                                       K_CMENDIPFirstname + ',' + K_CMENDIPMiddle + ',' +
                                       K_CMENDIPTitle     + ',' + K_CMENDIPGender + ',' +
                                       K_CMENDIPCardNum   + ',' + K_CMENDIPDOB + ',' +
                                       K_CMENDAUID        + ',' + K_CMENDIPAddr1 + ',' +
                                       K_CMENDIPAddr2     + ',' + K_CMENDIPSuburb + ',' +
                                       K_CMENDIPPostCode  + ',' + K_CMENDIPState + ',' +
                                       K_CMENDIPPhone1    + ',' + K_CMENDIPPhone2 +
                          ' FROM ' + K_CMENDBImportPatientsTable + ',' + K_CMENDBAllProvidersTable +
                          ' WHERE NOT EXISTS (SELECT 1 FROM ' + K_CMENDBAllPatientsTable +
                                             ' WHERE ' + K_CMENDAPBridgeID + ' = ' + K_CMENDIPID + ')' +
                          '   AND ' + K_CMENDIPProvID + ' = ' + K_CMENDAUBridgeID;
            Execute;
          end; // with CurSQLCommand1 do
        end; // Patients Import
      //
      //  Import Patients data
      //////////////////////////////
      end; // Import Providers and Patients data

      LbInfo.Caption := '';

      // Create Report

      TmpStrings.Clear;
      TmpStrings.Add(';Imported;Updated;Created;Orphaned');

      TmpStrings.Add( format( 'Patients;%s;%s;%s;%d',
        [SGStateView.Cells[2,1], SGStateView.Cells[3,1], SGStateView.Cells[4,1], PatA] ) );

      TmpStrings.Add( format( 'Dentists;%s;%s;%s;%d',
        [SGStateView.Cells[2,2], SGStateView.Cells[3,2], SGStateView.Cells[4,2], ProvA] ) );

      TmpStrings.Add( format( 'Practices;%s;%s;%s;%d',
        [SGStateView.Cells[2,3], SGStateView.Cells[3,3], SGStateView.Cells[4,3], LocA] ) );

      TmpStrings.SaveToFile( CurImportPath + 'Import_' + FNameDate + '.csv' );

      N_Dump1Str( 'SAI>> import_' + FNameDate );
      N_Dump1Strings( TmpStrings, 0 );

      if SL.Count > 0 then
      begin
        SL.SaveToFile( CurImportPath + 'orphan_' + FNameDate + '.csv' );
        N_Dump1Str( 'SAI>> orphan_' + FNameDate );
        N_Dump1Strings( SL, 0 );
      end;

      K_CMShowMessageDlg1( format(K_CML1Form.LLLImpFin.Caption,
          [#13#10 + PatFName + #13#10 + ProvFName +  #13#10 + LocFName]), mtInformation );

      N_Dump1Str( 'SAI>> Import Fin' );
      SL.Free;
      Screen.Cursor := SavedCursor;
    except
      on E: Exception do
      begin
        Screen.Cursor := SavedCursor;
        ExtDataErrorString := 'TK_FormCMImportPPL.BtStartClick ' + E.Message;
        CurDSet1.Close;
        SL.Free;
        ExtDataErrorCode := K_eeDBUpdate;
        EDAShowErrMessage(TRUE);
      end;
    end;
  end; // with TK_CMEDDBAccess(K_CMEDAccess) do

end; // procedure TK_FormCMImportPPL.BtStartClick
}
//***********************************  TK_FormCMImportPPL.BtStartClick  ******
// BtStart onClick handler
//
procedure TK_FormCMImportPPL.BtStartClick(Sender: TObject);
var
  L : Integer;
begin
//
  N_Dump1Str( 'SAI>> TK_FormCMImportPPL.BtStartClick ' );

  if TK_CMEDDBAccess(K_CMEDAccess).EDACheckActiveInstances( K_CMEDAInstanceStandaloneFlag ) > 1 then
  begin
    if (mrYes <> K_CMShowMessageDlg( K_CML1Form.LLLExpImpNotSingleUser.Caption + ' ' +
                                     K_CML1Form.LLLPressYesToProceed.Caption,
//                                     'Some users run CMS in alone mode. Press Yes to proceed'
                                     mtConfirmation )) then Exit;
  end;

  SL := TStringList.Create;


  CurImportPath := IncludeTrailingPathDelimiter( ExtractFilePath( FileNameFrame.mbFileName.Text ) );
  FNameDate := ExtractFileName(FileNameFrame.mbFileName.Text);
  L := Length( FNameDate );
  FNameDate := Copy( FNameDate, L - 13, 10 );
  PatFName := 'patients_' + FNameDate + '.xml';
  K_ScanFilesTree( CurImportPath, TestLinkFile, PatFName );
  if SL.Count = 0 then
  begin
    K_CMShowMessageDlg1( format( K_CML1Form.LLLImpFileIsMissing.Caption +
                                 #13#10'                            '   +
                                 K_CML1Form.LLLPressOKToContinue.Caption,
//      'File %s is missing. Please copy this file to the XML folder and resume import.'#13#10 +
//      '                            Press OK to continue.', [PatFName] ),
                                 [PatFName] ), mtWarning );
    SL.Free;
    Exit;
  end;

//  SL.Sort();
//  PatFName := SL[SL.Count - 1];
//  FNameDate := Copy( PatFName, 10, 10 );
{}
  ProvFName := 'dentists_' + FNameDate + '.xml';
  if not FileExists( CurImportPath + ProvFName ) then
  begin
    K_CMShowMessageDlg1( format( K_CML1Form.LLLImpFileIsMissing.Caption +
                                 #13#10'                            '   +
                                 K_CML1Form.LLLPressOKToContinue.Caption,
//      'File %s is missing. Please copy this file to the XML folder and resume import.'#13#10 +
//      '                            Press OK to continue.',
                                 [ProvFName] ), mtWarning );
    SL.Free;
    Exit;
  end;

  LocFName := 'practices_' + FNameDate + '.xml';
  if not FileExists( CurImportPath + LocFName ) then
  begin
//    K_CMShowMessageDlg1( 'File ' + LocFName + ' is not found', mtWarning );
//    SL.Free;
//    Exit;
    LocFName := '';
  end;
{}
  SL.Clear;

  SavedCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;

  ImportState := 1;
  DoImportPPL();

end; // procedure TK_FormCMImportPPL.BtStartClick

//***********************************  TK_FormCMImportPPL.DoImportPPL  ******
// Import PPL
//
procedure TK_FormCMImportPPL.DoImportPPL();
var
  SQLText : string;
  WPos, PatCount : Integer;
begin
//

  with TK_CMEDDBAccess(K_CMEDAccess) do
  begin
    if ImportState = 1 then
    begin
      try
      // Process Import Files

        LocT := 0;
        SGStateView.Cells[1,3] := '0';
        LocU := 0;
        SGStateView.Cells[3,3] := '0';
        LocN := 0;
        SGStateView.Cells[4,3] := '0';
        LocA := 0;

        ProvT := 0;
        SGStateView.Cells[1,2] := '0';
        ProvU := 0;
        SGStateView.Cells[3,2] := '0';
        ProvN := 0;
        SGStateView.Cells[4,2] := '0';
        ProvA := 0;

        PatT := 0;
        SGStateView.Cells[1,1] := '0';
        PatU := 0;
        SGStateView.Cells[3,1] := '0';
        PatN := 0;
        SGStateView.Cells[4,1] := '0';
        PatA := 0;

        if LocFName <> '' then
        begin
      //////////////////////////////
      //  Import Locations data
      //
          N_Dump1Str( 'SAI>> Import from ' + LocFName );
          if not K_VFLoadText( StrTextBuf, CurImportPath + LocFName ) then
          begin
            K_CMShowMessageDlg1( format( K_CML1Form.LLLImpReadFileError.Caption + ' ' +
                                         K_CML1Form.LLLPressOKToContinue.Caption, [LocFName] ), mtWarning );
          end
          else
          begin
            // Parse SQL to Special Import Table
            LbInfo.Caption := K_CML1Form.LLLImpProcTexts.Items[0];
            LbInfo.Refresh();

            with CurStoredProc1 do
            begin
              Connection := LANDBConnection;

              // Exec Procedure
              ProcedureName := 'dba.cms_ImportLocationsData';
              Parameters.Clear;
              with Parameters.AddParameter do
              begin
                Name := '@xml_data';
                Direction := pdInput;
                DataType := ftString;
                Value := StrTextBuf;
              end;
              ExecProc;
            end; // with CurStoredProc1 do

            // Count Total|Updated|Created|Orphaned
            with CurDSet1 do
            begin
              Connection := LANDBConnection;
              Filtered := FALSE;

              // Total Locations
              SQLText := 'select count(*) ' +
                         ' from ' + K_CMENDBImportLocationsTable;
              SQL.Text := SQLText;
              Open();
              LocT := Fields[0].AsInteger;
              SGStateView.Cells[1,3] := Fields[0].AsString;
              Close();

              // Update Locations
              SQL.Text := SQLText + ',' + K_CMENDBAllLocationsTable +
                      ' where ' + K_CMENDALBridgeID + '=' + K_CMENDILID;
              Open();
              LocU := Fields[0].AsInteger;
              SGStateView.Cells[3,3] := Fields[0].AsString;
              Close();

              // New Locations
              SQL.Text := SQLText +
                          ' where not exists (select 1 from ' + K_CMENDBAllLocationsTable +
                                         ' where ' + K_CMENDALBridgeID + '=' + K_CMENDILID + ')';
              Open();
              LocN := Fields[0].AsInteger;
              SGStateView.Cells[4,3] := Fields[0].AsString;
              Close();
              SGStateView.Cells[2,3] := IntToStr( LocU + LocN );

              // Orphans Locations
              SQL.Text := 'select ' + K_CMENDALID + ',' + K_CMENDALBridgeID + ',' + K_CMENDALName +
                          ' from ' + K_CMENDBAllLocationsTable +
                          ' where '+ K_CMENDALBridgeID + ' > 0' +
                          ' and not exists (select 1 from ' + K_CMENDBImportLocationsTable +
                                            ' where ' + K_CMENDALBridgeID + '=' + K_CMENDILID + ')';
              Open();
              LocA := 0;
              while not EOF do
              begin
                Inc(LocA);
                SL.Add( format('%d;%s;%s;%s;',
                   [LocA,Fields[0].AsString,Fields[1].AsString,Fields[2].AsString] ) );
                Next;
              end;
              Close();
              if LocA > 0 then
              begin
                SL.Insert( 0, 'Orphan practice;;;;' );
                SL.Insert( 1, '#;CMS ID;Bridge ID;Name;' );
              end;
            end; // with CurDSet1 do

           // Load Data from Import Table
            with CurSQLCommand1 do
            begin
            // Update Existing
              Connection := LANDBConnection;
              CommandText :='UPDATE ' + K_CMENDBAllLocationsTable +
                            ' SET ' + K_CMENDALName + '=' + K_CMENDILName +
                            ' FROM ' + K_CMENDBImportLocationsTable +
                            ' WHERE ' + K_CMENDALBridgeID + ' = ' + K_CMENDILID;
              Execute;

            // Create New
              CommandText :='INSERT INTO ' + K_CMENDBAllLocationsTable +
                            ' (' + K_CMENDALBridgeID + ',' + K_CMENDALName + ')' +
                            ' SELECT ' + K_CMENDILID + ',' + K_CMENDILName +
                            ' FROM ' + K_CMENDBImportLocationsTable +
                            ' WHERE NOT EXISTS (SELECT 1 FROM ' + K_CMENDBAllLocationsTable +
                                               ' WHERE ' + K_CMENDALBridgeID + ' = ' + K_CMENDILID + ')';
              Execute;
            end; // with CurSQLCommand1 do
          end; // Import Locations
      //
      //  Import Locations data
      //////////////////////////////
        end; // if LocFName <> '' then

        SGStateView.Refresh();


      //////////////////////////////
      //  Import Providers data
      //
        N_Dump1Str( 'SAI>> Import from ' + ProvFName );
        if not K_VFLoadText( StrTextBuf, CurImportPath + ProvFName ) then
        begin
          K_CMShowMessageDlg1( format( K_CML1Form.LLLImpReadFileError1.Caption +
                                       #13#10'                 ' +
                                       K_CML1Form.LLLPressOKToContinue.Caption,
                               [ProvFName] ), mtWarning );
          ImportState := 0;
        end
        else
        begin
          // Parse SQL to Special Import Table
          LbInfo.Caption := K_CML1Form.LLLImpProcTexts.Items[1];
          LbInfo.Refresh();

          with CurStoredProc1 do
          begin
            Connection := LANDBConnection;

            // Exec Procedure
            ProcedureName := 'dba.cms_ImportProvidersData';
            Parameters.Clear;
            with Parameters.AddParameter do
            begin
              Name := '@xml_data';
              Direction := pdInput;
              DataType := ftString;
              Value := StrTextBuf;
            end;
            ExecProc;
          end; // with CurStoredProc1 do

          // Count Total|Updated|Created|Orphaned
          with CurDSet1 do
          begin
            Connection := LANDBConnection;
            Filtered := FALSE;

            // Total Providers
            SQLText := 'select count(*) ' +
                       ' from ' + K_CMENDBImportProvidersTable;
            SQL.Text := SQLText;
            Open();
            ProvT := Fields[0].AsInteger;
            SGStateView.Cells[1,2] := Fields[0].AsString;
            Close();

            // Update Providers
            SQL.Text := SQLText + ',' + K_CMENDBAllProvidersTable +
                    ' where ' + K_CMENDAUBridgeID + '=' + K_CMENDIUID;
            Open();
            ProvU := Fields[0].AsInteger;
            SGStateView.Cells[3,2] := Fields[0].AsString;
            Close();

            // New Providers
            SQL.Text := SQLText +
                    ' where not exists (select 1 from ' + K_CMENDBAllProvidersTable +
                                       ' where ' + K_CMENDAUBridgeID + '=' + K_CMENDIUID + ')';
            Open();
            ProvN := Fields[0].AsInteger;
            SGStateView.Cells[4,2] := Fields[0].AsString;
            Close();
            SGStateView.Cells[2,2] := IntToStr(ProvU + ProvN);

            // Orphans Providers
            SQL.Text := 'select ' + K_CMENDAUID + ',' + K_CMENDAUBridgeID + ',' +
                                    K_CMENDAUSurname + ',' + K_CMENDAUFirstname +
                        ' from ' + K_CMENDBAllProvidersTable +
                        ' where '+ K_CMENDAUBridgeID + ' > 0' +
                        ' and not exists (select 1 from ' + K_CMENDBImportProvidersTable +
                                          ' where ' + K_CMENDAUBridgeID + '=' + K_CMENDIUID + ')';
            Open();
            ProvA := 0;
            while not EOF do
            begin
              SL.Insert( ProvA, format('%d;%s;%s;%s;%s',
                 [ProvA+1,Fields[0].AsString,Fields[1].AsString,
                  Fields[2].AsString,Fields[3].AsString] ) );
              Inc(ProvA);
              Next;
            end;
            Close();
            if ProvA > 0 then
            begin
              SL.Insert( 0, 'Orphan Dentists;;;;' );
              SL.Insert( 1, '#;CMS ID;Bridge ID;Surname;Name' );
            end;
          end; // with CurDSet1 do

         // Load Data from Import Table
          with CurSQLCommand1 do
          begin
          // Update Existing
            Connection := LANDBConnection;
            CommandText :='UPDATE ' + K_CMENDBAllProvidersTable +
                          ' SET ' + K_CMENDAUSurname     + '=' + K_CMENDIUSurname + ',' +
                                    K_CMENDAUFirstname   + '=' + K_CMENDIUFirstname + ',' +
                                    K_CMENDAUMiddle      + '=' + K_CMENDIUMiddle + ',' +
                                    K_CMENDAUTitle       + '=' + K_CMENDIUTitle + ',' +
                                    K_CMENDAUAuthorities + '=' + K_CMENDIUAuthorities +
                          ' FROM ' + K_CMENDBImportProvidersTable +
                          ' WHERE ' + K_CMENDAUBridgeID + ' = ' + K_CMENDIUID;
            Execute;

          // Create New
            CommandText :='INSERT INTO ' + K_CMENDBAllProvidersTable +
                          ' (' + K_CMENDAUBridgeID  + ',' + K_CMENDAUSurname + ',' +
                                 K_CMENDAUFirstname + ',' + K_CMENDAUMiddle + ',' +
                                 K_CMENDAUTitle     + ',' + K_CMENDAUAuthorities + ')' +
                          ' SELECT ' + K_CMENDIUID        + ',' + K_CMENDIUSurname + ',' +
                                       K_CMENDIUFirstname + ',' + K_CMENDIUMiddle + ',' +
                                       K_CMENDIUTitle     + ',' + K_CMENDIUAuthorities +
                          ' FROM ' + K_CMENDBImportProvidersTable +
                          ' WHERE NOT EXISTS (SELECT 1 FROM ' + K_CMENDBAllProvidersTable +
                                             ' WHERE ' + K_CMENDAUBridgeID + ' = ' + K_CMENDIUID + ')';
            Execute;
          end; // with CurSQLCommand1 do
        //
        //  Import Providers data
        //////////////////////////////
        end;
        SGStateView.Refresh();

      //////////////////////////////
      //  Import Patients data
      //
        N_Dump1Str( 'SAI>> Import from ' + PatFName );
        if not K_VFLoadText( StrTextBuf, CurImportPath + PatFName ) then
        begin
          K_CMShowMessageDlg1( format( K_CML1Form.LLLImpReadFileError.Caption + ' ' +
                                       K_CML1Form.LLLPressOKToContinue.Caption,
                                       [PatFName] ), mtWarning );
          ImportState := 0;
        end
        else
        begin
          // Parse SQL to Special Import Table
          with CurStoredProc1 do
          begin
            Connection := LANDBConnection;

            ProcedureName := 'dba.cms_ImportPatientsData';
            with Parameters.AddParameter do
            begin
              Name := '@xml_data';
              Direction := pdInput;
              DataType := ftString;
            end;
            with Parameters.AddParameter do
            begin
              Name := '@ind';
              Direction := pdInput;
              DataType := ftInteger;
              Value := 0; // for 1-st portion
            end;

            // Init Patients Loop
            // Search start position
            SLeng := Length(StrTextBuf);
            SPos := 1;
            SPos := N_PosEx( '>', StrTextBuf, SPos, SLeng );
            if StrTextBuf[SPos - 1] = '?' then
              SPos := N_PosEx( '>', StrTextBuf, SPos + 1, SLeng );
            SPos := N_PosEx( '<', StrTextBuf, SPos, SLeng );

            //////////////////////
            // All Patients Loop
            //
            AllPatCount := 0;
            FPos := SPos;
            ImportState := 2;
          end; // with CurStoredProc1 do
        end;
      except
        on E: Exception do
        begin
          ImportState := 0;
          Screen.Cursor := SavedCursor;
          ExtDataErrorString := 'TK_FormCMImportPPL.DoImportPPL 1 ' + E.Message;
          CurDSet1.Close;
          SL.Free;
          ExtDataErrorCode := K_eeDBUpdate;
          EDAShowErrMessage(TRUE);
        end;
      end;
    end; // if ImportState = 1 then

    if ImportState = 2 then
    begin
      try
        with CurStoredProc1 do
        begin
          while TRUE do
          begin
            WPos := 0;
            PatCount := 0;
//            while PatCount < 1 do
            while PatCount < 1000 do
            begin // Next 100 patients loop
              WPos := N_PosEx( '/>', StrTextBuf, FPos, SLeng );
              if WPos > 0 then
              begin
                FPos := WPos + 2;
                Inc(PatCount);
              end
              else
                break;
            end; // Next 100 patients loop

            AllPatCount := AllPatCount + PatCount;
            LbInfo.Caption := format( K_CML1Form.LLLImpProcTexts.Items[2], [AllPatCount, 100.0*FPos/SLeng] );
            LbInfo.Refresh();
            if PatCount = 0 then break; // Empty Patients Portion
            // Exec Procedure
            Parameters.Items[0].Value := '<patients>' +
                                         Copy( StrTextBuf, SPos, FPos - SPos ) +
                                         '</patients>';
            ExecProc;

            Parameters.Items[1].Value := 1; // for next portions

            SPos := FPos;
            if WPos = 0 then break; // Last Patients Portion
            // Process Events
            Timer.Enabled := TRUE;
            Exit;
          end; // while TRUE do
          //
          // All Patients Loop
          //////////////////////
        end; // with CurStoredProc1 do

        // Count Total|Updated|Created|Orphaned
        with CurDSet1 do
        begin
          Connection := LANDBConnection;
          Filtered := FALSE;

          // Total Patients
          SQLText := 'select count(*) ' +
                     ' from ' + K_CMENDBImportPatientsTable;
          SQL.Text := SQLText;
          Open();
          PatT := Fields[0].AsInteger;
          SGStateView.Cells[1,1] := Fields[0].AsString;
          Close();

          // Update Patients
          SQL.Text := SQLText + ',' + K_CMENDBAllPatientsTable +
                  ' where ' + K_CMENDAPBridgeID + '=' + K_CMENDIPID;
          Open();
          PatU := Fields[0].AsInteger;
          SGStateView.Cells[3,1] := Fields[0].AsString;
          Close();

          // New Patients
          SQL.Text := SQLText +
                  ' where not exists (select 1 from ' + K_CMENDBAllPatientsTable +
                                     ' where ' + K_CMENDAPBridgeID + '=' + K_CMENDIPID + ')';
          Open();
          PatN := Fields[0].AsInteger;
          SGStateView.Cells[4,1] := Fields[0].AsString;
          Close();
          SGStateView.Cells[2,1] := IntToStr(PatU + PatN);

          // Orphans Patients
          SQL.Text := 'select ' + K_CMENDAPID + ',' + K_CMENDAPBridgeID + ',' +
                                  K_CMENDAPSurname + ',' + K_CMENDAPFirstname +
                      ' from ' + K_CMENDBAllPatientsTable +
                      ' where '+ K_CMENDAPBridgeID + ' > 0' +
                      ' and not exists (select 1 from ' + K_CMENDBImportPatientsTable +
                                        ' where ' + K_CMENDAPBridgeID + '=' + K_CMENDIPID + ')';
          Open();
          PatA := 0;
          while not EOF do
          begin
            SL.Insert( PatA, format('%d;%s;%s;%s;%s',
               [PatA+1,Fields[0].AsString,Fields[1].AsString,
                Fields[2].AsString,Fields[3].AsString] ) );
            Inc(PatA);
            Next;
          end;
          Close();
          if PatA > 0 then
          begin
            SL.Insert( 0, 'Orphan Patients;;;;' );
            SL.Insert( 1, '#;CMS ID;Bridge ID;Surname;Name' );
          end;

        end; // with CurDSet1 do

       // Load Data from Import Table
        with CurSQLCommand1 do
        begin
          LbInfo.Caption := K_CML1Form.LLLImpProcTexts.Items[3];
          LbInfo.Refresh();

        // Update Existing
          Connection := LANDBConnection;
          if K_CMEDDBVersion >= 22 then
            CommandText :='UPDATE ' + K_CMENDBAllPatientsTable +
                          ' SET ' + K_CMENDAPSurname     + '=' + K_CMENDIPSurname + ',' +
                                    K_CMENDAPFirstname   + '=' + K_CMENDIPFirstname + ',' +
                                    K_CMENDAPMiddle      + '=' + K_CMENDIPMiddle + ',' +
                                    K_CMENDAPTitle       + '=' + K_CMENDIPTitle + ',' +
                                    K_CMENDAPGender      + '=' + K_CMENDIPGender + ',' +
                                    K_CMENDAPCardNum     + '=' + K_CMENDIPCardNum + ',' +
                                    K_CMENDAPDOB         + '=' + K_CMENDIPDOB + ',' +
                                    K_CMENDAPProvID      + '=' + K_CMENDIPProvID + ',' +
                                    K_CMENDAPAddr1       + '=' + K_CMENDIPAddr1 + ',' +
                                    K_CMENDAPAddr2       + '=' + K_CMENDIPAddr2 + ',' +
                                    K_CMENDAPSuburb      + '=' + K_CMENDIPSuburb + ',' +
                                    K_CMENDAPPostCode    + '=' + K_CMENDIPPostCode + ',' +
                                    K_CMENDAPState       + '=' + K_CMENDIPState + ',' +
                                    K_CMENDAPPhone1      + '=' + K_CMENDIPPhone1 + ',' +
                                    K_CMENDAPPhone2      + '=' + K_CMENDIPPhone2 +
                          ' FROM ' + K_CMENDBImportPatientsTable +
                          ' WHERE ' + K_CMENDAPBridgeID + ' = ' + K_CMENDIPID
          else
            CommandText :='UPDATE ' + K_CMENDBAllPatientsTable +
                          ' SET ' + K_CMENDAPSurname     + '=' + K_CMENDIPSurname + ',' +
                                    K_CMENDAPFirstname   + '=' + K_CMENDIPFirstname + ',' +
                                    K_CMENDAPMiddle      + '=' + K_CMENDIPMiddle + ',' +
                                    K_CMENDAPTitle       + '=' + K_CMENDIPTitle + ',' +
                                    K_CMENDAPGender      + '=' + K_CMENDIPGender + ',' +
                                    K_CMENDAPCardNum     + '=' + K_CMENDIPCardNum + ',' +
                                    K_CMENDAPDOB         + '=' + K_CMENDIPDOB + ',' +
                                    K_CMENDAPProvID      + '=' + K_CMENDAUID + ',' +
                                    K_CMENDAPAddr1       + '=' + K_CMENDIPAddr1 + ',' +
                                    K_CMENDAPAddr2       + '=' + K_CMENDIPAddr2 + ',' +
                                    K_CMENDAPSuburb      + '=' + K_CMENDIPSuburb + ',' +
                                    K_CMENDAPPostCode    + '=' + K_CMENDIPPostCode + ',' +
                                    K_CMENDAPState       + '=' + K_CMENDIPState + ',' +
                                    K_CMENDAPPhone1      + '=' + K_CMENDIPPhone1 + ',' +
                                    K_CMENDAPPhone2      + '=' + K_CMENDIPPhone2 +
                          ' FROM '  + K_CMENDBImportPatientsTable + ',' + K_CMENDBAllProvidersTable +
                          ' WHERE ' + K_CMENDAPBridgeID + ' = ' + K_CMENDIPID +
                          '   AND ' + K_CMENDIPProvID + ' = ' + K_CMENDAUBridgeID;
          Execute;

          LbInfo.Caption := K_CML1Form.LLLImpProcTexts.Items[4];
          LbInfo.Refresh();
        // Create New
          if K_CMEDDBVersion >= 22 then
            CommandText :='INSERT INTO ' + K_CMENDBAllPatientsTable +
                        ' (' + K_CMENDAPBridgeID  + ',' + K_CMENDAPSurname + ',' +
                               K_CMENDAPFirstname + ',' + K_CMENDAPMiddle + ',' +
                               K_CMENDAPTitle     + ',' + K_CMENDAPGender + ',' +
                               K_CMENDAPCardNum   + ',' + K_CMENDAPDOB + ',' +
                               K_CMENDAPProvID    + ',' + K_CMENDAPAddr1 + ',' +
                               K_CMENDAPAddr2     + ',' + K_CMENDAPSuburb + ',' +
                               K_CMENDAPPostCode  + ',' + K_CMENDAPState + ',' +
                               K_CMENDAPPhone1    + ',' + K_CMENDAPPhone2 + ')' +
                        ' SELECT ' + K_CMENDIPID        + ',' + K_CMENDIPSurname + ',' +
                                     K_CMENDIPFirstname + ',' + K_CMENDIPMiddle + ',' +
                                     K_CMENDIPTitle     + ',' + K_CMENDIPGender + ',' +
                                     K_CMENDIPCardNum   + ',' + K_CMENDIPDOB + ',' +
                                     K_CMENDIPProvID    + ',' + K_CMENDIPAddr1 + ',' +
                                     K_CMENDIPAddr2     + ',' + K_CMENDIPSuburb + ',' +
                                     K_CMENDIPPostCode  + ',' + K_CMENDIPState + ',' +
                                     K_CMENDIPPhone1    + ',' + K_CMENDIPPhone2 +
                        ' FROM ' + K_CMENDBImportPatientsTable +
                        ' WHERE NOT EXISTS (SELECT 1 FROM ' + K_CMENDBAllPatientsTable +
                                           ' WHERE ' + K_CMENDAPBridgeID + ' = ' + K_CMENDIPID + ')'
          else
            CommandText :='INSERT INTO ' + K_CMENDBAllPatientsTable +
                        ' (' + K_CMENDAPBridgeID  + ',' + K_CMENDAPSurname + ',' +
                               K_CMENDAPFirstname + ',' + K_CMENDAPMiddle + ',' +
                               K_CMENDAPTitle     + ',' + K_CMENDAPGender + ',' +
                               K_CMENDAPCardNum   + ',' + K_CMENDAPDOB + ',' +
                               K_CMENDAPProvID    + ',' + K_CMENDAPAddr1 + ',' +
                               K_CMENDAPAddr2     + ',' + K_CMENDAPSuburb + ',' +
                               K_CMENDAPPostCode  + ',' + K_CMENDAPState + ',' +
                               K_CMENDAPPhone1    + ',' + K_CMENDAPPhone2 + ')' +
                        ' SELECT ' + K_CMENDIPID        + ',' + K_CMENDIPSurname + ',' +
                                     K_CMENDIPFirstname + ',' + K_CMENDIPMiddle + ',' +
                                     K_CMENDIPTitle     + ',' + K_CMENDIPGender + ',' +
                                     K_CMENDIPCardNum   + ',' + K_CMENDIPDOB + ',' +
                                     K_CMENDAUID        + ',' + K_CMENDIPAddr1 + ',' +
                                     K_CMENDIPAddr2     + ',' + K_CMENDIPSuburb + ',' +
                                     K_CMENDIPPostCode  + ',' + K_CMENDIPState + ',' +
                                     K_CMENDIPPhone1    + ',' + K_CMENDIPPhone2 +
                        ' FROM ' + K_CMENDBImportPatientsTable + ',' + K_CMENDBAllProvidersTable +
                        ' WHERE NOT EXISTS (SELECT 1 FROM ' + K_CMENDBAllPatientsTable +
                                           ' WHERE ' + K_CMENDAPBridgeID + ' = ' + K_CMENDIPID + ')' +
                        '   AND ' + K_CMENDIPProvID + ' = ' + K_CMENDAUBridgeID;
          Execute;
        end; // with CurSQLCommand1 do
      //
      //  Import Patients data
      //////////////////////////////
      except
        on E: Exception do
        begin
          ImportState := 0;
          Screen.Cursor := SavedCursor;
          ExtDataErrorString := 'TK_FormCMImportPPL.DoImportPPL 2 ' + E.Message;
          CurDSet1.Close;
          SL.Free;
          ExtDataErrorCode := K_eeDBUpdate;
          EDAShowErrMessage(TRUE);
        end;
      end;
    end; // if ImportState = 2 then
    ImportState := 0;
    LbInfo.Caption := '';

    // Create Report

    TmpStrings.Clear;
    TmpStrings.Add(';Imported;Updated;Created;Orphaned');

    TmpStrings.Add( format( 'Patients;%s;%s;%s;%d',
      [SGStateView.Cells[2,1], SGStateView.Cells[3,1], SGStateView.Cells[4,1], PatA] ) );

    TmpStrings.Add( format( 'Dentists;%s;%s;%s;%d',
      [SGStateView.Cells[2,2], SGStateView.Cells[3,2], SGStateView.Cells[4,2], ProvA] ) );

    TmpStrings.Add( format( 'Practices;%s;%s;%s;%d',
      [SGStateView.Cells[2,3], SGStateView.Cells[3,3], SGStateView.Cells[4,3], LocA] ) );

    TmpStrings.SaveToFile( CurImportPath + 'Import_' + FNameDate + '.csv' );

    N_Dump1Str( 'SAI>> import_' + FNameDate );
    N_Dump1Strings( TmpStrings, 0 );

    if SL.Count > 0 then
    begin
      SL.SaveToFile( CurImportPath + 'orphan_' + FNameDate + '.csv' );
      N_Dump1Str( 'SAI>> orphan_' + FNameDate );
      N_Dump1Strings( SL, 0 );
    end;

    K_CMShowMessageDlg1( format(K_CML1Form.LLLImpFin.Caption,
        [#13#10 + PatFName + #13#10 + ProvFName +  #13#10 + LocFName]), mtInformation );

    N_Dump1Str( 'SAI>> Import Fin' );
    SL.Free;
    Screen.Cursor := SavedCursor;

  end; // with TK_CMEDDBAccess(K_CMEDAccess) do

end; // procedure TK_FormCMImportPPL.DoImportPPL

//***********************************  TK_FormCMImportPPL.TestLinkFile  ******
// Test File while search Link files
//
function TK_FormCMImportPPL.TestLinkFile( const APathName, AFileName: string; AScanLevel : Integer ): TK_ScanTreeResult;
begin
  Result := K_tucOK;
  if AFileName = '' then Result := K_tucSkipSubTree;
  SL.Add( AFileName );
end; // function TK_FormCMImportPPL.TestLinkFile

procedure TK_FormCMImportPPL.TimerTimer(Sender: TObject);
begin
  Timer.Enabled := FALSE;
  if ImportState = 2 then DoImportPPL();
end;

procedure TK_FormCMImportPPL.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := ImportState = 0;

end;

end.
