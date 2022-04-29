inherited N_CMCaptDev14Form: TN_CMCaptDev14Form
  Left = 353
  Top = 183
  Caption = 'Press and release F9 to get Image'
  ClientHeight = 669
  ClientWidth = 790
  Constraints.MinHeight = 585
  Constraints.MinWidth = 788
  KeyPreview = True
  OldCreateOrder = True
  OnKeyDown = FormKeyDown
  OnKeyUp = FormKeyUp
  OnShow = FormShow
  ExplicitWidth = 806
  ExplicitHeight = 708
  DesignSize = (
    790
    669)
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
    Width = 79
    Height = 16
    Anchors = [akLeft, akBottom]
    Caption = 'Not Initialized'
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
    Width = 790
    Height = 553
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    object RightPanel: TPanel
      Left = 660
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
      Width = 659
      Height = 551
      Align = alClient
      TabOrder = 1
      OnResize = SlidePanelResize
      inline SlideRFrame: TN_Rast1Frame
        Left = 1
        Top = 1
        Width = 657
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
        ExplicitWidth = 657
        ExplicitHeight = 549
        inherited PaintBox: TPaintBox
          Width = 641
          Height = 533
          ExplicitWidth = 641
          ExplicitHeight = 533
        end
        inherited HScrollBar: TScrollBar
          Top = 533
          Width = 657
          ExplicitTop = 533
          ExplicitWidth = 657
        end
        inherited VScrollBar: TScrollBar
          Left = 641
          Height = 533
          ExplicitLeft = 641
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
  object tbRotateImage: TToolBar
    Left = 455
    Top = 562
    Width = 204
    Height = 54
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
      Top = 2
      AllowAllUp = True
      ImageIndex = 20
      OnClick = tbLeft90Click
    end
    object tbRight90: TToolButton
      Left = 51
      Top = 2
      AllowAllUp = True
      ImageIndex = 21
      OnClick = tbRight90Click
    end
    object tb180: TToolButton
      Left = 102
      Top = 2
      AllowAllUp = True
      ImageIndex = 22
      OnClick = tb180Click
    end
    object tbFlipHor: TToolButton
      Left = 153
      Top = 2
      Caption = 'tbFlipHor'
      ImageIndex = 24
      OnClick = tbFlipHorClick
    end
  end
  object bnSetup: TButton
    Left = 8
    Top = 586
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Setup'
    TabOrder = 4
    OnClick = bnSetupClick
  end
end
