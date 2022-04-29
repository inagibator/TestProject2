inherited N_CMCaptDev34Form: TN_CMCaptDev34Form
  Left = 439
  Top = 239
  Caption = 'Press and release F9 to get Image'
  ClientHeight = 534
  ClientWidth = 764
  Constraints.MinHeight = 573
  Constraints.MinWidth = 780
  KeyPreview = True
  OldCreateOrder = True
  OnKeyDown = FormKeyDown
  OnKeyUp = FormKeyUp
  OnShow = FormShow
  ExplicitWidth = 780
  ExplicitHeight = 573
  DesignSize = (
    764
    534)
  PixelsPerInch = 96
  TextHeight = 13
  object CtrlsPanelParent: TPanel [0]
    Left = 0
    Top = 440
    Width = 700
    Height = 88
    Anchors = [akLeft, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 3
    object CtrlsPanel: TPanel
      Left = 0
      Top = 0
      Width = 700
      Height = 88
      Align = alClient
      Anchors = [akLeft, akTop, akRight]
      BevelOuter = bvNone
      TabOrder = 0
      DesignSize = (
        700
        88)
      object StatusShape: TShape
        Left = 8
        Top = 6
        Width = 15
        Height = 15
        Brush.Color = clRed
        Shape = stCircle
      end
      object StatusLabel: TLabel
        Left = 29
        Top = 5
        Width = 83
        Height = 16
        Caption = 'Disconnected'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clRed
        Font.Height = -15
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
      end
      object lbUID: TLabel
        Left = 251
        Top = 34
        Width = 3
        Height = 13
      end
      object Label1: TLabel
        Left = 10
        Top = 68
        Width = 55
        Height = 13
        Caption = 'Filter Type: '
      end
      object lbCount: TLabel
        Left = 251
        Top = 52
        Width = 3
        Height = 13
      end
      object lbIP: TLabel
        Left = 165
        Top = 31
        Width = 3
        Height = 13
        Visible = False
      end
      object bnSetup: TButton
        Left = 8
        Top = 27
        Width = 75
        Height = 25
        Caption = 'Setup'
        Enabled = False
        TabOrder = 0
        OnClick = bnSetupClick
      end
      object BitBtnGetImage: TBitBtn
        Left = 89
        Top = 27
        Width = 25
        Height = 25
        Enabled = False
        Glyph.Data = {
          76010000424D7601000000000000760000002800000020000000100000000100
          04000000000000010000120B0000120B00001000000000000000000000000000
          800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00555555555555
          5555555555555555555555555555555555555555555555555555555555555555
          555555555555555555555555555555555555555FFFFFFFFFF555550000000000
          55555577777777775F55500B8B8B8B8B05555775F555555575F550F0B8B8B8B8
          B05557F75F555555575F50BF0B8B8B8B8B0557F575FFFFFFFF7F50FBF0000000
          000557F557777777777550BFBFBFBFB0555557F555555557F55550FBFBFBFBF0
          555557F555555FF7555550BFBFBF00055555575F555577755555550BFBF05555
          55555575FFF75555555555700007555555555557777555555555555555555555
          5555555555555555555555555555555555555555555555555555}
        NumGlyphs = 2
        TabOrder = 1
        OnClick = BitBtnGetImageClick
      end
      object cbAutoTake: TCheckBox
        Left = 165
        Top = 50
        Width = 80
        Height = 17
        Caption = 'Auto Take'
        Checked = True
        State = cbChecked
        TabOrder = 2
        Visible = False
      end
      object ProgressBar: TProgressBar
        Left = 165
        Top = 8
        Width = 252
        Height = 17
        Max = 1000
        TabOrder = 3
      end
      object cbRFID: TCheckBox
        Left = 165
        Top = 31
        Width = 88
        Height = 17
        Caption = 'RFID Reader'
        TabOrder = 4
        Visible = False
        OnClick = cbRFIDClick
      end
      object cbFilterPar: TComboBox
        Left = 69
        Top = 65
        Width = 71
        Height = 21
        ItemIndex = 0
        TabOrder = 5
        Text = 'LOW'
        OnChange = cbFilterParChange
        Items.Strings = (
          'LOW'
          'MEDIUM'
          'HIGH')
      end
      object Edit1: TEdit
        Left = 408
        Top = 55
        Width = 25
        Height = 21
        TabOrder = 6
        Text = '3'
        Visible = False
      end
      object bnSetPatientID: TButton
        Left = 439
        Top = 60
        Width = 75
        Height = 25
        Caption = 'SetPatientID'
        TabOrder = 7
        Visible = False
        OnClick = bnSetPatientIDClick
      end
      object bnGetPatientID: TButton
        Left = 520
        Top = 60
        Width = 75
        Height = 25
        Caption = 'GetPatientID'
        TabOrder = 8
        Visible = False
        OnClick = bnGetPatientIDClick
      end
      object tbRotateImage: TToolBar
        Left = 425
        Top = 4
        Width = 204
        Height = 50
        Align = alNone
        Anchors = [akTop, akRight]
        AutoSize = True
        ButtonHeight = 50
        ButtonWidth = 51
        Caption = 'tbRotateImage'
        Ctl3D = False
        TabOrder = 9
        Wrapable = False
        object tbLeft90: TToolButton
          Left = 0
          Top = 0
          AllowAllUp = True
          ImageIndex = 20
          OnClick = tbLeft90Click
        end
        object tbRight90: TToolButton
          Left = 51
          Top = 0
          AllowAllUp = True
          ImageIndex = 21
          OnClick = tbRight90Click
        end
        object tb180: TToolButton
          Left = 102
          Top = 0
          AllowAllUp = True
          ImageIndex = 22
          OnClick = tb180Click
        end
        object tbFlipHor: TToolButton
          Left = 153
          Top = 0
          Caption = 'tbFlipHor'
          ImageIndex = 24
          OnClick = tbFlipHorClick
        end
      end
      object bnCapture: TButton
        Left = 639
        Top = 6
        Width = 57
        Height = 46
        Anchors = [akTop, akRight]
        Caption = 'Capture'
        TabOrder = 10
        Visible = False
      end
      object cbMask: TCheckBox
        Left = 343
        Top = 50
        Width = 76
        Height = 17
        Caption = 'Corner Mask'
        TabOrder = 11
        OnClick = cbMaskClick
      end
    end
  end
  inherited BFMinBRPanel: TPanel
    Left = 766
    Top = 541
    TabOrder = 2
    ExplicitLeft = 766
    ExplicitTop = 541
  end
  object MainPanel: TPanel
    Left = 0
    Top = 0
    Width = 764
    Height = 434
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    object RightPanel: TPanel
      Left = 634
      Top = 1
      Width = 129
      Height = 432
      Align = alRight
      TabOrder = 0
      inline ThumbsRFrame: TN_Rast1Frame
        Left = 1
        Top = 1
        Width = 127
        Height = 430
        HelpType = htKeyword
        Align = alClient
        Constraints.MinHeight = 56
        Constraints.MinWidth = 56
        Color = clBtnFace
        ParentColor = False
        TabOrder = 0
        ExplicitLeft = 1
        ExplicitTop = 1
        ExplicitWidth = 127
        ExplicitHeight = 430
        inherited PaintBox: TPaintBox
          Width = 111
          Height = 414
          ExplicitWidth = 111
          ExplicitHeight = 414
        end
        inherited HScrollBar: TScrollBar
          Top = 414
          Width = 127
          ExplicitTop = 414
          ExplicitWidth = 127
        end
        inherited VScrollBar: TScrollBar
          Left = 111
          Height = 414
          ExplicitLeft = 111
          ExplicitHeight = 414
        end
      end
    end
    object SlidePanel: TPanel
      Left = 1
      Top = 1
      Width = 633
      Height = 432
      Align = alClient
      TabOrder = 1
      OnResize = SlidePanelResize
      inline SlideRFrame: TN_Rast1Frame
        Left = 1
        Top = 1
        Width = 631
        Height = 430
        HelpType = htKeyword
        Align = alClient
        Constraints.MinHeight = 56
        Constraints.MinWidth = 56
        Color = clBtnFace
        ParentColor = False
        TabOrder = 0
        ExplicitLeft = 1
        ExplicitTop = 1
        ExplicitWidth = 631
        ExplicitHeight = 430
        inherited PaintBox: TPaintBox
          Width = 615
          Height = 414
          ExplicitWidth = 623
          ExplicitHeight = 414
        end
        inherited HScrollBar: TScrollBar
          Top = 414
          Width = 631
          ExplicitTop = 414
          ExplicitWidth = 631
        end
        inherited VScrollBar: TScrollBar
          Left = 615
          Height = 414
          ExplicitLeft = 615
          ExplicitHeight = 414
        end
      end
      object bnOpen: TButton
        Left = 357
        Top = 204
        Width = 75
        Height = 25
        Caption = 'Open'
        TabOrder = 1
        Visible = False
        OnClick = bnOpenClick
      end
      object bnClose: TButton
        Left = 451
        Top = 204
        Width = 75
        Height = 25
        Caption = 'Close'
        TabOrder = 2
        Visible = False
        OnClick = bnCloseClick
      end
    end
  end
  object bnExit: TButton
    Left = 700
    Top = 446
    Width = 62
    Height = 46
    Anchors = [akRight, akBottom]
    Caption = 'Exit'
    ModalResult = 1
    TabOrder = 1
    OnClick = bnExitClick
  end
  object TimerCheck: TTimer
    Enabled = False
    OnTimer = TimerCheckTimer
    Left = 696
    Top = 496
  end
  object TimerBuf: TTimer
    OnTimer = TimerBufTimer
    Left = 736
    Top = 496
  end
  object TimerScannerCallback: TTimer
    OnTimer = TimerScannerCallbackTimer
    Left = 361
    Top = 257
  end
  object TimerReboot: TTimer
    Interval = 500
    OnTimer = TimerRebootTimer
    Left = 361
    Top = 313
  end
  object TimerConnect: TTimer
    Interval = 5000
    OnTimer = TimerConnectTimer
    Left = 433
    Top = 313
  end
end
