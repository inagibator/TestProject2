object N_RFrameOptionsForm: TN_RFrameOptionsForm
  Left = 271
  Top = 194
  Width = 304
  Height = 234
  Caption = 'Raster Frame Info'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  OnClose = FormClose
  DesignSize = (
    296
    207)
  PixelsPerInch = 96
  TextHeight = 13
  object bnApply: TButton
    Left = 233
    Top = 162
    Width = 56
    Height = 25
    Caption = 'Apply'
    TabOrder = 0
    OnClick = bnApplyClick
  end
  object bnCancel: TButton
    Left = 168
    Top = 161
    Width = 56
    Height = 25
    Caption = 'Cancel'
    TabOrder = 1
    OnClick = bnCancelClick
  end
  object bnOk: TButton
    Left = 106
    Top = 162
    Width = 56
    Height = 25
    Caption = 'OK'
    TabOrder = 2
    OnClick = bnOkClick
  end
  object PageControl: TPageControl
    Left = 0
    Top = 0
    Width = 296
    Height = 155
    ActivePage = tsAdjIUC
    Align = alTop
    TabOrder = 3
    TabWidth = 38
    object tsCoords: TTabSheet
      Caption = 'Coords'
      ImageIndex = 1
      object edBuferSize: TLabeledEdit
        Left = 6
        Top = 16
        Width = 73
        Height = 21
        EditLabel.Width = 60
        EditLabel.Height = 13
        EditLabel.Caption = '  Bufer Size :'
        TabOrder = 0
        Text = ' 98765 98765'
      end
      object edSrcPRect: TLabeledEdit
        Left = 153
        Top = 16
        Width = 119
        Height = 21
        EditLabel.Width = 58
        EditLabel.Height = 13
        EditLabel.Caption = '  SrcPRect :'
        TabOrder = 1
        Text = ' 9876 9876  9876 9876'
      end
      object edLogFrameRect: TLabeledEdit
        Left = 6
        Top = 56
        Width = 266
        Height = 21
        EditLabel.Width = 82
        EditLabel.Height = 13
        EditLabel.Caption = '  LogFrameRect :'
        TabOrder = 2
        Text = ' 66777888.9  66777888.9     66777888.9  66777888.9'
      end
      object edVisibleUCoords: TLabeledEdit
        Left = 7
        Top = 96
        Width = 199
        Height = 21
        EditLabel.Width = 97
        EditLabel.Height = 13
        EditLabel.Caption = 'Visible User Coords :'
        TabOrder = 3
        Text = ' 999.888  999.888     999.888  999.888'
      end
      object edPaintBoxSize: TLabeledEdit
        Left = 83
        Top = 16
        Width = 62
        Height = 21
        EditLabel.Width = 57
        EditLabel.Height = 13
        EditLabel.Caption = ' PBox Size :'
        EditLabel.OnDblClick = edFrameSizeDblClick
        TabOrder = 4
        Text = ' 9876 9876'
      end
      object edBufCompSize: TLabeledEdit
        Left = 209
        Top = 96
        Width = 62
        Height = 21
        EditLabel.Width = 55
        EditLabel.Height = 13
        EditLabel.Caption = '  BufCSize :'
        TabOrder = 5
        Text = ' 9876 9876'
      end
    end
    object tsAux: TTabSheet
      Caption = 'View'
      ImageIndex = 2
      object Label11: TLabel
        Left = 2
        Top = 9
        Width = 102
        Height = 13
        Caption = 'Cursor Coords Type : '
      end
      object mbSCType: TComboBox
        Left = 106
        Top = 7
        Width = 106
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 0
        OnCloseUp = mbSCTypeCloseUp
      end
      object cbShowPixelColor: TCheckBox
        Left = 153
        Top = 32
        Width = 103
        Height = 17
        Caption = 'Show Pixel Color'
        TabOrder = 1
      end
      object cbCenterInDst: TCheckBox
        Left = 153
        Top = 49
        Width = 103
        Height = 17
        Caption = 'Center in Dst'
        TabOrder = 2
      end
      object edResizeFlags: TLabeledEdit
        Left = 106
        Top = 32
        Width = 30
        Height = 21
        EditLabel.Width = 66
        EditLabel.Height = 13
        EditLabel.Caption = 'Resize Flags :'
        LabelPosition = lpLeft
        TabOrder = 3
      end
      object cbCenterInSrc: TCheckBox
        Left = 153
        Top = 66
        Width = 103
        Height = 17
        Caption = 'Center in Src'
        TabOrder = 4
      end
      inline frBackColor: TN_ColorViewFrame
        Left = 2
        Top = 55
        Width = 143
        Height = 28
        TabOrder = 5
        inherited edDecColor: TEdit
          Visible = False
        end
      end
    end
    object TabSheet1: TTabSheet
      Caption = ' Aux'
      ImageIndex = 2
      object Label14: TLabel
        Left = 11
        Top = 9
        Width = 63
        Height = 13
        Caption = 'Pixel Format :'
      end
      object mbBuferColors: TComboBox
        Left = 80
        Top = 6
        Width = 91
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 0
        Items.Strings = (
          'High Color'
          'True Color')
      end
      object rgMouseMoveAction: TRadioGroup
        Left = 178
        Top = 1
        Width = 118
        Height = 69
        Caption = ' Mouse Move Action '
        ItemIndex = 1
        Items.Strings = (
          'None'
          'Cursor Coords'
          'Window Coords')
        TabOrder = 1
      end
      object edFormSelfName: TLabeledEdit
        Left = 13
        Top = 48
        Width = 156
        Height = 21
        EditLabel.Width = 78
        EditLabel.Height = 13
        EditLabel.Caption = 'Form SelfName :'
        TabOrder = 2
      end
    end
    object tsFile: TTabSheet
      Caption = 'File'
      ImageIndex = 3
      inline frFileName: TN_FileNameFrame
        Tag = 161
        Left = -5
        Top = -1
        Width = 319
        Height = 28
        PopupMenu = frFileName.FilePopupMenu
        TabOrder = 0
        inherited Label1: TLabel
          Left = 9
          Width = 22
          Caption = 'File :'
        end
        inherited mbFileName: TComboBox
          Left = 33
          Width = 235
        end
        inherited bnBrowse_1: TButton
          Left = 272
        end
      end
      object GroupBox1: TGroupBox
        Left = 1
        Top = 25
        Width = 290
        Height = 39
        Caption = ' Metafile dimensions : '
        TabOrder = 1
        object edMetafilePix: TLabeledEdit
          Left = 28
          Top = 14
          Width = 75
          Height = 21
          EditLabel.Width = 20
          EditLabel.Height = 13
          EditLabel.Caption = 'Pix :'
          LabelPosition = lpLeft
          TabOrder = 0
          Text = ' 29000 29000'
          OnKeyDown = edMetafilePixKeyDown
        end
        object edMetafileDPI: TLabeledEdit
          Left = 139
          Top = 14
          Width = 39
          Height = 21
          EditLabel.Width = 24
          EditLabel.Height = 13
          EditLabel.Caption = 'DPI :'
          LabelPosition = lpLeft
          TabOrder = 1
          Text = '2400'
          OnKeyDown = edMetafileSmKeyDown
        end
        object edMetafileSm: TLabeledEdit
          Left = 212
          Top = 12
          Width = 70
          Height = 21
          EditLabel.Width = 21
          EditLabel.Height = 13
          EditLabel.Caption = 'Sm :'
          LabelPosition = lpLeft
          TabOrder = 2
          Text = ' 25.92 88.82'
          OnKeyDown = edMetafileSmKeyDown
        end
      end
      object cbAutoRename: TCheckBox
        Left = 103
        Top = 107
        Width = 90
        Height = 17
        Caption = 'Auto Rename'
        TabOrder = 2
      end
      object mbImageFormat: TComboBox
        Left = 243
        Top = 80
        Width = 49
        Height = 21
        ItemHeight = 13
        ItemIndex = 0
        TabOrder = 3
        Text = ' BMP '
        Items.Strings = (
          ' BMP '
          ' GIF'
          ' JPG'
          ' EMF')
      end
      object edTranspColor: TLabeledEdit
        Left = 170
        Top = 80
        Width = 65
        Height = 21
        EditLabel.Width = 63
        EditLabel.Height = 13
        EditLabel.Caption = 'Transp.Color:'
        TabOrder = 4
        Text = ' -1'
      end
      object StaticText1: TStaticText
        Left = 249
        Top = 64
        Width = 42
        Height = 17
        Caption = 'Format :'
        TabOrder = 5
      end
      object cbWholeBuf: TCheckBox
        Left = 7
        Top = 107
        Width = 85
        Height = 17
        Caption = 'Whole Buffer'
        TabOrder = 6
      end
      object bnCopyToClipboard: TButton
        Left = 78
        Top = 78
        Width = 86
        Height = 23
        Caption = 'Copy To Clipbrd.'
        TabOrder = 7
        OnClick = SaveCopyToClick
      end
      object bnSaveToFile: TButton
        Left = 4
        Top = 78
        Width = 69
        Height = 23
        Caption = 'Save To File'
        TabOrder = 8
        OnClick = SaveCopyToClick
      end
    end
    object tsAdjIUC: TTabSheet
      Caption = 'Adjust'
      ImageIndex = 4
      object Label1: TLabel
        Left = 51
        Top = 50
        Width = 9
        Height = 13
        Caption = 'P'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label2: TLabel
        Left = 181
        Top = 50
        Width = 9
        Height = 13
        Caption = 'S'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object bnPS8: TButton
        Tag = 8
        Left = 3
        Top = 47
        Width = 20
        Height = 20
        Caption = '<<'
        TabOrder = 0
        OnMouseDown = bnPSMouseDown
        OnMouseUp = bnPSMouseUp
      end
      object bnPS0: TButton
        Left = 24
        Top = 47
        Width = 20
        Height = 20
        Caption = '<'
        TabOrder = 1
        OnMouseDown = bnPSMouseDown
        OnMouseUp = bnPSMouseUp
      end
      object bnPS1: TButton
        Tag = 1
        Left = 68
        Top = 47
        Width = 20
        Height = 20
        Caption = '>'
        TabOrder = 2
        OnMouseDown = bnPSMouseDown
        OnMouseUp = bnPSMouseUp
      end
      object bnPS9: TButton
        Tag = 9
        Left = 89
        Top = 47
        Width = 20
        Height = 20
        Caption = '>>'
        TabOrder = 3
        OnMouseDown = bnPSMouseDown
        OnMouseUp = bnPSMouseUp
      end
      object bnPS2: TButton
        Tag = 2
        Left = 46
        Top = 25
        Width = 20
        Height = 20
        Caption = '^'
        TabOrder = 4
        OnMouseDown = bnPSMouseDown
        OnMouseUp = bnPSMouseUp
      end
      object bnPS10: TButton
        Tag = 10
        Left = 46
        Top = 5
        Width = 20
        Height = 20
        Caption = '^'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 5
        OnMouseDown = bnPSMouseDown
        OnMouseUp = bnPSMouseUp
      end
      object bnPS12: TButton
        Tag = 12
        Left = 133
        Top = 47
        Width = 20
        Height = 20
        Caption = '<<'
        TabOrder = 6
        OnMouseDown = bnPSMouseDown
        OnMouseUp = bnPSMouseUp
      end
      object bnPS4: TButton
        Tag = 4
        Left = 154
        Top = 47
        Width = 20
        Height = 20
        Caption = '<'
        TabOrder = 7
        OnMouseDown = bnPSMouseDown
        OnMouseUp = bnPSMouseUp
      end
      object bnPS5: TButton
        Tag = 5
        Left = 198
        Top = 47
        Width = 20
        Height = 20
        Caption = '>'
        TabOrder = 8
        OnMouseDown = bnPSMouseDown
        OnMouseUp = bnPSMouseUp
      end
      object bnPS13: TButton
        Tag = 13
        Left = 219
        Top = 47
        Width = 20
        Height = 20
        Caption = '>>'
        TabOrder = 9
        OnMouseDown = bnPSMouseDown
        OnMouseUp = bnPSMouseUp
      end
      object bnPS6: TButton
        Tag = 6
        Left = 176
        Top = 25
        Width = 20
        Height = 20
        Caption = '^'
        TabOrder = 10
        OnMouseDown = bnPSMouseDown
        OnMouseUp = bnPSMouseUp
      end
      object bnPS14: TButton
        Tag = 14
        Left = 176
        Top = 5
        Width = 20
        Height = 20
        Caption = '^'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 11
        OnMouseDown = bnPSMouseDown
        OnMouseUp = bnPSMouseUp
      end
      object bnPS7: TButton
        Tag = 7
        Left = 176
        Top = 68
        Width = 20
        Height = 20
        Caption = 'v'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 12
        OnMouseDown = bnPSMouseDown
        OnMouseUp = bnPSMouseUp
      end
      object bnPS15: TButton
        Tag = 15
        Left = 176
        Top = 88
        Width = 20
        Height = 20
        Caption = 'W'
        TabOrder = 13
        OnMouseDown = bnPSMouseDown
        OnMouseUp = bnPSMouseUp
      end
      object bnPS3: TButton
        Tag = 3
        Left = 46
        Top = 67
        Width = 20
        Height = 20
        Caption = 'v'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 14
        OnMouseDown = bnPSMouseDown
        OnMouseUp = bnPSMouseUp
      end
      object bnPS11: TButton
        Tag = 11
        Left = 46
        Top = 87
        Width = 20
        Height = 20
        Caption = 'W'
        TabOrder = 15
        OnMouseDown = bnPSMouseDown
        OnMouseUp = bnPSMouseUp
      end
      object cbMaintainAspect: TCheckBox
        Left = 75
        Top = 80
        Width = 97
        Height = 17
        Caption = 'Maintain Aspect'
        Checked = True
        State = cbChecked
        TabOrder = 16
      end
      object bnAspCoefEq1: TButton
        Left = 82
        Top = 24
        Width = 75
        Height = 19
        Caption = 'Asp.Coef = 1'
        TabOrder = 17
        OnClick = bnAspCoefEq1Click
      end
      object edAspectCoef: TEdit
        Left = 84
        Top = 2
        Width = 70
        Height = 21
        TabOrder = 18
      end
      object bnEditU2P: TButton
        Left = 8
        Top = 8
        Width = 33
        Height = 33
        BiDiMode = bdLeftToRight
        Caption = 'U2P'
        ParentBiDiMode = False
        TabOrder = 19
        OnClick = bnEditU2PClick
      end
    end
    object Tmp2: TTabSheet
      Caption = 'Tmp2'
      ImageIndex = 5
      object Label8: TLabel
        Left = 21
        Top = 11
        Width = 153
        Height = 13
        Caption = 'Cursor Snap Grid (User Coords) :'
      end
      object Label9: TLabel
        Left = 5
        Top = 29
        Width = 33
        Height = 13
        Caption = 'Origin :'
      end
      object Label10: TLabel
        Left = 5
        Top = 53
        Width = 54
        Height = 13
        Caption = 'Step (X,Y) :'
      end
      object edOrigin: TEdit
        Left = 62
        Top = 25
        Width = 117
        Height = 21
        TabOrder = 0
      end
      object edStep: TEdit
        Left = 61
        Top = 49
        Width = 117
        Height = 21
        TabOrder = 1
      end
    end
    object tsDeb: TTabSheet
      Caption = ' Deb'
      ImageIndex = 6
      object edDebugFlags: TLabeledEdit
        Left = 8
        Top = 16
        Width = 121
        Height = 21
        EditLabel.Width = 66
        EditLabel.Height = 13
        EditLabel.Caption = 'Debug Flags :'
        TabOrder = 0
      end
      object bnSetCapture: TButton
        Left = 8
        Top = 47
        Width = 75
        Height = 25
        Caption = 'bnSetCapture'
        TabOrder = 1
        OnClick = bnSetCaptureClick
      end
      object bnDebActions: TButton
        Left = 89
        Top = 47
        Width = 48
        Height = 25
        Caption = 'Actions'
        PopupMenu = DebActPopupMenu
        TabOrder = 2
      end
    end
  end
  object BFMinBRPanel2: TPanel
    Left = 286
    Top = 186
    Width = 10
    Height = 10
    Anchors = [akRight, akBottom]
    Color = clRed
    TabOrder = 4
    Visible = False
  end
  object PSTimer: TTimer
    Interval = 0
    OnTimer = PSTimerTimer
    Left = 72
    Top = 159
  end
  object DebActPopupMenu: TPopupMenu
    Left = 38
    Top = 159
    object ViewRastrFrActions1: TMenuItem
      Action = aDebViewRFActions
    end
  end
  object ActionList: TActionList
    Left = 4
    Top = 159
    object aDebViewRFActions: TAction
      Category = 'Deb'
      Caption = 'View RastrFr Actions'
      OnExecute = aDebViewRFActionsExecute
    end
  end
end
