unit N_K_Tmp;
// temporary code form K_xxx files

interface
// !!! don't change order in uses -> GDIPAPI, Graphics
uses Forms, Menus, Classes, ADODB, DB, Math, Dialogs, ActnList, Controls, Windows,
  GDIPAPI,
  Graphics, ExtCtrls, IniFiles,
  N_Lib0, N_Lib2, N_Types, N_Comp1, N_CompBase, N_BaseF,
  N_Gra2, N_Rast1Fr, N_Comp2, N_SGComp,
  K_CLib0, K_UDT1, K_Script1, K_SBuf, K_STBuf, K_CLib, K_Gra0, K_Types,
  K_CM0;

  procedure N_CMConvDIBBySlideViewConvData( var ADDIBObj: TN_DIBObj;
                ASDIBObj: TN_DIBObj; APImgViewConvData: TK_PCMSImgViewConvData;
                APixFmt: TPixelFormat; AExPixFmt: TN_ExPixFmt = epfBMP;
                APEmbDIB1: TN_PDIBObj = nil;
                APIsoMinMax : PInteger = nil; APXLatBCGHist : TN_PIArray = nil;
                APXLatBCGColor : TN_PIArray = nil );

implementation
uses
{$IF SizeOf(Char) = 2}
  AnsiStrings,
{$IFEND}
  StrUtils, SysUtils, ExtDlgs, ComCtrls, Messages, DateUtils, StdCtrls,
  N_Lib1, N_ClassRef, N_CMResF, N_CMMain5F, N_CompCL, N_CM1,
  N_IconSelF, N_CMTWAIN1F, N_CMTWAIN2F,
  N_Video, N_GCont, N_Gra0, N_Gra1, N_Gra3, N_Gra6,
  N_CMREd3Fr, N_InfoF, N_DGrid, N_BrigHist2F, N_EdParF,
  K_VFunc, K_UDC, K_Gra1,
  K_CML1F,K_CML3F,{K_FCMSetSlidesAttrs,} K_FCMSetSlidesAttrs2,
  K_MapiControl, K_Arch, K_UDT2, K_UDConst, K_FCMSTextAttrs,
  K_FCMSIsodensity, K_FCMECacheProc,
  K_FCMSCalibrate, K_FEText, K_FCMCaptButDelay, K_FCMSlideIcons, K_FCMSlideIcon,
  K_FCMReportShow, K_FCMProfileTwain, K_FTestUnit, K_FCMSASelectPat, K_FCMSASetPatData;



//****************************************** N_CMConvDIBBySlideViewConvData ***
// Convert given DIBObj by given View Attributes
//
//     Parameters
// ADDIBObj - resulting Device Independent Bitmap Object (if nil will be created)
// ASDIBObj - source Device Independent Bitmap Object
// APImgViewConvData - pointer to all view conversion attributes
// APixFmt   - resulting DIB pixel format
// AExPixFmt - resulting DIB extended pixel format
// APEmbDIB1 - pointer to first emboss buffer DIB
// APEmbDIB2 - pointer to second emboss buffer DIB obsolete, not used
//
// If ADDIBObj is nil, it will be created. If ADstDIB exists but have not proper
// attributes (Size and Pixel format) it will be restructed properly. ADstDIB
// cannot be the same object as Self.
//
procedure N_CMConvDIBBySlideViewConvData( var ADDIBObj: TN_DIBObj;
  ASDIBObj: TN_DIBObj; APImgViewConvData: TK_PCMSImgViewConvData;
  APixFmt: TPixelFormat; AExPixFmt: TN_ExPixFmt = epfBMP;
  APEmbDIB1: TN_PDIBObj = nil; 
  APIsoMinMax: PInteger = nil; APXLatBCGHist : TN_PIArray = nil;
  APXLatBCGColor : TN_PIArray = nil );
var
  i, SrcNumBits, YMax, XLatLeng, IsoMax, IsoMin, WIsoBaseColInt: Integer;
  XLatBCG: TN_IArray; // BriCoGam XLat
  XLatCI: TN_IArray;  // Colorize, Isodensity XLat
  Alfa: Double;
  ConvGrayToColor: Boolean;
  EmbDIB1: TN_DIBObj; // temporary DIB for Emboss effect
begin
  //***** Calc XLatLeng

  if (ASDIBObj.DIBExPixFmt = epfGray16) or
     (ASDIBObj.DIBExPixFmt = epfColor48) then // Source DIB is 16 bit Image
  begin
    Assert( ASDIBObj.DIBNumBits > 8 );
    SrcNumBits := ASDIBObj.DIBNumBits;
  end else // Source DIB is 8 bit Image
    SrcNumBits := 8;

  XLatLeng := 1 shl SrcNumBits;
  SetLength( XLatBCG, XLatLeng );

  with APImgViewConvData^ do
  begin
    //***** Calc YMax for calculating XLatBCG

    if VCShowEmboss or VCShowColorize or (VCShowIsodensity and (VCIsoBaseColInt >= 0)) then
    begin // with these effects ON YMax does not depend upon ADDIBObj, AExPixFmt
      YMax := XLatLeng - 1;
    end else if ADDIBObj <> nil then // Dst DIB is given
    begin
      if (ADDIBObj.DIBExPixFmt = epfGray16) or
         (ADDIBObj.DIBExPixFmt = epfColor48) then // Dst DIB is 16 bit Image
        YMax := XLatLeng -1
      else // Dst DIB is 8 bit Image
        YMax := 255;
    end else // ADDIBObj = nil
    begin
      if (AExPixFmt = epfGray16) or
         (AExPixFmt = epfColor48) then // Dst DIB will be created as 16 bit Image
        YMax := XLatLeng -1
      else // Dst DIB will be created as 8 bit Image
        YMax := 255;
    end;

    //***** Prepare XLatBCG - BriCoGam and Negate conversion

//    N_p1 := ASDIBObj.PRasterBytes;
//    N_p2 := @ASDIBObj.DIBPixels[0];
//    ASDIBObj.CalcBrighHistNData( N_IA, nil, @N_i1, @N_i2, nil, 16 );

    N_BCGImageXlatBuild( XLatBCG, YMax, VCCoFactor, VCBriFactor, VCGamFactor,
                                  VCBriMinFactor, VCBriMaxFactor, VCNegateFlag );
//    N_DumpIntegers( @XLatBCG[0], Length(XLatBCG), $30, K_ExpandFileName( '(#CMSLogFiles#)XLAT1.txt' ) );

    // Create Slide XLatBCG to show Histogram window
    if APXLatBCGHist <> nil then
    begin
      if Length(APXLatBCGHist^) <> 256 then
        SetLength( APXLatBCGHist^, 256 );
      N_BCGImageXlatBuild( APXLatBCGHist^, 255,
                           VCCoFactor, VCBriFactor, VCGamFactor,
                           VCBriMinFactor, VCBriMaxFactor, VCNegateFlag );
      // Prepare Slide XLatBCG16 to get Real Color
      if APXLatBCGColor <> nil then
      begin
        if XLatLeng > 256 then
        begin
          if Length(APXLatBCGColor^) <> XLatLeng then
            SetLength( APXLatBCGColor^, XLatLeng );
          N_BCGImageXlatBuild( APXLatBCGColor^, XLatLeng - 1,
                               VCCoFactor, VCBriFactor, VCGamFactor,
                               VCBriMinFactor, VCBriMaxFactor, VCNegateFlag );
        end
        else
          APXLatBCGColor^ := APXLatBCGHist^;
      end; // if APXLatBCGColor <> nil then
    end; // if APXLatBCGHist <> nil then

    if VCShowEmboss then //********************************* Emboss
    begin

      // Emboss Effect should be applied after BriCoGam and FlipRotate conversions
      // prepare EmbDIB1 - ASDIBObj converted by XLatBCG

      if APEmbDIB1 <> nil then // Pointer to needed DIB is given, use it
        EmbDIB1 := APEmbDIB1^
      else // EmbDIB1 will be created in ASDIBObj.CalcXLATDIB
        EmbDIB1 := nil;

//      ASDIBObj.DIBDumpSelf2( 'C:\ab0.bmp' ); // for debug
      ASDIBObj.CalcXLATDIB( EmbDIB1, VCFlipRotateAttrs, @XLatBCG[0], 1,
                            ASDIBObj.DIBPixFmt, ASDIBObj.DIBExPixFmt );
//      EmbDIB1.DIBDumpSelf2( 'C:\ab1.bmp' ); // for debug

      K_CMInitEmbossAttrs( APImgViewConvData );

      if ADDIBObj = nil then
        ADDIBObj := TN_DIBObj.Create( EmbDIB1, 0, APixFmt, -1, AExPixFmt ); // empty resulting DIB

      EmbDIB1.CalcEmbossDIB( ADDIBObj, VCEmbDirAngle, VCEmbRFactor, VCEmbDepth, VCEmbBase );
//      ADDIBObj.DIBDumpSelf2( 'C:\ab2.bmp' ); // for debug

      if APEmbDIB1 <> nil then // Pointer to needed DIB was given, update it
        APEmbDIB1^ := EmbDIB1
      else // free just created created DIB
        EmbDIB1.Free;

      Exit; // ADDIBObj is OK, all done for Emboss case
    end; // if VCShowEmboss then //*************************** Emboss

    if VCShowColorize then //********************************* Colorize
    begin
      // Build XLatCI by Pseudocolors and apply it after XLatBCG
      SetLength( XLatCI, XLatLeng ); // XLatCI has same size as XLatBCG
      K_CMColorizeBuildColors( @XLatCI[0], XLatLeng, VCColPalInd, TRUE );
    end; // if VCShowColorize then //************************* Colorize

    if VCShowIsodensity and (VCIsoBaseColInt >= 0) then //**** Isodensity
    begin
      // Prepare XLatCI - uniform gray values with added VCIsoColor for
      //       brightness in (IsoMin, IsoMax) range and apply it after XLatBCG

      N_CalcUniformXLAT( XLatCI, XLatLeng  ); // start with uniform gray values (same size as XLatBCG)

      WIsoBaseColInt := VCIsoBaseColInt; // VCIsoBaseColInt is ASDIBObj Gray value (may be Gray16)
      WIsoBaseColInt := XLatBCG[WIsoBaseColInt];

      //***** Calc IsoMin, IsoMax by WIsoBaseColInt and VCIsoRangeFactor:
      // WIsoBaseColInt is the middle of (IsoMin, IsoMax) range to mark
      // VCIsoRangeFactor is in [0, 100],   0 means IsoMin=IsoMax=WIsoBaseColInt
      //                                  100 means IsoMin=0, IsoMax=YMax=XLatLeng-1

      if VCIsoRangeFactor < 0.3 then
      begin
        IsoMin := WIsoBaseColInt;
        IsoMax := WIsoBaseColInt;
      end else if VCIsoRangeFactor < 1.2 then
      begin
        IsoMin := WIsoBaseColInt;
        IsoMax := WIsoBaseColInt + 1;
      end else if VCIsoRangeFactor < 2.1 then
      begin
        IsoMin := WIsoBaseColInt - 1;
        IsoMax := WIsoBaseColInt + 1;
      end else if VCIsoRangeFactor < 2.7 then
      begin
        IsoMin := WIsoBaseColInt - 1;
        IsoMax := WIsoBaseColInt + 2;
      end else if VCIsoRangeFactor < 6.0 then
      begin
        IsoMin := WIsoBaseColInt - Round(2 + (VCIsoRangeFactor - 2.1)/1.2);
        IsoMax := WIsoBaseColInt + Round(2 + (VCIsoRangeFactor - 2.7)/1.2);
      end else // VCIsoRangeFactor >= 6.0
      begin
        IsoMin := WIsoBaseColInt - Round(5 + (VCIsoRangeFactor - 6.0)*0.01*YMax);
        IsoMax := WIsoBaseColInt + Round(5 + (VCIsoRangeFactor - 6.0)*0.01*YMax);
      end;

      if IsoMax > YMax then IsoMax := YMax;
      if IsoMin <   0  then IsoMin := 0;

      if APIsoMinMax <> nil then // APIsoMinMax is given
      begin
        APIsoMinMax^ := IsoMin;
        Inc(APIsoMinMax);
        APIsoMinMax^ := IsoMax;
      end;

      N_ConvGrayToRGB8XLat( XLatCI, ASDIBObj.DIBNumBits ); // Convert Gray XLatCI to RGB8 XLatCI (G->GGG)
      Alfa := 0.01*VCIsoTranspFactor; // 0 means VCIsoColor, 1 - original gray value

      for i := IsoMin to IsoMax do
        XLatCI[i] := N_LinCombRGB8( XLatCI[i], N_SwapRedBlueBytes(VCIsoColor), Alfa );

//      N_Dump2Str( Format( '  VCIsoRangeFactor=%7.3f', [VCIsoRangeFactor] ) );
    end; // if VCShowIsodensity and (VCIsoBaseColInt >= 0) then //*** Isodensity

    if Length(XLatCI) = 0 then // all (Emboss, Colorize, Isodensity) effects are OFF, just BriCoGam (and Negate)
    begin
      //***** Set ConvGrayToColor

      if ADDIBObj <> nil then // Dst DIB is given
        ConvGrayToColor := (ADDIBObj.DIBPixFmt = pf24bit) and
                           (ASDIBObj.DIBPixFmt <> pf24bit)
      else // ADDIBObj = nil
        ConvGrayToColor := (APixFmt = pf24bit) and
                           (ASDIBObj.DIBPixFmt <> pf24bit);

      if ConvGrayToColor then // Convert XLatBCG elements from Gray to Color (G->GGG)
                              // Here XLatBCG values are always 8 bit (in [0,255] range)
        N_ConvGrayToRGB8XLat( XLatBCG, 8 ); // Convert Gray8 XLatBCG to RGB8 XLatBCG (G->GGG)

//      N_DumpIntegers( @XLatBCG[0], Length(XLatBCG), $30, K_ExpandFileName( '(#CMSLogFiles#)XLAT2.txt' ) );
    end else // Length(XLatCI) > 0, Colorize or Isodensity effect is ON
    begin    // apply first XLatBCG and then XLatCI
      N_CombineXLatTables( XLatBCG, XLatCI ); // XLatBCG[i] = XLatCI[XLatBCG[i]]
    end;

//***** Here: XLatBCG is OK, use it

//****** Below all variants are listed ( N means 2**NumBits-1, HX means High(XLat) )
//
//   Length(XLatCI)=0 (Emboss, Colorize, Isodensity are all Off)
//   Src  ->  Dst  - HX YMax - notes
//  24bit -> 24bit - 255 255 - apply 3 times for R->R,G->G,B->B channels (Color8->Color8 convertion)
//   8bit -> 24bit - 255 255 - RGB in all XLat elements R=G=B            (Gray8->Color8 convertion)
//   8bit ->  8bit - 255 255 - Gray8 in all XLat elements                (Gray8->Gray8 convertion)
//  16bit -> 24bit -  N  255 - RGB in all XLat elements R=G=B            (GrayN->Color8 convertion)
//  16bit -> 16bit -  N   N  - Gray16 in all XLat elements               (Gray15->Gray16 convertion)
//  48bit -> 48bit -  N   N  - apply 3 times for R->R,G->G,B->B channels (Color16->Color16 convertion)
//  48bit -> 24bit -  N  255 - RGB in all XLat elements R=G=B            (Gray16->Color8 convertion)
//
//   Length(XLatCI)>0, one of Emboss, Colorize, Isodensity effects is ON
//   Src  ->  Dst  - HX YMax - notes
//   8bit -> 24bit - 255 255 - RGB in XLat elements any R,G,B values     (Gray8->Color8 convertion)
//  16bit -> 24bit -  N  255 - RGB in XLat elements any R,G,B values     (GrayN->Color8 convertion)

    ASDIBObj.CalcBrighHistNData( N_IA, nil, @N_i1, @N_i2, nil, 16 );
//    N_Dump1Str( Format( '  N_K_ before XLAT %d, %d, %d', [SrcNumBits,N_i1,N_i2] ));
//    N_DumpIntegers( @XLatBCG[0], Length(XLatBCG), $30, K_ExpandFileName( '(#CMSLogFiles#)XLAT1.txt' ) );

    ASDIBObj.CalcXLATDIB( ADDIBObj, VCFlipRotateAttrs, @XLatBCG[0], 1, APixFmt, AExPixFmt );

  end; // with APImgViewConvData^ do

end; // procedure N_CMConvDIBBySlideViewConvData


end.
