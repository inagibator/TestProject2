unit N_CMCaptDev15aF;
// Request image for FireCR/MediaScan form changed from Valery Ovechkin 26.02.2013 Dev5 dialog

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  StdCtrls, ExtCtrls, Forms, Dialogs, Grids,
{$IF CompilerVersion >= 26.0} // Delphi >= XE5
  UITypes,
{$IFEND}
  K_CM0, N_Types, N_Lib1, N_BaseF, N_CMCaptDev0, K_FCMDeviceSetupEnter,
  N_Lib0, Buttons, ComCtrls, N_CompBase, N_Gra2, N_Rast1Fr, N_CMCaptDev15SF;

type TN_CMCaptDev15aForm = class( TN_BaseForm )
  SGImages: TStringGrid;
  bnRecoverImage: TButton;
  SpeedButton1: TSpeedButton;
  SpeedButton0: TSpeedButton;
  ProgressBarSecond: TProgressBar;
  bnSave: TButton;
  Timer1: TTimer;
  SpeedButton2: TSpeedButton;
  SpeedButton3: TSpeedButton;
  NewPanel: TPanel;
  NewRFrame: TN_Rast1Frame;
  bnClose: TButton;

  // ***** events handlers
  procedure FormCreate         ( Sender: TObject );
  procedure bnRecoverImageClick( Sender: TObject );
  procedure Timer1Timer        ( Sender: TObject );
  procedure FormClose          ( Sender: TObject; var Action: TCloseAction );
                                                                       override;
  procedure bnSaveClick        ( Sender: TObject );
  procedure SpeedButton0Click  ( Sender: TObject );
  procedure SpeedButton1Click  ( Sender: TObject );
  procedure SpeedButton2Click  ( Sender: TObject );
  procedure SpeedButton3Click  ( Sender: TObject );
  procedure SGImagesClick      ( Sender: TObject );
  procedure SGImagesSelectCell ( Sender: TObject; ACol, ARow: Integer;
                                                       var CanSelect: Boolean );
  procedure bnCloseClick       ( Sender: TObject );
  procedure FormShow           ( Sender: TObject );

  public
    CMOFPDevProfile: TK_PCMDeviceProfile;
    CMOFParentForm:  TN_CMCaptDev15Form;
end;

var
  N_ButtonFlag:  Byte; // which button is pressed
  N_ImagesSaved: array[0..99] of Boolean; // for not allowing a second time saving
  N_RowPressed:  Integer;

implementation
{$R *.dfm}

uses
  N_CMCaptDev15S;

//******************************************* TN_CMCaptDev15bForm.bnOKClick ***
// Button bnClose click event handler
//
//     Parameters
// Sender - sender object
//
// Closes a form
//
procedure TN_CMCaptDev15aForm.bnCloseClick(Sender: TObject);
var
  DLGResult: Word;
begin
  N_Dump1Str( 'Start TN_CMCaptDev15aForm.bnCloseClick' );
  if N_NewSlide <> Nil then
  begin
    DLGResult := MessageDlg(
                'There is an image in the preview that has not been saved.'+#13+
                       'Would you like to close the recovery interface anyway?',
                                                        mtWarning, mbYesNo, 0 );
    if DLGResult = mrYes then
      Close();
  end
  else
    Close();
  N_Dump1Str( 'End TN_CMCaptDev15aForm.bnCloseClick' );
end; // TN_CMCaptDev15aForm.bnCloseClick

//********************************* TN_CMCaptDev15bForm.bnRecoverImageClick ***
// Button bnRecoverImage click event handler
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev15aForm.bnRecoverImageClick( Sender: TObject );
var
  Temp: integer;
begin
  N_Dump1Str( 'Start TN_CMCaptDev15aForm.bnRecoverImageClick' );
  inherited;
  if N_ImagesSaved[SGImages.Row - 1] = False then // NewSlide was not added (saved)
  begin
    N_NewSlide.UDDelete();
    N_NewSlide := Nil;
  end
  else // NewSlide was added (saved)
    N_NewSlide := Nil;

  // ***** request image by index from buffer
  N_Dump1Str( 'FireCR - Before RequestImageFromList( '+
            IntToStr(N_CMCDServObj15.CDSIndexArray[SGImages.Row - 1]) );
  Temp := N_CMECDVDC_RequestImageFromList(
                              N_CMCDServObj15.CDSIndexArray[SGImages.Row - 1] ); // index from array of indexes
  N_Dump1Str( 'FireCR - After RequestImageFromList( '+
            IntToStr(N_CMCDServObj15.CDSIndexArray[SGImages.Row - 1]) + ' ) = '
                                                            + IntToStr( Temp ));

  bnRecoverImage.Enabled := False;
  N_RowPressed := SGImages.Row - 1;
  //PreviewPressed := True;
  N_Dump1Str( 'End TN_CMCaptDev15aForm.bnRecoverImageClick' );
end; // procedure TN_CMCaptDev15aForm.bnRecoverImageClick( Sender: TObject );

//**************************************** TN_CMCaptDev15aForm.bnSaveClick ***
// Button bnSave click event handler
//
//     Parameters
// Sender - sender object
//
// Saving last previewed image
//
procedure TN_CMCaptDev15aForm.bnSaveClick(Sender: TObject);
var
  PNList_i: PN_ImageIntro;
  TempStr: string;
begin
  N_Dump1Str( 'Start TN_CMCaptDev15aForm.bnSaveClick' );
  inherited;
  //FlagSave := True;
  with N_CMCDServObj15 do
  begin

    CDSList := N_CMECDVDC_RequestImageList; // request list of images from buffer

    PNList_i := CDSList;
    Inc( PNList_i, N_CMCDServObj15.CDSIndexArray[SGImages.Row - 1] );
    N_Dump1Str( 'After getting a right table cell, before getting a date' );

    N_SlideTime := PNList_i.IIStruct.TimeSaved;
    if N_SlideTime > 0 then
      N_Dump1Str( 'No time for the slide!' )
    else
    begin
      DateTimeToString(TempStr, 'c', N_SlideTime);
      N_Dump1Str( 'DateTime for the slide = ' + TempStr);
    end;
  end;

  CMOFParentForm.SaveImageFromBuffer;
  N_ImagesSaved[SGImages.Row - 1] := True;
  N_Dump1Str( 'End TN_CMCaptDev15aForm.bnSaveClick' );
end; // procedure TN_CMCaptDev15aForm.bnSaveClick(Sender: TObject);

//********************************** TN_CMCaptDev15aForm.SpeedButton0Click ***
// Button SpeedButton0 click event handler
//
//     Parameters
// Sender - sender object
//
// Sorting the grid
//
procedure TN_CMCaptDev15aForm.SGImagesClick(Sender: TObject);
begin
  inherited;
  {if (RowPressed = 0) or (RowPressed <> SGImages.Row - 1) then
  begin
    RowPressed := SGImages.Row - 1;
    //PreviewPressed := False;

  end;   }
  {if (ImagesSaved[SGImages.Row - 1] = True) and
                                           (RowPressed <> SGImages.Row - 1) then
    bnRecoverImage.Enabled := False
  else
    bnRecoverImage.Enabled := True;    }
end;

//********************************** TN_CMCaptDev15aForm.SpeedButton0Click ***
// Action for selctiong a table cell
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev15aForm.SGImagesSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
  N_Dump1Str( 'Start TN_CMCaptDev15aForm.SGImagesSelectCell' );
   if (N_ImagesSaved[SGImages.Row - 1] = True) and
                                         (N_RowPressed <> SGImages.Row - 1) then
    bnRecoverImage.Enabled := False
  else
    bnRecoverImage.Enabled := True;
  N_Dump1Str( 'End TN_CMCaptDev15aForm.SGImagesSelectCell' );
end; // procedure TN_CMCaptDev15aForm.SGImagesSelectCell

//********************************** TN_CMCaptDev15aForm.SpeedButton0Click ***
// Action for pressing a first arrow over the table
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev15aForm.SpeedButton0Click(Sender: TObject);
var
  i, j, Count, GridLength: integer;
  Params:           PN_ScannerIntro;
  TempStr, DumpStr: string;
  PNList_i:         PN_ImageIntro;
  ListArray:        array[0..99] of PN_ImageIntro;
  TempImage:        PN_ImageIntro;
  TempInt, TempIntArray: Integer;
begin
  N_Dump1Str( 'Start TN_CMCaptDev15aForm.SpeedButton0Click' );
  inherited;

  if N_ButtonFlag <> 0 then // if the button wasn't pressed before
  begin
    N_ButtonFlag := 0; // the button was pressed

    // ***** setting button's parameters
    SpeedButton0.Enabled := False;
    SpeedButton1.Enabled := False;
    SpeedButton2.Enabled := False;
    SpeedButton3.Enabled := False;

    // saving previous row
    TempIntArray := SGImages.Row - 1;
    TempIntArray := N_CMCDServObj15.CDSIndexArray[TempIntArray]; // saving the number of the element that is highlighted

    // set grid row widths
    with SGImages do
    begin
      ColWidths[0] := 30;
      ColWidths[1] := 125;
      ColWidths[2] := 125;
      ColWidths[3] := 40;
      ColWidths[4] := 25;
      ColWidths[5] := 105;
      ColWidths[6] := 120;
    end; // with SGImages do

    // ***** the head of the grid
    with SGImages do
    begin
      Cells[0,0] := 'Index';
      Cells[1,0] := 'Saved';
      Cells[2,0] := 'Served';
      Cells[3,0] := 'IP';
      Cells[4,0] := 'Res';
      Cells[5,0] := 'UID';
      Cells[6,0] := 'Patient name';
    end; // with SGImages do

    Count := 0; // index of the sensor
    Params := N_CMECDVDC_RequestScannerList( @Count ); // get parameters of the sensor

    // ***** set grid length
    if Assigned(Params) then
      GridLength := 100 //Params.ImageCount + 2// +1 added by me
    else
      GridLength := 2;

    with N_CMCDServObj15 do
    begin
      N_Dump1Str( 'FireCR - Before RequestImageList' );
      CDSList := N_CMECDVDC_RequestImageList; // request list of images from buffer
      N_Dump1Str( 'FireCR - After RequestImageList' );

      N_Dump1Str( 'FireCR - Length of the request images grid = ' +
                                                         IntToStr(GridLength) );
      SGImages.RowCount := GridLength + 1;

      N_Dump1Str( 'FireCR - List of images before sort:' );
      N_Dump1Str( 'FireCR - Index, TimeSaved, UID' );

      // ***** dump the initial list
      for i := 0 to 99 do
      begin
        PNList_i := CDSList;
        Inc( PNList_i, i );
        ListArray[i] := PNList_i;

        N_Dump1Str( 'FireCR - ' + IntToStr(i) + ', ' +
                       FloatToStr(PNList_i.IIStruct.TimeSaved) + Format( ', %x',
                                                     [PNList_i.IIStruct.UID]) );
      end; // for i := 0 to 99 do

      // ***** set initial (unsort) states for array of indexes
      for i := 0 to 99 do
      begin
        CDSIndexArray[i] := i;
      end; // for i := 0 to 99 do

      // ***** sort list of images by time saved
      for i := 0 to 99 do
      for j := 0 to 98 - i do
      begin
        if ListArray[j].IIStruct.TimeSaved < ListArray[j+1].IIStruct.TimeSaved
                                                                            then
        begin
          // ***** move images
          TempImage := ListArray[j];
          ListArray[j] := ListArray[j+1];
          ListArray[j+1] := TempImage;

          // ***** move indexes
          TempInt := CDSIndexArray[j];
          CDSIndexArray[j] := CDSIndexArray[j+1];
          CDSIndexArray[j+1] := TempInt;
        end;
      end; // for j := 0 to 98 - i do
      N_Dump1Str( 'FireCR - List of images after sort:' );
      N_Dump1Str(
      'FireCR - Index, TimeSaved, TimeServed, IPSize, Res, UID, Patient name' );

      // ***** fill the grid
      for i := 0 to 99 do
      begin
        with SGImages do
        begin
          DumpStr := ''; // current grid col for the dump initial state

          DumpStr := DumpStr + IntToStr(N_CMCDServObj15.CDSIndexArray[i]);

          Cells[0,i+1] := IntToStr(i);
          DumpStr := DumpStr + Cells[0,i+1] + ', ';

          if ListArray[i].IIStruct.TimeSaved > 0 then
          begin
            DateTimeToString(TempStr, 'c', ListArray[i].IIStruct.TimeSaved);
            Cells[1,i+1] := TempStr;
          end
          else
            Cells[1,i+1] := FloatToStr( ListArray[i].IIStruct.TimeSaved );
          DumpStr := DumpStr + Cells[1,i+1] + ', ';

          if ListArray[i].IIStruct.TimeServed > 0 then
          begin
            DateTimeToString(TempStr, 'c', ListArray[i].IIStruct.TimeServed);
            Cells[2,i+1] := TempStr;
          end
          else
            Cells[2,i+1] := FloatToStr( ListArray[i].IIStruct.TimeServed );
          DumpStr := DumpStr + Cells[2,i+1] + ', ';

          case ListArray[i].IIStruct.IPSize of
            0: Cells[3,i+1] := 'SIZE0';
            1: Cells[3,i+1] := 'SIZE1';
            2: Cells[3,i+1] := 'SIZE2';
            3: Cells[3,i+1] := 'SIZE3';
            4: Cells[3,i+1] := 'SIZE4ñ';
            else Cells[3,i+1] := 'None';
          end;

          DumpStr := DumpStr + Cells[3,i+1] + ', ';

          case ListArray[i].IIStruct.Resolution of
            0: Cells[4,i+1] := 'SD';
            1: Cells[4,i+1] := 'HD';
            else Cells[4,i+1] := 'None';
          end;
          DumpStr := DumpStr + Cells[4,i+1] + ', ';

          Cells[5,i+1] := Format( '%x',[ListArray[i].IIStruct.UID]);
          DumpStr := DumpStr + Cells[5,i+1] + ', ';

          Cells[6,i+1] := N_AnsiToString(
                                    AnsiString(@ListArray[i].IIStruct.PID[0]) );
          if AnsiString(@ListArray[i].IIStruct.PID[0]) = '' then
            Cells[6,i+1] := 'None';
          DumpStr := DumpStr + '~~~~~' + ', ';//Cells[6,i+1] + ', '; // no patient names in a log

          N_Dump1Str( 'FireCR - ' + DumpStr ); // save this col in the dump
        end; // with SGImages do
      end; // for i := 0 to 99 do
    end; // with N_CMCDServObj15 do

    // ***** setting the current row
    for i := 0 to 99 do
    begin
      if N_CMCDServObj15.CDSIndexArray[i] = TempIntArray then
      begin
        TempIntArray := i;
        SGImages.Row := TempIntArray + 1;
        Break;
      end;
    end;

    // ***** setting up the buttons
    SpeedButton0.Enabled := True;
    SpeedButton1.Enabled := True;
    SpeedButton2.Enabled := True;
    SpeedButton3.Enabled := True;
  end
  else // if the button was pressed before
  begin
    // ***** choosing the right button, then click it
    SpeedButton0.Visible := False;
    SpeedButton0.Down := False;
    SpeedButton1.Visible := True;
    SpeedButton1.Down := False;
    SpeedButton2.Down := False;
    SpeedButton3.Down := False;
    SpeedButton1.Click;
    SpeedButton1.Down := True;
  end;
  N_Dump1Str( 'End TN_CMCaptDev15aForm.SpeedButton0Click' );
end; // procedure TN_CMCaptDev15aForm.SpeedButton0Click(Sender: TObject);

//********************************** TN_CMCaptDev15aForm.SpeedButton1Click ***
// Button SpeedButton1 click event handler
//
//     Parameters
// Sender - sender object
//
// Sorting the grid
//
procedure TN_CMCaptDev15aForm.SpeedButton1Click(Sender: TObject);
var
  i, j, Count, GridLength: integer;
  Params:           PN_ScannerIntro;
  TempStr, DumpStr: string;
  PNList_i:         PN_ImageIntro;
  ListArray:        array[0..99] of PN_ImageIntro;
  TempImage:        PN_ImageIntro;
  TempInt, TempIntArray: Integer;
begin
  N_Dump1Str( 'Start TN_CMCaptDev15aForm.SpeedButton1Click' );
  inherited;

  if N_ButtonFlag <> 1 then // if the button wasn't pressed before
  begin
    N_ButtonFlag := 1; // the button was pressed

    // ***** disabling the buttons while processing
    SpeedButton0.Enabled := False;
    SpeedButton1.Enabled := False;
    SpeedButton2.Enabled := False;
    SpeedButton3.Enabled := False;

    // ***** saving the current row
    TempIntArray := SGImages.Row - 1;
    TempIntArray := N_CMCDServObj15.CDSIndexArray[TempIntArray]; // saving the number of the element that is highlighted

    // set grid row widths
    with SGImages do
    begin
      ColWidths[0] := 30;
      ColWidths[1] := 125;
      ColWidths[2] := 125;
      ColWidths[3] := 40;
      ColWidths[4] := 25;
      ColWidths[5] := 105;
      ColWidths[6] := 120;
    end; // with SGImages do

    // ***** the head of the grid
    with SGImages do
    begin
      Cells[0,0] := 'Index';
      Cells[1,0] := 'Saved';
      Cells[2,0] := 'Served';
      Cells[3,0] := 'IP';
      Cells[4,0] := 'Res';
      Cells[5,0] := 'UID';
      Cells[6,0] := 'Patient name';
    end; // with SGImages do

    Count := 0; // index of the sensor
    Params := N_CMECDVDC_RequestScannerList( @Count ); // get parameters of the sensor

    // ***** set grid length
    if Assigned(Params) then
      GridLength := 100 //Params.ImageCount + 2// +1 added by me
    else
      GridLength := 2;

    with N_CMCDServObj15 do
    begin
      N_Dump1Str( 'FireCR - Before RequestImageList' );
      CDSList := N_CMECDVDC_RequestImageList; // request list of images from buffer
      N_Dump1Str( 'FireCR - After RequestImageList' );

      N_Dump1Str( 'FireCR - Length of the request images grid = ' +
                                                         IntToStr(GridLength) );
      SGImages.RowCount := GridLength + 1;

      N_Dump1Str( 'FireCR - List of images before sort:' );
      N_Dump1Str( 'FireCR - Index, TimeSaved, UID' );

      // ***** dump the initial list
      for i := 0 to 99 do
      begin
        PNList_i := CDSList;
        Inc( PNList_i, i );
        ListArray[i] := PNList_i;

        N_Dump1Str( 'FireCR - ' + IntToStr(i) + ', ' +
                       FloatToStr(PNList_i.IIStruct.TimeSaved) + Format( ', %x',
                                                     [PNList_i.IIStruct.UID]) );
      end; // for i := 0 to 99 do

      // ***** set initial (unsort) states for array of indexes
      for i := 0 to 99 do
      begin
        CDSIndexArray[i] := i;
      end; // for i := 0 to 99 do

      // ***** sort list of images by time saved
      for i := 0 to 99 do
      for j := 0 to 98 - i do
      begin
        if ListArray[j].IIStruct.TimeSaved > ListArray[j+1].IIStruct.TimeSaved
                                                                            then
        begin
          // ***** move images
          TempImage := ListArray[j];
          ListArray[j] := ListArray[j+1];
          ListArray[j+1] := TempImage;

          // ***** move indexes
          TempInt := CDSIndexArray[j];
          CDSIndexArray[j] := CDSIndexArray[j+1];
          CDSIndexArray[j+1] := TempInt;
        end;
      end; // for j := 0 to 98 - i do
      N_Dump1Str( 'FireCR - List of images after sort:' );
      N_Dump1Str(
      'FireCR - Index, TimeSaved, TimeServed, IPSize, Res, UID, Patient name' );

      // ***** fill the grid
      for i := 0 to 99 do
      begin
        with SGImages do
        begin
          DumpStr := ''; // current grid col for the dump initial state

          DumpStr := DumpStr + IntToStr(N_CMCDServObj15.CDSIndexArray[i]);

          Cells[0,i+1] := IntToStr(i);
          DumpStr := DumpStr + Cells[0,i+1] + ', ';

          if ListArray[i].IIStruct.TimeSaved > 0 then
          begin
            DateTimeToString(TempStr, 'c', ListArray[i].IIStruct.TimeSaved);
            Cells[1,i+1] := TempStr;
          end
          else
            Cells[1,i+1] := FloatToStr( ListArray[i].IIStruct.TimeSaved );
          DumpStr := DumpStr + Cells[1,i+1] + ', ';

          if ListArray[i].IIStruct.TimeServed > 0 then
          begin
            DateTimeToString(TempStr, 'c', ListArray[i].IIStruct.TimeServed);
            Cells[2,i+1] := TempStr;
          end
          else
            Cells[2,i+1] := FloatToStr( ListArray[i].IIStruct.TimeServed );
          DumpStr := DumpStr + Cells[2,i+1] + ', ';

          case ListArray[i].IIStruct.IPSize of
            0: Cells[3,i+1] := 'SIZE0';
            1: Cells[3,i+1] := 'SIZE1';
            2: Cells[3,i+1] := 'SIZE2';
            3: Cells[3,i+1] := 'SIZE3';
            4: Cells[3,i+1] := 'SIZE4ñ';
            else Cells[3,i+1] := 'None';
          end;

          DumpStr := DumpStr + Cells[3,i+1] + ', ';

          case ListArray[i].IIStruct.Resolution of
            0: Cells[4,i+1] := 'SD';
            1: Cells[4,i+1] := 'HD';
            else Cells[4,i+1] := 'None';
          end;
          DumpStr := DumpStr + Cells[4,i+1] + ', ';

          Cells[5,i+1] := Format( '%x',[ListArray[i].IIStruct.UID]);
          DumpStr := DumpStr + Cells[5,i+1] + ', ';

          Cells[6,i+1] := N_AnsiToString(
                                    AnsiString(@ListArray[i].IIStruct.PID[0]) );
          if AnsiString(@ListArray[i].IIStruct.PID[0]) = '' then
            Cells[6,i+1] := 'None';
          DumpStr := DumpStr + Cells[6,i+1] + ', ';

          N_Dump1Str( 'FireCR - ' + DumpStr ); // save this col in the dump
        end; // with SGImages do
      end; // for i := 0 to 99 do
    end; // with N_CMCDServObj15 do

    // ***** setting the current row
    for i := 0 to 99 do
    begin
      if N_CMCDServObj15.CDSIndexArray[i] = TempIntArray then
      begin
        TempIntArray := i;
        SGImages.Row := TempIntArray + 1;
        Break;
      end;
    end;

    // ***** enables the buttons after processing
    SpeedButton0.Enabled := True;
    SpeedButton1.Enabled := True;
    SpeedButton2.Enabled := True;
    SpeedButton3.Enabled := True;
  end
  else // if the button was pressed before
  begin
    // ***** choosing the right button, then click it
    SpeedButton1.Visible := False;
    SpeedButton1.Down := False;
    SpeedButton0.Visible := True;
    SpeedButton0.Down := False;
    SpeedButton2.Down := False;
    SpeedButton3.Down := False;
    SpeedButton0.Click;
    SpeedButton0.Down := True;
  end;
  N_Dump1Str( 'End TN_CMCaptDev15aForm.SpeedButton1Click' );
end; // procedure TN_CMCaptDev15aForm.SpeedButton1Click(Sender: TObject);

//********************************** TN_CMCaptDev15aForm.SpeedButton2Click ***
// Button SpeedButton2 click event handler
//
//     Parameters
// Sender - sender object
//
// Sorting the grid
//
procedure TN_CMCaptDev15aForm.SpeedButton2Click(Sender: TObject);
var
  i, j, Count, GridLength: integer;
  Params:           PN_ScannerIntro;
  TempStr, DumpStr: string;
  PNList_i:         PN_ImageIntro;
  ListArray:        array[0..99] of PN_ImageIntro;
  TempImage:        PN_ImageIntro;
  TempInt, TempIntArray: Integer;
  TempAnsiStr1, TempAnsiStr2: AnsiString;
begin
  N_Dump1Str( 'Start TN_CMCaptDev15aForm.SpeedButton2Click' );
  inherited;
  if N_ButtonFlag <> 2 then // if the button wasn't pressed before
  begin
    N_ButtonFlag := 2; // the button was pressed

    // ***** disabling the buttons
    SpeedButton0.Enabled := False;
    SpeedButton1.Enabled := False;
    SpeedButton2.Enabled := False;
    SpeedButton3.Enabled := False;

    // saving the current row
    TempIntArray := SGImages.Row - 1;
    TempIntArray := N_CMCDServObj15.CDSIndexArray[TempIntArray]; // saving the number of the element that is highlighted

    // set grid row widths
    with SGImages do
    begin
      ColWidths[0] := 30;
      ColWidths[1] := 125;
      ColWidths[2] := 125;
      ColWidths[3] := 40;
      ColWidths[4] := 25;
      ColWidths[5] := 105;
      ColWidths[6] := 120;
    end; // with SGImages do

    // ***** the head of the grid
    with SGImages do
    begin
      Cells[0,0] := 'Index';
      Cells[1,0] := 'Saved';
      Cells[2,0] := 'Served';
      Cells[3,0] := 'IP';
      Cells[4,0] := 'Res';
      Cells[5,0] := 'UID';
      Cells[6,0] := 'Patient name';
    end; // with SGImages do

    Count := 0; // index of the sensor
    Params := N_CMECDVDC_RequestScannerList( @Count ); // get parameters of the sensor

    // ***** set grid length
    if Assigned(Params) then
      GridLength := 100 //Params.ImageCount + 2// +1 added by me
    else
      GridLength := 2;

    with N_CMCDServObj15 do
    begin
      N_Dump1Str( 'FireCR - Before RequestImageList' );
      CDSList := N_CMECDVDC_RequestImageList; // request list of images from buffer
      N_Dump1Str( 'FireCR - After RequestImageList' );

      N_Dump1Str( 'FireCR - Length of the request images grid = ' +
                                                         IntToStr(GridLength) );
      SGImages.RowCount := GridLength + 1;

      N_Dump1Str( 'FireCR - List of images before sort:' );
      N_Dump1Str( 'FireCR - Index, TimeSaved, UID' );

      // ***** dump the initial list
      for i := 0 to 99 do
      begin
        PNList_i := CDSList;
        Inc( PNList_i, i );
        ListArray[i] := PNList_i;

        N_Dump1Str( 'FireCR - ' + IntToStr(i) + ', ' +
                       FloatToStr(PNList_i.IIStruct.TimeSaved) + Format( ', %x',
                                                     [PNList_i.IIStruct.UID]) );
      end; // for i := 0 to 99 do

      // ***** set initial (unsort) states for array of indexes
      for i := 0 to 99 do
      begin
        CDSIndexArray[i] := i;
      end; // for i := 0 to 99 do

      // ***** sort list of images by time saved first
      for i := 0 to 99 do
      for j := 0 to 98 - i do
      begin
        if ListArray[j].IIStruct.TimeSaved < ListArray[j+1].IIStruct.TimeSaved
                                                                            then
        begin
          // ***** move images
          TempImage := ListArray[j];
          ListArray[j] := ListArray[j+1];
          ListArray[j+1] := TempImage;

          // ***** move indexes
          TempInt := CDSIndexArray[j];
          CDSIndexArray[j] := CDSIndexArray[j+1];
          CDSIndexArray[j+1] := TempInt;
        end;
      end; // for j := 0 to 98 - i do

      // ***** sort list of images by patient's name
      for i := 0 to 99 do
      for j := 0 to 98 - i do
      begin
        // ***** if there is no name
        if ListArray[j].IIStruct.PID <> '' then
          TempAnsiStr1 := ListArray[j].IIStruct.PID
        else
          TempAnsiStr1 := 'None';

        if ListArray[j+1].IIStruct.PID <> '' then
          TempAnsiStr2 := ListArray[j+1].IIStruct.PID
        else
          TempAnsiStr2 := 'None';

        if not(AnsiCompareStr( N_AnsiToString(TempAnsiStr1),
                                        N_AnsiToString(TempAnsiStr2) ) > 0) then
        begin
          // ***** move images
          TempImage := ListArray[j];
          ListArray[j] := ListArray[j+1];
          ListArray[j+1] := TempImage;

          // ***** move indexes
          TempInt := CDSIndexArray[j];
          CDSIndexArray[j] := CDSIndexArray[j+1];
          CDSIndexArray[j+1] := TempInt;
        end;
      end; // for j := 0 to 98 - i do

      N_Dump1Str( 'FireCR - List of images after sort:' );
      N_Dump1Str(
      'FireCR - Index, TimeSaved, TimeServed, IPSize, Res, UID, Patient name' );

      // ***** fill the grid
      for i := 0 to 99 do
      begin
        with SGImages do
        begin
          DumpStr := ''; // current grid col for the dump initial state

          DumpStr := DumpStr + IntToStr(N_CMCDServObj15.CDSIndexArray[i]);

          Cells[0,i+1] := IntToStr(i);
          DumpStr := DumpStr + Cells[0,i+1] + ', ';

          if ListArray[i].IIStruct.TimeSaved > 0 then
          begin
            DateTimeToString(TempStr, 'c', ListArray[i].IIStruct.TimeSaved);
            Cells[1,i+1] := TempStr;
          end
          else
            Cells[1,i+1] := FloatToStr( ListArray[i].IIStruct.TimeSaved );
          DumpStr := DumpStr + Cells[1,i+1] + ', ';

          if ListArray[i].IIStruct.TimeServed > 0 then
          begin
            DateTimeToString(TempStr, 'c', ListArray[i].IIStruct.TimeServed);
            Cells[2,i+1] := TempStr;
          end
          else
            Cells[2,i+1] := FloatToStr( ListArray[i].IIStruct.TimeServed );
            DumpStr := DumpStr + Cells[2,i+1] + ', ';

          case ListArray[i].IIStruct.IPSize of
            0: Cells[3,i+1] := 'SIZE0';
            1: Cells[3,i+1] := 'SIZE1';
            2: Cells[3,i+1] := 'SIZE2';
            3: Cells[3,i+1] := 'SIZE3';
            4: Cells[3,i+1] := 'SIZE4ñ';
            else Cells[3,i+1] := 'None';
          end;

          DumpStr := DumpStr + Cells[3,i+1] + ', ';

          case ListArray[i].IIStruct.Resolution of
            0: Cells[4,i+1] := 'SD';
            1: Cells[4,i+1] := 'HD';
            else Cells[4,i+1] := 'None';
          end;
          DumpStr := DumpStr + Cells[4,i+1] + ', ';

          Cells[5,i+1] := Format( '%x',[ListArray[i].IIStruct.UID]);
          DumpStr := DumpStr + Cells[5,i+1] + ', ';

          Cells[6,i+1] := N_AnsiToString(
                                      AnsiString(@ListArray[i].IIStruct.PID[0]) );
          if AnsiString(@ListArray[i].IIStruct.PID[0]) = '' then
            Cells[6,i+1] := 'None';
          DumpStr := DumpStr + Cells[6,i+1] + ', ';

          N_Dump1Str( 'FireCR - ' + DumpStr ); // save this col in the dump
        end; // with SGImages do
      end; // for i := 0 to 99 do
    end; // with N_CMCDServObj15 do

    // ***** setting up the row
    for i := 0 to 99 do
    begin
      if N_CMCDServObj15.CDSIndexArray[i] = TempIntArray then
      begin
        TempIntArray := i;
        SGImages.Row := TempIntArray + 1;
        Break;
      end;
    end;

    // ***** enabling the buttons
    SpeedButton0.Enabled := True;
    SpeedButton1.Enabled := True;
    SpeedButton2.Enabled := True;
    SpeedButton3.Enabled := True;
  end
  else // the button was already pressed
  begin
    // ***** choosing the button and click it
    SpeedButton2.Visible := False;
    SpeedButton2.Down := False;
    SpeedButton3.Visible := True;
    SpeedButton3.Down := False;
    SpeedButton0.Down := False;
    SpeedButton1.Down := False;
    SpeedButton3.Click;
    SpeedButton3.Down := True;
  end;
  N_Dump1Str( 'End TN_CMCaptDev15aForm.SpeedButton2Click' );
end; // procedure TN_CMCaptDev15aForm.SpeedButton2Click(Sender: TObject);

//********************************** TN_CMCaptDev15aForm.SpeedButton3Click ***
// Button SpeedButton3 click event handler
//
//     Parameters
// Sender - sender object
//
// Sorting the grid
//
procedure TN_CMCaptDev15aForm.SpeedButton3Click(Sender: TObject);
var
  i, j, Count, GridLength: integer;
  Params:           PN_ScannerIntro;
  TempStr, DumpStr: string;
  PNList_i:         PN_ImageIntro;
  ListArray:        array[0..99] of PN_ImageIntro;
  TempImage:        PN_ImageIntro;
  TempInt, TempIntArray: Integer;
  TempAnsiStr1, TempAnsiStr2: AnsiString;
begin
  N_Dump1Str( 'Start TN_CMCaptDev15aForm.SpeedButton3Click' );
  inherited;

  if N_ButtonFlag <> 3 then // if the button wasn't pressed before
  begin
    N_ButtonFlag := 3; // the button is pressed

    // ***** disabling the buttons
    SpeedButton0.Enabled := False;
    SpeedButton1.Enabled := False;
    SpeedButton2.Enabled := False;
    SpeedButton3.Enabled := False;

    // saving the current row
    TempIntArray := SGImages.Row - 1;
    TempIntArray := N_CMCDServObj15.CDSIndexArray[TempIntArray];

    // set grid row widths
    with SGImages do
    begin
      ColWidths[0] := 30;
      ColWidths[1] := 125;
      ColWidths[2] := 125;
      ColWidths[3] := 40;
      ColWidths[4] := 25;
      ColWidths[5] := 105;
      ColWidths[6] := 120;
    end; // with SGImages do

    // ***** the head of the grid
    with SGImages do
    begin
      Cells[0,0] := 'Index';
      Cells[1,0] := 'Saved';
      Cells[2,0] := 'Served';
      Cells[3,0] := 'IP';
      Cells[4,0] := 'Res';
      Cells[5,0] := 'UID';
      Cells[6,0] := 'Patient name';
    end; // with SGImages do

    Count := 0; // index of the sensor
    Params := N_CMECDVDC_RequestScannerList( @Count ); // get parameters of the sensor

    // ***** set grid length
    if Assigned(Params) then
      GridLength := 100 //Params.ImageCount + 2// +1 added by me
    else
      GridLength := 2;

    with N_CMCDServObj15 do
    begin
      N_Dump1Str( 'FireCR - Before RequestImageList' );
      CDSList := N_CMECDVDC_RequestImageList; // request list of images from buffer
      N_Dump1Str( 'FireCR - After RequestImageList' );

      N_Dump1Str( 'FireCR - Length of the request images grid = ' +
                                                         IntToStr(GridLength) );
      SGImages.RowCount := GridLength + 1;

      N_Dump1Str( 'FireCR - List of images before sort:' );
      N_Dump1Str( 'FireCR - Index, TimeSaved, UID' );

      // ***** dump the initial list
      for i := 0 to 99 do
      begin
        PNList_i := CDSList;
        Inc( PNList_i, i );
        ListArray[i] := PNList_i;

        N_Dump1Str( 'FireCR - ' + IntToStr(i) + ', ' +
                          FloatToStr(PNList_i.IIStruct.TimeSaved) + Format( ', %x',
                                                       [PNList_i.IIStruct.UID]) );
      end; // for i := 0 to 99 do

      // ***** set initial (unsort) states for array of indexes
      for i := 0 to 99 do
      begin
        CDSIndexArray[i] := i;
      end; // for i := 0 to 99 do

      // ***** sort list of images by time saved first
      for i := 0 to 99 do
      for j := 0 to 98 - i do
      begin
        if ListArray[j].IIStruct.TimeSaved > ListArray[j+1].IIStruct.TimeSaved then
        begin
          // ***** move images
          TempImage := ListArray[j];
          ListArray[j] := ListArray[j+1];
          ListArray[j+1] := TempImage;

          // ***** move indexes
          TempInt := CDSIndexArray[j];
          CDSIndexArray[j] := CDSIndexArray[j+1];
          CDSIndexArray[j+1] := TempInt;
        end;
      end; // for j := 0 to 98 - i do

      // ***** sort list of images by patient name
      for i := 0 to 99 do
      for j := 0 to 98 - i do
      begin
        // ***** if there is no name
        if ListArray[j].IIStruct.PID <> '' then
          TempAnsiStr1 := ListArray[j].IIStruct.PID
        else
          TempAnsiStr1 := 'None';

        if ListArray[j+1].IIStruct.PID <> '' then
          TempAnsiStr2 := ListArray[j+1].IIStruct.PID
        else
          TempAnsiStr2 := 'None';

        if AnsiCompareStr( N_AnsiToString(TempAnsiStr1),
                                         N_AnsiToString(TempAnsiStr2) ) > 0 then
        begin
          // ***** move images
          TempImage := ListArray[j];
          ListArray[j] := ListArray[j+1];
          ListArray[j+1] := TempImage;

          // ***** move indexes
          TempInt := CDSIndexArray[j];
          CDSIndexArray[j] := CDSIndexArray[j+1];
          CDSIndexArray[j+1] := TempInt;
        end;
      end; // for j := 0 to 98 - i do

      N_Dump1Str( 'FireCR - List of images after sort:' );
      N_Dump1Str(
      'FireCR - Index, TimeSaved, TimeServed, IPSize, Res, UID, Patient name' );

      // ***** fill the grid
      for i := 0 to 99 do
      begin
        with SGImages do
        begin
          DumpStr := ''; // current grid col for the dump initial state

          DumpStr := DumpStr + IntToStr(N_CMCDServObj15.CDSIndexArray[i]);

          Cells[0,i+1] := IntToStr(i);
          DumpStr := DumpStr + Cells[0,i+1] + ', ';

          if ListArray[i].IIStruct.TimeSaved > 0 then
          begin
            DateTimeToString(TempStr, 'c', ListArray[i].IIStruct.TimeSaved);
            Cells[1,i+1] := TempStr;
          end
          else
            Cells[1,i+1] := FloatToStr( ListArray[i].IIStruct.TimeSaved );
          DumpStr := DumpStr + Cells[1,i+1] + ', ';

          if ListArray[i].IIStruct.TimeServed > 0 then
          begin
            DateTimeToString(TempStr, 'c', ListArray[i].IIStruct.TimeServed);
            Cells[2,i+1] := TempStr;
          end
          else
            Cells[2,i+1] := FloatToStr( ListArray[i].IIStruct.TimeServed );
          DumpStr := DumpStr + Cells[2,i+1] + ', ';

          case ListArray[i].IIStruct.IPSize of
            0: Cells[3,i+1] := 'SIZE0';
            1: Cells[3,i+1] := 'SIZE1';
            2: Cells[3,i+1] := 'SIZE2';
            3: Cells[3,i+1] := 'SIZE3';
            4: Cells[3,i+1] := 'SIZE4ñ';
            else Cells[3,i+1] := 'None';
          end;

          DumpStr := DumpStr + Cells[3,i+1] + ', ';

          case ListArray[i].IIStruct.Resolution of
            0: Cells[4,i+1] := 'SD';
            1: Cells[4,i+1] := 'HD';
            else Cells[4,i+1] := 'None';
          end;
          DumpStr := DumpStr + Cells[4,i+1] + ', ';

          Cells[5,i+1] := Format( '%x',[ListArray[i].IIStruct.UID]);
          DumpStr := DumpStr + Cells[5,i+1] + ', ';

          Cells[6,i+1] := N_AnsiToString(
                                      AnsiString(@ListArray[i].IIStruct.PID[0]) );
          if AnsiString(@ListArray[i].IIStruct.PID[0]) = '' then
            Cells[6,i+1] := 'None';
          DumpStr := DumpStr + Cells[6,i+1] + ', ';

          N_Dump1Str( 'FireCR - ' + DumpStr ); // save this col in the dump
        end; // with SGImages do
      end; // for i := 0 to 99 do
    end; // with N_CMCDServObj15 do

    // ***** setting up new row
    for i := 0 to 99 do
    begin
      if N_CMCDServObj15.CDSIndexArray[i] = TempIntArray then
      begin
        TempIntArray := i;
        SGImages.Row := TempIntArray + 1;
        Break;
      end;
    end;

    // ***** enabling after processing
    SpeedButton0.Enabled := True;
    SpeedButton1.Enabled := True;
    SpeedButton2.Enabled := True;
    SpeedButton3.Enabled := True;
  end
  else
  begin
    // ***** choosing the right button and click it
    SpeedButton3.Visible := False;
    SpeedButton3.Down := False;
    SpeedButton2.Visible := True;
    SpeedButton2.Down := False;
    SpeedButton0.Down := False;
    SpeedButton1.Down := False;
    SpeedButton2.Click;
    SpeedButton2.Down := True;
  end;
  N_Dump1Str( 'Start TN_CMCaptDev15aForm.SpeedButton3Click' );
end; // procedure TN_CMCaptDev15aForm.SpeedButton3Click(Sender: TObject);

//******************************************* TN_CMCaptDev15aForm.FormClose ***
// FormClose event handler
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev15aForm.FormClose(Sender: TObject;
                                                      var Action: TCloseAction);
begin
  N_Dump1Str( 'Start TN_CMCaptDev15aForm.FormClose' );
  inherited;
  N_FlagBuf := True; // buffer capture is closed

  if N_ImagesSaved[SGImages.Row - 1] = False then // NewSlide was not added (saved)
  begin
    N_NewSlide.UDDelete();
    N_NewSlide := Nil;
  end
  else // NewSlide was added (saved)
    N_NewSlide := Nil;
  N_Dump1Str( 'End TN_CMCaptDev15aForm.FormClose' );
end; // procedure TN_CMCaptDev15aForm.FormClose(Sender: TObject; var Action: TCloseAction);

//****************************************** TN_CMCaptDev15aForm.FormCreate ***
// FormCreate event handler
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev15aForm.FormCreate( Sender: TObject );
var
  i, j, Count, GridLength: integer;
  Params:           PN_ScannerIntro;
  TempStr, DumpStr: string;
  PNList_i:         PN_ImageIntro;
  ListArray:        array[0..99] of PN_ImageIntro;
  TempImage:        PN_ImageIntro;
  TempInt:          Integer;
begin
  N_Dump1Str( 'Start TN_CMCaptDev15aForm.FormCreate' );
  inherited;

  N_NewSlide := Nil;

  N_RowPressed := -1;
  //PreviewPressed := False;

  for i := 0 to 99 do
    N_ImagesSaved[i] := False; // none of the images was saved yet

  N_ButtonFlag := 0;

  // set grid row widths
  with SGImages do
  begin
    ColWidths[0] := 30;
    ColWidths[1] := 125;
    ColWidths[2] := 125;
    ColWidths[3] := 40;
    ColWidths[4] := 25;
    ColWidths[5] := 105;
    ColWidths[6] := 120;
  end; // with SGImages do

  // ***** the head of the grid
  with SGImages do
  begin
    Cells[0,0] := 'Index';
    Cells[1,0] := 'Saved';
    Cells[2,0] := 'Served';
    Cells[3,0] := 'IP';
    Cells[4,0] := 'Res';
    Cells[5,0] := 'UID';
    Cells[6,0] := 'Patient name';
  end; // with SGImages do

  Count := 0; // index of the sensor
  Params := N_CMECDVDC_RequestScannerList( @Count ); // get parameters of the sensor

  // ***** set grid length
  if Assigned(Params) then
    GridLength := 100 //Params.ImageCount + 2// +1 added by me
  else
    GridLength := 2;

  with N_CMCDServObj15 do
  begin
    N_Dump1Str( 'FireCR - Before RequestImageList' );
    CDSList := N_CMECDVDC_RequestImageList; // request list of images from buffer
    N_Dump1Str( 'FireCR - After RequestImageList' );

    N_Dump1Str( 'FireCR - Length of the request images grid = ' +
                                                         IntToStr(GridLength) );
    SGImages.RowCount := GridLength + 1;

    N_Dump1Str( 'FireCR - List of images before sort:' );
    N_Dump1Str( 'FireCR - Index, TimeSaved, UID' );

    // ***** dump the initial list
    for i := 0 to 99 do
    begin
      PNList_i := CDSList;
      Inc( PNList_i, i );
      ListArray[i] := PNList_i;

      N_Dump1Str( 'FireCR - ' + IntToStr(i) + ', ' +
                          FloatToStr(PNList_i.IIStruct.TimeSaved) + Format( ', %x',
                                                       [PNList_i.IIStruct.UID]) );
    end; // for i := 0 to 99 do

    // ***** set initial (unsort) states for array of indexes
    for i := 0 to 99 do
    begin
      CDSIndexArray[i] := i;
    end; // for i := 0 to 99 do

    // ***** sort list of images by time saved
    for i := 0 to 99 do
    for j := 0 to 98 - i do
    begin
      if ListArray[j].IIStruct.TimeSaved < ListArray[j+1].IIStruct.TimeSaved then
      begin
        // ***** move images
        TempImage := ListArray[j];
        ListArray[j] := ListArray[j+1];
        ListArray[j+1] := TempImage;

       // ***** move indexes
        TempInt := CDSIndexArray[j];
        CDSIndexArray[j] := CDSIndexArray[j+1];
        CDSIndexArray[j+1] := TempInt;
      end;
    end; // for j := 0 to 98 - i do
    N_Dump1Str( 'FireCR - List of images after sort:' );
    N_Dump1Str(
      'FireCR - Index, TimeSaved, TimeServed, IPSize, Res, UID, Patient name' );

    // ***** fill the grid
    for i := 0 to 99 do
    begin
      with SGImages do
      begin
        DumpStr := ''; // current grid col for the dump initial state

        DumpStr := DumpStr + IntToStr(N_CMCDServObj15.CDSIndexArray[i]);

        Cells[0,i+1] := IntToStr(i);
        DumpStr := DumpStr + Cells[0,i+1] + ', ';

        if ListArray[i].IIStruct.TimeSaved > 0 then
        begin
          DateTimeToString(TempStr, 'c', ListArray[i].IIStruct.TimeSaved);
          Cells[1,i+1] := TempStr;
        end
        else
          Cells[1,i+1] := FloatToStr( ListArray[i].IIStruct.TimeSaved );
        DumpStr := DumpStr + Cells[1,i+1] + ', ';

        if ListArray[i].IIStruct.TimeServed > 0 then
        begin
          DateTimeToString(TempStr, 'c', ListArray[i].IIStruct.TimeServed);
          Cells[2,i+1] := TempStr;
        end
        else
          Cells[2,i+1] := FloatToStr( ListArray[i].IIStruct.TimeServed );
        DumpStr := DumpStr + Cells[2,i+1] + ', ';

        case ListArray[i].IIStruct.IPSize of
          0: Cells[3,i+1] := 'SIZE0';
          1: Cells[3,i+1] := 'SIZE1';
          2: Cells[3,i+1] := 'SIZE2';
          3: Cells[3,i+1] := 'SIZE3';
          4: Cells[3,i+1] := 'SIZE4ñ';
          else Cells[3,i+1] := 'None';
        end;

        DumpStr := DumpStr + Cells[3,i+1] + ', ';

        case ListArray[i].IIStruct.Resolution of
          0: Cells[4,i+1] := 'SD';
          1: Cells[4,i+1] := 'HD';
          else Cells[4,i+1] := 'None';
        end;
        DumpStr := DumpStr + Cells[4,i+1] + ', ';

        Cells[5,i+1] := Format( '%x',[ListArray[i].IIStruct.UID]);
        DumpStr := DumpStr + Cells[5,i+1] + ', ';

        Cells[6,i+1] := N_AnsiToString(AnsiString(@ListArray[i].IIStruct.PID[0]));
        if AnsiString(@ListArray[i].IIStruct.PID[0]) = '' then
          Cells[6,i+1] := 'None';
        DumpStr := DumpStr + Cells[6,i+1] + ', ';

        N_Dump1Str( 'FireCR - ' + DumpStr ); // save this col in the dump
      end; // with SGImages do
    end; // for i := 0 to 99 do
  end; // with N_CMCDServObj15 do

  SGImages.Row := 1; // select the first row
  N_FlagBuf := False;
  N_Dump1Str( 'End TN_CMCaptDev15aForm.FormCreate' );
end;

//******************************************** TN_CMCaptDev15aForm.FormShow ***
// Form show action
//
//     Parameters
// Sender - sender object
//
procedure TN_CMCaptDev15aForm.FormShow(Sender: TObject);
var
  DIB:              TN_DIBObj;
  RootComp:         TN_UDCompVis;
begin
  N_Dump1Str( 'Start TN_CMCaptDev15aForm.FormShow' );
  inherited;
  DIB := TN_DIBObj.Create( 164, 124, pfCustom, ColorToRGB(clBtnFace),
                                                                     epfGray8 );
  N_NewSlide := K_CMSlideCreateFromDIBObj( DIB,
                           @(CMOFParentForm.CMOFPProfile^.CMAutoImgProcAttrs) );
  RootComp := N_NewSlide.GetMapRoot();

  with NewRFrame do
  begin
    RFCenterInDst := true;
    RVCTFrInit3( RootComp );
    RVCTreeRootOwner := false;
    aFitInWindowExecute( nil ); // already previewed
  end;
  N_Dump1Str( 'End TN_CMCaptDev15aForm.FormShow' );
end; // procedure TN_CMCaptDev15aForm.FormShow

//***************************************** TN_CMCaptDev15aForm.Timer1Timer ***
// Timer1Timer event handler
//
//     Parameters
// Sender - sender object
//
// Seeking if the image is captured, also progress bar
//
procedure TN_CMCaptDev15aForm.Timer1Timer(Sender: TObject);
var
  RootComp: TN_UDCompVis;
begin
  N_Dump1Str( 'Start TN_CMCaptDev15aForm.Timer1Timer' );
  inherited;
  Timer1.Enabled := False;

  if ( N_ImagesSaved[SGImages.Row - 1] = True ) or
                                          ( N_RowPressed = SGImages.Row-1 ) then
    bnRecoverImage.Enabled := False
  else
    bnRecoverImage.Enabled := True;

  if N_NewSlide = Nil then // if the image is already captured
    bnSave.Enabled := False
  else
  begin
    bnSave.Enabled := True;
  end;

  ProgressBarSecond.Position := N_TempProgress; // setting the progress bar

  // ***** preview the image
  if N_FlagGot then
  begin
   if N_NewSlide <> Nil then
   begin
     RootComp := N_NewSlide.GetMapRoot();

      with NewRFrame do
      begin
        RFCenterInDst := true;
        RVCTFrInit3( RootComp );
        RVCTreeRootOwner := false;
        aFitInWindowExecute( nil );
        N_FlagGot := False; // already previewed
      end;

    end;
  end;

  Timer1.Enabled := True;
  N_Dump1Str( 'End TN_CMCaptDev15aForm.Timer1Timer' );
end; // procedure TN_CMCaptDev15aForm.Timer1Timer(Sender: TObject);
end.
