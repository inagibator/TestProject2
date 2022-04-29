inherited N_CMCaptDev29Form: TN_CMCaptDev29Form
  Left = 253
  Top = 107
  Caption = 'Press and release F9 to get Image'
  ClientHeight = 546
  ClientWidth = 869
  Constraints.MinHeight = 585
  Constraints.MinWidth = 788
  KeyPreview = True
  OldCreateOrder = True
  OnCloseQuery = FormCloseQuery
  OnKeyDown = FormKeyDown
  OnKeyUp = FormKeyUp
  OnPaint = FormPaint
  OnShow = FormShow
  ExplicitWidth = 885
  ExplicitHeight = 585
  DesignSize = (
    869
    546)
  PixelsPerInch = 96
  TextHeight = 13
  object StatusShape: TShape [0]
    Left = 8
    Top = 492
    Width = 15
    Height = 15
    Anchors = [akLeft, akBottom]
    Brush.Color = clRed
    Shape = stCircle
  end
  object StatusLabel: TLabel [1]
    Left = 29
    Top = 491
    Width = 83
    Height = 16
    Anchors = [akLeft, akBottom]
    Caption = 'Disconnected'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  inherited BFMinBRPanel: TPanel
    Left = 871
    Top = 535
    TabOrder = 2
    ExplicitLeft = 871
    ExplicitTop = 535
  end
  object MainPanel: TPanel
    Left = 0
    Top = 0
    Width = 869
    Height = 482
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    object RightPanel: TPanel
      Left = 739
      Top = 1
      Width = 129
      Height = 480
      Align = alRight
      TabOrder = 0
      inline ThumbsRFrame: TN_Rast1Frame
        Left = 1
        Top = 1
        Width = 127
        Height = 478
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
        ExplicitHeight = 478
        inherited PaintBox: TPaintBox
          Width = 111
          Height = 462
          ExplicitWidth = 111
          ExplicitHeight = 462
        end
        inherited HScrollBar: TScrollBar
          Top = 462
          Width = 127
          ExplicitTop = 462
          ExplicitWidth = 127
        end
        inherited VScrollBar: TScrollBar
          Left = 111
          Height = 462
          ExplicitLeft = 111
          ExplicitHeight = 462
        end
      end
    end
    object SlidePanel: TPanel
      Left = 1
      Top = 1
      Width = 738
      Height = 480
      Align = alClient
      TabOrder = 1
      OnResize = SlidePanelResize
      inline SlideRFrame: TN_Rast1Frame
        Left = 1
        Top = 1
        Width = 736
        Height = 478
        HelpType = htKeyword
        Align = alClient
        Constraints.MinHeight = 56
        Constraints.MinWidth = 56
        Color = clBtnFace
        ParentColor = False
        TabOrder = 0
        ExplicitLeft = 1
        ExplicitTop = 1
        ExplicitWidth = 736
        ExplicitHeight = 478
        inherited PaintBox: TPaintBox
          Width = 720
          Height = 462
          ExplicitWidth = 728
          ExplicitHeight = 462
        end
        inherited HScrollBar: TScrollBar
          Top = 462
          Width = 736
          ExplicitTop = 462
          ExplicitWidth = 736
        end
        inherited VScrollBar: TScrollBar
          Left = 720
          Height = 462
          ExplicitLeft = 720
          ExplicitHeight = 462
        end
      end
    end
  end
  object bnExit: TButton
    Left = 810
    Top = 492
    Width = 62
    Height = 46
    Anchors = [akRight, akBottom]
    Caption = 'Exit'
    ModalResult = 1
    TabOrder = 1
  end
  object tbRotateImage: TToolBar
    Left = 527
    Top = 489
    Width = 204
    Height = 50
    Align = alNone
    Anchors = [akRight, akBottom]
    AutoSize = True
    ButtonHeight = 50
    ButtonWidth = 51
    Caption = 'tbRotateImage'
    Ctl3D = False
    TabOrder = 3
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
  object bnSetup: TButton
    Left = 8
    Top = 513
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Setup'
    TabOrder = 4
    OnClick = bnSetupClick
  end
  object bnCapture: TButton
    Left = 739
    Top = 492
    Width = 65
    Height = 46
    Anchors = [akRight, akBottom]
    Caption = 'Capture'
    TabOrder = 5
    Visible = False
    OnClick = bnCaptureClick
  end
  object bnStop: TButton
    Left = 739
    Top = 492
    Width = 65
    Height = 46
    Anchors = [akRight, akBottom]
    Caption = 'Stop'
    TabOrder = 6
    Visible = False
    OnClick = bnStopClick
  end
  object ProgressBar1: TProgressBar
    Left = 104
    Top = 515
    Width = 217
    Height = 17
    Anchors = [akRight, akBottom]
    Step = 1
    TabOrder = 7
  end
  object TimerImage: TTimer
    Enabled = False
    Interval = 500
    OnTimer = TimerImageTimer
    Left = 544
    Top = 360
  end
  object Timer3DEnabled: TTimer
    Enabled = False
    OnTimer = Timer3DEnabledTimer
    Left = 616
    Top = 360
  end
  object TimerStatus: TTimer
    Interval = 100
    OnTimer = TimerStatusTimer
    Left = 656
    Top = 360
  end
end
