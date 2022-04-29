inherited K_FormCMSelectSlide: TK_FormCMSelectSlide
  Left = 513
  Top = 210
  Width = 192
  Height = 151
  Caption = 'Select current visible'
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 164
    Top = 99
    TabOrder = 3
  end
  object BtOK: TButton
    Left = 6
    Top = 82
    Width = 74
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 0
  end
  object BtCancel: TButton
    Left = 94
    Top = 82
    Width = 74
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object PnSlides: TPanel
    Left = 8
    Top = 8
    Width = 161
    Height = 67
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvLowered
    Caption = 'PnSlides'
    TabOrder = 2
    inline ThumbsRFrame: TN_Rast1Frame
      Left = 1
      Top = 1
      Width = 159
      Height = 65
      HelpType = htKeyword
      Align = alClient
      Constraints.MinHeight = 56
      Constraints.MinWidth = 56
      Color = clBtnFace
      ParentColor = False
      TabOrder = 0
      inherited PaintBox: TPaintBox
        Width = 143
        Height = 49
        OnDblClick = ThumbsRFramePaintBoxDblClick
      end
      inherited HScrollBar: TScrollBar
        Top = 49
        Width = 159
      end
      inherited VScrollBar: TScrollBar
        Left = 143
        Height = 49
      end
    end
  end
end
