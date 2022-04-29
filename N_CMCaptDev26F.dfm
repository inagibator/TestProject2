inherited N_CMCaptDev26Form: TN_CMCaptDev26Form
  Left = 253
  Top = 107
  Caption = 'Press and release F9 to get Image'
  ClientHeight = 546
  ClientWidth = 877
  Constraints.MinHeight = 585
  Constraints.MinWidth = 788
  KeyPreview = True
  OldCreateOrder = True
  OnCloseQuery = FormCloseQuery
  OnKeyDown = FormKeyDown
  OnKeyUp = FormKeyUp
  OnPaint = FormPaint
  OnShow = FormShow
  ExplicitWidth = 893
  ExplicitHeight = 585
  DesignSize = (
    877
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
    Width = 877
    Height = 482
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    object RightPanel: TPanel
      Left = 747
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
          ExplicitHeight = 529
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
      Width = 746
      Height = 480
      Align = alClient
      TabOrder = 1
      OnResize = SlidePanelResize
      inline SlideRFrame: TN_Rast1Frame
        Left = 1
        Top = 1
        Width = 744
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
        ExplicitWidth = 744
        ExplicitHeight = 478
        inherited PaintBox: TPaintBox
          Width = 728
          Height = 462
          ExplicitWidth = 631
          ExplicitHeight = 529
        end
        inherited HScrollBar: TScrollBar
          Top = 462
          Width = 744
          ExplicitTop = 462
          ExplicitWidth = 744
        end
        inherited VScrollBar: TScrollBar
          Left = 728
          Height = 462
          ExplicitLeft = 728
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
  object TimerSidexis: TTimer
    Enabled = False
    Interval = 200
    Left = 72
    Top = 8
  end
  object TimerImage: TTimer
    Interval = 500
    OnTimer = TimerImageTimer
    Left = 408
    Top = 488
  end
  object TimerStatus: TTimer
    Interval = 200
    OnTimer = TimerStatusTimer
    Left = 344
    Top = 488
  end
end
