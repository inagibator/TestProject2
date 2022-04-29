inherited K_FormCMSTextAttrs: TK_FormCMSTextAttrs
  Left = 168
  Top = 425
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Set Text Attributes'
  ClientHeight = 119
  ClientWidth = 406
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  object LbText: TLabel [0]
    Left = 23
    Top = 7
    Width = 21
    Height = 13
    Caption = 'Text'
  end
  inherited BFMinBRPanel: TPanel
    Left = 396
    Top = 109
    TabOrder = 5
  end
  object BtCancel: TButton
    Left = 321
    Top = 88
    Width = 77
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 0
  end
  object BtOK: TButton
    Left = 239
    Top = 88
    Width = 77
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    ModalResult = 1
    TabOrder = 1
  end
  object MemoText: TMemo
    Left = 10
    Top = 24
    Width = 388
    Height = 52
    Anchors = [akLeft, akTop, akRight, akBottom]
    Color = 10682367
    TabOrder = 2
  end
  object BtFont: TButton
    Left = 114
    Top = 88
    Width = 98
    Height = 23
    Hint = 'Click to edit font attributes'
    Anchors = [akRight, akBottom]
    Caption = 'Text Attributes'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 3
    OnClick = BtFontClick
  end
  object BtTextShow: TButton
    Left = 10
    Top = 88
    Width = 78
    Height = 23
    Hint = 'Click to update annotation text on Image'
    Anchors = [akRight, akBottom]
    Caption = 'Update Text'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 4
    OnClick = BtTextShowClick
  end
end
