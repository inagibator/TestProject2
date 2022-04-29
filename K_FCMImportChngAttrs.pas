unit K_FCMImportChngAttrs;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, Types,
  N_BaseF, N_Types,
  K_CM0;

type
  TK_FormCMImportChngAttrs = class(TN_BaseForm)
    PBProgress: TProgressBar;
    BtChange: TButton;
    LEdTotal: TLabeledEdit;
    LEdProcessed: TLabeledEdit;
    LEdImported: TLabeledEdit;
    LEdErrors: TLabeledEdit;
    LEdDate: TLabeledEdit;
    LEdTime: TLabeledEdit;
    BtExit: TButton;
    LEdBri: TLabeledEdit;
    LEdCo: TLabeledEdit;
    LEdGam: TLabeledEdit;
    LEdFName: TLabeledEdit;
    LEdConv: TLabeledEdit;
    ChBRebuildThumbnails: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure BtChangeClick(Sender: TObject);
  private
    { Private declarations }
    LIState : TK_CMImportState; // Last Import State
    ActMode : Integer; // Action  Mode: 0 - ready to start new Convertion
                       //               1 - Convertion is started
    SlidesIDArr: TN_IArray;
    SL : TStringList;
    SavedCursor : TCursor;
    IDInd : Integer;
    ProcNum : Integer;
  public
    { Public declarations }
  end;

var
  K_FormCMImportChngAttrs: TK_FormCMImportChngAttrs;

procedure K_CMSlideImportChangeAttrsDlg( );

implementation

{$R *.dfm}
uses IniFiles, GDIPAPI, MATH, DB,
     N_Lib0, N_Lib1, N_Gra2, N_Gra0, N_CM1, N_CMMain5F, N_Comp1, N_GCont, N_Gra1,
     N_CompBase,
     K_RImage, K_CLib0, K_UDT1, K_UDC, K_Script1, K_CML1F;
//     K_FCMImportReverseEnter;

//******************************************** K_CMSlideImportChangeAttrsDlg ***
// Files Import Dialog
//
procedure K_CMSlideImportChangeAttrsDlg(  );
//var
//  i : Integer;
begin

  if not (K_CMEDAccess is TK_CMEDDBAccess ) then
  begin
    K_CMShowMessageDlg( //sysout
            'This action could not be done in demo mode?',  mtWarning );
    Exit;
  end
  else
//  if K_CMReverseImportConfirmDlg( ) then
    with TK_FormCMImportChngAttrs.Create(Application) do begin
  //    BaseFormInit(nil);
      BaseFormInit( nil, '', [rspfMFRect,rspfCenter], [rspfMFRect,rspfCenter] );
      ShowModal();
    end;
end; // K_CMSlideImportChangeAttrsDlg

//***********************************  TK_FormCMImport.FormCloseQuery ***
//
procedure TK_FormCMImportChngAttrs.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if ActMode <> 1 then Exit;

 // Ask if stop process
  CanClose := mrYes = K_CMShowMessageDlg( K_CML1Form.LLLImportChng1.Caption,
//          'Do you really want to stop the action?',
                               mtConfirmation, [], TRUE, 'Action stop confirmation' );
  if not CanClose then Exit;
  Screen.Cursor := SavedCursor;
  SL.Free;
  with TK_CMEDDBAccess(K_CMEDAccess) do
  begin
    if CurSlidesDSet.Active then
    begin
      CurSlidesDSet.UpdateBatch();
      CurSlidesDSet.Close();
    end;
  end;
  K_CMShowMessageDlg( format( K_CML1Form.LLLImportChng2.Caption,
//   'The action is stoped. %d objects of %d are processed, %d images are changed.',
           [IDInd, LIState.CMIImpCount, ProcNum] ), mtInformation );


end; // end of TK_FormCMImport.FormCloseQuery

//*******************************************  TK_FormCMImport.BtChangeClick ***
//
procedure TK_FormCMImportChngAttrs.BtChangeClick(Sender: TObject);
const
  ChangeStep = 10;
  ImgAttrsStartLex = '<TK_CMSMRImgAttrs Name=ViewAttrs ImgInd=14 ElemCount=1';
  UndefVal = -999999;
var
  k : Integer;
  SlideSDBF : TN_CMSlideSDBF;
  i: Integer;
  Ind : Integer;
  SQLStr: string;
  PID : PInteger;
  DSize: Integer;
  PData: Pointer;
  ROP : TK_CMEDResult;
  SlideMapRootStr : string;
  BriCOGamPosStart, BriCOGamPosFin : Integer;
  ImgAttrsStr : string;
  BriVal, CoVal, GamVal : Double;
  Buf : TN_BArray;
  DFile: TK_DFile;
  RUDDIB, UDDIB : TN_UDDIB;
  WFName : string;
  PatID : Integer;
  DTCreated : TDateTime;

  ThumbAspect: Double;
  ThumbSize: TPoint;
  TmpGCont: TN_GlobCont;
  ExpParams: TN_ExpParams;
  ThumbRect: TRect;
  ThumbDIBObj: TN_DIBObj;
  ImgViewConvData: TK_CMSImgViewConvData;
  RebuildThumbnailsFlag : Boolean;


label FinConvertion, NextSlide;

  procedure SetNewVal( AttrName : string; AttrVal : Double );
  begin
    if AttrVal = UndefVal then Exit;
    Ind := SL.IndexOfName(AttrName);
    if Ind < 0 then
      SL.Add( format( '%s=%g', [AttrName, AttrVal] ) )
    else
      SL.ValueFromIndex[Ind] := FloatToStr(AttrVal);
  end;

begin
  ActMode := 0;
  with TK_CMEDDBAccess(K_CMEDAccess) do
  begin
    if EDACheckDBConnection(CurSlidesDSet.Connection) <> K_edOK then
    begin
      N_Dump1Str('Support>> DB connection problems');
      Exit;
    end;
    BriVal := StrToFloatDef( LEdBri.Text, UndefVal );
    if BriVal <> UndefVal then
      BriVal := Max( -100, Min( 100, BriVal ) );
    CoVal := StrToFloatDef( LEdCo.Text, UndefVal );
    if CoVal <> UndefVal then
      CoVal := Max( -100, Min( 100, CoVal ) );
    GamVal := StrToFloatDef( LEdGam.Text, UndefVal );
    if GamVal <> UndefVal then
      GamVal := Max( -100, Min( 100, GamVal ) );
    if (BriVal = UndefVal) and
       (CoVal = UndefVal)  and
       (GamVal = UndefVal) then
    begin
      K_CMShowMessageDlg( K_CML1Form.LLLImportChng3.Caption,
//        'New attributes are not specified. Nothing to do.',
                          mtWarning, [mbOK] );
      Exit;
    end;

    Screen.Cursor := crHourglass;
    IDInd := 0;
    ProcNum := 0;
    N_Dump1Str('Support>> Start imported slides attributes changing');
    SL := TStringList.Create;
    SL.Delimiter := ' ';

    ActMode := 1;
    RebuildThumbnailsFlag := ChBRebuildThumbnails.Checked;
    while IDInd < LIState.CMIImpCount do
    begin
      k := Min( LIState.CMIImpCount - IDInd, ChangeStep );
      try
        PID := @SlidesIDArr[IDInd];
        SQLStr := K_CMENDBSTFSlideID + ' = ' + IntToStr(PID^);
        for i := 1 to k - 1 do
        begin
          Inc(PID);
          SQLStr := SQLStr + ' or ' + K_CMENDBSTFSlideID + ' = ' + IntToStr(PID^);
        end;

        WFName := '';
        if RebuildThumbnailsFlag then
          WFName := ',' + K_CMENDBSTFPatID + ',' + K_CMENDBSTFSlideDTCr + ',' +
                    K_CMENDBSTFSlideThumbnail;

        CurSlidesDSet.SQL.Text := 'select ' + K_CMENDBSTFSlideID + ',' +
           K_CMENDBSTFSlideSysInfo + ',' + K_CMENDBSTFSlideMapRoot +
           WFName +
          ' from ' + EDAGetSlideSelectFromStr( ) +
          ' where (' +  SQLStr + ')' +
          K_CMEDAGetSlideSelectWhereStr( K_swfSkipAllDel );
//          EDAGetSlideSelectWhereStr( K_swfSkipAllDel );

        CurSlidesDSet.Filtered := false;
        CurSlidesDSet.Open;
        CurSlidesDSet.First;
        while not CurSlidesDSet.Eof do
        begin
          // Ñheck Slide Image Color
          K_CMEDAGetSlideSysFieldsData( K_CMEDAGetDBStringValue(CurSlidesDSet.Fields[1]), @SlideSDBF);
          if (cmsfIsMediaObj in SlideSDBF.SFlags) or
             not (cmsfGreyScale in SlideSDBF.SFlags) then goto NextSlide; // skip Video or Color Image convertion

        // Convert Image Attributes

          // Get MapRoot String
          ROP := EDAGetBlobFieldValue(CurSlidesDSet, CurSlidesDSet.FieldList[2], PData, DSize);
          if (ROP <> K_edOK) or (DSize = 0) then
          begin
            N_Dump1Str('Support>> SlideID =' + CurSlidesDSet.FieldList[0].AsString +
                        ' EDAGetBlobFieldValue problems');
            goto NextSlide;
          end;

          EDAAnsiTextToString(PData, DSize);
          SlideMapRootStr := String( PChar(PData) );

          // Search for BriCoGam Attributes position
          BriCOGamPosStart := N_PosEx( ImgAttrsStartLex, SlideMapRootStr, 0, Length(SlideMapRootStr) );
          if BriCOGamPosStart = 0 then
          begin
            N_Dump1Str('Support>> SlideID =' + CurSlidesDSet.FieldList[0].AsString +
                        ' ImgAttrs not found');
            goto NextSlide;
          end;
          BriCOGamPosStart := BriCOGamPosStart  + Length(ImgAttrsStartLex);
          BriCOGamPosFin := N_PosEx( '>', SlideMapRootStr, BriCOGamPosStart, Length(SlideMapRootStr) );
          ImgAttrsStr := Copy( SlideMapRootStr, BriCOGamPosStart, BriCOGamPosFin - BriCOGamPosStart );

          SL.DelimitedText := Trim(ImgAttrsStr);
          SetNewVal( 'MRBriFactor', BriVal );
          SetNewVal( 'MRCoFactor', CoVal );
          SetNewVal( 'MRGamFactor', GamVal );

          SlideMapRootStr := Copy( SlideMapRootStr, 1, BriCOGamPosStart - 1 ) +
                             ' ' + SL.DelimitedText + ' ' +
                             Copy( SlideMapRootStr, BriCOGamPosFin, Length(SlideMapRootStr) );

          CurSlidesDSet.Edit;
          DSize := EDAStringToAnsiText( @SlideMapRootStr[1], Length(SlideMapRootStr), PData);
          EDAPutBlobFieldValue( CurSlidesDSet, CurSlidesDSet.FieldList.Fields[2], PData, DSize );


          if RebuildThumbnailsFlag then
          begin
            // Load Current DIBObj
            PatID := CurSlidesDSet.FieldList[3].AsInteger;
            DTCreated := TDateTimeField(CurSlidesDSet.FieldList[4]).Value;
            WFName := SlidesImgRootFolder +
              K_CMSlideGetPatientFilesPathSegm(PatId) +
              K_CMSlideGetFileDatePathSegm(DTCreated) +
              K_CMSlideGetCurImgFileName( CurSlidesDSet.FieldList[0].AsString );
            if not K_DFOpen( WFName, DFile, [] ) then
            begin
              N_Dump1Str('Support>> Image File =' + WFName + ' is not found');
              goto NextSlide;
            end;
            SetLength( Buf, DFile.DFPlainDataSize );
            K_DFReadAll( @Buf[0], DFile );

            UDDIB := K_CMCreateUDDIBBySData( @Buf[0], DFile.DFPlainDataSize );
            if UDDIB = nil then
            begin
              N_Dump1Str('Support>> Image File =' + WFName + ' has not proper format 1');
              goto NextSlide;
            end;

            try
              UDDIB.LoadDIBObj(); 
            except
              on E: Exception do begin
                N_Dump1Str('Support>> Image File =' + WFName + ' has not proper format 2 >> ' + E.Message );
                FreeAndNil( UDDIB );
              end;
            end;

            if UDDIB = nil then goto NextSlide;

            // Create Thumbnail
            FillChar( ImgViewConvData, SizeOf(ImgViewConvData), 0 );

            ImgViewConvData.VCNegateFlag := pos( 'K_smriNegateImg', ImgAttrsStr ) > 0;

            if BriVal <> UndefVal then
              ImgViewConvData.VCBriFactor := BriVal;
            if CoVal <> UndefVal then
              ImgViewConvData.VCCoFactor  := CoVal;
            if GamVal <> UndefVal then
              ImgViewConvData.VCGamFactor := GamVal;

            Ind := SL.IndexOfName('MRBriMinFactor');
            if SL.ValueFromIndex[Ind] <> '' then
              ImgViewConvData.VCBriMinFactor := StrToFloat(SL.ValueFromIndex[Ind]);

            Ind := SL.IndexOfName('MRBriMaxFactor');
            if SL.ValueFromIndex[Ind] <> '' then
              ImgViewConvData.VCBriMaxFactor := StrToFloat(SL.ValueFromIndex[Ind]);

            Ind := SL.IndexOfName('MRFlipRotateAttrs');
            if SL.ValueFromIndex[Ind] <> '' then
              ImgViewConvData.VCFlipRotateAttrs := StrToInt(SL.ValueFromIndex[Ind]);

            RUDDIB := N_CreateUDDIB(N_CMDIBURect, [], '', 'MapImg');
            K_CMConvDIBBySlideViewConvData( RUDDIB.DIBObj, UDDIB.DIBObj,
                                            @ImgViewConvData, pf24bit, epfBMP );
            with RUDDIB.DIBObj.DIBSize do
              ThumbAspect := Y / X;
            ThumbSize := Point(K_CMSlideThumbSize, K_CMSlideThumbSize);
            ThumbSize := N_AdjustSizeByAspect(aamDecRect, ThumbSize, ThumbAspect);
            TmpGCont := TN_GlobCont.Create();

            ExpParams := N_DefExpParams;
            ExpParams.EPImageExpMode := iemJustDraw;
            ExpParams.EPExecFlags := ExpParams.EPExecFlags + [epefHALFTONE];
            TmpGCont.ExecuteRootComp( RUDDIB, [], nil, nil, @ExpParams );

            ThumbDIBObj := TN_DIBObj.Create( ThumbSize.X, ThumbSize.Y, pf24bit );
            ThumbRect := IRect(ThumbSize);

            with TmpGCont do
            begin
              SetStretchBltMode( ThumbDIBObj.DIBOCanv.HMDC, HALFTONE );
              N_StretchRect( ThumbDIBObj.DIBOCanv.HMDC, ThumbRect, DstOCanv.HMDC,
                             DstPixRect );
            end;

            EDPutBlobFieldFromDIB( CurSlidesDSet, CurSlidesDSet.FieldList[5], ThumbDIBObj,
                                   rietJPG, K_CMSlideThumbQuality );
            TmpGCont.Free;
            ThumbDIBObj.Free;
            RUDDIB.Free;
            UDDIB.Free;

          end;



          Inc(ProcNum);
NextSlide:
          CurSlidesDSet.Next();
        end;
        CurSlidesDSet.UpdateBatch();
        CurSlidesDSet.Close();
//        N_Dump2Str(format('DB>> Get %d slides by given IDs', [Ind]));
      except
        on E: Exception do
        begin
          ExtDataErrorString := 'EDAGetCurSlidesByID ' + E.Message;
          EDAShowErrMessage(TRUE);
          ExtDataErrorCode := K_eeDBSelect;
          Exit;
        end;
      end;
      Inc(IDInd, k);
      LEdConv.Text := IntToStr(ProcNum);
      PBProgress.Position := Round( 100 * IDInd / LIState.CMIImpCount );
      Application.ProcessMessages();
    end;


    K_CMShowMessageDlg( format( K_CML1Form.LLLImportChng4.Caption,
//       'The action is finished. All %d objects are processed, %d images are changed.',
               [LIState.CMIImpCount, ProcNum] ), mtInformation );
    ActMode := 0;
    ModalResult := mrOK;

FinConvertion:
    SL.Free;
    Screen.Cursor := SavedCursor;

  end;
end; // end of TK_FormCMImport.BtChangeClick


//*********************************************** TK_FormCMImport.FormShow ***
//
procedure TK_FormCMImportChngAttrs.FormShow(Sender: TObject);
begin
  SavedCursor := Screen.Cursor;
  K_CMEDAccess.EDAGetLastImportHistory1( @LIState, @SlidesIDArr );

  if LIState.CMIDBID <> -1 then
  begin
    LEdFName.Text := LIState.CMIXMLSlidesFName;
    LEdTotal.Text := format( '%7d', [LIState.CMIAllCount] );
    LEdProcessed.Text := format( '%7d', [LIState.CMIProcCount] );
    LEdErrors.Text := format( '%7d', [LIState.CMIErrCount] );
    LEdImported.Text := format( '%7d', [LIState.CMIImpCount] );
    LEdDate.Text := K_DateTimeToStr( LIState.CMIDate, 'dd"/"mm"/"yyyy' );
    LEdTime.Text := K_DateTimeToStr( LIState.CMIDate, 'hh":"nn AM/PM' );
    BtChange.Enabled := (LIState.CMIImpCount <> 0);
  end;

end; // TK_FormCMImport.FormShow

end.
