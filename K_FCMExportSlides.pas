unit K_FCMExportSlides;

interface

uses
  {Windows, }Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls,
  N_Types, N_BaseF,
  K_FPathNameFr, K_CM0;

type
  TK_FormCMExportSlides = class(TN_BaseForm)
    GBAll: TGroupBox;
    PathNameFrame: TK_FPathNameFrame;
    GBFtypes: TGroupBox;
    RBJPEG: TRadioButton;
    RBTIFF: TRadioButton;
    RBBMP: TRadioButton;
    RBPNG: TRadioButton;
    RBDICOM: TRadioButton;
    RBDICOMDIR: TRadioButton;
    GBExportInfo: TGroupBox;
    PBProgress: TProgressBar;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label5: TLabel;

    LbFNum: TLabel;
    LbSpace: TLabel;
    LbSpaceFree: TLabel;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    ChBAnnot: TCheckBox;
    BtCancel: TButton;
    BtOK: TButton;
    Label4: TLabel;
    LbCurFNum: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure RBJPEGClick(Sender: TObject);
    procedure BtOKClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
    CurExportPath : string;
    CurPatientSegm : string;

    NeededSpace, FreeSpaceAvailable{, TotalSpace}: int64;
    FType : Integer;
    ML : TStrings;

    procedure OnPathChange();
  public
    { Public declarations }
    PSlide: TN_PUDCMSlide;
    SlidesCount: Integer;
    ExportCount: Integer;
    VExportCount: Integer;
    Export3DCount: Integer;
    ExportFType: Integer; // 0 - any type, can be selected by user
                          // 1 - only DICOM format should be used
                          // 2 - only DICOMDIR format should be used
                          // 3 - export to D4W patient documents
    Export3DMode : Boolean;
    ExportVideoMode : Boolean;
    procedure RebuildNeededSpace( APSlide: TN_PUDCMSlide;
                                  ASlidesCount: Integer );
    procedure CurStateToMemIni (); override;
    procedure MemIniToCurState (); override;
  end;

var
  K_FormCMExportSlides: TK_FormCMExportSlides;

const
  JPEGType  = 0;
  TIFFType  = 1;
  BMPType   = 2;
  PNGType   = 3;
  DICOMType = 4;
  DICOMDIRType = 5;

function K_CMExportSlidesDlg( APSlide : TN_PUDCMSlide = nil;
                              ASlidesCount : Integer = 0;
                              AExpFType : Integer = 0 ) : Integer;

implementation

{$R *.dfm}
uses ShlObj,
     N_Lib0, N_Lib1, N_Gra2, N_CM1, N_CMMain5F, N_ImLib,
     K_RImage, K_CLib0, K_CML1F, K_CM1, K_CMDCMDLib, K_CMDCM;

//***************************************************** K_CMExportSlidesDlg ***
// Files Export Dialog
//
//   Parameters
// APSlide       - pointer to slides
// ASlidesCount  - number of slides
// AExpFType     - 0 - any type, can be selected by user
//                 1 - only DICOM format should be used
//                 2 - only DICOMDIR format should be used
//                 3 - export to D4W documents manager
// ACurD4WDocPath - path to D4W patient documents
// Result - Returns number of exported slides
//
function K_CMExportSlidesDlg( APSlide : TN_PUDCMSlide = nil;
                              ASlidesCount : Integer = 0;
                              AExpFType : Integer = 0 ) : Integer;
//var
//  i : Integer;
begin

  with TK_FormCMExportSlides.Create(Application) do
  begin
//    BaseFormInit(nil);
    BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfAppWAR,rspfShiftAll] );
    LbFNum.Caption := IntToStr(ASlidesCount);
    LbCurFNum.Caption := '0';
    PSlide := APSlide;
    SlidesCount := ASlidesCount;
    RebuildNeededSpace( APSlide, ASlidesCount );
    ExportFType := AExpFType;
    CurExportPath := K_CMD4WPatDocPath;
    ML := TStringList.Create;
    ShowModal();
    ML.Free;
    Result := ExportCount + VExportCount;
  end;
end; // K_CMExportSlidesDlg


//*********************************************** TK_FormCMExportSlides.OnPathChange ***
// Rebuild needed files space
//
//   Parameters
// APSlide       - pointer to slides
// ASlidesCount  - number of slides
//
procedure TK_FormCMExportSlides.RebuildNeededSpace( APSlide: TN_PUDCMSlide;
                                              ASlidesCount: Integer );
var
  i : Integer;
  RK : Double;
  CSize : Int64;
begin
  case FType of
  JPEGType : RK := 3.2;
  TIFFType : RK := 1.5;
  BMPType  : RK := 1;
  PNGType  : RK := 1.8;
  DICOMDIRType,DICOMType: RK := 0.9;
  else
    RK := 1;
  end;

  NeededSpace := 0;
  Export3DMode := FALSE;
  ExportVideoMode := FALSE;
  for i := 1 to ASlidesCount do
  begin
    with APSlide^.P.CMSDB do
    begin
      CSize := BytesSize;
      if not (cmsfIsMediaObj in SFlags) and
         not (cmsfIsImg3DObj in SFlags) then
        CSize := Round( CSize / RK )
      else
      if cmsfIsMediaObj in SFlags then
        ExportVideoMode := TRUE
      else
      if cmsfIsImg3DObj in SFlags then
        Export3DMode := TRUE;
    end;
    NeededSpace := NeededSpace + CSize;
    Inc(APSlide);
  end;
  LbSpace.Caption := N_DataSizeToString(NeededSpace);
end; // TK_FormCMExportSlides.RebuildNeededSpace

//*********************************************** TK_FormCMExportSlides.OnPathChange ***
//
procedure TK_FormCMExportSlides.OnPathChange;
//var
//  Path : string;
begin
  CurExportPath := IncludeTrailingPathDelimiter(PathNameFrame.TopName);
  K_CMEDAccess.EDAGetDirFreeSpace( CurExportPath, TRUE, FreeSpaceAvailable );
  LbSpaceFree.Caption := N_DataSizeToString( FreeSpaceAvailable );
{
  Path := CurExportPath;
  while not DirectoryExists( Path ) do Path := ExtractFilePath(ExcludeTrailingPathDelimiter(Path));
  if GetDiskFreeSpaceEx( @Path[1], FreeSpaceAvailable, TotalSpace, nil ) then
    LbSpaceFree.Caption := N_DataSizeToString(FreeSpaceAvailable);
}
end; // TK_FormCMExportSlides.OnPathChange

//*********************************************** TK_FormCMExportSlides.FormCreate ***
//
procedure TK_FormCMExportSlides.FormCreate(Sender: TObject);
begin
  inherited;
  if K_CMVUIMode then
  begin // CMSuiteWEB
    PathNameFrame.Visible := false;
  end
  else
  begin // CMSuite
    PathNameFrame.SelectCaption := 'Change Export folder';
    PathNameFrame.OnChange := OnPathChange;
  end;
end; // TK_FormCMExportSlides.FormCreate

//********************************************** TK_FormCMExportSlides.RBJPEGClick ***
//
procedure TK_FormCMExportSlides.RBJPEGClick(Sender: TObject);
begin
  if Sender <> RBJPEG then
    RBJPEG.Checked := FALSE;
  if Sender <> RBTIFF then
    RBTIFF.Checked := FALSE;
  if Sender <> RBBMP then
    RBBMP.Checked := FALSE;
  if Sender <> RBPNG then
    RBPNG.Checked := FALSE;
  if Sender <> RBDICOM then
    RBDICOM.Checked := FALSE;
  if Sender <> RBDICOMDIR then
    RBDICOMDIR.Checked := FALSE;

  FType := TControl(Sender).Tag;
  if (FType = DICOMType) or (FType = DICOMDIRType) then
  begin
    if N_ImageLib.ILInitAll() <> 0 then
    begin
      RBDICOM.Enabled := FALSE;
      RBDICOMDIR.Enabled := FALSE;
      RBJPEG.Checked := TRUE;
    end;
  end;

  RebuildNeededSpace( PSlide, SlidesCount );
end; // TK_FormCMExportSlides.RBJPEGClick

//*********************************************** TK_FormCMExportSlides.BtOKClick ***
//
procedure TK_FormCMExportSlides.BtOKClick(Sender: TObject);
var
  i : Integer;
  ExportSpace : Int64;
  RK : Double;
  CSize : Int64;
  FPSlide0, FPSlide: TN_PUDCMSlide;
//  GPCWrapper : TK_GPDIBCodecsWrapper;
//  DICOMAccess : TK_DICOMAccess;
  SlideDIB : TN_DIBObj;
  FName, WFName, FExt0, FExt, FVideo,F3D : string;
  NotEnoughDiskSpace : Boolean;
  ExpFNames : TStringList;
  ExpFormat : TK_CMSlideHistExpFormat;
  SaveCursor : TCursor;
  DResult : Word;
  ExportDIBFlags : TK_CMBSlideExportToDIBFlags;
  HistActCode, VHistActCode, Hist3DCode : Integer;
  RIEncodingInfo : TK_RIFileEncInfo;
  OutOfMemoryCount : Integer;
  ImgErrCount : Integer;
  DCMDPatDataArr : TK_CMDCMDPatientOutArr;
  DCMCount : Integer;
  RInds : TN_IArray;
  Ind1 : Integer;
  WSlides  : TN_UDCMSArray;
  WVSlides : TN_UDCMSArray;
  WSlides3D: TN_UDCMSArray;
  WCurExportPath : WideString;
  DCMExpMode : Integer;
  DCMResCode : Integer;
  WStr : string;
  ProgressRatio : Double;
  DestExists    : Boolean;
  One3DRes : Integer;
  One3DAllCount : Integer;
  One3DRCount   : Integer;
  One3DFSize    : Int64;
  WDCMFNames, WStudiesUID, WStudiesSID, WSeriesUID, WSeriesSID, WContentUID, WContentSID : TN_SArray;
  WStudiesTS, WSeriesTS, WContentTS, WAcqTS : TN_DArray;
  MesStr : string;
  DefaultCurExportPath : string;

  function ExportSlide( Slide : TN_UDCMSlide ) : Integer;
  var
    CurHistActCode : Integer;
    ResCode : TK_RIResult;
    DelFlag : Boolean;
  begin
    Result := 0;
    with Slide, P^, CMSDB do
    begin
      // Show Progress
      CSize := Round( BytesSize / RK );
      ExportSpace := ExportSpace +  CSize;
//      PBProgress.StepBy( Round(100 * ExportSpace / NeededSpace) );

      FExt := FExt0;
      if cmsfIsMediaObj in SFlags then
      begin
      // Export Video
        N_Dump2Str( 'Export before K_CMPrepSlideMediaFile' );
        FVideo := '';
        if not K_CMPrepSlideMediaFile( Slide, FVideo, TRUE ) then Exit;
        FExt := ExtractFileExt( FVideo );
      end
      else
      if not (cmsfIsImg3DObj in SFlags) then
      begin
      // Export Image

      // Check Memory for Image Loading if needed
      //!!! check here because MapImage and CurImage are created in EDACheckSlideMedia in ExtDB mode
        N_Dump2Str( 'Export before K_CMSCheckMemForSlide1' );
        if not K_CMSCheckMemForSlide1( Slide ) then
        begin
          Inc(OutOfMemoryCount);
          Exit;
        end;
      // Check if Image File Exists and if it is not corrupted
        if K_CMEDAccess.EDACheckSlideMedia( Slide ) = K_edFails then Exit;
      end   // if not (cmsfIsImg3DObj in SFlags) then
      else
      begin // 3D object export
        F3D := TK_CMEDDBAccess(K_CMEDAccess).EDAGetSlideImg3DPath( Slide ) +
                   K_CMSlideGetImg3DFolderName( Slide.ObjName );

        FExt := '';
      end;

      // Build File Name
      FName := CurExportPath + K_PrepFileName( K_CMSlideEEFNameBuild( ML, Slide, i ) + FExt, '-' );

      if not (cmsfIsImg3DObj in SFlags) then
        DestExists := FileExists( FName )
      else
        DestExists := DirectoryExists( FName );


      // Check if File Exists
      if DestExists then
      begin

        DResult := K_CMShowMessageDlg( format( K_CML1Form.LLLExport1.Caption,
//          'File or folder "%s" exists, overwrite?',
              [ExtractFileName(FName)] ), mtWarning, [mbYes, mbNo, mbCancel], not CMS_LogsCtrlAll );
        Self.Refresh();

        if not CMS_LogsCtrlAll then
          N_Dump1Str('File or folder "'+
          ExtractFilePath(ExcludeTrailingPathDelimiter(ExtractFilePath(FName)))
            +'????\???? exists, overwrite?');

        N_CM_MainForm.CMMCurFMainForm.Refresh();

        case DResult  of
         mrYes:;
         mrNo: Exit;
         mrCancel: begin; Result := -1; Exit; end;
        end;
      end; // if FileExists( FName ) then

      // Export To File
      ExpFNames.Add( FName );
      if cmsfIsMediaObj in SFlags then
      begin // if cmsfIsMediaObj in SFlags) then
      // Export Video
        N_Dump2Str( 'Export before copy file' );
        if K_CopyFile( FVideo, FName, [K_cffOverwriteNewer] ) = 4 then
        begin
          NotEnoughDiskSpace := TRUE;
          Result := -1;
          Exit;
        end;
        WVSlides[VExportCount] := Slide;
        Inc(VExportCount);
        CurHistActCode := VHistActCode;
      // Export Video
      end   // if cmsfIsMediaObj in SFlags) then
      else
      if cmsfIsImg3DObj in SFlags then
      begin // 3D Export
        N_Dump2Str( 'Export before copy 3D files' );

        if not DirectoryExists( F3D ) then
        begin
        // Show Message
          N_CM_MainForm.CMMImg3DFolderAbsentDlg(F3D);
          Result := -1;
          Exit;
        end;

        One3DAllCount := 0;
        One3DRCount   := 0;
        One3DFSize    := 0;
        One3DRes := K_CMExport3DObj( Slide, FName, F3D, One3DAllCount, One3DRCount, One3DFSize );
        if One3DRes = 1 then
        begin
          N_Dump1Str( 'K_CMExportSlidesDlg >> not proper 3D object for export' );
          Result := -1;
          Exit;
        end
        else
        if One3DAllCount > One3DRCount then
        begin
          N_Dump1Str( format( 'K_CMExportSlidesDlg >> only %d of %d files (total size %d) were copied from %s ',
                            [One3DRCount, One3DAllCount, One3DFSize, F3D] ) );
          NotEnoughDiskSpace := TRUE;
          Result := -1;
          Exit;
        end
        else
          N_Dump1Str( format( 'K_CMExportSlidesDlg >> %d files (total size %d) were copied to %s ',
                            [One3DRCount, One3DFSize, ExtractFileName(Copy( FName, 1, Length(FName) - 1))] ) );

        WSlides3D[Export3DCount] := Slide;
        Inc(Export3DCount);
        CurHistActCode := Hist3DCode;
      end
      else
      begin // if not (cmsfIsMediaObj in SFlags) and  not (cmsfIsImg3DObj in SFlags) then
       // Export Image
        N_Dump2Str( 'Export before ExportToDIB' );
        SlideDIB := ExportToDIB( ExportDIBFlags );
        N_Dump2Str( 'Export after ExportToDIB Res='+N_B2S(SlideDIB <> nil) );
        if SlideDIB = nil then
        begin
          Inc(OutOfMemoryCount);
          Exit;
        end   // if SlideDIB = nil then
        else
        begin // if SlideDIB <> nil then
          try
            // Export to Raster File
            ResCode := K_RIObj.RISaveDIBToFile( SlideDIB, FName, @RIEncodingInfo );
            if ResCode <> rirOK then
            begin
              Inc(ImgErrCount);
              DelFlag := FileExists( FName );
              if DelFlag then
                K_DeleteFile( FName );

              if not CMS_LogsCtrlAll then
              begin
                WFName := FName;
                FName := ExtractFilePath(ExcludeTrailingPathDelimiter(ExtractFilePath(FName))) + '????\????';
              end;

              N_Dump1Str( format( 'Export Error >> SlideID=%s to "%s" ErrCode=%d Del=%s',
                  [ObjName,FName,K_RIObj.RIGetLastNativeErrorCode(),N_B2S(DelFlag)] ) );
//              N_Dump1Str( 'Export Error >> SlideID=' + ObjName + ' to "' + FName + '" ErrCode=' +
//                          IntToStr(K_RIObj.RIGetLastNativeErrorCode()) );

              if not CMS_LogsCtrlAll then
                FName := WFName;

              Exit;
            end
            else
            begin
              WSlides[ExportCount] := Slide;
              Inc(ExportCount);
              CurHistActCode := HistActCode;
            end;
          except
            NotEnoughDiskSpace := TRUE;
            Result := -1;
            Exit;
          end; // try
          FreeAndNil( SlideDIB );
          // Export Image
        end; // if SlideDIB <> nil then
      end;   // if not (cmsfIsMediaObj in SFlags) and  not (cmsfIsImg3DObj in SFlags) then

      if not CMS_LogsCtrlAll then
      begin
        WFName := FName;
        FName := ExtractFilePath(ExcludeTrailingPathDelimiter(ExtractFilePath(FName))) + '????\????';
      end;

      N_Dump1Str( 'Export Slide ID=' + ObjName + ' to "' + FName + '"' );

      if not CMS_LogsCtrlAll then
        FName := WFName;

      if not (K_CMEDAccess is TK_CMEDDBAccess) then
        // Save Statistics to Slide buffer if work without DB
        with  K_CMEDAccess do
          EDAAddHistActionToSlideBuffer( Slide, CurHistActCode );
      Result := 1;
    end; // with Slide, P^, CMSDB do
  end; // function ExportSlide

  function ExportDCMSlide( Slide : TN_UDCMSlide ) : Integer;
  var
    WFName : WideString;
    PWFName : PWideChar;
    DelFlag : Boolean;
  begin
    Result := 0;
    with Slide, P^, CMSDB do
    begin
      // Show Progress
      CSize := Round( BytesSize / RK );
      ExportSpace := ExportSpace +  CSize;


    // Check Memory for Image Loading if needed
    //!!! check here because MapImage and CurImage are created in EDACheckSlideMedia in ExtDB mode
      N_Dump2Str( format( 'Export before MemCheck ID=%s Type=%d', [Slide.ObjName,Ord(FType)] ) );
      if not K_CMSCheckMemForSlide1( Slide ) then
      begin
        Inc(OutOfMemoryCount);
        Exit;
      end;

    // Check if Image File Exists and if it is not corrupted
      if K_CMEDAccess.EDACheckSlideMedia( Slide ) = K_edFails then
      begin
        Exit;
      end;

      // Build File Name
      if FType = DICOMDIRType then
      begin
        FName := IntToStr(ExportCount + 1)+'.dcm';
//!!!        WFName := N_StringToWide( FName );
//!!!        PWFName := @WFName[1];
        PWFName := nil; // ImageLibrary Error
      end
      else
      begin
        FName := K_PrepFileName( K_CMSlideEEFNameBuild( ML, Slide, i ) + FExt, '-' ); // ImageLibrary Error
///!!!        FName := Slide.ObjName + '.dcm';
        WFName := N_StringToWide( FName );
        PWFName := @WFName[1];
        ExpFNames.Add( CurExportPath + FName );
      end;

      // Check if File Exists
{
      if FileExists( FName ) then
      begin
        DResult := K_CMShowMessageDlg( format( K_CML1Form.LLLExport1.Caption,
//          'File "%s" exists, overwrite?',
              [ExtractFileName(FName)] ), mtWarning, [mbYes, mbNo, mbCancel] );
        Self.Refresh();
        N_CM_MainForm.CMMCurFMainForm.Refresh();

        case DResult  of
         mrYes:;
         mrNo: Exit;
         mrCancel: begin; Result := -1; Exit; end;
        end;
      end; // if FileExists( FName ) then
}
      // Export To File
//      ExpFNames.Add( FName );
     // Export Image
      N_Dump2Str( 'Export before ExportToDIB' );
      SlideDIB := ExportToDIB( ExportDIBFlags );
      N_Dump2Str( 'Export after ExportToDIB Res='+N_B2S(SlideDIB <> nil) );
      if SlideDIB = nil then
      begin
        Inc(OutOfMemoryCount);
        Exit;
      end
      else
      begin
        try
          WSlides[ExportCount] := Slide;
          // Export to Raster File
          N_Dump2Str( 'Export slide before' );

          if K_CMDICOMNewFlag then
          begin
//            DCMResCode := K_CMDCMExportOneSlide( Slide, SlideDIB, CurExportPath + FName );
{}
            K_CMS_LogsCtrlAll := CMS_LogsCtrlAll;
            DCMResCode := K_CMDCMExportDCMSlideToFile( Slide, SlideDIB, CurExportPath + FName,
                                WDCMFNames[i], WStudiesUID[i], WStudiesSID[i], WStudiesTS[i],
                                WSeriesUID[i], WSeriesSID[i], WSeriesTS[i],
                                WContentUID[i], WContentSID[i], WContentTS[i], WAcqTS[i] );
            K_CMS_LogsCtrlAll := TRUE;
{}
            N_Dump2Str( 'Export after K_CMDCMExportDCMSlideToFile' );
          end
          else
          begin
            DCMResCode := N_ImageLib.ILDCMAddImage( PWFName, 0, RInds[Ind1], RInds[Ind1+1], 0, @SlideDIB.DIBInfo, SlideDIB.PRasterBytes );
            N_Dump2Str( 'Export after ILDCMAddImage' );
          end;

          if DCMResCode <> 0 then
          begin
            Inc(ImgErrCount);
            DelFlag := FALSE;
            if FType = DICOMType then
            begin
              DelFlag := FileExists(FName);
              if DelFlag then
                K_DeleteFile( FName ) // Delete bad file for DICOM
            end
            else
              Result := -1;           // breake Loop for DICOMDIR

            if not CMS_LogsCtrlAll then
            begin
              WFName := FName;
              FName := ExtractFilePath(ExcludeTrailingPathDelimiter(ExtractFilePath(FName))) + '????\????';
            end;

            N_Dump1Str( format( 'Export DIB >> FName="%s" ResCode=%d Del=%s',
                                [FName,DCMResCode,N_B2S(DelFlag)] ) );

            if not CMS_LogsCtrlAll then
              FName := WFName;

            Exit;
          end
          else
            Ind1 := Ind1 + 2;
        except
          on E: Exception do
          begin
//          NotEnoughDiskSpace := TRUE;
            N_Dump1Str( format( 'ILDCMAddImage >> FName"%s" E=', [FName,E.Message]) );
            Result := -1;
            Exit;
          end;
        end; // try
        FreeAndNil( SlideDIB );
      end;

      if not CMS_LogsCtrlAll then
      begin
        WFName := FName;
        FName := ExtractFilePath(ExcludeTrailingPathDelimiter(ExtractFilePath(FName))) + '????\????';
      end;

      N_Dump1Str( 'Export Slide ID=' + ObjName + ' to "' + FName + '"' );

      if not CMS_LogsCtrlAll then
        FName := WFName;

      if not (K_CMEDAccess is TK_CMEDDBAccess) then
        // Save Statistics to Slide buffer
        with  K_CMEDAccess do
          EDAAddHistActionToSlideBuffer( Slide, HistActCode );
      Result := 1;
    end; // with Slide, P^, CMSDB do
  end; // function ExportDCMSlide

Label NexSlide, NexDCMSlide;
begin
//
//  DICOMAccess := nil;
  RInds := nil;
  DCMCount := 0;
  RK := 1;
  ExpFormat := K_shExpImgDCM; // precaution for 3D Export mode
  if not Export3DMode then
  begin
    K_RIObj.RIClearFileEncInfo( @RIEncodingInfo );
    case FType of
    JPEGType : begin
      RK := 3.2;
      FExt0 := '.jpg';
      ExpFormat := K_shExpImgJPG;
      RIEncodingInfo.RIFileEncType := rietJPG;
  //    RIEncodingInfo.RIEComprQuality := 100;
      ExportDIBFlags := [];
    end;
    TIFFType : begin
      RK := 1.5;
      FExt0 := '.tiff';
      ExpFormat := K_shExpImgTIF;
      RIEncodingInfo.RIFileEncType := rietTIF;
      ExportDIBFlags := [K_bsedSkipConvGrey16To8];
    end;
    BMPType  :  begin
      RK := 1;
      FExt0 := '.bmp';
      ExpFormat := K_shExpImgBMP;
      RIEncodingInfo.RIFileEncType := rietBMP;
      ExportDIBFlags := [];
    end;
    PNGType  : begin
      RK := 1.8;
      FExt0 := '.png';
      ExpFormat := K_shExpImgPNG;
      RIEncodingInfo.RIFileEncType := rietPNG;
      ExportDIBFlags := [K_bsedSkipConvGrey16To8];
    end;
    DICOMDIRType, DICOMType: begin
      RK := 0.9;
      FExt0 := '.dcm';
      ExpFormat := K_shExpImgDCM;
  //    DICOMAccess := TK_DICOMAccess.Create;
      SetLength(RInds, 3 * SlidesCount);
      DCMCount := K_CMCreateDCMDPatData( DCMDPatDataArr, PSlide, SlidesCount, @RInds[0] );
      ExportDIBFlags := [K_bsedSkipConvGrey16To8,K_bsedSkipAnnotations];
    end;
    else
      ExpFormat := K_shExpImgJPG; // for skip warning
      ExportDIBFlags := [];
    end;
  end; // if not Export3DMode then
  ExportSpace := 0;
  FPSlide := PSlide;

  CurExportPath := ExcludeTrailingPathDelimiter(PathNameFrame.TopName);
  if not DirectoryExists( CurExportPath ) then
  begin
    WStr := 'New ExportPath >> ';
{
// SIR #25738 - warning if file does not exists
//    if not K_ForceDirPath( CurExportPath ) then
    begin
      K_CMShowMessageDlg( K_CML1Form.LLLExport3.Caption,

//The CMSuite cannot export the image(s) to the destination folder. Possibly it#13#10 +
//doesn't exist anymore. Please change the export folder and repeat the operation.

       mtWarning, [mbOK] );
      Exit;
//      raise Exception.Create( 'Can''t create path for export >> ' + CurExportPath );
    end
}
// SIR #25738 from 2021-05-11
    MesStr := format( K_CML1Form.LLLExport3.Caption, [CurExportPath] );
//    The folder <folder name> doesn’t exist. Click OK to automatically create this folder or Cancel to close the Export dialogue
    if mrOK <> K_CMShowMessageDlg( MesStr, mtConfirmation, [mbOK,mbCancel] ) then
      Exit
    else
    if not K_ForceDirPath( CurExportPath ) then
    begin
      DefaultCurExportPath := K_GetWinUserDocumentsPath( 'CMS Exported objects\'+ CurPatientSegm  );
      MesStr := format( K_CML1Form.LLLExport4.Caption, [CurExportPath, DefaultCurExportPath ] );
  // Mediasuite cannot create the folder <folder name>. The default folder <default folder name> can be used to export the images.
  // Click OK to proceed or Cancel to close the Export dialogue
      if mrOK <> K_CMShowMessageDlg( MesStr, mtConfirmation, [mbOK,mbCancel] ) then
        Exit
      else
      begin
        CurExportPath := DefaultCurExportPath;
        K_ForceDirPath( CurExportPath );
      end;
    end;
  end
  else
    WStr := 'Existing ExportPath >> ';

  if not CMS_LogsCtrlAll and (Pos( ',', ExtractFileName(CurExportPath) ) > 0) then
    N_Dump1Str( WStr + ExtractFilePath(CurExportPath) + '?????' )
  else
    N_Dump1Str( WStr + CurExportPath );

  CurExportPath := IncludeTrailingPathDelimiter(CurExportPath);

  SaveCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;

  NotEnoughDiskSpace := FALSE;
  ExpFNames := TStringList.Create;
  ExportCount := 0;
  SlideDIB := nil;

  HistActCode  := K_CMEDAccess.EDABuildHistActionCode( K_shATNotChange,
                                    Ord(K_shNCAExportFile), Ord(ExpFormat) );
  VHistActCode := K_CMEDAccess.EDABuildHistActionCode( K_shATNotChange,
                                    Ord(K_shNCAExportFile), Ord(K_shExpVideo) );
  Hist3DCode   := K_CMEDAccess.EDABuildHistActionCode( K_shATNotChange,
                                    Ord(K_shNCAExportFile), Ord(K_shExpImgDCM) );
  FPSlide0 := FPSlide;
  OutOfMemoryCount := 0;
  ImgErrCount := 0;
  K_CMSCheckMemConstraints( nil ); // Free Memory before Slide action MemCheck

  if ChBAnnot.Checked then
    ExportDIBFlags := ExportDIBFlags + [K_bsedExportOriginal];

  if ((FType = DICOMDIRType) or (FType = DICOMType)) and not Export3DMode then
  begin

    if DCMCount > 0 then
    begin
      DCMExpMode := 0;
      if not K_CMDICOMNewFlag then
      begin
        WCurExportPath := N_StringToWide(CurExportPath);
        if FType = DICOMDIRType then
        begin
          DCMExpMode := 1;
          ExpFNames.Add( CurExportPath + 'DICOMDIR' );

        end;
        DCMResCode := N_ImageLib.ILDCMStartExport( @WCurExportPath[1], DCMExpMode, TK_PCMDCMDPatientIn(@DCMDPatDataArr[0]), 1  );
        N_Dump1Str( format( 'ILDCMStartExport >> ExpMode=%d ResCode=%d', [DCMExpMode,DCMResCode]) );
      end;
    end;

    if DCMResCode = 0 then
    begin
      SetLength( WSlides, DCMCount);
      NeededSpace := 0;
      for i := 0 to DCMCount - 1 do
      begin
        FPSlide := TN_PUDCMSlide(TN_BytesPtr(FPSlide0) + SizeOf(Integer)* RInds[i]);
        WSlides[i] := FPSlide^;
        with FPSlide^.P.CMSDB do
          NeededSpace := NeededSpace + Round( BytesSize / RK );
      end;
      LbSpace.Caption := N_DataSizeToString(NeededSpace);

      if K_CMDICOMNewFlag then
        K_CMEDAccess.EDAGetDCMSlideUCAttrs( @WSlides[0], DCMCount,
               WDCMFNames, WStudiesUID, WStudiesSID, WStudiesTS,
               WSeriesUID, WSeriesSID, WSeriesTS,
               WContentUID, WContentSID, WContentTS, WAcqTS );

      Ind1 := DCMCount;
      FExt := FExt0;
      for i := 0 to High(WSlides) do
      begin
        case ExportDCMSlide( WSlides[i] ) of
         0 : goto NexDCMSlide;
        -1 : break;
         1 :;
        end;

        // Step to Next Slide
        Inc(ExportCount);

NexDCMSlide:
        ProgressRatio := 1;
        if NeededSpace <> 0 then
          ProgressRatio := ExportSpace / NeededSpace;
        PBProgress.Position :=  Round(100 * ProgressRatio);
        LbCurFNum.Caption := IntToStr(ExportCount);
        LbCurFNum.Refresh;
      end; // for i := 1 to SlidesCount
    end; // if DCMResCode = 0 then

    if not K_CMDICOMNewFlag then
    begin
      DCMResCode := N_ImageLib.ILDCMFinExport();
      N_Dump1Str( format( 'ILDCMFinExport >> ResCode=%d', [DCMResCode]) );
    end;
  end // if (FType = DICOMDIRType) or (FType = DICOMType) and not Export3DMode  then
  else
  begin // if (FType <> DICOMDIRType) and (FType <> DICOMType) then
    SetLength( WSlides, SlidesCount);
    SetLength( WVSlides, SlidesCount);
    SetLength( WSlides3D, SlidesCount );
    for i := 1 to SlidesCount do
    begin

      if ExportSlide( FPSlide^ ) = -1 then break;

      ProgressRatio := 1;
      if NeededSpace <> 0 then
        ProgressRatio := ExportSpace / NeededSpace;
      PBProgress.Position :=  Round(100 * ProgressRatio);
      LbCurFNum.Caption := IntToStr(ExportCount + VExportCount);
      LbCurFNum.Refresh;
      Inc(FPSlide);
    end; // for i := 1 to SlidesCount

  end; // // if (FType <> DICOMDIRType) and (FType <> DICOMType) then


  FreeAndNil( SlideDIB ); // Needed if Loop is broken
//  GPCWrapper.Free;
//  DICOMAccess.Free;

  Screen.Cursor := SaveCursor;

  if ImgErrCount > 0 then
  begin
    K_CMShowMessageDlg( format( 'Some error were detected. %d object(s) haven''t been exported.',
//'Some error were detected. %d object(s) haven''t been exported.'
                [ImgErrCount] ), mtWarning );
  end;

  if OutOfMemoryCount > 0 then
  begin
    K_CMShowMessageDlg( format( K_CML1Form.LLLMemory5.Caption,
//'There is not enough memory to process all images. %d object(s) haven''t been exported.'+
//'        Please close some open image(s) or restart Media Suite if needed.',
                [OutOfMemoryCount] ), mtWarning );
    K_CMOutOfMemoryFlag := TRUE;
  end;

  if NotEnoughDiskSpace then
  begin
    if mrOK = K_CMShowMessageDlg( format( K_CML1Form.LLLExport2.Caption,
//      'There is not enough space in the destination folder.'#13#10 +
//      'Only %d object(s) out of %d have been exported.'#13#10 +
//      'Please select another export folder and repeat the operation.',
      [ExportCount,SlidesCount] ), mtWarning, [mbOK, mbCancel] ) then
    begin
    // Clear Exported and try to export again
      for i := 0 to ExpFNames.Count - 1 do
        K_DeleteFile( ExpFNames[i] );
      ExpFNames.Free;
      ExportCount := 0;
      PBProgress.Position := 0;
      LbCurFNum.Caption := '0';
      Exit; // Continue Export Dialog
    end;
  end;

  if K_CMEDAccess is TK_CMEDDBAccess then
  begin
  // Save Statistics directly to DB
    if ExportCount > 0 then
      K_CMEDAccess.EDASaveSlidesListHistory( @WSlides[0], ExportCount, HistActCode );
    if VExportCount > 0 then
      K_CMEDAccess.EDASaveSlidesListHistory( @WVSlides[0], VExportCount, VHistActCode );
    if Export3DCount > 0 then
      K_CMEDAccess.EDASaveSlidesListHistory( @WSlides3D[0], Export3DCount, Hist3DCode );

  end;

  if K_CMVUIMode and
     Assigned(K_CMVUIDownloadFileProc) then
  begin
    for i := 0 to ExpFNames.Count - 1 do
    begin
      K_CMVUIDownloadFileProc(ExpFNames[i]);
      //DeleteFile(ExpFNames[i]);
    end;
  end;

  ExpFNames.Free;
  PBProgress.Position := 100;
  Sleep(100);
  ModalResult := mrOK;

end; // TK_FormCMExportSlides.BtOKClick

//****************************************** TK_FormCMExportSlides.FormShow ***
//
procedure TK_FormCMExportSlides.FormShow(Sender: TObject);
begin
  //*** Get MacroList
  PBProgress.Smooth := TRUE;
//  ML := K_CMEDAccess.EDAGetPatientMacroInfo( K_CMEDAccess.CurPatID );  // Change 2020-04-25 after Add DCM Series processing
  K_CMEDAccess.EDAGetPatientMacroInfo( K_CMEDAccess.CurPatID, ML );

  RBDICOMDIR.Visible := not K_CMDICOMNewFlag;

  if ExportFType = 3 then
  begin
    GBAll.Enabled := FALSE;
    RBJPEG.Checked   := TRUE;
  end
  else
  begin
    if ExportFType = 0 then
    begin
      if not Export3DMode then
      begin
        RBJPEG.Checked     := TRUE;
    //    RBDICOM.Enabled    := (K_CMD4WAppRunByClient or K_CMStandaloneGUIMode);
        RBDICOM.Enabled    := not ExportVideoMode;
        RBDICOMDIR.Enabled := RBDICOM.Enabled;
      end
      else
      begin
        GBfTypes.Enabled := FALSE;
        RBDICOM.Checked := TRUE;
        RBJPEG.Enabled := FALSE;
        RBTIFF.Enabled := FALSE;
        RBBMP.Enabled  := FALSE;
        RBPNG.Enabled  := FALSE;
        RBDICOM.Enabled := FALSE;
        RBDICOMDIR.Enabled := FALSE;
        ChBAnnot.Visible := FALSE;
      end;
    end
    else
    begin
      if ExportFType = 1 then
      begin
        RBDICOM.Checked := TRUE;
        RBDICOMDIR.Enabled := FALSE;
      end
      else
      if ExportFType = 2 then
      begin
        RBDICOMDIR.Checked := TRUE;
        RBDICOM.Enabled := FALSE;
      end;
      RBJPEG.Enabled := FALSE;
      RBTIFF.Enabled := FALSE;
      RBBMP.Enabled  := FALSE;
      RBPNG.Enabled  := FALSE;
    end;

    CurPatientSegm := K_PrepFileName( K_StringMListReplace( K_CMENPTNExportPName, ML, K_ummRemoveMacro ) );
    if Trim(CurPatientSegm) = '' then
      CurPatientSegm := 'PatName PatSurname';

    with K_CMSServerClientInfo.CMSSessionInfo do
    if WTSClientProtocolType = WTS_PROTOCOL_TYPE_CONSOLE then
      CurExportPath := K_GetWinUserDocumentsPath( 'CMS Exported objects\'+ CurPatientSegm + '\' )
    else
      CurExportPath := K_ExpandFileName( '\\tsclient\C\Users\'+ WTSUserName +'\Documents\CMS Exported objects\' );
//    CurExportPath := K_GetWinUserDocumentsPath( 'CMS Exported objects\'+ CurPatientSegm + '\' );
  end;
{
  CurExportPath :=
     GetEnvironmentVariable( 'HOMEDRIVE' ) +
     GetEnvironmentVariable( 'HOMEPATH' ) +
     '\My documents\CMS Exported objects\' + CurPatientSegm + '\';
{}
  if K_CMVUIMode then
  begin // CMSuiteWEB
    CurExportPath := K_ExpandFileName( '(#TmpFiles#)ExpSlides\' );
    K_DeleteFolderFiles( CurExportPath );
    K_ForceDirPath( CurExportPath );
  end;

  PathNameFrame.AddNameToTop( CurExportPath );
  OnPathChange();


  K_CMSlideEEFNamePrepMacro( ML, ML );
end; // TK_FormCMExportSlides.FormShow

//************************************ TK_FormCMExportSlides.FormCloseQuery ***
//
procedure TK_FormCMExportSlides.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  inherited;

end; // TK_FormCMExportSlides.FormCloseQuery

//********************************** TK_FormCMExportSlides.CurStateToMemIni ***
//
procedure TK_FormCMExportSlides.CurStateToMemIni();
begin
  inherited;
  N_ComboBoxToMemIni( 'CMSExportPathsHistory', PathNameFrame.mbPathName );
end; // end of TK_FormCMExportSlides.CurStateToMemIni

//*********************************  TK_FormCMExportSlides.MemIniToCurState ***
//
procedure TK_FormCMExportSlides.MemIniToCurState();
begin
  inherited;
  N_MemIniToComboBox( 'CMSExportPathsHistory', PathNameFrame.mbPathName );
end; // end of TK_FormCMExportSlides.MemIniToCurState

end.
