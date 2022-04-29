inherited N_CMCaptDev7Form: TN_CMCaptDev7Form
  Left = 593
  Top = 223
  Caption = 'Press and release F9 to get Image'
  ClientHeight = 546
  ClientWidth = 772
  Constraints.MinHeight = 585
  Constraints.MinWidth = 788
  KeyPreview = True
  OldCreateOrder = True
  OnKeyDown = FormKeyDown
  OnKeyUp = FormKeyUp
  OnShow = FormShow
  ExplicitWidth = 788
  ExplicitHeight = 585
  DesignSize = (
    772
    546)
  PixelsPerInch = 96
  TextHeight = 13
  object CtrlsPanelParent: TPanel [0]
    Left = 0
    Top = 458
    Width = 695
    Height = 73
    Anchors = [akLeft, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 3
    object CtrlsPanel: TPanel
      Left = 0
      Top = 0
      Width = 695
      Height = 73
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 0
      DesignSize = (
        695
        73)
      object StatusShape: TShape
        Left = 8
        Top = 4
        Width = 15
        Height = 15
        Brush.Color = clRed
        Shape = stCircle
      end
      object StatusLabel: TLabel
        Left = 29
        Top = 3
        Width = 127
        Height = 16
        Caption = 'Sensor disconnected'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clRed
        Font.Height = -15
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
      end
      object bnCapture: TButton
        Left = 637
        Top = 6
        Width = 57
        Height = 46
        Anchors = [akTop, akRight]
        Caption = 'Capture'
        Enabled = False
        TabOrder = 0
        OnClick = bnCaptureClick
      end
      object tbRotateImage: TToolBar
        Left = 419
        Top = 3
        Width = 204
        Height = 50
        Align = alNone
        Anchors = [akTop, akRight]
        AutoSize = True
        ButtonHeight = 50
        ButtonWidth = 51
        Caption = 'tbRotateImage'
        Ctl3D = False
        TabOrder = 1
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
          Caption = '`'
          ImageIndex = 24
          OnClick = tbFlipHorClick
        end
      end
      object cbAutoTake: TCheckBox
        Left = 96
        Top = 32
        Width = 80
        Height = 17
        Caption = 'Auto Take'
        Checked = True
        State = cbChecked
        TabOrder = 2
        OnClick = cbAutoTakeClick
      end
      object bnSetup: TButton
        Left = 8
        Top = 24
        Width = 75
        Height = 25
        Caption = 'Setup'
        TabOrder = 3
        OnClick = bnSetupClick
      end
    end
  end
  inherited BFMinBRPanel: TPanel
    Left = 766
    Top = 540
    TabOrder = 2
    ExplicitLeft = 766
    ExplicitTop = 540
  end
  object MainPanel: TPanel
    Left = 0
    Top = 0
    Width = 772
    Height = 452
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    object RightPanel: TPanel
      Left = 642
      Top = 1
      Width = 129
      Height = 450
      Align = alRight
      TabOrder = 0
      inline ThumbsRFrame: TN_Rast1Frame
        Left = 1
        Top = 1
        Width = 127
        Height = 448
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
        ExplicitHeight = 448
        inherited PaintBox: TPaintBox
          Width = 111
          Height = 432
          ExplicitWidth = 111
          ExplicitHeight = 432
        end
        inherited HScrollBar: TScrollBar
          Top = 432
          Width = 127
          ExplicitTop = 432
          ExplicitWidth = 127
        end
        inherited VScrollBar: TScrollBar
          Left = 111
          Height = 432
          ExplicitLeft = 111
          ExplicitHeight = 432
        end
      end
    end
    object SlidePanel: TPanel
      Left = 1
      Top = 1
      Width = 641
      Height = 450
      Align = alClient
      TabOrder = 1
      OnResize = SlidePanelResize
      inline SlideRFrame: TN_Rast1Frame
        Left = 1
        Top = 1
        Width = 639
        Height = 448
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
        ExplicitHeight = 448
        inherited PaintBox: TPaintBox
          Width = 623
          Height = 432
          ExplicitWidth = 623
          ExplicitHeight = 432
        end
        inherited HScrollBar: TScrollBar
          Top = 432
          Width = 639
          ExplicitTop = 432
          ExplicitWidth = 639
        end
        inherited VScrollBar: TScrollBar
          Left = 623
          Height = 432
          ExplicitLeft = 623
          ExplicitHeight = 432
        end
      end
    end
  end
  object bnExit: TButton
    Left = 700
    Top = 464
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
    Interval = 200
    OnTimer = TimerCheckTimer
    Left = 720
    Top = 512
  end
end
