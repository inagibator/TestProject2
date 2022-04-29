inherited N_CMCaptDev16Form: TN_CMCaptDev16Form
  Left = 358
  Top = 159
  Caption = 'Press and release F9 to get Image'
  ClientHeight = 534
  ClientWidth = 845
  Constraints.MinHeight = 573
  Constraints.MinWidth = 788
  KeyPreview = True
  OldCreateOrder = True
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnKeyUp = FormKeyUp
  OnShow = FormShow
  ExplicitWidth = 861
  ExplicitHeight = 573
  DesignSize = (
    845
    534)
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 848
    Top = 541
    TabOrder = 2
    ExplicitLeft = 848
    ExplicitTop = 541
  end
  object MainPanel: TPanel
    Left = 0
    Top = 0
    Width = 845
    Height = 451
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    object RightPanel: TPanel
      Left = 715
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
      Width = 714
      Height = 449
      Align = alClient
      TabOrder = 1
      OnResize = SlidePanelResize
      inline SlideRFrame: TN_Rast1Frame
        Left = 1
        Top = 1
        Width = 712
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
        ExplicitWidth = 712
        ExplicitHeight = 447
        inherited PaintBox: TPaintBox
          Width = 696
          Height = 431
          ExplicitWidth = 704
          ExplicitHeight = 431
        end
        inherited HScrollBar: TScrollBar
          Top = 431
          Width = 712
          ExplicitTop = 431
          ExplicitWidth = 712
        end
        inherited VScrollBar: TScrollBar
          Left = 696
          Height = 431
          ExplicitLeft = 696
          ExplicitHeight = 431
        end
      end
    end
  end
  object CtrlsPanelParent: TPanel
    Left = 7
    Top = 460
    Width = 773
    Height = 70
    Anchors = [akLeft, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 3
    object CtrlsPanel: TPanel
      Left = 0
      Top = 0
      Width = 773
      Height = 70
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 0
      DesignSize = (
        773
        70)
      object bnSetup: TButton
        Left = 2
        Top = 16
        Width = 57
        Height = 38
        Anchors = [akLeft, akBottom]
        Caption = 'Setup'
        TabOrder = 0
        OnClick = bnSetupClick
      end
      object bnCapture: TButton
        Left = 65
        Top = 15
        Width = 58
        Height = 39
        Anchors = [akLeft, akBottom]
        Caption = 'Capture'
        TabOrder = 1
        OnClick = bnCaptureClick
      end
      object pnFilter: TPanel
        Left = 135
        Top = 0
        Width = 600
        Height = 70
        Anchors = [akLeft, akBottom]
        TabOrder = 2
        Visible = False
      end
      object tbRotateImage: TToolBar
        Left = 473
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
    Left = 783
    Top = 473
    Width = 62
    Height = 46
    Anchors = [akRight, akBottom]
    Caption = 'Exit'
    ModalResult = 1
    TabOrder = 1
  end
  object TimerCheck: TTimer
    Enabled = False
    Interval = 200
    Left = 680
    Top = 584
  end
end
