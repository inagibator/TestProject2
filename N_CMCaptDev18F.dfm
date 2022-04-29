inherited N_CMCaptDev18Form: TN_CMCaptDev18Form
  Left = 253
  Top = 107
  AlphaBlend = True
  Caption = 'Press and release F9 to get Image'
  ClientHeight = 643
  ClientWidth = 772
  Constraints.MinHeight = 585
  Constraints.MinWidth = 788
  KeyPreview = True
  OldCreateOrder = True
  OnKeyDown = FormKeyDown
  OnKeyUp = FormKeyUp
  OnShow = FormShow
  ExplicitWidth = 788
  ExplicitHeight = 682
  DesignSize = (
    772
    643)
  PixelsPerInch = 96
  TextHeight = 13
  object StatusShape: TShape [0]
    Left = 8
    Top = 565
    Width = 15
    Height = 15
    Anchors = [akLeft, akBottom]
    Brush.Color = clRed
    Shape = stCircle
  end
  object StatusLabel: TLabel [1]
    Left = 29
    Top = 564
    Width = 80
    Height = 16
    Anchors = [akLeft, akBottom]
    Caption = 'Not available'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  inherited BFMinBRPanel: TPanel
    Left = 796
    Top = 614
    TabOrder = 2
    ExplicitLeft = 796
    ExplicitTop = 614
  end
  object MainPanel: TPanel
    Left = 0
    Top = 0
    Width = 772
    Height = 553
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    object RightPanel: TPanel
      Left = 642
      Top = 1
      Width = 129
      Height = 551
      Align = alRight
      TabOrder = 0
      inline ThumbsRFrame: TN_Rast1Frame
        Left = 1
        Top = 1
        Width = 127
        Height = 549
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
        ExplicitHeight = 549
        inherited PaintBox: TPaintBox
          Width = 111
          Height = 533
          ExplicitWidth = 111
          ExplicitHeight = 533
        end
        inherited HScrollBar: TScrollBar
          Top = 533
          Width = 127
          ExplicitTop = 533
          ExplicitWidth = 127
        end
        inherited VScrollBar: TScrollBar
          Left = 111
          Height = 533
          ExplicitLeft = 111
          ExplicitHeight = 533
        end
      end
    end
    object SlidePanel: TPanel
      Left = 1
      Top = 1
      Width = 641
      Height = 551
      Align = alClient
      TabOrder = 1
      OnResize = SlidePanelResize
      inline SlideRFrame: TN_Rast1Frame
        Left = 1
        Top = 1
        Width = 639
        Height = 549
        HelpType = htKeyword
        Align = alClient
        Constraints.MinHeight = 56
        Constraints.MinWidth = 56
        Color = clBtnFace
        ParentColor = False
        TabOrder = 0
        ExplicitLeft = 1
        ExplicitTop = 1
        ExplicitWidth = 639
        ExplicitHeight = 549
        inherited PaintBox: TPaintBox
          Width = 623
          Height = 533
          ExplicitWidth = 623
          ExplicitHeight = 533
        end
        inherited HScrollBar: TScrollBar
          Top = 533
          Width = 639
          ExplicitTop = 533
          ExplicitWidth = 639
        end
        inherited VScrollBar: TScrollBar
          Left = 623
          Height = 533
          ExplicitLeft = 623
          ExplicitHeight = 533
        end
      end
    end
  end
  object bnExit: TButton
    Left = 736
    Top = 565
    Width = 62
    Height = 46
    Anchors = [akRight, akBottom]
    Caption = 'Exit'
    ModalResult = 1
    TabOrder = 1
    OnClick = bnExitClick
  end
  object bnCapture: TButton
    Left = 673
    Top = 565
    Width = 57
    Height = 46
    Anchors = [akRight, akBottom]
    Caption = 'Capture'
    TabOrder = 3
    Visible = False
  end
  object tbRotateImage: TToolBar
    Left = 455
    Top = 562
    Width = 204
    Height = 50
    Align = alNone
    Anchors = [akRight, akBottom]
    AutoSize = True
    ButtonHeight = 50
    ButtonWidth = 51
    Caption = 'tbRotateImage'
    Ctl3D = False
    TabOrder = 4
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
  object TimerCheck: TTimer
    Enabled = False
    Interval = 200
    OnTimer = TimerCheckTimer
    Left = 376
    Top = 568
  end
end
