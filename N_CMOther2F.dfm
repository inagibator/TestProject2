inherited N_CMOther2Form: TN_CMOther2Form
  Left = 384
  Top = 181
  Width = 815
  Height = 653
  Caption = 'Press and release F9 to get Image'
  Constraints.MinHeight = 585
  Constraints.MinWidth = 788
  KeyPreview = True
  OldCreateOrder = True
  OnKeyDown = FormKeyDown
  OnKeyUp = FormKeyUp
  OnShow = FormShow
  DesignSize = (
    799
    614)
  PixelsPerInch = 96
  TextHeight = 13
  object StatusShape: TShape [0]
    Left = 144
    Top = 580
    Width = 15
    Height = 15
    Anchors = [akLeft, akBottom]
    Shape = stCircle
  end
  object StatusLabel: TLabel [1]
    Left = 173
    Top = 580
    Width = 71
    Height = 16
    Anchors = [akLeft, akBottom]
    Caption = 'StatusLabel'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  inherited BFMinBRPanel: TPanel
    Left = 797
    Top = 609
    TabOrder = 3
  end
  object MainPanel: TPanel
    Left = 0
    Top = 0
    Width = 799
    Height = 560
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    object RightPanel: TPanel
      Left = 669
      Top = 1
      Width = 129
      Height = 558
      Align = alRight
      TabOrder = 0
      inline ThumbsRFrame: TN_Rast1Frame
        Left = 1
        Top = 1
        Width = 127
        Height = 556
        HelpType = htKeyword
        Align = alClient
        Constraints.MinHeight = 56
        Constraints.MinWidth = 56
        Color = clBtnFace
        ParentColor = False
        TabOrder = 0
        inherited PaintBox: TPaintBox
          Width = 111
          Height = 540
        end
        inherited HScrollBar: TScrollBar
          Top = 540
          Width = 127
        end
        inherited VScrollBar: TScrollBar
          Left = 111
          Height = 540
        end
      end
    end
    object SlidePanel: TPanel
      Left = 1
      Top = 1
      Width = 668
      Height = 558
      Align = alClient
      TabOrder = 1
      OnResize = SlidePanelResize
      inline SlideRFrame: TN_Rast1Frame
        Left = 1
        Top = 1
        Width = 666
        Height = 556
        HelpType = htKeyword
        Align = alClient
        Constraints.MinHeight = 56
        Constraints.MinWidth = 56
        Color = clBtnFace
        ParentColor = False
        TabOrder = 0
        inherited PaintBox: TPaintBox
          Width = 650
          Height = 540
        end
        inherited HScrollBar: TScrollBar
          Top = 540
          Width = 666
        end
        inherited VScrollBar: TScrollBar
          Left = 650
          Height = 540
        end
      end
    end
  end
  object bnExit: TButton
    Left = 750
    Top = 588
    Width = 50
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Exit'
    ModalResult = 1
    TabOrder = 1
  end
  object bnSetup: TButton
    Left = 19
    Top = 576
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Setup'
    TabOrder = 2
    OnClick = bnSetupClick
  end
end
