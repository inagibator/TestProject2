inherited K_FormCMPrint: TK_FormCMPrint
  Left = 64
  Top = 21
  Width = 935
  Height = 734
  Caption = 'Print'
  KeyPreview = True
  OldCreateOrder = True
  OnCloseQuery = FormCloseQuery
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 906
    Top = 683
    TabOrder = 2
  end
  object PnPreview: TPanel
    Left = 265
    Top = 0
    Width = 654
    Height = 695
    Align = alClient
    BevelOuter = bvNone
    Caption = 'PnPreview'
    TabOrder = 0
    object PnPageScroll: TPanel
      Left = 0
      Top = 0
      Width = 654
      Height = 33
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
      object LbSlideScale: TLabel
        Left = 169
        Top = 10
        Width = 60
        Height = 13
        Caption = 'Scale:  1 to  '
        Visible = False
      end
      object PnPageScroll0: TPanel
        Left = 287
        Top = 5
        Width = 191
        Height = 24
        BevelOuter = bvNone
        TabOrder = 6
        DesignSize = (
          191
          24)
        object LbPageNum: TLabel
          Left = 61
          Top = 6
          Width = 66
          Height = 13
          Alignment = taCenter
          Caption = '_age 00 of 00'
        end
        object BBPageFirst: TBitBtn
          Left = 1
          Top = 2
          Width = 21
          Height = 19
          Caption = '| <'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
          OnClick = BBPageFirstClick
        end
        object BBPageLast: TBitBtn
          Left = 165
          Top = 2
          Width = 21
          Height = 19
          Anchors = [akTop, akRight]
          Caption = '> |'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
          TabOrder = 3
          OnClick = BBPageLastClick
        end
        object BBPageNext: TBitBtn
          Left = 140
          Top = 2
          Width = 21
          Height = 19
          Anchors = [akTop, akRight]
          Caption = '>'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
          TabOrder = 2
          OnClick = BBPageNextClick
          Layout = blGlyphBottom
        end
        object BBPagePrev: TBitBtn
          Left = 25
          Top = 2
          Width = 21
          Height = 19
          Caption = '<'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
          OnClick = BBPagePrevClick
        end
      end
      object TBPageView: TToolBar
        Left = 4
        Top = 2
        Width = 27
        Height = 27
        Align = alNone
        ButtonHeight = 24
        ButtonWidth = 25
        Caption = 'TBPageView'
        EdgeInner = esNone
        EdgeOuter = esNone
        Images = N_CMResForm.MainIcons18
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        TabStop = True
        object TBZoomIn: TToolButton
          Left = 0
          Top = 2
          Hint = 'Zoom In (+)'
          Action = RFrame.aZoomIn
          ImageIndex = 61
        end
      end
      object TBSlideScale: TToolBar
        Left = 96
        Top = 2
        Width = 27
        Height = 27
        Align = alNone
        ButtonHeight = 24
        ButtonWidth = 25
        Caption = 'TBSlideScale'
        EdgeInner = esNone
        EdgeOuter = esNone
        Images = N_CMResForm.MainIcons18
        ParentShowHint = False
        ShowHint = True
        TabOrder = 3
        TabStop = True
        object TBSlideFitToView: TToolButton
          Left = 0
          Top = 2
          Hint = 'Fit to Page'
          Caption = 'Fit to Page'
          Grouped = True
          ImageIndex = 63
          Style = tbsCheck
          Visible = False
          OnClick = TBSlideFixZoomClick
        end
      end
      object CmBSlideScale_7: TComboBox
        Left = 228
        Top = 7
        Width = 46
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        ItemIndex = 1
        TabOrder = 5
        Text = '1.0'
        Visible = False
        OnChange = CmBSlideScale_7Change
        Items.Strings = (
          '0.5'
          '1.0'
          '1.5'
          '2.0'
          '2.5')
      end
      object TBSlideScale1: TToolBar
        Left = 123
        Top = 2
        Width = 27
        Height = 27
        Align = alNone
        ButtonHeight = 24
        ButtonWidth = 25
        Caption = 'TBSlideScale'
        EdgeInner = esNone
        EdgeOuter = esNone
        Images = N_CMResForm.MainIcons18
        ParentShowHint = False
        ShowHint = True
        TabOrder = 4
        TabStop = True
        object TBSlideFixZoom1: TToolButton
          Left = 0
          Top = 2
          Hint = 'Restore to Actual Size'
          Caption = 'Restore to Actual Size'
          ImageIndex = 64
          Style = tbsCheck
          Visible = False
          OnClick = TBSlideFixZoomClick
        end
      end
      object TBPageView1: TToolBar
        Left = 31
        Top = 2
        Width = 28
        Height = 27
        Align = alNone
        ButtonHeight = 24
        ButtonWidth = 25
        Caption = 'TBPageView'
        EdgeInner = esNone
        EdgeOuter = esNone
        Images = N_CMResForm.MainIcons18
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        TabStop = True
        object TBZoomOut1: TToolButton
          Left = 0
          Top = 2
          Hint = 'Zoom Out (-)'
          Action = RFrame.aZoomOut
          ImageIndex = 60
        end
      end
      object TBPageView2: TToolBar
        Left = 58
        Top = 2
        Width = 27
        Height = 27
        Align = alNone
        ButtonHeight = 24
        ButtonWidth = 25
        Caption = 'TBPageView'
        EdgeInner = esNone
        EdgeOuter = esNone
        Images = N_CMResForm.MainIcons18
        ParentShowHint = False
        ShowHint = True
        TabOrder = 2
        TabStop = True
        object TBFitInWindow1: TToolButton
          Left = 0
          Top = 2
          Hint = 'Reset Zoom'
          Action = RFrame.aFitInWindow
          Caption = 'Reset Zoom'
          ImageIndex = 62
        end
      end
    end
    inline RFrame: TN_Rast1Frame
      Left = 0
      Top = 41
      Width = 654
      Height = 654
      HelpType = htKeyword
      Align = alBottom
      Anchors = [akLeft, akTop, akRight, akBottom]
      Constraints.MinHeight = 104
      Constraints.MinWidth = 78
      Color = clBtnFace
      ParentColor = False
      TabOrder = 1
      inherited PaintBox: TPaintBox
        Width = 638
        Height = 638
      end
      inherited HScrollBar: TScrollBar
        Top = 638
        Width = 654
      end
      inherited VScrollBar: TScrollBar
        Left = 638
        Height = 638
      end
    end
  end
  object SBControls: TScrollBox
    Left = 0
    Top = 0
    Width = 265
    Height = 695
    VertScrollBar.Position = 35
    Align = alLeft
    BorderStyle = bsNone
    TabOrder = 1
    object PnControls: TPanel
      Left = 0
      Top = -35
      Width = 257
      Height = 713
      BevelOuter = bvNone
      TabOrder = 0
      DesignSize = (
        257
        713)
      object GBPrinter: TGroupBox
        Left = 8
        Top = 222
        Width = 249
        Height = 234
        Caption = '  Printer  '
        Font.Charset = DEFAULT_CHARSET
        Font.Color = cl3DDkShadow
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 4
        object LbPaperSize: TLabel
          Left = 50
          Top = 43
          Width = 168
          Height = 13
          Caption = '_aper (width, height): 216 x 279 mm'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
        end
        object UDCopyCount: TUpDown
          Left = 170
          Top = 203
          Width = 16
          Height = 21
          Associate = EdCopyCount
          Min = 1
          Position = 1
          TabOrder = 4
          OnChanging = UDINumChanging
        end
        object BBPrinterSetUp: TBitBtn
          Left = 84
          Top = 63
          Width = 118
          Height = 25
          Caption = 'Printer &Setup'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
          OnClick = BBPrinterSetUpClick
          Glyph.Data = {
            46050000424D4605000000000000360000002800000012000000120000000100
            2000000000001005000000000000000000000000000000000000FF00FF00FF00
            FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
            FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
            FF00FF00FF00FF00FF0000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000FF00FF00FF00
            FF00FF00FF00FF00FF00FF00FF000000000099A8AC0099A8AC0099A8AC0099A8
            AC0099A8AC0099A8AC0099A8AC0099A8AC0099A8AC0099A8AC0099A8AC0099A8
            AC0000000000FF00FF00FF00FF00FF00FF00FF00FF0000000000D8E9EC00D8E9
            EC00D8E9EC00D8E9EC00D8E9EC00D8E9EC00D8E9EC00D8E9EC00D8E9EC00D8E9
            EC00D8E9EC00D8E9EC0099A8AC0000000000FF00FF00FF00FF00FF00FF000000
            00000000FF000000FF00D8E9EC00D8E9EC00D8E9EC00D8E9EC00D8E9EC00D8E9
            EC00D8E9EC00D8E9EC00D8E9EC00D8E9EC0099A8AC0099A8AC0000000000FF00
            FF00FF00FF0000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
            FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0099A8AC0099A8
            AC0000000000FF00FF00FF00FF0000000000D8E9EC00D8E9EC00D8E9EC00D8E9
            EC00D8E9EC00D8E9EC00D8E9EC00D8E9EC00D8E9EC00D8E9EC0099A8AC0099A8
            AC00FFFFFF0099A8AC0000000000FF00FF00FF00FF00FF00FF0000000000D8E9
            EC0099A8AC0099A8AC0099A8AC0099A8AC0099A8AC0099A8AC0099A8AC0099A8
            AC0099A8AC0099A8AC0099A8AC00FFFFFF0000000000FF00FF00FF00FF00FF00
            FF00FF00FF000000000000000000000000000000000000000000000000000000
            0000000000000000000000000000000000000000000000000000FF00FF00FF00
            FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
            FF00FF00FF00FF00FF00FF00FF00FF00FF0080800000FFFF0000FFFF0000FFFF
            000000000000FF00FF00FF00FF00FF00FF00FF00FF0000000000000000000000
            0000000000000000000000000000000000000000000000000000FFFF00008080
            00000000000000000000FF00FF00FF00FF00FF00FF00FF00FF0000000000FFFF
            000080800000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF
            0000FFFF000000000000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
            FF00FF00FF000000000000000000000000000000000000000000000000000000
            00000000000000000000FFFF0000808000000000000000000000FF00FF00FF00
            FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
            FF00FF00FF00FF00FF00FF00FF00FF00FF0080800000FFFF0000FFFF0000FFFF
            000000000000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
            FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF000000
            00000000000000000000FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
            FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
            FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
            FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
            FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
            FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
            FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00
            FF00FF00FF00FF00FF00}
        end
        object EdCopyCount: TLabeledEdit
          Left = 147
          Top = 203
          Width = 23
          Height = 21
          BiDiMode = bdRightToLeft
          Color = 10682367
          EditLabel.Width = 89
          EditLabel.Height = 13
          EditLabel.BiDiMode = bdRightToLeft
          EditLabel.Caption = 'Number of copies  '
          EditLabel.Font.Charset = DEFAULT_CHARSET
          EditLabel.Font.Color = clWindowText
          EditLabel.Font.Height = -11
          EditLabel.Font.Name = 'MS Sans Serif'
          EditLabel.Font.Style = []
          EditLabel.ParentBiDiMode = False
          EditLabel.ParentFont = False
          EditLabel.Layout = tlCenter
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          LabelPosition = lpLeft
          ParentBiDiMode = False
          ParentFont = False
          TabOrder = 3
          Text = '1'
          OnExit = EdCopyCountExit
          OnKeyDown = EdKeyDown
        end
        object EdPrinterName: TLabeledEdit
          Left = 66
          Top = 16
          Width = 177
          Height = 21
          Hint = 'Printer name'
          TabStop = False
          Color = clBtnFace
          EditLabel.Width = 49
          EditLabel.Height = 13
          EditLabel.Caption = 'Name:      '
          EditLabel.Font.Charset = DEFAULT_CHARSET
          EditLabel.Font.Color = clWindowText
          EditLabel.Font.Height = -11
          EditLabel.Font.Name = 'MS Sans Serif'
          EditLabel.Font.Style = []
          EditLabel.ParentFont = False
          EditLabel.Layout = tlCenter
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          LabelPosition = lpLeft
          ParentFont = False
          ParentShowHint = False
          ReadOnly = True
          ShowHint = True
          TabOrder = 5
        end
        object GBPrintRange: TGroupBox
          Left = 8
          Top = 135
          Width = 233
          Height = 62
          Caption = '  Print Range  '
          TabOrder = 2
          object RBPageAll: TRadioButton
            Left = 23
            Top = 15
            Width = 48
            Height = 17
            Caption = 'All'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            ParentFont = False
            TabOrder = 0
            OnClick = RBPageAllClick
          end
          object RBPageRange: TRadioButton
            Left = 23
            Top = 35
            Width = 72
            Height = 17
            Caption = 'Pages'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            ParentFont = False
            TabOrder = 1
            OnClick = RBPageRangeClick
          end
          object EdBegPage: TLabeledEdit
            Left = 128
            Top = 32
            Width = 31
            Height = 21
            Color = 10682367
            EditLabel.Width = 23
            EditLabel.Height = 13
            EditLabel.Caption = 'from '
            EditLabel.Font.Charset = DEFAULT_CHARSET
            EditLabel.Font.Color = clWindowText
            EditLabel.Font.Height = -11
            EditLabel.Font.Name = 'MS Sans Serif'
            EditLabel.Font.Style = []
            EditLabel.ParentFont = False
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            LabelPosition = lpLeft
            ParentFont = False
            TabOrder = 2
            OnChange = EdINumChange
            OnEnter = EdBegPageEnter
            OnExit = EdINumExit
            OnKeyDown = EdKeyDown
          end
          object EdEndPage: TLabeledEdit
            Left = 186
            Top = 32
            Width = 31
            Height = 21
            Color = 10682367
            EditLabel.Width = 12
            EditLabel.Height = 13
            EditLabel.Caption = 'to '
            EditLabel.Font.Charset = DEFAULT_CHARSET
            EditLabel.Font.Color = clWindowText
            EditLabel.Font.Height = -11
            EditLabel.Font.Name = 'MS Sans Serif'
            EditLabel.Font.Style = []
            EditLabel.ParentFont = False
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            LabelPosition = lpLeft
            ParentFont = False
            TabOrder = 3
            OnChange = EdINumChange
            OnEnter = EdEndPageEnter
            OnExit = EdINumExit
            OnKeyDown = EdKeyDown
          end
        end
        object GBPageOrientation: TGroupBox
          Left = 8
          Top = 93
          Width = 233
          Height = 38
          Caption = '  Orientation  '
          TabOrder = 1
          object RBPortrait: TRadioButton
            Left = 31
            Top = 14
            Width = 67
            Height = 17
            Caption = 'Portrait'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            ParentFont = False
            TabOrder = 0
            OnClick = RBPortraitClick
          end
          object RBLandscape: TRadioButton
            Left = 128
            Top = 14
            Width = 83
            Height = 17
            Caption = 'Landscape'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            ParentFont = False
            TabOrder = 1
            OnClick = RBLandscapeClick
          end
        end
      end
      object GBPageMargins: TGroupBox
        Left = 8
        Top = 81
        Width = 249
        Height = 138
        Caption = '  Page Margins in mm    '
        Font.Charset = DEFAULT_CHARSET
        Font.Color = cl3DDkShadow
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 3
        object EdMarginTop: TLabeledEdit
          Left = 97
          Top = 16
          Width = 41
          Height = 21
          Color = 10682367
          EditLabel.Width = 25
          EditLabel.Height = 13
          EditLabel.Caption = 'Top  '
          EditLabel.Font.Charset = DEFAULT_CHARSET
          EditLabel.Font.Color = clWindowText
          EditLabel.Font.Height = -11
          EditLabel.Font.Name = 'MS Sans Serif'
          EditLabel.Font.Style = []
          EditLabel.ParentFont = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          LabelPosition = lpLeft
          ParentFont = False
          TabOrder = 0
          Text = '0'
          OnChange = EdFNumChange
          OnEnter = EdFNumEnter
          OnExit = EdFNumExit
          OnKeyDown = EdKeyDown
        end
        object EdMarginBottom: TLabeledEdit
          Left = 98
          Top = 76
          Width = 41
          Height = 21
          Color = 10682367
          EditLabel.Width = 39
          EditLabel.Height = 13
          EditLabel.Caption = 'Bottom  '
          EditLabel.Font.Charset = DEFAULT_CHARSET
          EditLabel.Font.Color = clWindowText
          EditLabel.Font.Height = -11
          EditLabel.Font.Name = 'MS Sans Serif'
          EditLabel.Font.Style = []
          EditLabel.ParentFont = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          LabelPosition = lpLeft
          ParentFont = False
          TabOrder = 3
          Text = '0'
          OnChange = EdFNumChange
          OnEnter = EdFNumEnter
          OnExit = EdFNumExit
          OnKeyDown = EdKeyDown
        end
        object EdMarginLeft: TLabeledEdit
          Left = 49
          Top = 46
          Width = 41
          Height = 21
          Color = 10682367
          EditLabel.Width = 24
          EditLabel.Height = 13
          EditLabel.Caption = 'Left  '
          EditLabel.Font.Charset = DEFAULT_CHARSET
          EditLabel.Font.Color = clWindowText
          EditLabel.Font.Height = -11
          EditLabel.Font.Name = 'MS Sans Serif'
          EditLabel.Font.Style = []
          EditLabel.ParentFont = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          LabelPosition = lpLeft
          ParentFont = False
          TabOrder = 1
          Text = '0'
          OnChange = EdFNumChange
          OnEnter = EdFNumEnter
          OnExit = EdFNumExit
          OnKeyDown = EdKeyDown
        end
        object EdMarginRight: TLabeledEdit
          Left = 143
          Top = 46
          Width = 41
          Height = 21
          Color = 10682367
          EditLabel.Width = 46
          EditLabel.Height = 13
          EditLabel.Caption = '       Right'
          EditLabel.Font.Charset = DEFAULT_CHARSET
          EditLabel.Font.Color = clWindowText
          EditLabel.Font.Height = -11
          EditLabel.Font.Name = 'MS Sans Serif'
          EditLabel.Font.Style = []
          EditLabel.ParentFont = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          LabelPosition = lpRight
          ParentFont = False
          TabOrder = 2
          Text = '0'
          OnChange = EdFNumChange
          OnEnter = EdFNumEnter
          OnExit = EdFNumExit
          OnKeyDown = EdKeyDown
        end
        object UDMarginRight: TUpDown
          Left = 184
          Top = 46
          Width = 17
          Height = 21
          Max = 10000
          TabOrder = 7
          OnChanging = UDFNumChanging
          OnClick = UDFNumClick
          OnEnter = UDMarginsEnter
        end
        object UDMarginLeft: TUpDown
          Left = 90
          Top = 46
          Width = 17
          Height = 21
          Max = 10000
          TabOrder = 6
          OnChanging = UDFNumChanging
          OnClick = UDFNumClick
          OnEnter = UDMarginsEnter
        end
        object UDMarginTop: TUpDown
          Left = 138
          Top = 16
          Width = 17
          Height = 21
          Max = 10000
          TabOrder = 5
          OnChanging = UDFNumChanging
          OnClick = UDFNumClick
          OnEnter = UDMarginsEnter
        end
        object UDMarginBottom: TUpDown
          Left = 139
          Top = 76
          Width = 17
          Height = 21
          Max = 10000
          TabOrder = 8
          OnChanging = UDFNumChanging
          OnClick = UDFNumClick
          OnEnter = UDMarginsEnter
        end
        object ChBtSetMinMargins: TCheckBox
          Left = 17
          Top = 110
          Width = 217
          Height = 17
          BiDiMode = bdLeftToRight
          Caption = 'Set Minimal Margins'
          Color = clBtnFace
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentBiDiMode = False
          ParentColor = False
          ParentFont = False
          TabOrder = 4
          OnClick = ChBtSetMinMarginsClick
        end
      end
      object GBPageLayout: TGroupBox
        Left = 8
        Top = 0
        Width = 249
        Height = 79
        Anchors = [akLeft, akTop, akRight]
        Caption = '  Page Layout  '
        Font.Charset = DEFAULT_CHARSET
        Font.Color = cl3DDkShadow
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 2
        object EdColCount: TLabeledEdit
          Left = 62
          Top = 17
          Width = 25
          Height = 21
          Color = 10682367
          EditLabel.Width = 46
          EditLabel.Height = 13
          EditLabel.Caption = 'Columns  '
          EditLabel.Font.Charset = DEFAULT_CHARSET
          EditLabel.Font.Color = clWindowText
          EditLabel.Font.Height = -11
          EditLabel.Font.Name = 'MS Sans Serif'
          EditLabel.Font.Style = []
          EditLabel.ParentFont = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          LabelPosition = lpLeft
          ParentFont = False
          ReadOnly = True
          TabOrder = 0
          Text = '1'
        end
        object UDColCount: TUpDown
          Left = 87
          Top = 17
          Width = 16
          Height = 21
          Associate = EdColCount
          Min = 1
          Max = 10
          Position = 1
          TabOrder = 4
          OnClick = UDPageLayoutClick
        end
        object EdRowCount: TLabeledEdit
          Left = 62
          Top = 47
          Width = 25
          Height = 21
          Color = 10682367
          EditLabel.Width = 36
          EditLabel.Height = 13
          EditLabel.Caption = 'Rows   '
          EditLabel.Font.Charset = DEFAULT_CHARSET
          EditLabel.Font.Color = clWindowText
          EditLabel.Font.Height = -11
          EditLabel.Font.Name = 'MS Sans Serif'
          EditLabel.Font.Style = []
          EditLabel.ParentFont = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          LabelPosition = lpLeft
          ParentFont = False
          ReadOnly = True
          TabOrder = 1
          Text = '1'
        end
        object UDRowCount: TUpDown
          Left = 87
          Top = 47
          Width = 16
          Height = 21
          Associate = EdRowCount
          Min = 1
          Max = 10
          ParentShowHint = False
          Position = 1
          ShowHint = True
          TabOrder = 5
          OnClick = UDPageLayoutClick
        end
        object ChBHCenter: TCheckBox
          Left = 126
          Top = 19
          Width = 108
          Height = 17
          Caption = 'Center Horizontally'
          Color = clBtnFace
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentColor = False
          ParentFont = False
          TabOrder = 2
          OnClick = ChBImgDetailsClick
        end
        object ChBVCenter: TCheckBox
          Left = 126
          Top = 50
          Width = 108
          Height = 17
          Caption = 'Center Vertically'
          Color = clBtnFace
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentColor = False
          ParentFont = False
          TabOrder = 3
          OnClick = ChBImgDetailsClick
        end
      end
      object BtCancel: TButton
        Left = 155
        Top = 686
        Width = 65
        Height = 21
        Caption = '&Cancel'
        ModalResult = 2
        TabOrder = 0
      end
      object BtPrint: TButton
        Left = 59
        Top = 686
        Width = 65
        Height = 21
        Caption = '&Print'
        TabOrder = 1
        OnClick = BtPrintClick
      end
      object GBData: TGroupBox
        Left = 8
        Top = 460
        Width = 249
        Height = 213
        Anchors = [akLeft, akTop, akRight]
        Caption = '  Data  '
        Font.Charset = DEFAULT_CHARSET
        Font.Color = cl3DDkShadow
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 5
        DesignSize = (
          249
          213)
        object GBHeader: TGroupBox
          Left = 8
          Top = 16
          Width = 233
          Height = 113
          Anchors = [akLeft, akTop, akRight]
          Caption = '  Page Header  '
          TabOrder = 0
          object EdReportTitle: TLabeledEdit
            Left = 56
            Top = 80
            Width = 167
            Height = 21
            Color = 10682367
            EditLabel.Width = 47
            EditLabel.Height = 13
            EditLabel.Caption = 'Title:        '
            EditLabel.Font.Charset = DEFAULT_CHARSET
            EditLabel.Font.Color = clWindowText
            EditLabel.Font.Height = -11
            EditLabel.Font.Name = 'MS Sans Serif'
            EditLabel.Font.Style = []
            EditLabel.ParentFont = False
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            LabelPosition = lpLeft
            ParentFont = False
            TabOrder = 0
            OnKeyDown = EdReportTitleKeyDown
          end
          object ChBProvDetails: TCheckBox
            Left = 8
            Top = 56
            Width = 218
            Height = 17
            Caption = 'Provider Details'
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 1
            OnClick = ChBPatDetailsClick
          end
          object ChBPatDetails: TCheckBox
            Left = 8
            Top = 36
            Width = 216
            Height = 17
            Caption = 'Patient Details'
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 2
            OnClick = ChBPatDetailsClick
          end
          object ChBPrintPageHeader: TCheckBox
            Left = 8
            Top = 16
            Width = 216
            Height = 16
            Caption = 'Page header on each page'
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 3
            OnClick = ChBImgDetailsClick
          end
        end
        object GBPageFooter: TGroupBox
          Left = 8
          Top = 160
          Width = 233
          Height = 41
          Anchors = [akLeft, akTop, akRight]
          Caption = '  Page Footer  '
          TabOrder = 1
          object ChBPrintPageNumber: TCheckBox
            Left = 8
            Top = 16
            Width = 216
            Height = 16
            Caption = 'Print page number'
            Color = clBtnFace
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            TabOrder = 0
            OnClick = ChBImgDetailsClick
          end
        end
        object ChBImgDetails: TCheckBox
          Left = 16
          Top = 138
          Width = 216
          Height = 16
          Caption = 'Image Details'
          Color = clBtnFace
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentColor = False
          ParentFont = False
          TabOrder = 2
          OnClick = ChBImgDetailsClick
        end
      end
    end
  end
  object PrinterSetupDialog: TPrinterSetupDialog
    OnClose = PrinterSetupDialogClose
    Left = 278
    Top = 439
  end
  object TimerMin: TTimer
    Enabled = False
    Interval = 100
    OnTimer = TimerMinTimer
    Left = 310
    Top = 439
  end
  object TimerMax: TTimer
    Enabled = False
    Interval = 3000
    OnTimer = TimerMaxTimer
    Left = 342
    Top = 439
  end
  object StartDragTimer: TTimer
    Enabled = False
    Interval = 75
    OnTimer = StartDragTimerTimer
    Left = 373
    Top = 439
  end
end
