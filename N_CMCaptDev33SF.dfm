inherited N_CMCaptDev33Form: TN_CMCaptDev33Form
  Left = 358
  Top = 159
  Caption = 'Press and release F9 to get Image'
  ClientHeight = 546
  ClientWidth = 928
  Constraints.MinHeight = 585
  Constraints.MinWidth = 788
  KeyPreview = True
  OldCreateOrder = True
  OnKeyDown = FormKeyDown
  OnKeyUp = FormKeyUp
  OnShow = FormShow
  ExplicitWidth = 944
  ExplicitHeight = 585
  DesignSize = (
    928
    546)
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 923
    Top = 541
    TabOrder = 2
    ExplicitLeft = 923
    ExplicitTop = 541
  end
  object MainPanel: TPanel
    Left = 0
    Top = 0
    Width = 928
    Height = 451
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    object RightPanel: TPanel
      Left = 798
      Top = 1
      Width = 129
      Height = 449
      Align = alRight
      TabOrder = 0
      inline ThumbsRFrame: TN_Rast1Frame
        Left = 1
        Top = 1
        Width = 127
        Height = 447
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
        ExplicitHeight = 447
        inherited PaintBox: TPaintBox
          Width = 111
          Height = 431
          ExplicitWidth = 111
          ExplicitHeight = 431
        end
        inherited HScrollBar: TScrollBar
          Top = 431
          Width = 127
          ExplicitTop = 431
          ExplicitWidth = 127
        end
        inherited VScrollBar: TScrollBar
          Left = 111
          Height = 431
          ExplicitLeft = 111
          ExplicitHeight = 431
        end
      end
    end
    object SlidePanel: TPanel
      Left = 1
      Top = 1
      Width = 797
      Height = 449
      Align = alClient
      TabOrder = 1
      OnResize = SlidePanelResize
      inline SlideRFrame: TN_Rast1Frame
        Left = 1
        Top = 1
        Width = 795
        Height = 447
        HelpType = htKeyword
        Align = alClient
        Constraints.MinHeight = 56
        Constraints.MinWidth = 56
        Color = clBtnFace
        ParentColor = False
        TabOrder = 0
        ExplicitLeft = 1
        ExplicitTop = 1
        ExplicitWidth = 795
        ExplicitHeight = 447
        inherited PaintBox: TPaintBox
          Width = 779
          Height = 431
          ExplicitWidth = 712
          ExplicitHeight = 431
        end
        inherited HScrollBar: TScrollBar
          Top = 431
          Width = 795
          ExplicitTop = 431
          ExplicitWidth = 795
        end
        inherited VScrollBar: TScrollBar
          Left = 779
          Height = 431
          ExplicitLeft = 779
          ExplicitHeight = 431
        end
      end
    end
  end
  object CtrlsPanelParent: TPanel
    Left = 6
    Top = 461
    Width = 848
    Height = 70
    Anchors = [akLeft, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 3
    object CtrlsPanel: TPanel
      Left = 0
      Top = 0
      Width = 848
      Height = 70
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 0
      DesignSize = (
        848
        70)
      object StatusLabel: TLabel
        Left = 23
        Top = 1
        Width = 45
        Height = 16
        Caption = 'Waiting'
        Color = 1478391
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clRed
        Font.Height = -15
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentColor = False
        ParentFont = False
        Visible = False
      end
      object StatusShape: TShape
        Left = 2
        Top = 2
        Width = 15
        Height = 15
        Brush.Color = 1478391
        Pen.Color = 1478391
        Shape = stCircle
        Visible = False
      end
      object bnSetup: TButton
        Left = 2
        Top = 24
        Width = 57
        Height = 38
        Anchors = [akLeft, akBottom]
        Caption = 'Setup'
        TabOrder = 0
        OnClick = bnSetupClick
      end
      object bnCapture: TButton
        Left = 65
        Top = 23
        Width = 58
        Height = 39
        Anchors = [akLeft, akBottom]
        Caption = 'Capture'
        TabOrder = 1
        OnClick = bnCaptureClick
      end
      object pnFilter: TPanel
        Left = 129
        Top = -4
        Width = 717
        Height = 70
        Anchors = [akLeft, akBottom]
        TabOrder = 2
        Visible = False
        OnClick = pnFilterClick
      end
      object tbRotateImage: TToolBar
        Left = 548
        Top = 16
        Width = 457
        Height = 50
        Align = alNone
        Anchors = [akRight, akBottom]
        AutoSize = True
        ButtonHeight = 50
        ButtonWidth = 51
        Caption = 'tbRotateImage'
        Ctl3D = False
        TabOrder = 3
        Visible = False
        Wrapable = False
        object tbLeft90: TToolButton
          Left = 0
          Top = 0
          AllowAllUp = True
          ImageIndex = 20
          OnClick = tbLeft90Click
        end
        object mp: TMediaPlayer
          Left = 51
          Top = 0
          Width = 253
          Height = 50
          Visible = False
          TabOrder = 0
        end
        object tbRight90: TToolButton
          Left = 304
          Top = 0
          AllowAllUp = True
          ImageIndex = 21
          OnClick = tbRight90Click
        end
        object tb180: TToolButton
          Left = 355
          Top = 0
          AllowAllUp = True
          ImageIndex = 22
          OnClick = tb180Click
        end
        object tbFlipHor: TToolButton
          Left = 406
          Top = 0
          Caption = 'tbFlipHor'
          ImageIndex = 24
          OnClick = tbFlipHorClick
        end
      end
    end
  end
  object bnExit: TButton
    Left = 864
    Top = 484
    Width = 58
    Height = 39
    Anchors = [akRight, akBottom]
    Caption = 'Exit'
    ModalResult = 1
    TabOrder = 1
  end
  object cbAutoTake: TCheckBox
    Left = 8
    Top = 529
    Width = 97
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'Auto-Take'
    TabOrder = 4
    Visible = False
    OnClick = cbAutoTakeClick
  end
  object TimerAutotake: TTimer
    Enabled = False
    Interval = 200
    OnTimer = TimerAutotakeTimer
    Left = 513
    Top = 161
  end
  object IdTCPServer1: TIdTCPServer
    Bindings = <>
    DefaultPort = 0
    OnExecute = IdTCPServer1Execute
    Left = 329
    Top = 161
  end
  object TimerFirstStart: TTimer
    Enabled = False
    OnTimer = TimerFirstStartTimer
    Left = 561
    Top = 161
  end
end
