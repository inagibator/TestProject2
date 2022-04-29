inherited N_CMCaptDev35Form: TN_CMCaptDev35Form
  Left = 253
  Top = 107
  Anchors = [akLeft, akTop, akRight, akBottom]
  Caption = 'Press and release F9 to get Image'
  ClientHeight = 260
  ClientWidth = 529
  Constraints.MinHeight = 299
  Constraints.MinWidth = 545
  KeyPreview = True
  OldCreateOrder = True
  OnCloseQuery = FormCloseQuery
  OnKeyDown = FormKeyDown
  OnKeyUp = FormKeyUp
  OnPaint = FormPaint
  OnShow = FormShow
  ExplicitWidth = 545
  ExplicitHeight = 299
  DesignSize = (
    529
    260)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel [0]
    Left = 24
    Top = 8
    Width = 85
    Height = 13
    Caption = 'Received images:'
  end
  inherited BFMinBRPanel: TPanel
    Left = 537
    Top = 249
    ExplicitLeft = 537
    ExplicitTop = 249
  end
  object tbRotateImage: TToolBar
    Left = 203
    Top = 203
    Width = 204
    Height = 50
    Align = alNone
    Anchors = [akRight, akBottom]
    AutoSize = True
    ButtonHeight = 50
    ButtonWidth = 51
    Caption = 'tbRotateImage'
    Ctl3D = False
    TabOrder = 1
    Visible = False
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
  object bnStop: TButton
    Left = 415
    Top = 206
    Width = 65
    Height = 46
    Anchors = [akRight, akBottom]
    Caption = 'Stop'
    Enabled = False
    TabOrder = 2
    Visible = False
    OnClick = bnStopClick
  end
  object bnCapture: TButton
    Left = 739
    Top = 492
    Width = 65
    Height = 46
    Caption = 'New Case'
    TabOrder = 3
    Visible = False
    OnClick = bnCaptureClick
  end
  object bnClose: TButton
    Left = 454
    Top = 210
    Width = 75
    Height = 25
    Caption = 'Close'
    TabOrder = 4
    OnClick = bnCloseClick
  end
  object PnSlides: TPanel
    Left = 8
    Top = 28
    Width = 513
    Height = 166
    Anchors = []
    BevelOuter = bvLowered
    Caption = 'PnSlides'
    TabOrder = 5
    inline ThumbsRFrame: TN_Rast1Frame
      Left = 1
      Top = 1
      Width = 511
      Height = 164
      HelpType = htKeyword
      Align = alClient
      Constraints.MinHeight = 56
      Constraints.MinWidth = 56
      Color = clBtnFace
      ParentColor = False
      TabOrder = 0
      ExplicitLeft = 1
      ExplicitTop = 1
      ExplicitWidth = 511
      ExplicitHeight = 164
      inherited PaintBox: TPaintBox
        Width = 495
        Height = 148
        ExplicitWidth = 675
        ExplicitHeight = 148
      end
      inherited HScrollBar: TScrollBar
        Top = 148
        Width = 511
        ExplicitTop = 148
        ExplicitWidth = 511
      end
      inherited VScrollBar: TScrollBar
        Left = 495
        Height = 148
        ExplicitLeft = 495
        ExplicitHeight = 148
      end
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 241
    Width = 529
    Height = 19
    Panels = <
      item
        Text = 'This window will be closed automatically'
        Width = 50
      end>
  end
  object TimerSidexis: TTimer
    Enabled = False
    Interval = 200
    Left = 96
    Top = 16
  end
  object TimerImage: TTimer
    Enabled = False
    Interval = 500
    OnTimer = TimerImageTimer
    Left = 400
    Top = 368
  end
  object TimerStatus: TTimer
    Interval = 100
    OnTimer = TimerStatusTimer
    Left = 656
    Top = 360
  end
  object TimerCase: TTimer
    Enabled = False
    Left = 616
    Top = 240
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 100
    OnTimer = Timer1Timer
    Left = 400
    Top = 504
  end
  object TimerClose: TTimer
    Enabled = False
    OnTimer = TimerCloseTimer
    Left = 88
    Top = 200
  end
end
